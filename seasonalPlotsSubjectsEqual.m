function seasonalPlotsSubjectsEqual
% Reset matlab
close all
clear
clc

% Load data
data = loadData;

n  = numel(data);
t  = cell(n,1);
cs = cell(n,1);
ai = cell(n,1);
id = cell(n,1);

for iObj = 1:n
    idx = data(iObj).Observation & data(iObj).Compliance;
    t1 = min(data(iObj).Time(idx));
    t{iObj}  = dateshift(t1,'start','day') + duration(0,data(iObj).MillerTime',0);
    cs{iObj} = data(iObj).MillerCircadianStimulus;
    ai{iObj} = data(iObj).MillerActivityIndex;
    id{iObj} = repmat({data(iObj).ID},size(cs{iObj}));
end

t  = vertcat(t{:});
cs = vertcat(cs{:});
ai = vertcat(ai{:});
id = vertcat(id{:});

[s,idxSpring,idxSummer,idxAutumn,idxWinter] = season(t);
h = hour(t);

r = d12pack.report;
r.Orientation = 'landscape';
r.Title = {'ACS - Hourly CS by Season';'(subjects equal, bedtime = 0)';'outliers not shown'};

ax0 = axes(r.Body);
subplot(2,2,1,ax0)
ax1 = customBoxPlot(cs(idxSpring),h(idxSpring),'Spring',[0 0.7],'CS');
subplot(2,2,2)
ax2 = customBoxPlot(cs(idxSummer),h(idxSummer),'Summer',[0 0.7],'CS');
subplot(2,2,3)
ax3 = customBoxPlot(cs(idxAutumn),h(idxAutumn),'Autumn',[0 0.7],'CS');
subplot(2,2,4)
ax4 = customBoxPlot(cs(idxWinter),h(idxWinter),'Winter',[0 0.7],'CS');

saveas(r.Figure,'C:\Users\jonesg5\Desktop\ACS temp\csBoxPlotSubjectsEqualBedtime0.pdf')


r = d12pack.report;
r.Orientation = 'landscape';
r.Title = {'ACS - Hourly AI by Season';'(subjects equal, bedtime = 0)';'outliers not shown'};

ax0 = axes(r.Body);
subplot(2,2,1,ax0)
ax1 = customBoxPlot(ai(idxSpring),h(idxSpring),'Spring',[0 1],'AI');
subplot(2,2,2)
ax2 = customBoxPlot(ai(idxSummer),h(idxSummer),'Summer',[0 1],'AI');
subplot(2,2,3)
ax3 = customBoxPlot(ai(idxAutumn),h(idxAutumn),'Autumn',[0 1],'AI');
subplot(2,2,4)
ax4 = customBoxPlot(ai(idxWinter),h(idxWinter),'Winter',[0 1],'AI');

saveas(r.Figure,'C:\Users\jonesg5\Desktop\ACS temp\aiBoxPlotSubjectsEqualBedtime0.pdf')

end


function ax = customBoxPlot(x,G,titleText,YLim,YLabel)
boxplot(x,G,'BoxStyle','filled','MedianStyle','target','OutlierSize',4,'Symbol','')
ax = gca;
ax.YLim = [YLim(1)-0.02,YLim(2)+0.02];
ax.YTick = YLim(1):0.1:YLim(2);
ax.TickLength = [0 0];
grid(ax,'on');
ax.FontSize = 8;
title(titleText)
ylabel(YLabel)
xlabel('Hour of Day')

end