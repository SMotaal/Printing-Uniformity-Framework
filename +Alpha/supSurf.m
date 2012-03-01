function [ hFig, hSurf ] = supSurf( sourceData, hFig, mView, pBar, cl, input_args )
%SUPSURF plots supSample as a surf
%   Detailed explanation goes here

%% Plot Design Notes (To be implemented)
% Layers:
%   Print Area: entire printing plane, origin at lead-operator (mm)
%     Press Size (mm, to spec)
%   Print Zones: sub-divisions for the printing plane
%     Zone Count X/Y
%   Target Area: entire target plane, off-origin (mm)
%     Patch Count X/Y (to spec)
%     Patch Width X/Y (mm, to spec)
%     Patch Offset X/Y (mm, calculated)
%       Sheet Size X/Y (mm, to spec)
%       Patch Origin X/Y (mm, calculated)
%   Data Area: entire data plane, off-origin (mm)

% Create and/or Capture Figure

%% Define format / style variables (Text, Line, Bar, Axes, Title, Label)
defUnits      = 'normalized';

defLineStyle    = '-';
defLineWidth    = 1;

defGridColor    = [1,1,1].*0.5;

defTextFont   = 'Gill Sans';
defBoldFont   = defTextFont;
defBoldWeight = 'normal';
defTextColor  = 'k';

mTextFont     = {'FontName',   defTextFont};
mTextColor    = {'Color', defTextColor};
mBoldFont     = {'FontName',   defBoldFont}; %[mTextFont ' Bold']; %'Helvetica Bold'
mBoldWeight   = {'FontWeight', defBoldWeight};

mBarStyle     = {mBoldFont{:}, 'FontSize', 10, mBoldWeight{:}};
mGridStyle    = {'GridLineStyle', '-', 'MinorGridLineStyle','-', ...
                   'XColor',defGridColor, 'YColor',defGridColor, 'ZColor',defGridColor};
mAxesStyle    = {mBoldFont{:}, 'FontSize', 12, mBoldWeight{:}, mGridStyle{:}};
mGlobalStyle  = {'LineSmoothing','on'};
mZoneStyle    = {'LineStyle',':', 'FaceColor', 'none', 'LineWidth', 0.25};

mTitleStyle   = {mBoldFont{:}, 'FontSize', 16, mBoldWeight{:}, mTextColor{:}};
mLabelStyle   = {mBoldFont{:}, 'FontSize', 14, mBoldWeight{:}, mTextColor{:}}; %...
  %'Units', defUnits}; % 'VerticalAlignment','middle', 'HorizontalAlignment','center', 
  
mZReverse     = true;
mPatchScatter = false;

%% Define view variables (mView)
if ~exist('mView','var'), mView = 1; end

%% Get/Create figure handle
try
  hFig = hFig;
catch exception
  hFig = [];
end

if isempty(hFig)
    hFig = figure('name', 'SUP Plot', 'units', defUnits, ...
    'Color', 'w', 'Renderer', 'OpenGL', 'Interruptible','on'); %OpenGL
    %'Toolbar', 'none', 'WindowStyle', 'modal', 'MenuBar', 'none',  ...
end

%  assignin('base', 'supCA', gca);
clf;


%% Prepare figure
hold on;

%% Get base variables (Data, Sample, CMS, PatchSet, Sheet, FileName)
supData     = sourceData.Data;     % evalin('base','supData');
supSample   = sourceData.Sample;   % evalin('base','supSample');
cms         = sourceData.CMS;      % evalin('base','cms');
% supPatchSet = sourceData.PatchSet; % evalin('base','supPatchSet');
supSheet    = sourceData.Sheet;    % evalin('base','supSheet');
% supFileName = sourceData.Filename; %evalin('base','supFileName');

%% Get sample data (xZ, xR, xC)
dataSamples   = supSample.lstar;
dataRows      = supSample.lstarR; % - 0.5;
dataColumns   = supSample.lstarC; % - 0.5;

targetSize    = supData.targetSize;

%% Interpolate using meshgrid & griddata
xLims     = [1 targetSize(1)]; %get(gca,'XLim');
yLims     = [1 targetSize(2)]; %get(gca,'YLim');

