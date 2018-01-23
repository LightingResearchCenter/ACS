function convertData

[githubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(githubDir,'circadian');
d12packDir = fullfile(githubDir,'d12pack');
addpath(circadianDir,d12packDir);

CalibrationPath = '\\root\projects\DaysimeterAndDimesimeterReferenceFiles\recalibration2016\calibration_log.csv';


ignoreFiles = {'.','..'};

projectDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';
TimeZonePath = fullfile(projectDir,'TimeZones by Quarter.xlsx');
quarterNames = {'Q1','Q2','Q3','Q4'}';
quarterDir = fullfile(projectDir,quarterNames);
nQ = numel(quarterDir);

%% Import Calibration Data
% cal = readtable(CalibrationPath,'Format','%d %f %f %f %{yyyy-MMM-dd}D %s');
cal = readtable(CalibrationPath,'Format','%d %f %f %f %s %s');
cal.Properties.VariableNames{1} = 'SN';

%% Import Time Zone Data
Q1tz = readtable(TimeZonePath,'Sheet','Q1');
Q2tz = readtable(TimeZonePath,'Sheet','Q2');
Q3tz = readtable(TimeZonePath,'Sheet','Q3');
Q4tz = readtable(TimeZonePath,'Sheet','Q4');
subjectTz = vertcat(Q1tz,Q2tz,Q3tz,Q4tz);

%% Inventory files
for iQ = nQ:-1:1
    ls = dir(quarterDir{iQ});
    theseSubjects = {ls.name}';
    ignoreDir = ismember(theseSubjects,ignoreFiles);
    theseSubjects(ignoreDir,:) = [];
    
    subject{iQ,1} = theseSubjects;
    subjectQ{iQ,1} = repmat(iQ,size(theseSubjects));
    subjectQDir{iQ,1} = repmat(quarterDir(iQ),size(theseSubjects));
end

subject     = vertcat(subject{:});
subjectQ    = vertcat(subjectQ{:});
subjectQDir = vertcat(subjectQDir{:});

% Construct folder paths
downloadDir = fullfile(subjectQDir,subject,'best_download');
markedDir   = fullfile(subjectQDir,subject,'marked_download');
diaryDir    = fullfile(subjectQDir,subject,'best_diary');

% Find subjects that have required folders
idxDownload = cellfun(@isdir, downloadDir);
idxMarked   = cellfun(@isdir, markedDir);
idxDiary    = cellfun(@isdir, diaryDir);

idxExist = idxDownload & idxDiary & idxMarked;

% Remove subjects that do not have required folders
subject(~idxExist)      = [];
subjectQ(~idxExist)     = [];
subjectQDir(~idxExist)  = [];

downloadDir(~idxExist)  = [];
markedDir(~idxExist)    = [];
diaryDir(~idxExist)     = [];

%% Iterate through subjects
h = waitbar(0,'Please wait. Converting subject data...');
nSub = numel(subject);
objArray = cell(nSub,1); % Preallocate storage for objects
for iSub = nSub:-1:1
    thisSub = subject{iSub};
    
    % Find subject files
%     lsLOG   = dir([downloadDir{iSub},filesep,'*-LOG.txt']);
%     lsDATA  = dir([downloadDir{iSub},filesep,'*-DATA.txt']);
    lsRawCDF  = dir([downloadDir{iSub},filesep,'*.cdf']);
    lsCroppedCDF   = dir([markedDir{iSub},filesep,'*.cdf']);
    lsDiary = dir([diaryDir{iSub},filesep,'*.xlsx']);
    
    % Skip subjects missing files
    if isempty(lsRawCDF) || isempty(lsCroppedCDF) || isempty(lsDiary)
        warning(['Subject ',thisSub,' is missing files and was skipped.']);
        continue;
    end
    
    % Construct subject file paths
%     loginfoPath = fullfile(downloadDir{iSub},lsLOG(1).name);
%     datalogPath	= fullfile(downloadDir{iSub},lsDATA(1).name);
    rawCdfFilePath = fullfile(downloadDir{iSub},lsRawCDF(1).name);
    croppedCdfPath = fullfile(markedDir{iSub},  lsCroppedCDF(1).name);
    diaryPath	   = fullfile(diaryDir{iSub},   lsDiary(1).name);
    
    % Find subject's timezone
    idxTz = strcmp(subjectTz.id,thisSub);
    matchingTz = subjectTz(idxTz,:);
    if ~isempty(matchingTz)
        thisTz = matchingTz.tz{1};
    else
        warning(['Subject ',thisSub,' missing time zone. New York used.'])
        thisTz = 'America/New_York';
    end
    
    % Read data from CDF
    croppedCdfData = daysimeter12.readcdf(croppedCdfPath);
    thisSn = str2double(croppedCdfData.GlobalAttributes.deviceSN(end-2:end));
    
    % Check if calibration is avaliable for Daysimeter
    idxCalSn = ismember(cal.SN,thisSn);
    thisCal = cal(idxCalSn,:);
    
    % Skip if missing calibration otherwise convert data
    if ~any(isnan(thisCal.Red)) && ~isempty(thisCal)
        % Create object
        thisObj = d12pack.HumanData;
        
        % Set calibration path
        thisObj.CalibrationPath = CalibrationPath;
        
        % Set ccalibration ratio method
        thisObj.RatioMethod = 'original+factor';
        
        postIRdateStr = thisCal.Date(strcmp(thisCal.Label,'PostIRCorrection'));
        postIRdateNum = datenum(postIRdateStr{1});
        
        cdfStartEpoch = cdflib.epochBreakdown(croppedCdfData.Variables.time(1));
        cdfStartNum = datenum(cdfStartEpoch(1:6)');
        
        if cdfStartNum < postIRdateNum
            thisObj.CorrectionFactor = 1.16;
        else
            thisObj.CorrectionFactor = 1;
        end
        
        % Add subject ID
        thisObj.ID = thisSub;
        
        % Set time zones
        thisObj.TimeZoneLaunch = 'America/New_York';
        thisObj.TimeZoneDeploy = thisTz;
        
        % Add Session
        thisObj.Session = struct('Name',['Q',num2str(subjectQ(iSub))]);
        
        % Import the original data
        [log_info,data_log] = cdf2raw(rawCdfFilePath);
        
        thisObj.log_info = log_info;
        thisObj.data_log = data_log;
        
        % Correct for DST
        if ~isdst(thisObj.Time(1)) && isdst(thisObj.Time(end))
            idxDst = isdst(thisObj.Time);
            thisObj.Time(idxDst) = thisObj.Time(idxDst) - repmat(duration(1,0,0),size(thisObj.Time(idxDst)));
        end
        
        % Add observation mask (accounting for cdfread error)
        thisObj.Observation = false(size(thisObj.Time));
        tmpObservation = logical(croppedCdfData.Variables.logicalArray);
        m = numel(thisObj.Observation);
        n = numel(tmpObservation);
        if n == m
            thisObj.Observation = tmpObservation(:);
        elseif n < m
            thisObj.Observation(1:n,1) = tmpObservation(:);
        else %if m > n
            tmpObservation = tmpObservation(1:m);
            thisObj.Observation = tmpObservation(:);
        end
        
        % Add compliance mask (accounting for cdfread error)
        thisObj.Compliance = true(size(thisObj.Time));
        tmpCompliance = logical(croppedCdfData.Variables.complianceArray);
        m = numel(thisObj.Compliance);
        n = numel(tmpCompliance);
        if n == m
            thisObj.Compliance = tmpCompliance(:);
        elseif n < m
            thisObj.Compliance(1:n,1) = tmpCompliance(:);
        else %if m > n
            tmpCompliance = tmpCompliance(1:m);
            thisObj.Compliance = tmpCompliance(:);
        end
        
        % Add bed log
        thisObj.BedLog = thisObj.BedLog.import(diaryPath,thisTz);
        
        objArray{iSub,1} = thisObj;
    end
    
    waitbar((nSub-iSub)/nSub);
end
close(h)

idxEmpty = cellfun(@isempty,objArray);
objArray(idxEmpty) = [];
objArray = vertcat(objArray{:});

fileName = ['data snapshot ',datestr(now,'yyyy-mmm-dd HH-MM'),'.mat'];
filePath = fullfile(projectDir,fileName);
save(filePath,'objArray');
end


