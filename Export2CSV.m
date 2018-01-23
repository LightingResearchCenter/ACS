function Export2CSV
%EXPORT2CSV Summary of this function goes here
%   Detailed explanation goes here

h = waitbar(0,'Please wait exporting data...');

addpath('C:\Users\jonesg5\Documents\GitHub\d12pack');

projectDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';

dataPath = fullfile(projectDir,'data snapshot 2016-Nov-09 11-20.mat');

exportDir = fullfile(projectDir,'exported_data');

load(dataPath)

timestamp = upper(datestr(now,'mmmdd'));

nObj = numel(objArray);

for iObj = 1:nObj
    thisObj = objArray(iObj);
    
    sessionDir = fullfile(exportDir,thisObj.Session.Name);
    
    fileName = [thisObj.ID,'_',timestamp,'_',num2str(thisObj.SerialNumber),'.csv'];
    
    filePath = fullfile(sessionDir,fileName);
    
    thisObj.export(filePath);
    
    waitbar(iObj/nObj,h);
end

close(h);

end