[r,c]     = meshgrid(xLims(1):xLims(2),yLims(1):yLims(2));
V         = TriScatteredInterp(dataRows(:), dataColumns(:), dataSamples(:));
dataMesh  = V(r,c);
uM        = (dataMesh-min(dataMesh(:)))./(max(dataMesh(:))-min(dataMesh(:)));

%% Reset z axis
zValues   = dataMesh(dataMesh >0);
zMean     = round(nanmean(zValues));
zRange    = [min(zValues) max(zValues)];
zOffset   = 5.0;
zSnapStep = 2.0;

zLims     = [zMean-zOffset zMean+zOffset];
zLims     = round(zLims./zSnapStep).*zSnapStep;

%% Reset the color map

cExtent   = 5;
cToneLims = [0.05 0.98];
cToneRng  = max(cToneLims)-min(cToneLims);
cToneStps = cExtent*2*2;

cKeyColor = [0.5 1.0 0.5];

% cMap      = [ 1.00  1.00  1.00      % Unscaled map
%               0.85  0.85  0.85
%               0.50  1.00  0.50      % cKeyColor
%               0.25  0.25  0.25
%               0.00  0.00  0.00  ];

cMap      = [ 1.00  1.00  1.00      % Unscaled map
              0.90  0.90  0.90
              0.80  0.80  0.80
              0.70  0.70  0.70
              0.60  0.60  0.60              
              0.50  1.00  0.50      % cKeyColor
              0.40  0.40  0.40
              0.30  0.30  0.30
              0.20  0.20  0.20              
              0.10  0.10  0.10
              0.00  0.00  0.00  ];            

cColors   = size(cMap,1);

cMap      = cMap.*(cToneRng) + min(cToneLims);
cMap      = flipud(cMap);

[scx scy] = meshgrid(1:3,1:cColors/cToneStps:cColors);
cMap = interp2(cMap,scx,scy);

colormap(cMap);

cLims     = [zMean-cExtent zMean+cExtent];
cSize     = max(cLims) - min(cLims);

set(gca,'CLimMode', 'Manual');
set(gca,'CLim', cLims);

%% Define Plane & Press offsets, tics, etc.
daspect([1,1,0.25]);

% aTic is the tic step
% aTicLims is the range of tics (defaults to data lims)
% aTics is the tick location vector
% aLims is the range of a given axis (pads a tic step around data)
% X/Y Ticks (default to the row/column of a patch)
set(gca, 'LineWidth', defLineWidth);

xTic      = 10;
xTicLims  = xLims;
xTics     = xTicLims(1):xTic:xTicLims(2);
xLims     = xLims + [-xTic +xTic];

yTic      = 4;
yTicLims  = yLims;
yTics     = yTicLims(1):yTic:yTicLims(2);
yLims     = yLims + [-yTic +yTic];

zTic      = 1;
zTicLims  = zLims;
zTics     = zTicLims(1):zTic:zTicLims(2);
zLims     = zLims + [-zTic +zTic];

xlim(xLims);
ylim(yLims);
zlim(zLims);
set(gca, 'XTick', xTics-0.5);
set(gca, 'YTick', yTics-0.5);
set(gca, 'ZTick', zTics);

set(gca, 'xTickLabel', xTics);
set(gca, 'YTickLabel', yTics);

set(gca, 'Clipping', 'off');

% Offset & Draw to Print Plane

planeLayer = 0;
planeGap   = 0.02;

