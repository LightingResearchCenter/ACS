function Export2CSV
%EXPORT2CSV Summary of this function goes here
%   Detailed explanation goes here

addpath('C:\Users\jonesg5\Documents\GitHub\d12pack');

projectDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';

dataPath = fullfile(projectDir,'data snapshot 2016-Jul-08 15-52.mat');

exportDir = fullfile(projectDir,'exported_data');

load(dataPath)

timestamp = upper(datestr(now,'mmmdd'));

for iObj = 1:numel(objArray)
    thisObj = objArray(iObj);
    
    sessionDir = fullfile(exportDir,thisObj.Session.Name);
    
    fileName = [thisObj.ID,'_',timestamp,'_',num2str(thisObj.SerialNumber),'.csv'];
    
    filePath = fullfile(sessionDir,fileName);
    
    thisObj.export(filePath);
end

end

