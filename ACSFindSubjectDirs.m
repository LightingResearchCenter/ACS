function [dirPath,dirName] = ACSFindSubjectDirs(parentDir)
%ACSFINDSUBJECTDIRS Summary of this function goes here
%   Detailed explanation goes here

% Find sub-folders
listing = findSubDirs(parentDir);
% Match only folders with subject IDs
startIdx = regexp({listing.name},'A\d{5}');
nonmatchIdx = cellfun(@isempty,startIdx);
subjectIdx = ~nonmatchIdx;
subjectDirListing = listing(subjectIdx);
% Convert listing to cell array of full paths
dirName = {subjectDirListing.name}';
dirPath = fullfile(parentDir,dirName);

end

