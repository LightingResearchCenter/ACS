function [recentPath,recentName] = findRecent(parentDir,varargin)
%FINDRECENTDIR Summary of this function goes here
%   Detailed explanation goes here

if nargin == 2
    listing = varargin{1};
else
    listing = findSubDirs(parentDir);
end

[~,recentIdx] = max([listing.datenum]);
recentListing = listing(recentIdx);
recentName = recentListing.name;
recentPath = fullfile(parentDir,recentName);

end

