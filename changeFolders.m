function changeFolders
%MAKEFOLDERS Summary of this function goes here
%   Detailed explanation goes here

rootDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';

listing = dir(rootDir);
listingDir = listing([listing.isdir]);

excludedDir = strcmp('.',{listingDir.name}) | ...
              strcmp('..',{listingDir.name}) | ...
              strcmp('archive',{listingDir.name}) | ...
              strcmp('weekly_reports',{listingDir.name});

listingSubjectDir = listingDir(~excludedDir);

subject = fullfile(rootDir,{listingSubjectDir.name}');

originals = fullfile(subject,'originals');
cropped = fullfile(subject,'cropped');
diagnostics = fullfile(subject,'diagnostics');

best_download = fullfile(subject,'best_download');
marked_download = fullfile(subject,'marked_download');
downloaded_files = fullfile(subject,'downloaded_files');
diaries = fullfile(subject,'diaries');
best_diary = fullfile(subject,'best_diary');
diagnostic_reports = fullfile(subject,'diagnostic_reports');

paths = table(subject, originals, cropped,diagnostics, best_download, ...
    marked_download, downloaded_files, diaries, best_diary, ...
    diagnostic_reports);

nSubject = numel(subject);

for iSubject = 1:nSubject
    thesePaths = paths(iSubject,:);
    
    % Rename folders
    % “diagnostics” -> “downloaded_files”
    if exist(thesePaths.diagnostics{1},'dir') == 7
        movefile(thesePaths.diagnostics{1},thesePaths.downloaded_files{1});
    elseif exist(thesePaths.downloaded_files{1},'dir') ~= 7
        mkdir(thesePaths.downloaded_files{1});
    end
    % “originals” -> “best_download”
    if exist(thesePaths.originals{1},'dir') == 7
        movefile(thesePaths.originals{1},thesePaths.best_download{1});
    elseif exist(thesePaths.best_download{1},'dir') ~= 7
        mkdir(thesePaths.best_download{1});
    end
    % “cropped” -> “marked_download”
    if exist(thesePaths.cropped{1},'dir') == 7
        movefile(thesePaths.cropped{1},thesePaths.marked_download{1});
    elseif exist(thesePaths.marked_download{1},'dir') ~= 7
        mkdir(thesePaths.marked_download{1});
    end
    
    % Make new folders
    if exist(thesePaths.diaries{1},'dir') ~= 7
        mkdir(thesePaths.diaries{1});
    end
    if exist(thesePaths.best_diary{1},'dir') ~= 7
        mkdir(thesePaths.best_diary{1});
    end
    if exist(thesePaths.diagnostic_reports{1},'dir') ~= 7
        mkdir(thesePaths.diagnostic_reports{1});
    end
    
    % Move diary into folder
    diaryListing = dir([thesePaths.subject{1},filesep,'*.xlsx']);
    if ~isempty(diaryListing)
        diaryPath = fullfile(thesePaths.subject{1},diaryListing(1).name);
        newDiaryPath = fullfile(thesePaths.best_diary{1},diaryListing(1).name);
        if exist(diaryPath,'file') == 2
            movefile(diaryPath,newDiaryPath);
        end
    end
    
    % Move comparison file
    comparisonPath = fullfile(thesePaths.downloaded_files{1},'comparison.xlsx');
    if exist(comparisonPath,'file') == 2
        newComparisonPath = fullfile(thesePaths.diagnostic_reports{1},'comparison.xlsx');
        movefile(comparisonPath,newComparisonPath);
    end
    
    % Move preflight copies
    preflightListing = dir([thesePaths.downloaded_files{1},filesep,'*preflight*.xlsx']);
    if ~isempty(preflightListing)
        for iPreflight = 1:numel(preflightListing);
            preflightPath = fullfile(thesePaths.downloaded_files{1},preflightListing(iPreflight).name);
            newPreflightPath = fullfile(thesePaths.diagnostic_reports{1},preflightListing(iPreflight).name);
            if exist(preflightPath,'file') == 2
                movefile(preflightPath,newPreflightPath);
            end
        end
    end
    
    % Move diary copies
    diaryCopyListing = dir([thesePaths.downloaded_files{1},filesep,'*Diary*.xlsx']);
    if ~isempty(diaryCopyListing)
        for iDiaryCopy = 1:numel(diaryCopyListing);
            diaryCopyPath = fullfile(thesePaths.downloaded_files{1},diaryCopyListing(iDiaryCopy).name);
            newDairyCopyPath = fullfile(thesePaths.diaries{1},diaryCopyListing(iDiaryCopy).name);
            if exist(diaryCopyPath,'file') == 2
                movefile(diaryCopyPath,newDairyCopyPath);
            end
        end
    end
end

end

