function inventoryFolders
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

best_download = fullfile(subject,'best_download');
marked_download = fullfile(subject,'marked_download');
downloaded_files = fullfile(subject,'downloaded_files');
diaries = fullfile(subject,'diaries');
best_diary = fullfile(subject,'best_diary');
diagnostic_reports = fullfile(subject,'diagnostic_reports');

paths = table(subject, best_download, marked_download, ...
    downloaded_files, diaries, best_diary, diagnostic_reports);

nSubject = numel(subject);
folder_name = {listingSubjectDir.name}';
best_diary_exists = false(nSubject,1);
downloaded_files_exists = false(nSubject,1);
best_download_exists = false(nSubject,1);
marked_download_exists = false(nSubject,1);

for iSubject = 1:nSubject
    thesePaths = paths(iSubject,:);
    
    % Check for best diary
    diaryListing = dir([thesePaths.best_diary{1},filesep,'*.xlsx']);
    best_diary_exists(iSubject) = ~isempty(diaryListing);
    
    % Check for downloaded files
    downloadedFilesListingsting = dir([thesePaths.downloaded_files{1},filesep,'*.cdf']);
    downloaded_files_exists(iSubject) = ~isempty(downloadedFilesListingsting);
    
    % Check for best download
    downloadListing = dir([thesePaths.best_download{1},filesep,'*.cdf']);
    best_download_exists(iSubject) = ~isempty(downloadListing);
    
    % Check for marked download
    markedDownloadListing = dir([thesePaths.marked_download{1},filesep,'*.cdf']);
    marked_download_exists(iSubject) = ~isempty(markedDownloadListing);
end

folder_inventory = table(folder_name, downloaded_files_exists, ...
    best_diary_exists, best_download_exists, marked_download_exists);

timestamp = datestr(now,'yyyy-mm-dd_HHMM');
excelPath = fullfile(rootDir,'weekly_reports',['folder_inventory_',timestamp,'.xlsx']);
writetable(folder_inventory,excelPath);
winopen(excelPath);

end

