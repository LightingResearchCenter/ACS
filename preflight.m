function preflight
%PREFLIGHT Summary of this function goes here
%   Detailed explanation goes here

% Enable supporting functions and libraries
[githubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(githubDir,'circadian');
addpath(circadianDir);

% Map file paths
[~,originalDir,preflightDir,~,~,~] = ACSPaths;
[recentPath,recentName] = findRecent(originalDir);
[dirPath,dirName] = ACSFindSubjectDirs(recentPath);

timeStamp = datestr(now,'yyyy-mm-dd_MMSS');
reportName = ['preflight_',timeStamp,'_',recentName,'.xlsx'];
reportPath = fullfile(preflightDir,reportName);

% Initialize variables
nDir = numel(dirPath);

% Iterate through each subject directory
for iDir = 1:nDir
    thisDirPath = dirPath{iDir};
    thisDirName = dirName{iDir};
    
    acsFiles = ACSCheckFiles(thisDirPath);
    
    % Check resets from CSV
    if acsFiles.CSV.exists
        csvTable = readtable(acsFiles.CSV.path);
        nResets = max(csvTable.resets);
    else
        nResets = {[]};
    end
    
    % Read contents of CDF
    if acsFiles.CDF.exists
        cdfData = daysimeter12.readcdf(acsFiles.CDF.path);
        cdfSubjectID = cdfData.GlobalAttributes.subjectID;
        cdfDeviceSN = cdfData.GlobalAttributes.deviceSN(end-2:end);
    else
        cdfSubjectID = '';
        cdfDeviceSN = '';
    end
    
    % Compare subject IDs
    subjectIdArray = [{acsFiles.(:).];
end

% Prepare report contents for output
reportHeader = {};
reportContents = table2cell(reportTable);
reportCell = [reportHeader;reportContents];

% Write report to disk
xlswrite(reportPath,reportCell);

end

