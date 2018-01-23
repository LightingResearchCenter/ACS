
%CLACULATESLEEP Summary of this function goes here
%   Detailed explanation goes here

% Reset matlab
close all
clear
clc

h = waitbar(0,'Please wait calculating sleep metrics...');

addpath('C:\Users\jonesg5\Documents\GitHub\d12pack');
addpath('C:\Users\jonesg5\Documents\GitHub\circadian');

saveDir = '\\root\projects\AmericanCancerSociety\DaysimeterData\metrics';

objArray = loadData;

timestamp = upper(datestr(now,'mmmdd'));

nObj = numel(objArray);

nights   = {'night_1','night_2','night_3','night_4','night_5','night_6','night_7'};
varNames = [{'ID','Quarter'},nights];
cellTmp  = cell(nObj,1);
nanTmp   = nan(nObj,1);
template = table(cellTmp,cellTmp,nanTmp,nanTmp,nanTmp,nanTmp,nanTmp,nanTmp,nanTmp,'VariableNames',varNames);
assumedSleepTime       = template;
reportedSleepTime      = template;
sleepEfficiency        = template;
timeWokenWhileSleeping = template;


for iObj = 1:nObj
    thisObj = objArray(iObj);
    
    assumedSleepTime.ID{iObj}       = thisObj.ID;
    reportedSleepTime.ID{iObj}      = thisObj.ID;
    sleepEfficiency.ID{iObj}        = thisObj.ID;
    timeWokenWhileSleeping.ID{iObj} = thisObj.ID;
    
    assumedSleepTime.Quarter{iObj}       = thisObj.Session.Name;
    reportedSleepTime.Quarter{iObj}      = thisObj.Session.Name;
    sleepEfficiency.Quarter{iObj}        = thisObj.Session.Name;
    timeWokenWhileSleeping.Quarter{iObj} = thisObj.Session.Name;
    
    idx      = thisObj.Compliance&thisObj.Observation;
    time     = datenum(thisObj.Time(idx));
    activity = thisObj.ActivityIndex(idx);
    epoch    = samplingrate(mode(diff(time)),'days');
    
    nBed = numel(thisObj.BedLog);
    if nBed >= 1
        for iBed = 1:nBed
            bedTime   = datenum(thisObj.BedLog(iBed).BedTime);
            getupTime = datenum(thisObj.BedLog(iBed).RiseTime);
            analysisStartTime = bedTime   - 20/60/24;
            analysisEndTime   = getupTime + 20/60/24;
            try
                param = sleep.sleep(time,activity,epoch,...
                    analysisStartTime,analysisEndTime,...
                    bedTime,getupTime,'auto');
                
                if iBed <= 7
                    assumedSleepTime.(nights{iBed})(iObj)       = param.assumedSleepTime;
                    reportedSleepTime.(nights{iBed})(iObj)      = param.timeInBed;
                    sleepEfficiency.(nights{iBed})(iObj)        = param.sleepEfficiency;
                    timeWokenWhileSleeping.(nights{iBed})(iObj) = param.wakeBouts;
                end
            catch err
                param = NaN;
            end
        end
    end
    
    waitbar(iObj/nObj,h);
end

close(h);

h = waitbar(0,'Saving sleep metrics...');

idx1 = strcmp(assumedSleepTime.Quarter,'Q1');
idx2 = strcmp(assumedSleepTime.Quarter,'Q2');
idx3 = strcmp(assumedSleepTime.Quarter,'Q3');
idx4 = strcmp(assumedSleepTime.Quarter,'Q4');

waitbar(1/7,h)

fn1 = ['Sleep-Metrics_Q1',timestamp,'.xlsx'];
fn2 = ['Sleep-Metrics_Q2',timestamp,'.xlsx'];
fn3 = ['Sleep-Metrics_Q3',timestamp,'.xlsx'];
fn4 = ['Sleep-Metrics_Q4',timestamp,'.xlsx'];

waitbar(2/7,h)

fp1 = fullfile(saveDir,fn1);
fp2 = fullfile(saveDir,fn2);
fp3 = fullfile(saveDir,fn3);
fp4 = fullfile(saveDir,fn4);

waitbar(3/7,h)

writetable(assumedSleepTime(idx1,:),fp1,'Sheet','assumedSleepTime');
writetable(assumedSleepTime(idx2,:),fp2,'Sheet','assumedSleepTime');
writetable(assumedSleepTime(idx3,:),fp3,'Sheet','assumedSleepTime');
writetable(assumedSleepTime(idx4,:),fp4,'Sheet','assumedSleepTime');

waitbar(4/7,h)

writetable(reportedSleepTime(idx1,:),fp1,'Sheet','reportedSleepTime');
writetable(reportedSleepTime(idx2,:),fp2,'Sheet','reportedSleepTime');
writetable(reportedSleepTime(idx3,:),fp3,'Sheet','reportedSleepTime');
writetable(reportedSleepTime(idx4,:),fp4,'Sheet','reportedSleepTime');

waitbar(5/7,h)

writetable(sleepEfficiency(idx1,:),fp1,'Sheet','sleepEfficiency');
writetable(sleepEfficiency(idx2,:),fp2,'Sheet','sleepEfficiency');
writetable(sleepEfficiency(idx3,:),fp3,'Sheet','sleepEfficiency');
writetable(sleepEfficiency(idx4,:),fp4,'Sheet','sleepEfficiency');

waitbar(6/7,h)

writetable(timeWokenWhileSleeping(idx1,:),fp1,'Sheet','timeWokenWhileSleeping');
writetable(timeWokenWhileSleeping(idx2,:),fp2,'Sheet','timeWokenWhileSleeping');
writetable(timeWokenWhileSleeping(idx3,:),fp3,'Sheet','timeWokenWhileSleeping');
writetable(timeWokenWhileSleeping(idx4,:),fp4,'Sheet','timeWokenWhileSleeping');

waitbar(7/7,h)

close(h)


