function seasonalPhasors
% Reset matlab
close all
clear
clc

% Load data
data = loadData;

n  = numel(data);
t  = cell(n,1);
Vector = cell(n,1);
id = cell(n,1);

for iObj = 1:n
    idx          = data(iObj).Observation & data(iObj).Compliance;
    t{iObj}      = min(data(iObj).Time(idx));
    Vector{iObj} = data(iObj).Phasor.Vector;
    id{iObj}     = data(iObj).ID;
end

t  = vertcat(t{:});
Vector = vertcat(Vector{:});

[s,idxSpring,idxSummer,idxAutumn,idxWinter] = season(t);

r = d12pack.report;
r.Orientation = 'landscape';
r.Title = {'ACS - Phasors by Season'};

ax1 = subplot_tight(2,2,1,0,'Parent',r.Body);
groupPhasorPlot(ax1,Vector(idxSpring),'Spring',id(idxSpring))

ax2 = subplot_tight(2,2,2,0,'Parent',r.Body);
groupPhasorPlot(ax2,Vector(idxSummer),'Summer',id(idxSummer))

ax3 = subplot_tight(2,2,3,0,'Parent',r.Body);
groupPhasorPlot(ax3,Vector(idxAutumn),'Autumn',id(idxAutumn))

ax4 = subplot_tight(2,2,4,0,'Parent',r.Body);
groupPhasorPlot(ax4,Vector(idxWinter),'Winter',id(idxWinter))

pdf = 'C:\Users\jonesg5\Desktop\ACS temp\phasors.pdf';
saveas(r.Figure,pdf)
winopen(pdf)

end

function groupPhasorPlot(ax,Vectors,TitleText,varargin)

initPhasorAxes(ax)

plot(ax,real(Vectors),imag(Vectors),'.','Color',[ 30,  63, 134]/255);

plotPhasor(mean(Vectors),ax,2,[180, 211, 227]/255)
title(TitleText)

if nargin >= 4
    dataLabels = varargin{1};
    hrs = angle(Vectors)*12/pi;
    mag = abs(Vectors);
    highMag = mag >= 0.49;
    lowMag = mag <= 0.1;
    highHrs = hrs >= 4;
    lowHrs = hrs <= -2;
    special = mag > 0.34 & hrs < -1;
    outliers = highMag | lowMag | highHrs | lowHrs | special;
    text(ax,real(Vectors(outliers)),imag(Vectors(outliers)),dataLabels(outliers),'FontSize',6)
    disp('Outliers')
    disp(TitleText)
    disp(dataLabels(outliers))
end

end

function initPhasorAxes(ax)
rMin = 0;
rMax = 0.6;
rTicks = 6;
rInc = (rMax - rMin)/rTicks;

% Make original axes invisible
ax.Visible = 'off';

% Prevent unwanted resizing of axes.
ax.ActivePositionProperty = 'position';

% Prevent axes from being erased.
ax.NextPlot = 'add';

% Make aspect ratio equal.
ax.DataAspectRatio = [1 1 1];

% Create a handle groups.
hGrid = hggroup;
set(hGrid,'Parent',ax);
hLabels = hggroup;
set(hLabels,'Parent',ax);

% Define a circle.
th = 0:pi/100:2*pi;
xunit = cos(th);
yunit = sin(th);
% Now really force points on x/y axes to lie on them exactly.
inds = 1 : (length(th) - 1) / 4 : length(th);
xunit(inds(2 : 2 : 4)) = zeros(2, 1);
yunit(inds(1 : 2 : 5)) = zeros(3, 1);

% Plot spokes.
th = (1:12)*2*pi/12;
cst = cos(th);
snt = sin(th);
cs = [zeros(size(cst)); cst];
sn = [zeros(size(snt)); snt];
hSpoke = line(rMax*cs,rMax*sn);
for iSpoke = 1:numel(hSpoke)
    hSpoke(iSpoke).HandleVisibility = 'off';
    hSpoke(iSpoke).Parent = hGrid;
    hSpoke(iSpoke).LineStyle = ':';
    hSpoke(iSpoke).Color = [0.5 0.5 0.5];
