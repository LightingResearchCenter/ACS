function CalculatePhasors
%CLACULATEPHASORS Summary of this function goes here
%   Detailed explanation goes here

addpath('C:\Users\jonesg5\Documents\GitHub\d12pack');

projectDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';

ls = dir([projectDir,filesep,'data snapshot*']);
[~,idxMostRecent] = max(vertcat(ls.datenum));
dataName = ls(idxMostRecent).name;
dataPath = fullfile(projectDir,dataName);

load(dataPath)

timestamp = upper(datestr(now,'mmmdd'));

nObj = numel(objArray);

t = table(cell(nObj,1),cell(nObj,1),nan(nObj,1),nan(nObj,1),'VariableNames',{'ID','Quarter','PhasorMagnitude','PhasorAngle'});

for iObj = 1:nObj
    thisObj = objArray(iObj);
    t.ID{iObj} = thisObj.ID;
    t.Quarter{iObj} = thisObj.Session.Name;
    t.PhasorMagnitude(iObj) = thisObj.Phasor.Magnitude;
    t.PhasorAngle(iObj) = thisObj.Phasor.Angle.hours;
end

idx1 = strcmp(t.Quarter,'Q1');
idx2 = strcmp(t.Quarter,'Q2');
idx3 = strcmp(t.Quarter,'Q3');
idx4 = strcmp(t.Quarter,'Q4');
Q1 = t(idx1,:);
Q2 = t(idx2,:);
Q3 = t(idx3,:);
Q4 = t(idx4,:);

fileName = ['Phasors_',timestamp,'.xlsx'];

filePath = fullfile(projectDir,fileName);

writetable(Q1,filePath,'Sheet','Q1');
writetable(Q2,filePath,'Sheet','Q2');
writetable(Q3,filePath,'Sheet','Q3');
writetable(Q4,filePath,'Sheet','Q4');

winopen(filePath);
end

