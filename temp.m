% Reset workspace
close all
clear
clc

% Enable dependencies
circadianDir = 'C:\Users\jonesg5\Documents\GitHub\circadian';
addpath(circadianDir);

% Map paths

defaultDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';
selectedDir = uigetdir(defaultDir,'Select folder of files to compare.');
if selectedDir == 0;
    return;
end

% projectDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';
originalDir = fullfile(selectedDir,'originals'); %fullfile(projectDir,'originalData');
croppedDir = fullfile(selectedDir,'cropped');
daysigramDir = fullfile(selectedDir,'reports');
compositeDir = fullfile(selectedDir,'reports');

if exist(croppedDir,'dir') ~= 7
    mkdir(croppedDir)
end

if exist(daysigramDir,'dir') ~= 7
    mkdir(daysigramDir)
end

if exist(compositeDir,'dir') ~= 7
    mkdir(compositeDir)
end

% subDirListing = findSubDirs(originalDir);
% 
% [~,recentIdx] = max([subDirListing.datenum]);
% dirRecent = subDirListing(recentIdx);
% 
% batchDir = fullfile(originalDir,dirRecent.name);
% subjectDirListing = findSubDirs(batchDir);

subjectDirArray = {selectedDir}; %fullfile(batchDir,{subjectDirListing.name});

% Iterate through subject directories
nSubject = numel(subjectDirArray);
for iSubject = 1:nSubject
    % Map paths
    thisSubjectDir = subjectDirArray{iSubject};
    
    originalCdfListing = dir([originalDir,filesep,'*.cdf']);
    if isempty(originalCdfListing)
        continue;
    end
    originalCdfPath = fullfile(originalDir,originalCdfListing(1).name);
    
    croppedCdfPath = fullfile(croppedDir,originalCdfListing(1).name);
    
    diaryListing = dir([thisSubjectDir,filesep,'*.xlsx']);
    diaryPath = fullfile(thisSubjectDir,diaryListing(1).name);
    
    ACScropcdf(originalCdfPath,croppedCdfPath,diaryPath);
    
    cdfData = daysimeter12.readcdf(croppedCdfPath);
    
    [absTime,relTime,epoch,light,activity,masks,subjectID,deviceSN] = daysimeter12.convertcdf(cdfData);
    
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