try
  columnPitch = supData.columnPitch;
  rowPitch    = supData.rowPitch;
  
  axialShift  = supData.axialShift;
  leadOffset  = supData.leadOffset;
  
  printWidth  = supData.printWidth;
  printLength = supData.printLength;
  
  dataWidth   = yTicLims(2) .* columnPitch;
  dataHeight  = xTicLims(2) .* rowPitch;
  
  dataLeft    = (printWidth-dataWidth)/2 + axialShift;
  dataTop     = leadOffset;
  
  printLeft   = - dataLeft;
  printTop    = - dataTop;
  
  planeInset  = 0; % 40
  
  planeWidth  = printWidth    + planeInset*2;
  planeLength = printLength   + planeInset*2;
  
  planeLeft   = -dataLeft     - planeInset;
  planeTop    = -dataTop      - planeInset;
  
  yLims       = ([0   planeWidth ] + planeLeft) ./ columnPitch;
  xLims       = ([0   planeLength] + planeTop ) ./ rowPitch;
  
  BoxY        = [0 0; 0 1; 1 1; 1 0];
  BoxX        = circshift(BoxY,-1); %[0 1; 1 1; 1 0; 0 0];
  BoxZ        = [1 1; 1 1; 1 1; 1 1];
  
  if planeInset >0
    planeBoxY   = (BoxY .* planeWidth  + planeLeft ) ./ columnPitch;
    planeBoxX   = (BoxX .* planeLength + planeTop  ) ./ rowPitch;
    planeBoxZ   = (BoxZ .* max(zLims)  - planeLayer);
    
    if mZReverse
      planeBoxZ   = (BoxZ .* max(zLims)  - planeLayer);
    else
      planeBoxZ   = (BoxZ .* min(zLims)  + planeLayer);
    end
    
    patch(planeBoxX,planeBoxY,planeBoxZ, [0.8 0.8 0.8],...
                  'EdgeColor', 'none', mGlobalStyle {:}, 'LineWidth', defLineWidth);  %'FaceAlpha', 0.1,   
  end
  %planeBoxZ   = (BoxZ .* min(zLims));
  
  planeLayer  = planeLayer + planeGap; 
  printBoxY   = (BoxY .* printWidth  + printLeft ) ./ columnPitch;
  printBoxX   = (BoxX .* printLength + printTop  ) ./ rowPitch;
  %zMean);
  %printBoxZ   = (BoxZ .* (min(zLims)+0.01))%zMean);

  planeLayer  = planeLayer + planeGap;
  patchBoxY   = (BoxY .* targetSize(2) ); %./ columnPitch
  patchBoxX   = (BoxX .* targetSize(1) ); %./ rowPitch
  
  if mZReverse
    printBoxZ   = (BoxZ .* (max(zLims) - planeLayer));
    patchBoxZ   = (BoxZ .* (max(zLims) - planeLayer));%zMean);
  else
    printBoxZ   = (BoxZ .* (min(zLims) + planeLayer));
    patchBoxZ   = (BoxZ .* (min(zLims) + planeLayer));%zMean);
  end

  patch(printBoxX,printBoxY,printBoxZ, [0.9 0.9 0.9], 'Tag', 'PressBox', ...
                'EdgeColor', 'none', mGlobalStyle {:}, 'LineWidth', defLineWidth); %'FaceAlpha', 0.1, 
  patch(patchBoxX,patchBoxY,patchBoxZ, [1.0 1.0 1.0], 'Tag', 'TargetBox', ...
                'EdgeColor', [0.7 0.7 0.7], mGlobalStyle {:}, 'LineWidth', defLineWidth); %'FaceAlpha', 0.1, 
  
  ylim(yLims);
  xlim(xLims);
  
  set(gca, 'xTickLabel', xTics .* rowPitch);
  set(gca, 'YTickLabel', yTics .* columnPitch);  
  
end

%% Offset & Draw to InkZones
try
  inkZones = supData.inkZones;

  pressZones = inkZones.range;
  patchZones = inkZones.targetrange;
  zoneRange = [ setdiff(pressZones(:),patchZones(:))' ...
                intersect(pressZones(:),patchZones(:))'];  

  BoxY        = [0 0; 0 1; 1 1; 1 0];
  BoxX        = circshift(BoxY,-1); %[0 1; 1 1; 1 0; 0 0];
  BoxZ        = [1 1; 1 1; 1 1; 1 1];
  
  planeLayer  = planeLayer + planeGap;
  
  zoneWidth = inkZones.patches;
  zoneBoxX  = printBoxX; %BoxX .* (xLims(2)-xLims(1)) + xLims(1);  
  %zoneBoxZ  = BoxZ .* (max(zLims)-planeLayer);
  zoneBoxZ  = BoxZ .* zMean;
  % zoneBoxZ  = BoxZ .* (min(zLims)+0.03);
  zoneShift = -min(inkZones.targetrange(:));
  
  for zone = zoneRange
    zoneLeft  = zoneWidth * (zone+zoneShift);
    zoneBoxY  = BoxY .* zoneWidth + zoneLeft;
    
    if any(patchZones(:)==zone) % Draw as Active
      zoneStyle = {mZoneStyle{:}, 'EdgeColor', [0 0 0], mGlobalStyle{:} }; %, 'EdgeAlpha', 1.0}
    else % Draw as Inactive
      zoneStyle = {mZoneStyle{:}, 'EdgeColor', [0.5 0.5 0.5], mGlobalStyle{:}}; %, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.1}
    end
    patch(zoneBoxX,zoneBoxY,zoneBoxZ, [0 0 0], zoneStyle{:});
  end
  
  yTics     = min(zoneRange):2:max(zoneRange);
  set(gca, 'YTick', ( yTics.*zoneWidth + zoneShift*zoneWidth) + zoneWidth/2.0 );
  set(gca, 'YTickLabel', yTics);  

