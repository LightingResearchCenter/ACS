function [log_info,data_log] = cdf2raw(filePath)
%CDF2RAW Summary of this function goes here
%   Detailed explanation goes here

% Read data from file
CDF = readcdf(filePath);

% Prepare data_log
% Uncalibrate data
RedCounts   = uint16(round(CDF.Variables.red./CDF.GlobalAttributes.redCalibration));
GreenCounts = uint16(round(CDF.Variables.green./CDF.GlobalAttributes.greenCalibration));
BlueCounts  = uint16(round(CDF.Variables.blue./CDF.GlobalAttributes.blueCalibration));
ActivityIndexCounts = uint16(round((CDF.Variables.activity./(0.0039*4)).^2));

% Combine data to create data_log
d = horzcat(RedCounts,GreenCounts,BlueCounts,ActivityIndexCounts);
data_log = reshape(d',numel(d),1);

% Prepare log_info
% Line 1: Daysimeter Status
line1 = sprintf('0\r\n');

% Line 2: Daysimeter Serial Number
line2 = sprintf('0%s\r\n',CDF.GlobalAttributes.deviceSN(end-2:end));

% Line 3: Daysimeter Initialization Date and Time
% Convert time
t = cdflib.epochBreakdown(CDF.Variables.time)';
t = t(:,1:6);
t = datetime(t);
InitializationTime = t(1);
line3 = sprintf('%s\r\n',datestr(InitializationTime,'mm-dd-yy HH:MM'));

% Line 4: Daysimeter Logging Rate in Seconds
% Find Logging Rate
LoggingRate = mode(diff(t));
line4 = sprintf('%03u\r\n',seconds(LoggingRate));

% Assemble log_info
log_info = [line1,line2,line3,line4];

end




function CDF = readcdf(filePath)
%READCDF Summary of this function goes here
%   Detailed explanation goes here

CDF = struct('Variables',[],'GlobalAttributes',[],'VariableAttributes',[]);

cdfId = cdflib.open(filePath);

fileInfo = cdflib.inquire(cdfId);

% Read in variables
nVars = fileInfo.numVars;

for iVar = 0:nVars-1
    varInfo = cdflib.inquireVar(cdfId,iVar);
    
    % Determine the number of records allocated for the first variable in the file.
    maxRecNum = cdflib.getVarMaxWrittenRecNum(cdfId,iVar);
    
    % Retrieve all data in records for variable.
    if maxRecNum > 0
        varData = cdflib.hyperGetVarData(cdfId,iVar,[0 maxRecNum+1 1]);
    else
        varData = cdflib.getVarData(cdfId,iVar,0);
    end
    
    CDF.Variables.(varInfo.name) = varData;
end

% Read in attributes
nAttrs = fileInfo.numvAttrs + fileInfo.numgAttrs;

for iAttr = 0:nAttrs-1
    attrInfo = cdflib.inquireAttr(cdfId,iAttr);
    switch attrInfo.scope
        case 'GLOBAL_SCOPE'
            nEntry = cdflib.getAttrMaxgEntry(cdfId,iAttr) + 1;
            if nEntry == 1
                attrData = cdflib.getAttrgEntry(cdfId,iAttr,0);
                CDF.GlobalAttributes.(attrInfo.name) = attrData;
            else
                CDF.GlobalAttributes.(attrInfo.name) = cell(nEntry,1);
                for iEntry = 0:nEntry-1
                    attrData = cdflib.getAttrgEntry(cdfId,iAttr,iEntry);
                    CDF.GlobalAttributes.(attrInfo.name){iEntry+1,1} = attrData;
                end
            end
        case 'VARIABLE_SCOPE'
            nEntry = cdflib.getAttrMaxEntry(cdfId,iAttr) + 1;
            for iEntry = 0:nEntry-1
                varName = cdflib.getVarName(cdfId,iEntry);
                attrData = cdflib.getAttrEntry(cdfId,iAttr,iEntry);
                CDF.VariableAttributes.(varName).(attrInfo.name) = attrData;
            end
        otherwise
            error('Unknown attribute scope.');
    end
end

% Clean up
cdflib.close(cdfId)

clear cdfId
end