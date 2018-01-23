% Reset matlab
close all
clear
clc

% Load data
data = loadData;

n  = numel(data);
t_i  = cell(n,1);
t_f  = cell(n,1);

for iObj = 1:n
    t_i{iObj} = data(iObj).Time(1);
    t_f{iObj} = data(iObj).Time(end);
end

t_i = vertcat(t_i{:});
t_f = vertcat(t_f{:});

[~,~,~,~,idxWinter_i] = season(t_i);
[~,~,~,~,idxWinter_f] = season(t_f);

idxWinter = idxWinter_i | idxWinter_f;

winterData = data(idxWinter);

exportDir = 'C:\Users\jonesg5\Desktop\ACS temp\WinterDaysigrams';

timestamp = upper(datestr(now,'mmmdd'));

for iObj = 1:numel(winterData)
    thisObj = winterData(iObj);
    
    if isempty(thisObj.Time)
        continue
    end
    
    titleText = {'American Cancer Society';['ID: ',thisObj.ID,', Session: ',thisObj.Session.Name,', Device SN: ',num2str(thisObj.SerialNumber)]};
    
    d = d12pack.daysigram(thisObj,titleText);
    
    for iFile = 1:numel(d)
        d(iFile).Title = titleText;
        
        fileName = [thisObj.ID,'_',thisObj.Session.Name,'_',timestamp,'_p',num2str(iFile),'.pdf'];
        filePath = fullfile(exportDir,fileName);
        saveas(d(iFile).Figure,filePath);
        close(d(iFile).Figure);
        
    end
end
