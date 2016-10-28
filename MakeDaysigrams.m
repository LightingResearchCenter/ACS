function MakeDaysigrams
%MAKE Summary of this function goes here
%   Detailed explanation goes here

addpath('C:\Users\jonesg5\Documents\GitHub\d12pack');

projectDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';

dataPath = fullfile(projectDir,'data snapshot 2016-Jul-08 15-52.mat');

exportDir = fullfile(projectDir,'daysigrams');

load(dataPath)

timestamp = upper(datestr(now,'mmmdd'));

for iObj = 1:numel(objArray)
    thisObj = objArray(iObj);
    
    sessionDir = fullfile(exportDir,thisObj.Session.Name);
    
    fileName = [thisObj.ID,'_',timestamp,'_',num2str(thisObj.SerialNumber),'.pdf'];
    
    filePath = fullfile(sessionDir,fileName);
    
    titleText = {'American Cancer Society';['Subject ID: ',thisObj.ID,', Device SN: ',num2str(thisObj.SerialNumber)]};
    
    d = d12pack.daysigram(thisObj,titleText);
    
    saveas(d.Figure,filePath);
    
    close(d.Figure);
end

end

