function move2quarters
%MOVE2QUARTERS Summary of this function goes here
%   Detailed explanation goes here

% Main path for project
ACSPath = '\\root\projects\AmericanCancerSociety\DaysimeterData';

% Quarter names
quarters = {'Q1';'Q2';'Q3';'Q4'};
% Construct quarter directory path strings
quarterPathArray = fullfile(ACSPath,quarters);
% Check if quarter directories exist
quarterDoesNotExist = ~cellfun(@isdir,quarterPathArray);
% Make missing quarter directories
cellfun(@mkdir,quarterPathArray(quarterDoesNotExist));

% Import index
index = readtable(fullfile(ACSPath,'index.xlsx'));
quarterArray = cellstr([repmat('Q',size(index.quarter)),num2str(index.quarter)]);
subjectArray = index.subject;
% Construct subject path strings
subjectPathArray = fullfile(ACSPath,subjectArray);
% Check if subject directories exist
subjectDoesNotExist = ~cellfun(@isdir,subjectPathArray);
% Remove non-existant subject directories from list
subjectPathArray(subjectDoesNotExist) = [];
subjectArray(subjectDoesNotExist) = [];
quarterArray(subjectDoesNotExist) = [];


% Construct new subject path strings
newSubjectPathArray = fullfile(ACSPath,quarterArray,subjectArray);

% Move subject directories into quarter directories
cellfun(@movefile,subjectPathArray,newSubjectPathArray);

end