end

%% Optimize lims


% xLims = xLims(1):xStep:xLims(2);
% yLims = yLims(1):yStep:yLims(2);
% zLims = ones(numel(xLims), numel(yLims));
% 
% [xLims yLims] = meshgrid(xLims, yLims);

% Grid ticks
% xTic      = size(supData.data,2) / 4.0;
% xTics     = gX(1):xTic:gX(2);
% set(gca, 'XTick', xTics);

% if strfind(supFileName,'sm74')>0
%   yTic      = yStep;
%   yTics     = gY(1)-4:yTic:gY(2)+4;
% 
% 
%   yTicLabels = [1:gY(2)-gY(1)-1 []];
%   set(gca, 'YTick', yTics + 2);
%   set(gca, 'YTickLabel', yTicLabels);
% end

set(gca, 'YGrid', 'off');
%set(gca, 'YMinorGrid', 'off');
set(gca, 'YMinorTick', 'on');
set(gca, 'Clipping', 'off');


if mZReverse, set(gca,'ZDir','reverse'); end

%% Reset Axes
hAxes = gca;
set(hAxes,'ActivePositionProperty','Position');
set(hAxes,'Tag','Axes');
set(hAxes,mAxesStyle{:});

%% Reset mView options
BarPositions  =	[	205	205	225	285	]; % cbov

Views         =	[	 -80  25
                   -90  90
                  -180   0
                   -90   0	];
Projections = { 'perspective', 'orthographic', 'orthographic', 'orthographic'};

Grids = {'on', 'off', 'on', 'on'};
YMinorGrids = {'off', 'off', 'off', 'on'};

XLabelAngles = [90, 90, 0, 0];


view(Views(mView,:));
set(hAxes,  'Projection', Projections{mView});

grid(hAxes, Grids{mView});
set(hAxes, 'YMinorGrid',  YMinorGrids{mView});

rXLabel = XLabelAngles(mView);


%% Surf Plots
rOffset = -1;
cOffset = -1;
switch mView
  case 2
    %size dataRows, size dataColumns, size dataSamples,
    %contourf(r, c, dataMesh, 'ZDataSource','supZData'); %, 'CDataMapping', 'scaled', ...
    %'EdgeColor', 'none');%(dataSamples>0),dataColumns(dataSamples>0),dataSamples(dataSamples>0)); %,'ZDataSource','supZData');
    %, 'CDataMapping', 'scaled', ...
    %'EdgeColor', 'none',);
    hSurf = surf(r+rOffset,c+cOffset,dataMesh,dataMesh,'ZDataSource','supZData', 'CDataMapping', 'scaled', ...
    'EdgeColor', 'none', 'CDataSource','supZData', mGlobalStyle{:}, 'LineWidth', defLineWidth);  
  otherwise
    hSurf = surf(r+rOffset,c+cOffset,dataMesh,dataMesh,'ZDataSource','supZData', 'CDataMapping', 'scaled', ...
    'EdgeColor', 'none', 'CDataSource','supZData', mGlobalStyle{:}, 'LineWidth', defLineWidth);
end

