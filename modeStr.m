function [freqStr,matchIdx] = modeStr(strArray)
%MODESTR Find the most common string in a list of strings
%   Excludes empty strings.

% Vectorize string array
strArray2 = strArray(:);

% Remove empty strings
idxEmpty = strcmp('',strArray2);
strArray2(idxEmpty) = [];

% Find unique strings
unqStr = unique(strArray2);

% Count the instances of each unique string
nUnq = numel(unqStr);
count = zeros(nUnq,1);
for iUnq = 1:nUnq
    idx = strcmp(unqStr{iUnq},strArray2);
    count(iUnq) = sum(idx);
end

% Find the most frequent string
[~,idxMax] = max(count);
freqStr = unqStr{idxMax};

% Locate instances of the most frequent string
matchIdx = strcmp(freqStr,strArray);

end

