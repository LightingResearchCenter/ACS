function [bedTimeArray,riseTimeArray,offset] = readDiary(diaryPath)
%READDIARY Summary of this function goes here
%   Detailed explanation goes here

% Read diary
[~,~,diaryCell] = xlsread(diaryPath,'A1:F35');

% Get UTC offset
offsetStr = diaryCell{2,6};
offsetValue = str2double(regexprep(offsetStr,'[^-.0-9]*([-.0-9]*)[^-.0-9]*','$1'));
offset = utcoffset(offsetValue,'hours');

% Get bed and rise times
bedCell = diaryCell(2:end,2);
riseCell = diaryCell(2:end,3);

% Find rows with text
bedChar = cellfun(@ischar,bedCell);
riseChar = cellfun(@ischar,riseCell);
rowChar = bedChar | riseChar;

% Remove empty rows
bedCell(~rowChar) = [];
riseCell(~rowChar) = [];

% Convert text to datenum
bedTimeArray = cellfun(@datenum,bedCell);
riseTimeArray = cellfun(@datenum,riseCell);

end

