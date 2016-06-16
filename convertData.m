function convertData

[githubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(githubDir,'circadian');
addpath(circadianDir);

CalibrationPath = '\\root\projects\DaysimeterAndDimesimeterReferenceFiles\recalibration2016\calibration_log.csv';


ignoreFiles = {'.','..'};

projectDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';
TimeZonePath = fullfile(projectDir,'TimeZones by Quarter.xlsx');
quarterNames = {'Q1','Q2','Q3','Q4'}';
quarterDir = fullfile(projectDir,quarterNames);
nQ = numel(quarterDir);

%% Import Calibration Data
cal = readtable(CalibrationPath);
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
    lsLOG   = dir([downloadDir{iSub},filesep,'*-LOG.txt']);
    lsDATA  = dir([downloadDir{iSub},filesep,'*-DATA.txt']);
    lsCDF   = dir([markedDir{iSub},filesep,'*.cdf']);
    lsDiary = dir([diaryDir{iSub},filesep,'*.xlsx']);
    
    % Skip subjects missing files
    if isempty(lsLOG) || isempty(lsDATA) || isempty(lsCDF) || isempty(lsDiary)
        warning(['Subject ',thisSub,' is missing files and was skipped.']);
        continue;
    end
    
    % Construct subject file paths
    loginfoPath = fullfile(downloadDir{iSub},lsLOG(1).name);
    datalogPath	= fullfile(downloadDir{iSub},lsDATA(1).name);
    cdfPath     = fullfile(markedDir{iSub},  lsCDF(1).name);
    diaryPath	= fullfile(diaryDir{iSub},   lsDiary(1).name);
    
    % Find subject's timezone
    idxTz = strcmp(subjectTz.id,thisSub);
    matchingTz = subjectTz(idxTz,:);
    thisTz = matchingTz.tz{1};
    
    % Read data from CDF
    cdfData = daysimeter12.readcdf(cdfPath);
    thisSn = str2double(cdfData.GlobalAttributes.deviceSN(end-2:end));
    
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
        thisObj.RatioMethod = 'luxthreshold';
        
        % Add subject ID
        thisObj.ID = thisSub;
        
        % Set time zones
        thisObj.TimeZoneLaunch = 'America/New_York';
        thisObj.TimeZoneDeploy = thisTz;
        
        % Add Session
        thisObj.Session = struct('Name',['Q',num2str(subjectQ(iSub))]);
        
        % Import the original data
        thisObj.log_info = thisObj.readloginfo(loginfoPath);
        thisObj.data_log = thisObj.readdatalog(datalogPath);
        
        % Correct for DST
        if ~isdst(thisObj.Time(1)) && isdst(thisObj.Time(end))
            idxDst = isdst(thisObj.Time);
            thisObj.Time(idxDst) = thisObj.Time(idxDst) - repmat(duration(1,0,0),size(thisObj.Time(idxDst)));
        end
        
        % Add observation mask (accounting for cdfread error)
        thisObj.Observation = false(size(thisObj.Time));
        tmpObservation = logical(cdfData.Variables.logicalArray);
        thisObj.Observation(1:numel(cdfData.Variables.logicalArray),1) = tmpObservation(:);
        
        % Add compliance mask (accounting for cdfread error)
        thisObj.Compliance = true(size(thisObj.Time));
        tmpCompliance = logical(cdfData.Variables.complianceArray);
        thisObj.Compliance(1:numel(cdfData.Variables.complianceArray),1) = tmpCompliance(:);
        
        % Add bed log
        thisObj.BedLog = thisObj.BedLog.import(diaryPath);
        
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


