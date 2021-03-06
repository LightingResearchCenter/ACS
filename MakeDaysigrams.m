function MakeDaysigrams
%MAKE Summary of this function goes here
%   Detailed explanation goes here

h = waitbar(0,'Please wait generating Daysigrams...');

addpath('C:\Users\jonesg5\Documents\GitHub\d12pack');

projectDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';

exportDir = fullfile(projectDir,'daysigrams');

objArray = loadData;

timestamp = upper(datestr(now,'mmmdd'));

nObj = numel(objArray);
for iObj = 1:nObj
    thisObj = objArray(iObj);
    
    sessionDir = fullfile(exportDir,thisObj.Session.Name);
    
    fileName = [thisObj.ID,'_',thisObj.Session.Name,'_',timestamp,'.pdf'];
    
    filePath = fullfile(sessionDir,fileName);
    
    titleText = {'American Cancer Society';['ID: ',thisObj.ID,', Session: ',thisObj.Session.Name,', Device SN: ',num2str(thisObj.SerialNumber)]};
    
    d = d12pack.daysigram(thisObj,titleText);
    
    d(1).Title = titleText;
    
    saveas(d(1).Figure,filePath);
    
    close(d(1).Figure);
    
    waitbar(iObj/nObj,h);
end
close(h);

end