%% Plot Scatter Block Map
if mPatchScatter
  if mZReverse
    xZC = ones(size(dataSamples)) .* max(ZLim) - 10;
  else
    xZC = ones(size(dataSamples)) .* min(ZLim) + 10;
  end
  scatter3(dataRows(dataSamples>0)+rOffset,dataColumns(dataSamples>0)+cOffset,xZC(dataSamples>0),25,[0 0 0], ...
    'LineWidth', 0.25, 'Marker', 's'); %'filled', 
end

%% Update labels & title
s=supData.sheetIndex(supSheet);

hTitle = title(['Sample #' num2str(s)], 'VerticalAlignment','bottom', 'HorizontalAlignment','left', 'Units',defUnits, mTitleStyle{:});
% set(hTitle,'Units', defUnits);
pTitle = get(hTitle,'Position');
set(hTitle,'Position', [0 1.0]);
updateTitle(hAxes, sourceData);

hXLabel = xlabel('Circumferential','Rotation',rXLabel, mLabelStyle{:}); 
ylabel('Axial', mLabelStyle{:});
zlabel('L*', mLabelStyle{:});
  
pXLabel = get(hXLabel,'Position');


%% Reset Colorbar
bBar  = []; % BarPositions(mView);


hBar    = findobj(hFig, 'Type', 'Axes', 'Tag', 'Colorbar');
if numel(hBar)>1, delete(hBar); hBar = []; end
if isempty(hBar) 
  hBar   = colorbar('North','XAxisLocation','top', mBarStyle {:}, 'LineWidth', defLineWidth + 0.5, 'ActivePositionProperty', 'Position', 'Position', [-1 -1 1 1]);
end

pBar  = updateBarPosition(hFig, hAxes, hTitle, hBar, mView, bBar);

set(hFig,'ResizeFcn', @resizeFigure); %,hFig, hAxes, hTitle, hBar, mView, bBar));


%% Store Plot Data
vFig  = getUserData(hFig  );
vAxes = getUserData(hAxes );

vAxes.mView = mView;

setUserData(hFig,   vFig  );
setUserData(hAxes,  vAxes );

%gridcolor(hAxes, mGridColor{:});

hold off;

end

function [output] = resizeFigure(src,evt)

try
  hFig    = gcf;
  set(0,'CurrentFigure',hFig);

  hAxes   = get(hFig,     'CurrentAxes');
  hTitle  = get(hAxes,    'Title');
  hBar    = findobj(hFig, 'Type', 'Axes', 'Tag', 'Colorbar');

  vFig    = getUserData(hFig  );
  vAxes   = getUserData(hAxes );

  mView   = vAxes.mView;
  
%   hXLabel = get(hAxes,'xticklabel')
%   hYLabel = get(hAxes,'ylabel')
%   hZLabel = get(hAxes,'zlabel')
%   
%   hTexts  = [hXLabel]; % hYLabel(:) hZLabel(:)];
%   
% %   set(0,'HideUndocumented','off')
% %   %cds = get(hAxes,'Children');
% %   for d = hTexts(1)
% %     get(d)
% %   end
% %   set(0,'HideUndocumented','on')
%     
%   for iT = 1:numel(hTexts)
%     hTexts(iT)
%     set(hTexts, 'Color', 'k')
%   end

  try
    pBar  = updateBarPosition(hFig, hAxes, hTitle, hBar, mView);
  catch exception
    warning('Could not update colorbar position');
  end

  setUserData(hFig, vFig    );
  setUserData(hAxes, vAxes  );
catch exception
end
end

function [output] = updateTitle(hAxes, sourceData) %, hTitle, hBar, fView, pbBar)
  setPlotTitle(hAxes);
end

