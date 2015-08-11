% Reset workspace
close all
clear
clc

% Enable dependencies
circadianDir = 'C:\Users\jonesg5\Documents\GitHub\circadian';
addpath(circadianDir);

% Map paths
projectDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';
originalDir = fullfile(projectDir,'originalData');
croppedDir = fullfile(projectDir,'croppedData');
daysigramDir = fullfile(projectDir,'daysigramReports');
compositeDir = fullfile(projectDir,'compositeReports');

subDirListing = findSubDirs(originalDir);

[~,recentIdx] = max([subDirListing.datenum]);
dirRecent = subDirListing(recentIdx);

batchDir = fullfile(originalDir,dirRecent.name);
subjectDirListing = findSubDirs(batchDir);

subjectDirArray = fullfile(batchDir,{subjectDirListing.name});

% Iterate through subject directories
nSubject = numel(subjectDirArray);
for iSubject = 1:nSubject
    % Map paths
    thisSubjectDir = subjectDirArray{iSubject};
    
    originalCdfListing = dir([thisSubjectDir,filesep,'*.cdf']);
    originalCdfPath = fullfile(thisSubjectDir,originalCdfListing(1).name);
    
    croppedCdfPath = fullfile(croppedDir,originalCdfListing(1).name);
    
    diaryListing = dir([thisSubjectDir,filesep,'*.xlsx']);
    diaryPath = fullfile(thisSubjectDir,diaryListing(1).name);
    
    daysimeter12.cropcdf(originalCdfPath,croppedCdfPath,diaryPath);
    
    cdfData = daysimeter12.readcdf(croppedCdfPath);
    
    [absTime,relTime,epoch,light,activity,masks,subjectID,deviceSN] = daysimeter12.convertcdf(cdfData);
    
    % Read diary
    [~,~,diaryCell] = xlsread(diaryPath);
    
    % Get UTC offset
    offsetStr = diaryCell{2,6};
    offsetValue = str2double(regexprep(offsetStr,'[^-.0-9]*([-.0-9]*)[^-.0-9]*','$1'));
    
    % Adjust time
    offset = utcoffset(offsetValue,'hours');
    absTime.offset = offset;
    
    % Perform Analyses
    % Average
    Average = reports.composite.daysimeteraverages(light,activity,masks);
    % Calculate viable days
    idx2 = masks.observation & masks.compliance & ~masks.bed;
    t = absTime.localDateNum(idx2);
    d = unique(floor(t));
    n = numel(d);
    Average.nDays = n;
    % Phasor
    Phasor = phasor.prep(absTime,epoch,light,activity,masks);
    % Actigraphy
    Actigraphy = isiv.prep(absTime,epoch,activity,masks);
    % Miller
    Miller = struct('time',[],'cs',[],'activity',[]);
    [         ~,Miller.cs] = millerize.millerize(relTime,light.cs,masks);
    [Miller.time,Miller.activity] = millerize.millerize(relTime,activity,masks);
    
    
    % Generate Plots
    sheetTitle = {'American Cancer Society';['Subject ID: ',subjectID,', Device SN:',deviceSN]};
    fileID = ['subjectID',subjectID,'_deviceSN',deviceSN];
    reports.daysigram.daysigram(2,sheetTitle,absTime.localDateNum,masks,activity,light.cs,'cs',[0,1],10,daysigramDir,fileID);
    figTitle = 'American Cancer Society';
    reports.composite.compositeReport(compositeDir,Phasor,Actigraphy,Average,Miller,subjectID,deviceSN,figTitle);
    clf(1)
end

close all