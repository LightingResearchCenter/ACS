function data = loadData(varargin)
%LOADDATA Summary of this function goes here
%   Detailed explanation goes here

addpath('C:\Users\jonesg5\Documents\GitHub\d12pack');

if nargin >= 1
    projectDir = varargin{1};
else
    projectDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';
end

ls = dir([projectDir,filesep,'data snapshot*']);
[~,idxMostRecent] = max(vertcat(ls.datenum));
dataName = ls(idxMostRecent).name;
dataPath = fullfile(projectDir,dataName);

d = load(dataPath);

data = d.objArray;

end

