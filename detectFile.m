function [TF,n,filePath,fileName,tokens] = detectFile(parentDir,listing,expression)
%DETECTFILE Summary of this function goes here
%   Detailed explanation goes here

startIdx = regexp({listing.name},expression);
matchIdx = ~(cellfun(@isempty,startIdx));
TF = any(matchIdx);

if TF
    matchListing = listing(matchIdx);
    n = numel(matchListing);
    [filePath,fileName] = findRecent(parentDir,matchListing);
    tempTokens = regexp(fileName,expression,'tokens');
    tokens = tempTokens{1};
else
    n = 0;
    filePath = '';
    fileName = '';
    tokens = {};
end


end

