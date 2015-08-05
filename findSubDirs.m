function listing = findSubDirs(searchPath)
%FINDSUBDIRS Summary of this function goes here
%   Detailed explanation goes here

listing = dir(searchPath);
listing = listing([listing.isdir]);
parentIdx = strcmp({listing.name},'.');
parentParentIdx = strcmp({listing.name},'..');
notParentsIdx = ~parentIdx & ~parentParentIdx;
listing = listing(notParentsIdx);

end

