function MakeComposites
%MAKE Summary of this function goes here
%   Detailed explanation goes here

h = waitbar(0,'Please wait generating Reports...');

addpath('C:\Users\jonesg5\Documents\GitHub\d12pack');

projectDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';

exportDir = fullfile(projectDir,'composites');

objArray = loadData;

timestamp = upper(datestr(now,'mmmdd'));

nObj = numel(objArray);
for iObj = 1:nObj
    thisObj = objArray(iObj);
    
    sessionDir = fullfile(exportDir,thisObj.Session.Name);
    
    fileName = [thisObj.ID,'_',thisObj.Session.Name,'_',timestamp,'.pdf'];
    
    filePath = fullfile(sessionDir,fileName);
    
    titleText = {'American Cancer Society';['ID: ',thisObj.ID,', Session: ',thisObj.Session.Name,', Device SN: ',num2str(thisObj.SerialNumber)]};
    
    d = d12pack.composite(thisObj,titleText);
    
    d.Title = titleText;
    
    saveas(d.Figure,filePath);
    
    close(d.Figure);
    
    waitbar(iObj/nObj,h);
end
close(h);

end