function [output] = setPlotTitle(hAxes, sourceData)
  supNameFormat   = '%s ';
  supSheetFormat  = '- Sheet #%d ';
  supPatchFormat  = '- %d%% ';

  supTitleText    = '';

  %% Format Data Set String
  try
    supName       = sourceData.Filename; % evalin('base','supFileName');
    supNameText   = sprintf(supNameFormat,  supName);
  catch Exception
    supNameText   = sprintf(supNameFormat,  'Sample');
  end

  %% Format Sheet String
   try
    sheetIndex    = evalin('base','supData.sheetIndex');
    supSheet      = evalin('base','supSheet');
    supSheetIndex = sheetIndex(supSheet);
    supSheetText  = sprintf(supSheetFormat, supSheetIndex);
   catch
    supSheetText  = sprintf(supSheetFormat, 0);
   end

  %% Format Patch String
  try
    supPatch      = evalin('base','supPatchValue');
    supPatchText  = sprintf(supPatchFormat, supPatch);
  catch
    supPatchText  = '';
  end

  %% Figure out the axes handle
  % try
  %   mca = evalin('base', 'supCA');
  % catch
  %   mca = gca;
  % end
  
  try
    hAxes = findobj(hAxes,'Type','Axes');
  catch exception
    hAxes = gca;
  end

  % assignin('base', 'supCA', mca);

  %% Update the title
  supTitleText  = strtrim([supNameText supSheetText supPatchText]);
  title(hAxes,supTitleText);

end

function pBar = updateBarPosition(hFig, hAxes, hTitle, hBar, fView, pbBar)
% optimalColorbarBottom determines the best bottom position for color bar
%   The optimal color bar bottom is based on figure height, style and
%   whitespace in a given plot. The position must be determined after
%   resetting the figure size, view, etc.

% drawnow();

%% Backup & Reset units to pixels
uFig    = get(hFig,   'Units');
set(        hFig,     'Units',  'pixels');

uAxes   = get(hAxes,  'Units');
set(        hAxes,    'Units',  'pixels');

% apAxes  = get(hAxes,  'ActivePositionProperty');
% set(        hAxes,    'ActivePositionProperty',  'position');

uTitle  = get(hTitle, 'Units');
set(        hTitle,   'Units',  'pixels');

uBar    = get(hBar,   'Units');
set(        hBar,     'Units',  'pixels');

% figOuterPos = get(hFig,'OuterPosition')
% figPos = get(hFig,'Position')
% figEdge = figOuterPos - figPos
% figScale = figPos(3:4)

pBar        = get(hBar,   'Position');

pFig        = get(hFig,   'Position'      );
pFigOuter   = get(hFig,   'OuterPosition' );
%pFigEdge    = pFigOuter - pFig;

pAxes       = get(hAxes,  'Position');
pAxesOuter  = get(hAxes,  'OuterPosition');
%pAxesInset  = get(hAxes,  'TightInset');
%pAxesEdge   = pAxesOuter - pAxes;

%% Axes pixel position fix
pAxesPx = pAxes;
pAxesPx = get(hAxes,'PixelBounds');
%getpixelposition(hAxes,hFig);%hgconvertunits(hFig,getpixelposition(hAxes,hFig),'pixel','normalized',hFig);

try
  pbBar = pbBar;
catch exception
  pbBar = pBar(2);
end

% set(0,'HideUndocumented','off')
% cds = get(hAxes,'Children');
% for d = 1:numel(cds)
%   get(cds(d))
% end
% set(0,'HideUndocumented','on')

pwAxesPx = pAxesPx(3) - pAxesPx(1);
plAxesPx =  pAxesOuter(3) - pAxesPx(3);

phAxesPx = pAxesPx(4) - pAxesPx(2);
pbAxesPx =  pAxesOuter(4) - pAxesPx(4);

pwBar = min(250, pwAxesPx/3);
phBar = 10;
plBar = plAxesPx + pwAxesPx - pwBar; %  pAxesPx(3); %ptLeft; %ptrAxes(1); % + pAxesPx(1); %pAxesPx(1) + pAxesPx(3) - pwBar; %+ pAxes(3)

pBarStrategies  = {'TitleHigh'};
pBarStrategy    = 'TitleHigh';

switch lower(pBarStrategy)
  case 'titlehigh'
    
    pTitle        = get(hTitle, 'Position');
    pTitleExtent  = get(hTitle, 'Extent');
    pbBar = pbAxesPx + phAxesPx + pTitleExtent(4)/2 - phBar/2;
end

pBar = [plBar pbBar pwBar phBar];
set(hBar,'Position', pBar);
%pBar = get(hBar, 'Position');

%% Restore units to previous state
set(hFig,     'Units', uFig   );
set(hAxes,    'Units', uAxes  );
% set(hAxes,    'ActivePositionProperty', apAxes  );
set(hTitle,   'Units', uTitle );
set(hBar,     'Units', uBar   );

end

