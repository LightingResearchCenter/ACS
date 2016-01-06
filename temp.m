% Reset workspace
close all
clear
clc

% Enable dependencies
[githubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(githubDir,'circadian');
addpath(circadianDir);

% Map paths

defaultDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';
selectedDir = uigetdir(defaultDir,'Select folder of files to process.');
if selectedDir == 0;
    return;
end

% projectDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';
originalDir = fullfile(selectedDir,'best_download');
croppedDir = fullfile(selectedDir,'marked_download');
reportsDir = fullfile(selectedDir,'reports');





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
    
    diaryListing = dir([thisSubjectDir,filesep,'best_diary',filesep,'*.xlsx']);
    diaryPath = fullfile(thisSubjectDir,'best_diary',diaryListing(1).name);
    
    if exist(croppedDir,'dir') == 7
        rmdir(croppedDir,'s')
    end
    mkdir(croppedDir)
    
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
    
    if exist(reportsDir,'dir') == 7
        rmdir(reportsDir,'s')
    end
    mkdir(reportsDir)
    
    
    % Generate Plots
    sheetTitle = {'American Cancer Society';['Subject ID: ',subjectID,', Device SN:',deviceSN]};
    fileID = ['subjectID',subjectID,'_deviceSN',deviceSN];
    reports.daysigram.daysigram(2,sheetTitle,absTime.localDateNum,masks,activity,light.cs,'cs',[0,1],10,reportsDir,fileID);
    figTitle = 'American Cancer Society';
    reports.composite.compositeReport(reportsDir,Phasor,Actigraphy,Average,Miller,subjectID,deviceSN,figTitle);
    clf(1)
end

close all