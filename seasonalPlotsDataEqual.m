function seasonalPlotsDataEqual

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

for iObj = 1:n
    idx = data(iObj).Observation & data(iObj).Compliance;
    inBed = data(iObj).InBed(idx);
    t{iObj}  = data(iObj).Time(idx);
    cs{iObj} = data(iObj).CircadianStimulus(idx);
    cs{iObj}(inBed) = 0;
    ai{iObj} = data(iObj).ActivityIndex(idx);
    ai{iObj}(inBed) = 0;
end

t  = vertcat(t{:});
cs = vertcat(cs{:});
ai = vertcat(ai{:});

[s,idxSpring,idxSummer,idxAutumn,idxWinter] = season(t);
h = hour(t);

%%
% r = d12pack.report;
% r.Orientation = 'landscape';
% r.Title = {'ACS - Hourly CS by Season';'(data equal, bedtime = 0)';'outliers not shown'};
% 
% ax0 = axes(r.Body);
% subplot(2,2,1,ax0)
% ax1 = customBoxPlot(cs(idxSpring),h(idxSpring),'Spring',[0 0.7],'CS');
% subplot(2,2,2)
% ax2 = customBoxPlot(cs(idxSummer),h(idxSummer),'Summer',[0 0.7],'CS');
% subplot(2,2,3)
% ax3 = customBoxPlot(cs(idxAutumn),h(idxAutumn),'Autumn',[0 0.7],'CS');
% subplot(2,2,4)
% ax4 = customBoxPlot(cs(idxWinter),h(idxWinter),'Winter',[0 0.7],'CS');
% 
% saveas(r.Figure,'C:\Users\jonesg5\Desktop\ACS temp\csBoxPlotDataEqualBedtime0.pdf')

%%
% r = d12pack.report;
% r.Orientation = 'landscape';
% r.Title = {'ACS - Hourly AI by Season';'(data equal, bedtime = 0)';'outliers not shown'};
% 
% ax0 = axes(r.Body);
% subplot(2,2,1,ax0)
% ax1 = customBoxPlot(ai(idxSpring),h(idxSpring),'Spring',[0 1],'AI');
% subplot(2,2,2)
% ax2 = customBoxPlot(ai(idxSummer),h(idxSummer),'Summer',[0 1],'AI');
% subplot(2,2,3)
% ax3 = customBoxPlot(ai(idxAutumn),h(idxAutumn),'Autumn',[0 1],'AI');
% subplot(2,2,4)
% ax4 = customBoxPlot(ai(idxWinter),h(idxWinter),'Winter',[0 1],'AI');
% 
% saveas(r.Figure,'C:\Users\jonesg5\Desktop\ACS temp\aiBoxPlotDataEqualBedtime0.pdf')

%%
% r = d12pack.report;
% r.Orientation = 'landscape';
% r.Title = {'ACS - CS Distribution by Season';'(data equal, bedtime = 0)'};
% 
% ax0 = axes(r.Body);
% subplot(2,2,1,ax0)
% ax1 = customHistogram(cs(idxSpring),0:0.05:0.7,'Spring','CS');
% subplot(2,2,2)
% ax2 = customHistogram(cs(idxSummer),0:0.05:0.7,'Summer','CS');
% subplot(2,2,3)
% ax3 = customHistogram(cs(idxAutumn),0:0.05:0.7,'Autumn','CS');
% subplot(2,2,4)
% ax4 = customHistogram(cs(idxWinter),0:0.05:0.7,'Winter','CS');
% 
% saveas(r.Figure,'C:\Users\jonesg5\Desktop\ACS temp\csHistogramDataEqualBedtime0.pdf')

%%
r = d12pack.report;
r.Orientation = 'landscape';
r.Title = {'ACS - CS by Season';'(data equal, bedtime = 0)'};

t2 = mod(datenum(t),1)*24;

ax0 = axes(r.Body);
subplot(2,2,1,ax0)
ax1 = customPseudoColor(t2(idxSpring),cs(idxSpring),'Spring',[0 0.7],'CS');
subplot(2,2,2)
ax2 = customPseudoColor(t2(idxSummer),cs(idxSummer),'Summer',[0 0.7],'CS');
subplot(2,2,3)
ax3 = customPseudoColor(t2(idxAutumn),cs(idxAutumn),'Autumn',[0 0.7],'CS');
subplot(2,2,4)
ax4 = customPseudoColor(t2(idxWinter),cs(idxWinter),'Winter',[0 0.7],'CS');

saveas(r.Figure,'C:\Users\jonesg5\Desktop\ACS temp\csPseudoColorDataEqualBedtime0.pdf')

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


function ax = customHistogram(x,edges,titleText,XLabel)
histogram(x,edges)
ax = gca;
ax.TickLength = [0 0];
grid(ax,'on');
ax.XLim = [edges(1),edges(end)];
title(titleText)
xlabel(XLabel)
ylabel('# of Data Points')

end

function ax = customPseudoColor(x,y,titleText,YLim,YLabel)
ax = gca;

dat = [x,y];

[values,centers] = hist3(dat,[100,100]); % default is to 10x10 bins

colormap(jet)

h = pcolor(centers{1},centers{2},log(values'));

h.EdgeColor = 'none';

ax.YLim = YLim;
ax.YTick = YLim(1):0.1:YLim(2);
ax.XLim = [0 24];
ax.XTick = 0:1:24;
ax.TickLength = [0 0];

ax.FontSize = 8;
title(titleText)
ylabel(YLabel)
xlabel('Hour of Day')

end