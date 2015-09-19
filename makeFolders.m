function makeFolders
%MAKEFOLDERS Summary of this function goes here
%   Detailed explanation goes here

rootDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';
indexPath = fullfile(rootDir,'index.xlsx');

[~,~,indexCell] = xlsread(indexPath);
subjectIdArray = indexCell(2:end,1);
subjectDirArray = fullfile(rootDir,subjectIdArray);
originalsArray = fullfile(subjectDirArray,'originals');
croppedArray = fullfile(subjectDirArray,'cropped');
reportsArray = fullfile(subjectDirArray,'reports');
diagnosticsArray = fullfile(subjectDirArray,'diagnostics');

nSubject = numel(subjectIdArray);

for iSubject = 1:nSubject
    thisSubjectDir = subjectDirArray{iSubject};
    thisOriginalsDir = originalsArray{iSubject};
    thisCroppedDir = croppedArray{iSubject};
    thisReportsDir = reportsArray{iSubject};
    thisDiagnosticsDir = diagnosticsArray{iSubject};
    
    theseDirs = {thisSubjectDir;...
                 thisOriginalsDir;...
                 thisCroppedDir;...
                 thisReportsDir;...
                 thisDiagnosticsDir};
    
    for iDir = 1:numel(theseDirs)
        if exist(theseDirs{iDir},'dir') ~= 7
            mkdir(theseDirs{iDir});
        end
    end
    
end

end

