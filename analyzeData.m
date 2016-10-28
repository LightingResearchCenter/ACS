function analyzeData
%ANALYZEDATA Summary of this function goes here
%   Detailed explanation goes here
timestamp = datestr(now,'yyyy-mm-dd HH-MM');

[githubDir,~,~] = fileparts(pwd);
d12packDir = fullfile(githubDir,'d12pack');
addpath(d12packDir);

projectDir = '\\root\projects\AmericanCancerSociety';
dataDir = fullfile(projectDir,'DaysimeterData');
saveDir = fullfile(projectDir,'DaysimeterMetrics');

ls = dir([dataDir,filesep,'data snapshot*']);
[~,idxMostRecent] = max(vertcat(ls.datenum));
dataName = ls(idxMostRecent).name;
dataPath = fullfile(dataDir,dataName);

load(dataPath);

nObj = numel(objArray);
h = waitbar(0,'Please wait. Analyzing data...');
rn1 = datestr(datetime(0,0,0,0,0,0):duration(0,30,0):datetime(0,0,0,23,30,0),'HH:MM - ');
rn2 = datestr(datetime(0,0,0,0,30,0):duration(0,30,0):datetime(0,0,0,24,0,0),'HH:MM');
RowNames = cellstr([rn1,rn2]);
for iObj = 1:nObj
    
    obj = objArray(iObj);
    
    idxKeep = obj.Observation & obj.Compliance;
    
    t = obj.Time(idxKeep);
    ai = obj.ActivityIndex(idxKeep);
    lux = obj.Illuminance(idxKeep);
    cla = obj.CircadianLight(idxKeep);
    cs = obj.CircadianStimulus(idxKeep);
    
    date0 = dateshift(t(1),'start','day');
    dateF = dateshift(t(end),'start','day');
    dates = date0:calendarDuration(0,0,1):dateF;
    
    nDates = numel(dates);
    tb = array2table(nan(48,nDates));
    tb.Properties.VariableNames = cellstr(datestr(dates,'mmm_dd_yyyy'));
    tb.Properties.RowNames = RowNames;
    
    aiTB  = tb;
    luxTB = tb;
    claTB = tb;
    csTB  = tb;
    coverageTB = tb;
    
    aiTB.Properties.DimensionNames{1} = 'Activity Index';
    luxTB.Properties.DimensionNames{1} = 'Illuminance';
    claTB.Properties.DimensionNames{1} = 'Circadian Light';
    csTB.Properties.DimensionNames{1} = 'Circadian Stimulus';
    coverageTB.Properties.DimensionNames{1} = '# of Samples';
    
    for iCol = 1:nDates
        for iRow = 1:48
            idx = t >= (dates(iCol)+duration((iRow-1)/2,0,0)) & t < (dates(iCol)+duration(iRow/2,0,0));
            
            if any(idx)
                aiTB{iRow,iCol}  = mean(ai(idx));
                luxTB{iRow,iCol} = mean(lux(idx));
                claTB{iRow,iCol} = mean(cla(idx));
                csTB{iRow,iCol}  = mean(cs(idx));
            end
            
            coverageTB{iRow,iCol}  = sum(idx);
        end
    end
    
    
    sheet = obj.ID;
    
    aiName = [timestamp,' ',obj.Session.Name,' Mean AI','.xlsx'];
    aiPath = fullfile(saveDir,aiName);
    writetable(aiTB,aiPath,'Sheet',sheet,'WriteVariableNames',true,'WriteRowNames',true);
    
    luxName = [timestamp,' ',obj.Session.Name,' Mean Lux','.xlsx'];
    luxPath = fullfile(saveDir,luxName);
    writetable(luxTB,luxPath,'Sheet',sheet,'WriteVariableNames',true,'WriteRowNames',true);
    
    claName = [timestamp,' ',obj.Session.Name,' Mean CLA','.xlsx'];
    claPath = fullfile(saveDir,claName);
    writetable(claTB,claPath,'Sheet',sheet,'WriteVariableNames',true,'WriteRowNames',true);
    
    csName = [timestamp,' ',obj.Session.Name,' Mean CS','.xlsx'];
    csPath = fullfile(saveDir,csName);
    writetable(csTB,csPath,'Sheet',sheet,'WriteVariableNames',true,'WriteRowNames',true);
    
    coverageName = [timestamp,' ',obj.Session.Name,' Analysis Coverage','.xlsx'];
    coveragePath = fullfile(saveDir,coverageName);
    writetable(coverageTB,coveragePath,'Sheet',sheet,'WriteVariableNames',true,'WriteRowNames',true);
    
    waitbar(iObj/nObj);
end
close(h);


end