end

% Annotate spokes in hours
rt = rMax + 0.8*rInc;
pm = char(177);
hours = {' +2  ',' +4  ',' +6  ',' +8  ','+10  ',[pm,'12  '],'-10  ',' -8  ',' -6  ',' -4  ',' -2  ','  0  '};
for iSpoke = length(th):-1:1
    hSpokeLbl(iSpoke,1) = text(rt*cst(iSpoke),rt*snt(iSpoke),hours(iSpoke));
    hSpokeLbl(iSpoke,1) .FontName = 'Arial';
    hSpokeLbl(iSpoke,1).FontUnits = 'pixels';
    hSpokeLbl(iSpoke,1).FontSize = 10;
    hSpokeLbl(iSpoke,1).HorizontalAlignment = 'center';
    hSpokeLbl(iSpoke,1).HandleVisibility = 'off';
    hSpokeLbl(iSpoke,1).Parent = hLabels;
end
top = hSpokeLbl(3).Extent(2)+hSpokeLbl(3).Extent(4);
bottom = hSpokeLbl(9).Extent(2);
left = hSpokeLbl(6).Extent(1);
right = hSpokeLbl(12).Extent(1)+hSpokeLbl(12).Extent(3);
outer = max(abs([top,bottom,left,right]));
ax.YLim = [-outer,outer];
ax.XLim = [-outer,outer];


% Draw radial circles
cos105 = cos(105*pi/180);
sin105 = sin(105*pi/180);

for iTick = (rMin + rInc):rInc:rMax
    hRadial = line(xunit*iTick,yunit*iTick);
    hRadial.Color = [0.5 0.5 0.5];
    hRadial.LineStyle = ':';
    hRadial.HandleVisibility = 'off';
    hRadial.Parent = hGrid;
end
% Make outer circle balck and solid.
hRadial.Color = 'black';
hRadial.LineStyle = '-';
for iTick = (rMin + 2*rInc):2*rInc:rMax
    xText = (iTick)*cos105;
    yText = (iTick)*sin105;
    hTickLbl = text(xText,yText,num2str(iTick));
    hTickLbl.FontName = 'Arial';
    hTickLbl.FontUnits = 'pixels';
    hTickLbl.FontSize = 10;
    hTickLbl.VerticalAlignment = 'bottom';
    hTickLbl.HorizontalAlignment = 'center';
    hTickLbl.HandleVisibility = 'off';
    hTickLbl.Rotation = 15;
    hTickLbl.Parent = hLabels;
end
end % End of initPhasorAxes


function plotPhasor(Vector,Parent,LineWidth,Color)
scale = 1.25;

h = hggroup(Parent);

% Make line slightly shorter than the vector.
th = angle(Vector);
mag = abs(Vector);
offset = .05*scale;
[x2,y2] = pol2cart(th,mag-offset);
% Plot the line.
hLine = line(Parent,[0,x2],[0,y2]);
set(hLine,'Parent',h);
hLine.LineWidth = LineWidth;
hLine.Color = Color;

% Plot the arrowhead.
% Constants that define arrowhead proportions
xC = 0.05;
yC = 0.02;

% Create arrowhead points
xx = [1,(1-xC*scale),(1-xC*scale),1].';
yy = scale.*[0,(yC*scale),(-yC*scale),0].';
arrow = xx + yy.*1i;

% Calculate new vector with same angle but magnitude of 1
th = angle(Vector);
[x2,y2] = pol2cart(th,1);
vector2 = x2 + y2*1i;

% Find difference between vectors
dVec = vector2 - Vector;

% Calculate arrowhead points in transformed space.
a = arrow * vector2.' - dVec;
xA = real(a);
yA = imag(a);
cA = zeros(size(a));

% Plot and format arrowhead.
hHead = patch(Parent,xA,yA,cA);
set(hHead,'EdgeColor','none');
set(hHead,'FaceColor',get(hLine,'Color'));

set(hHead,'Parent',h);
end % End of plotPhasor
