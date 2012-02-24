roundTimer = tic; roundActions=0; close all;

%% Prepare Log
runlog(fullfile('output','testStats.log'),'optional');
runlog('\n');

%% Constants
TAB          = '     ';
TABS = TAB;

%% Exporting Settings
default exportVideo false;
default exportPng false;
default exportEps false;
default plotType "region";  % 'z;one';  % 'axial';
default plotMode "single";

if (exists('exportAll'))
  if ((exportAll==true))
    exportVideo = true;
    exportEps = false;
    exportPng = true;
  else
    exportVideo = false;
    exportEps = false;
    exportPng = false;
  end
end

isExporting = (exportVideo || exportEps || exportPng);

%% Load Source Uniformity Data
when [~exists('supData') && ~exists('source')] source = "ritsm7402a";

try
  if(exists('source'))
    supFilePath = datadir('uniprint',source);
    runName = whos('-file', supFilePath);
    runName = runName.name;
    stepTimer = tic; runlog(['Loading ' runName ' uniformity data ...']);    
    Data.supLoad(supFilePath); click roundActions;   
    runlog([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
    mTree = structTree(supMat.sourceTicket,[],[],4);
    disp(mTree);
    
    newPatchValue = 100;
    clear source;
  end
  
  runName = supMat.sourceTicket.folder.name;
catch err
  warning('UPStats:UPMatrix', 'Invalid uniformity data structure.');
end

%% Prepare PatchSet Uniformity Data

when [exists('newPatchValue')] clear supPatchSet;

if ~exists('supPatchSet')
  default newPatchValue 100;
  supPatchValue = newPatchValue;
  supPatchSet = supData.patchMap == supPatchValue;
  
  clear newPatchValue;
  clear supPlotData;
end

if ~exists('supPlotData')
  stepTimer = tic; runlog(['Interpolating ' int2str(supPatchValue) '%% tone value uniformity data ...']);
  Data.supInterp; click roundActions;
  runlog([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
  
  clear supStatPlots;
end

%% Defaults & Settings
% default exportVideo false;
% default exportPng false;
% default exportEps false;
% default plotType "region";  % 'z;one';  % 'axial';
% default plotMode "single";
% 
% if (exists('exportAll'))
%   if ((exportAll==true))
%     exportVideo = true;
%     exportEps = false;
%     exportPng = true;
%   else
%     exportVideo = false;
%     exportEps = false;
%     exportPng = false;
%   end
% end
% 
% isExporting = (exportVideo || exportEps || exportPng);

clear plotting stats;

isCombinedMode = (strcmpi(plotMode,'regions'));
if isCombinedMode
  plotTypes = {'region', 'axial', 'circumferential', 'sheet'};
  plotUnits = 'pixels';
  plotting.Specs = struct( ...
    'Dimensions',   {[0, 0],          [0,50],     [50, 0],    [50, 50]        }, ...
    'Offset',       {[0,0,-50,-50],   [],         [],         []              }, ...
    'Placement',    {[0,0],           [0,1],      [1,0],      [1,1]           }, ...
    'ColorBar',     {'SouthOutside',              [],         [],         []  }, ...
    'Grid',         {'off',           'off',      'off',      'off'           });
else
  plotTypes = {plotType};
  plotting.Specs = struct( ...
    'Dimensions', [0, 0], 'Offset',[], 'Placement', [0,0], ...
    'ColorBar', 'SouthOutside', 'Grid', 'off');
  plotMode = plotType;
end

nPlotTypes = numel(plotTypes);

strPlotType='';

for p = 1:nPlotTypes
  strType         = plotTypes{p}; %char(plotType);
  isLastPlotType  = p==nPlotTypes; % strcmpi(plotType, plotTypes(end));
  strPlotType     = [strPlotType strType resolve(isLastPlotType, '', ', ')];
end

%% Generate Uniformity Statistics

if ~exists('supStatPlots')
  stepTimer = tic; runlog(['Generating ' strPlotType ' statistics for ' runName ' - ' int2str(supPatchValue) '%% ...']);
  supStatPlots = Stats.supPlotStats(supPlotData, supData); click roundActions;
  runlog([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
  generating = true;
else
  generating = false;
end

if (roundActions>0)
  runlog(['>> Data Preparation Successful! \t\t' num2str(toc(roundTimer)) '\t seconds\n']);
end

roundTimer = tic;
try
  for plotType = plotTypes
    plotType = char(plotType);
    statPlots=supStatPlots.([plotType, 'Surfs']);
    statMasks=supStatPlots.([plotType, 'Masks']);
    
    stats.(plotType).Surfs = statPlots;
    stats.(plotType).Masks = statMasks;
  end
  when [generating] runlog('\n');
catch err
  return;
end

runMode = resolve(isExporting, 'Export', 'Display');

runlog([runMode 'ing ' strPlotType ' uniformity statistics plots for ' runName ' - ' int2str(supPatchValue) '%%:\n']);

if (isExporting)
  nFig = 'Spatial-Temporal Stats Output Plot';
  hFig = []; % findobj('type','figure','name', nFig);
  if (isempty(hFig))
    hFig =  figure('Name', nFig, 'units','pixels', ...
      'Color', 'w', 'Toolbar', 'none', ... %'WindowStyle', 'modal', ...
      'MenuBar', 'none', 'Renderer', 'OpenGL', 'Visible', 'off');
  else
    figure(hFig);
  end
else
  nFig = 'Spatial-Temporal Stats Plot';
  hFig = []; % findobj('type','figure','name', nFig);
  if (isempty(hFig))
    hFig =  figure('Name', nFig, 'units','pixels', ...
      'Color', 'w', 'Renderer', 'OpenGL');
  else
    figure(hFig);
  end
end

pause(0.5);

def.Units      = 'normalized';

def.LineStyle    = '-';
def.LineWidth    = 1;

def.GridColor    = [1,1,1].*0.3;

def.TextFont   = 'Gill Sans'; % 'Helvetica';
def.BoldFont   = def.TextFont; %'Gill Sans Bold';  %'Helvetica Bold';
def.BoldWeight = 'bold';
def.TextColor  = 'k';
def.FontSize   = 12;


style.TextFont     = {'FontName',   def.TextFont};
style.TextColor    = {'Color', def.TextColor};
style.BoldFont     = {'FontName',   def.BoldFont}; %[style.TextFont ' Bold']; %'Helvetica Bold'
style.BoldWeight   = {'FontWeight', def.BoldWeight};
style.LabelAlignment = {'HorizontalAlignment','center','VerticalAlignment','middle'};

style.TitleStyle   = {style.BoldFont{:}, 'FontSize', def.FontSize+4, style.TextColor{:}}; % style.BoldWeight{:},
style.LabelStyle   = {style.LabelAlignment{:}, style.BoldFont{:}, 'FontSize', def.FontSize+3, style.TextColor{:}}; %...

style.PlotStyle  = {'LineSmoothing','on'};

style.BarStyle     = {style.BoldFont{:}, 'FontSize', def.FontSize, style.BoldWeight{:}, 'Projection', 'orthographic', 'Box','off'};
style.GridStyle    = {'GridLineStyle', ':', 'MinorGridLineStyle','-', ...
  'XColor',def.GridColor, 'YColor',def.GridColor, 'ZColor',def.GridColor};
style.AxesStyle    = {'Clipping', 'off', 'Color', [1 1 1] .* 0.95, 'Box', 'off', style.BoldFont{:}, 'FontSize', def.FontSize, style.GridStyle{:}};
style.SurfStyle    = {'EdgeColor', 'none'};
style.ZoneStyle    = {'LineStyle',':', 'FaceColor', 'none', 'LineWidth', 0.25};

exporting.Scale        = 1.25;
exporting.Border = 20;

fields = {'RelativeMean', 'RelativePeakLimit', 'DeltaLimit'}; % , 'Mean'
nSheets   = supStatPlots.sheets + 1;
nFields   = numel(fields);


fHightDiff = 0;
if (~isExporting)
%   jFrame = get(handle(gcf),'JavaFrame');
%   jFrame.setMaximized(true);
  drawnow;
	pause(2);
%   fPos = get(hFig,'Position');

  fPos = get(hFig,'Position');
  fOut = get(hFig,'OuterPosition');
  fBorders = fOut - fPos;

  sPos = get(0,'ScreenSize');
  fWidth = sPos(3); %fPos(3);
  fHeight = ceil(fWidth/nFields) + fHightDiff;
  fTop = fBorders(2) + (sPos(4)-fHeight)/2;
  fPos = [0 fTop fWidth fHeight];
  fPos(4) = fHeight;
else
  fWidth = 1600;
  fHeight = ceil(fWidth/nFields) + fHightDiff;
  fPos = [0 0 fWidth fHeight];
end
set(hFig,'position',fPos);
drawnow;
pause(2);

runName = supMat.sourceTicket.folder.name;

clear zData*

dint = 1.5;

amin(1:numel(fields)) = 100;
amax(1:numel(fields)) = 0;

iX1 = 0; iX2 = 0; iY1 = 0; iY2 = 0;
% nMasks    = size(statMasks,1);

sheetIndex    = evalin('base','supData.sheetIndex');
sheetMax = max(sheetIndex);

if (isExporting)
  clear M;
  M(1:sheetMax+1) = struct('cdata', [], 'colormap', []);
end


stepTimer = tic; runlog([TABS 'Preparing ']);  fstring = '';

surfDataStruct = struct('fieldName', {}, ...
  'sheets', {},'masks', {},'rows', {},'columns', {}, ...
  'data', {},'dataMean', {},'dataStDev', {},'dataLimit', {},'dataRange', {}, ...
  'regionMean', {},'regionStDev', {},'regionCentres', {},'regionAreas', {}, ...
  'regionMasks', {}); %, ...
%   'summaryData', {}, ...
%   'patchData', {});

tStrings = cell(nFields, nPlotTypes); %, nMasks, nSheets);

hText = zeros(nFields, nPlotTypes, 25);
pText = zeros(nFields, nPlotTypes, 25, 2);
hCB   = zeros(nFields, nPlotTypes);
hAxes = zeros(nFields, nPlotTypes);
hSurf = zeros(nFields, nPlotTypes);
hPlots = zeros(nFields);
hTitles = zeros(nFields);

dLims = zeros(nFields, nPlotTypes, 2);
cLims = zeros(nFields, nPlotTypes, 2);

surfData = surfDataStruct;

%% Prepare Colormap
% cMap      = [ 1.00  1.00  1.00      % Unscaled map
%               0.90  0.90  0.90
%               0.80  0.80  0.80
%               0.70  0.70  0.70
%               0.60  0.60  0.60              
%               0.50  1.00  0.50      % cKeyColor
%               0.40  0.40  0.40
%               0.30  0.30  0.30
%               0.20  0.20  0.20              
%               0.10  0.10  0.10
%               0.00  0.00  0.00  ]; 
            
cMap    = [ 0.00  1.00  0.00
            1.00  1.00  0.00
            1.00  0.00  0.00];

cMap    = [ 1.00  1.00  1.00
            1.00  0.00  0.00];
            
cMap2   = vertcat(flipud(cMap), cMap(2:end, :));
            

cSteps  = size(cMap,1);
cMap    = interp1(0:cSteps-1,cMap,0:(cSteps-1)/(64-1):cSteps-1);

cSteps  = size(cMap2,1);
cMap2   = interp1(0:cSteps-1,cMap2,0:(cSteps-1)/(64-1):cSteps-1);

%% Create Subplots

for f = 1:nFields
  hPlots(f) = subaxis(1,nFields,f, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0.03);%subplot(1,nFields,f);
%   drawnow;

%   set(hPlots(f),'Position',pPos);  
  
  for p = 1:nPlotTypes %plotType = plotTypes
    plotType = plotTypes{p}; %char(plotType);
    isLastPlotType   = p==nPlotTypes; % strcmpi(plotType, plotTypes(end));
    
    nMasks    = size(stats.(plotType).Masks,1);
    
    field = char(fields(f));
    
    fupdate = [plotType ' ' field ' ' int2str(f) ' / ' int2str(nFields)] ;
    runlog(repmat('\b',1,numel(fstring)));
    fstring = fupdate;
    runlog(fstring);
    
    mergedSurfs = Stats.supMergeSurfs( stats.(plotType).Surfs, stats.(plotType).Masks, field);
    surfData(f,p) = mergedSurfs;
    
    fMean = nanmean(surfData(f,p).regionMean(:));
    fStd = nanmean(surfData(f,p).regionStDev(:));
    
    isDelta  = numel(field)>=5 && strcmpi(field(1:5),'Delta');
    isMean   = strcmpi(field,'Mean');  % ~isempty(regexpi(field,'mean'));
    isUpperLimit   = strcmpi(field,'UpperLimit');
    isLowerLimit   = strcmpi(field,'LowerLimit');
    isRelative = ~isempty(regexpi(field,'relative'));
    
    isLabelField  = true;
    
    
    %     zLabel = [plotType 'ZData' field];
    zLabel = ['zData' upper(plotType(1)) lower(plotType(2:end)) field];
    zData = surfData(f,p).data(:,:,1);
    
    cmap = cMap2;
    
    if(isDelta)
      dlim = [0 10];
      clim = [-10 10];
    elseif isMean || isUpperLimit || isLowerLimit
      dlim = surfData(f,p).dataRange;
      clim = dlim; % [min(dlim)-(diff(dlim)) max(dlim)]; 
    elseif isRelative
      dlim = [-5 +5];
      clim = [-5 +5];
    else
      clear('clim', 'dlim');
    end
    
    opt dLims(f,p,:)  = dlim;
    opt cLims(f,p,:) 	= clim;
    opt colormap(cmap);
    
    eval([zLabel '=zData;']);
    
    %% Create the plot
    
    clear plotSpecs;
    try
      plotSpecs = plotting.Specs(p);
    catch err
      disp err;
    end
        
    hold all;
    
    if (p==1)
      hSurf(f,p) = surf(zData,'ZDataSource',zLabel, style.SurfStyle{:});
      hAxes(f,p) = gca;
      
      set(hAxes(f,p),style.AxesStyle{:});
%       daspect([1 1 1]); % daspect([100 100 20]);
      view([0, 90]);
      
      xlim([1 surfData(f,p).columns]);
      ylim([1 surfData(f,p).rows]);
      
      drawnow;
      pause(0.001);      
      
    else
      pHandle = hAxes(f,p);
      set(hFig,'CurrentAxes',pHandle);
%       axes(pHandle);
      if (numel(zData)>1)
        hSurf(f,p) = surf(zData,'ZDataSource',zLabel, style.SurfStyle{:});
      elseif numel(zData)==1
%         hSurf(f,p) = surf([xlim, ylim, zData zData],'ZDataSource',zLabel, style.SurfStyle{:});
        [pX pY pZ] = meshgrid(xlim, ylim, 1);
        hSurf(f,p) = surf(pX,pY,pZ.*zData,style.SurfStyle{:});
%         hSurf(f,p) = patch(patchX, patchY,zData,style.SurfStyle{:}); % 'ZDataSource',zLabel;
      end
    end
    
    %     hSurf(f,p) = surf(zData,'ZDataSource',zLabel, style.SurfStyle{:}); ...
    %       hold all;
    paHandle = hAxes(f,p);
    
    plotSpecs.secondarySize = [20 20];
    plotSpecs.paddingSize = [10 10];
    
    %% Optimize Dimensions
%     if (nPlotTypes>1)
      paUnits = get(paHandle, 'Units');
      set(paHandle, 'Units', 'pixels');
      
      if (p==1) % 'Placement'
        % Determine optimal plot dimensions
        paPos   = get(hAxes(f,p), 'Position');
        paOff   = paPos(1:2);
        
        paSlices = reshape([plotting.Specs(:).Placement],2,[])';
        
        paSlices = [any(paSlices(:,1)==0) && any(paSlices(:,1)~=0) ...
          any(paSlices(:,2)==0) && any(paSlices(:,2)~=0)];
        
        paShrink = [plotSpecs.secondarySize + plotSpecs.paddingSize] .* paSlices;
        
        paPos2  = [paPos(1:2) paPos(3:4)];
        
        paRC = [surfData(f,p).columns surfData(f,p).rows];
        
        ratRC = paPos2(3:4)'./paRC(:);
        
        pUnits = get(hPlots(f),'Units');
        set(hPlots(f),'Units','pixels');
        pPos = get(hPlots(f),'Position');
        set(hPlots(f),'Units',pUnits);
                
        % Row/Column Ratio
        if (ratRC(1)>paRC(2))
          paPos2(3) = paRC(1)*ratRC(2);
        else
          paPos2(4) = paRC(2)*ratRC(1);
        end
        
        % Plot Fitting
        ratPa = (pPos(4)-100)/paPos2(4);
        if (ratPa<1.0)
          paDim2 = paPos2(3:4).*ratPa;
          paPos2(3:4) = paDim2;
        end
        
        % Plot Centering
        paPos2(1) = paOff(1)  +  0  + (pPos(3)-paPos2(3))/2;  % paPos2(1)*ratRC(1)/ratRC(2);
        paPos2(2) = paOff(2)  + 25  + (pPos(4)-paPos2(4))/2; %(pPos(4)-paPos2(4))/2;  % paPos2(2)*ratRC(2)/ratRC(1);
        
        paPos  = paPos2;
        
        paPos3 = [paPos2(1:2) paPos2(3:4)-paShrink];
        ratRC2 = paPos2(3:4) ./ paPos3(3:4);
        paPos2 = paPos3;        
        plotting.Specs(1).Position = paPos;
        
        set(paHandle, 'Position', paPos2);
        
        titleX = (max(xlim)-min(xlim))/2*ratRC2(1); titleY = (max(ylim)+1)*ratRC2(2); % set(hTitles(1), 'Position', [titleX titleY]);
        titlePos = [pPos(3)/2 paPos2(4)+10+paShrink(2), 0];
        titleString = [runName TAB field TAB int2str(supPatchValue) '%'  TAB int2str(1)]; style.TitleStyle{:};
        titleStyle = {style.TitleStyle{:}, ... %'Units','Pixels', 'Position', titlePos, ...
          'HorizontalAlignment','center','VerticalAlignment','bottom'};
        hTitles(f) = text(titleX,titleY, titleString, titleStyle{:});

        
        % Determine optimal secondary plot dimensions
        for p2 = 2:nPlotTypes
          
          p1pos = paPos2;
          p2Place = plotting.Specs(p2).Placement;
          p2Dim = plotSpecs.secondarySize;
          p2Pad = plotSpecs.paddingSize;
          p2Size = p2Dim.*p2Place + p1pos(3:4).*~p2Place;
          p2Loc = p1pos(1:2) + ((p1pos(3:4)+p2Pad).*p2Place);
          p2Pos = [p2Loc p2Size];
          plotting.Specs(p2).Position = p2Pos;
          
          
          axes('Units', 'pixels', 'Position', p2Pos, 'XTickLabel', [], 'YTickLabel', []);
          hold all;
          
          hAxes(f,p2) = gca;
          
          if(p2Place(1)==1)
            set(hAxes(f,p2),'YAxisLocation', 'right');
          end          
          
          if(p2Place(2)==1)
            set(hAxes(f,p2),'XAxisLocation', 'top');
          end
          
%           daspect(hAxes(f,p2),[1 1 1]);
          
          set(hAxes(f,p2), 'Units', paUnits);
          
          set(hAxes(f,p2),style.AxesStyle{:});
          view(hAxes(f,p2),[0, 90]);
          
          paRC = [surfData(f,p).columns surfData(f,p).rows];
          paRC(p2Place==1) = 2;
          
          xlim(hAxes(f,p2),[1 paRC(1)]);
          ylim(hAxes(f,p2),[1 paRC(2)]);
 
        end     
        
      end
      
      set(paHandle, 'Units', paUnits);
%     end
    
          drawnow;
          pause(0.001);          
%           [plotting.Specs(:).Position]         
    set(hFig,'CurrentAxes',hAxes(f,p)); % axes(hAxes(f,p));
    
    opt zlim(dlim);
    opt caxis(clim);
    
%     colormap(cMap);
    
    try
      cbSpec = plotSpecs.ColorBar;
      
      if ~isempty(cbSpec)
        
        hCB(f,p) = colorbar(cbSpec, style.BarStyle {:}); %, 'LineWidth', def.LineWidth + 0.5);
        
        try
          xlim(hCB(f,p),dlim);
        catch err
          disp(err);
        end
        
        cbUnits = get(hCB(f,p),'Units');
        set(hCB(f,p),'Units','pixels');
        cbPos = get(hCB(f,p),'Position');
        cbExt = get(hCB(f,p),'OuterPosition');
        opt cbPos(4) = 4; ...
        opt cbPos(3) = paPos(3); %cbPos(3)-2;        
        opt cbPos(1) = paPos(1); ...
        opt cbPos(2) = cbPos(2) - 50; ...
        set(hCB(f,p),'Position', cbPos); ...
          set(hCB(f,p), 'Units', cbUnits);
%         xlim(hCB(f,p))
      end
    catch err
      disp err;      
    end
    
    opt grid(plotSpecs.Grid);
    
    for m = 1:nMasks
      
      fupdate = [plotType ' ' field ' ' int2str(f) ' / ' int2str(nFields) ' subset ' int2str(m) ' / ' int2str(nMasks)] ;
      runlog(repmat('\b',1,numel(fstring)));
      fstring = fupdate;
      runlog(fstring);
      
      tZ            = 101;
      tX            = surfData(f,p).regionCentres(m,1); ...
        tY          = surfData(f,p).regionCentres(m,2); ...
        tW          = surfData(f,p).regionAreas(m,1); ...
        tH          = surfData(f,p).regionAreas(m,2);
      
      if (tX>max(xlim))
        tX = min(xlim) + (max(xlim)-min(xlim))/2;
      end
      
      if (tY>max(ylim))
        tY = min(ylim) + (max(ylim)-min(ylim))/2;
      end
      
      pText(f,p,m,1:2) = [tX tY];
      
      hText(f,p,m)  = text(tX,tY,tZ,'##', style.LabelStyle{:});
      
      try
        tEx = num2cell(get(hText(f,p,m),'Extent'));
        [eL, eB, eW, eH] = deal(tEx{:});
        when [eW>tW*1.25] set(hText(f,m),'VerticalAlignment', resolve(rem(m,2)==1,'top','bottom'));
        when [eH>tH*1.25] set(hText(f,m),'HorizontalAlignment', resolve(rem(m,2)==1,'left','right'));
      end
      
      try
        for s = 1:nSheets
          tMean           = surfData(f,p).regionMean(m,s);
          tStDev          = surfData(f,p).regionStDev(m,s);
          %           tV              = ['' int2str(tMean)];
          %           tV = strtrim(strrep(int2str(tMean),'NaN',''));
%           tStrings(f,p,m,s) = {strtrim(strrep(int2str(tMean),'NaN',''))};
          tStrings(f,p,m,s) = {strtrim(strrep(sprintf('%2.1f',tMean),'NaN',''))};
        end
        
        set(hText(f,p,m),'String', char(tStrings(f,p,m,1)));
      catch err
        disp err;        
      end

    end
  end
  
  for p = 1:nPlotTypes %plotType = plotTypes
  end
  
  runlog(repmat('\b',1,numel(fstring)));
  fstring = '';
  runlog([field resolve(f==nFields, ' ', ', ')]);
  
  %   runlog([plotType resolve(isLastPlotType, ' ', ', ')]);
  
  %   plottingStruct.tStrings = tStrings;
  %   plottingStruct.hText    = hText;
  %   plottingStruct.hSurf    = hSurf;
  %   plottingStruct.hAxes    = hAxes;
  %   plottingStruct.hCB      = hCB;
  %   plottingStruct.dLims    = dLims;
  %   plottingStruct.cLims    = cLims;
  %   plottingStruct.surfData = surfData;
  
  % tStrings = cell(nFields, nPlotTypes, nMasks, nSheets);
  %
  % hText = zeros(nFields, nPlotTypes, nMasks);
  % hCB   = zeros(nFields, nPlotTypes);
  % hAxes = zeros(nFields, nPlotTypes);
  % hSurf = zeros(nFields, nPlotTypes);
  %
  % dLims = zeros(nFields, nPlotTypes, 2);
  % cLims = zeros(nFields, nPlotTypes, 2);
  
  
  %   if numel(plotTypes)>1
  %     plotting.(plotType) = plottingStruct
  %   else
  %     plotting = plottingStruct;
  %   end
  
  %   plotting.(plotType) = plottingStruct;
  %   clear plottingStruct;
  
end

drawnow;


plotting.tStrings = tStrings;
plotting.hText    = hText;
plotting.hSurf    = hSurf;
plotting.hAxes    = hAxes;
plotting.hCB      = hCB;
plotting.hPlots   = hPlots;
plotting.dLims    = dLims;
plotting.cLims    = cLims;
plotting.surfData = surfData;

runlog(['... OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);

% return;

%% Optimize plot limits
stepTimer = tic; runlog([TABS 'Optimizing plot limits ']);

dLims = zeros(nPlotTypes*nFields,2) * NaN;
cLims = zeros(nPlotTypes*nFields,2) * NaN;

for p = 1:nPlotTypes%plotType = plotTypes
  plotType = plotTypes{p};
  r = (((p-1) * nFields)+1):(p * nFields);
  dLims(r, :) = squeeze(plotting.dLims(:,p,:));
  cLims(r, :) = squeeze(plotting.cLims(:,p,:));
end

dlim = [floor(nanmin(dLims(:)))-1 ceil(nanmax(dLims(:)))+1];
% dlim = [0:100];
clim = [floor(nanmin(cLims(:)))-1 ceil(nanmax(cLims(:)))+1];

dMean = nanmean(dLims(:));
clim = [round(dMean)-5-10 round(dMean)+5];
cxlim = [round(dMean)-5 round(dMean)+5];

% cxlim = [dlim] + [+1 -1];

cform = makecform('srgb2xyz');
% cmaps = cell(nFields,1);

drawnow;

cmap1     = colormap(cMap); %get(gcf,'Colormap');
cmap1     = applycform(cmap1,cform);

cmap2     = colormap(cMap2);
cmap2     = applycform(cmap2,cform);

cmap      = cmap2;

% hAxes(1:end) = findobj(hFig,'type','axes');

for f = 1:nFields
  subplot(hPlots(f)); hold all;
  for p = 1:nPlotTypes
%     axes(hAxes(f,p));
    
    
    %% Set range for non-delta
    field = char(fields(f));
    
%     subplot(nPlotTypes,nFields,((p-1) * nFields) + f); ...
%       hold all;
    
%     try
%       cmaps{f,p}  = cmap;
%     catch err
%       disp(err);
%     end
    
    
    isMean   = strcmpi(field,'Mean'); % ~isempty(regexpi(field,'mean'));
    isUpperLimit   = strcmpi(field,'UpperLimit');
    isLowerLimit   = strcmpi(field,'LowerLimit');
    isRelative = ~isempty(regexpi(field,'relative'));
    
    if (isMean || isUpperLimit || isLowerLimit)
%       zlim(hAxes(f,p), dlim);
%       caxis(hAxes(f,p),clim);
      set(hAxes(f,p),'ZLim',dlim);
      set(hAxes(f,p),'CLim',clim);
      
      if (hCB(f,p)>0)
        set(hCB(f,p), 'XLim', cxlim);
      end
    end
    
    try
      if (hCB(f,p)>0)
        cbLims = get(hCB(f,p), 'XLim');
        cbMin = floor(min(cbLims));
        cbMax = ceil(max(cbLims));
        cbDiff = cbMax-cbMin;

        cbTicks = get(hCB(f,p), 'XTick');

        if(cbDiff >= 8)
          cbTicks = cbMin:2:cbMax;
        elseif(cbDiff < 8 && cbDiff >= 4)
          cbTicks = cbMin:1:cbMax;
        elseif(cbDiff < 4 && cbDiff >= 2)
          cbTicks = cbMin:0.5:cbMax;
        elseif (cbDiff < 2)
          cbTicks = cbMin:0.25:cbMax;
        end

        set(hCB(f,p), 'XTick', cbTicks);
      end
    catch err
            disp(err);
    end
  end
  drawnow;
  runlog(['.']);
end
runlog([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);

refreshdata;
drawnow;
pause(0.001);

if (exportVideo || exportPng)
  stepTimer = tic; runlog([TABS 'Determining crop box and frame scaling dimensions ']);
  
  img = print2array(hFig, exporting.Scale);
  
  runlog(['.']);
  
  mImg = mean(img,3);
  mIX = mean(mImg,1);
  mIY = mean(mImg,2);
  
  runlog(['.']);
  
  iY1 = find(mIY~=255, 1, 'first');
  iX1 = find(mIX~=255, 1, 'first');
  iY2 = find(mIY~=255, 1, 'last');
  iX2 = find(mIX~=255, 1, 'last');
  
  runlog(['.']);
  
  iY1 = max(iY1-exporting.Border,1);
  iX1 = max(iX1-exporting.Border,1);
  iY2 = min(iY2+exporting.Border,size(img,1));
  iX2 = min(iX2+exporting.Border,size(img,2));
  runlog([' ' int2str(iX2-iX1) 'x' int2str(iY2-iY1) '/' num2str(exporting.Scale) ' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
end

if (isExporting)
  exporting.path = fullfile(cd, 'output',['statsVideo-' datestr(now, 'yymmdd')]);
  exporting.name = lower([runName '-' plotMode '-' int2str(supPatchValue)]);
  exporting.file = fullfile(exporting.path, exporting.name);
end

if (isExporting && exists('mTree'))
  fid = fopen(fullfile(exporting.path, [runName '.log']),'w');
  for row = 1:size(mTree,1)
    fprintf(fid,'%s\n', mTree(row,:));
  end
  fclose(fid);
  clear mTree;
end


if (exportPng || exportEps)
  warning off MATLAB:MKDIR:DirectoryExists;
  opt mkdir (exporting.file);
  warning on MATLAB:MKDIR:DirectoryExists;
end

if (exportPng)
  htmlIndex = '';
end


stepTimer = tic; runlog([TABS 'Rendering sheets ']);

fstring = '';

tStrings = plotting.tStrings;
hText = plotting.hText;
hSurf = plotting.hSurf;
hAxes = plotting.hAxes;
hCB  = plotting.hCB;
% plotting.dLims    = dLims;
% plotting.cLims    = cLims;
% plotting.surfData = surfData;

sIndex = 0;
for s = [1:nSheets]
  
  fupdate = [int2str(s) ' / ' int2str(nSheets)] ;
  runlog(repmat('\b',1,numel(fstring)));
  fstring = fupdate;
  runlog(fstring);
  
  if (isnumeric(sIndex))
    sName = int2str(sIndex+1);
  else
    sName = upper(sIndex);
  end
  
  for p = 1:nPlotTypes
    plotType = plotTypes{p};
    isLastPlotType   = p==nPlotTypes;
    
    for f = 1:nFields
      field = char(fields(f));
      
      isRelative = ~isempty(regexpi(field,'relative'));
      
%       if (isRelative)
%         cmap = cmap2;
%       else
%         cmap = cmap1;
%       end

      
      subplot(hPlots(f)); %1,nFields,f); hold all; 
      hold all;
      
%       subplot(nPlotTypes,nFields,((p-1) * nFields) + f); ...
%         hold on;
      if (p==1)
        set(hTitles(f),'String', [runName TAB field TAB int2str(supPatchValue) '%'  TAB sName], style.TitleStyle{:});
%         title([runName TAB field TAB int2str(supPatchValue) '%'  TAB int2str(sIndex+1)], style.TitleStyle{:});
      end
      
      zData = surfData(f,p).data(:,:,s);
           
      clim = caxis;
      cmin = min(clim);
      cmax = max(clim);
      cdiff = abs(cmax-cmin);
      
      zData(zData>cmax) = cmax;
      zData(zData<cmin) = cmin;
      
      if numel(zData)>1
%         hSurf(f,p) = surf(zData,'ZDataSource',zLabel, style.SurfStyle{:});
      elseif numel(zData)==1
%         hSurf(f,p) = patch(xlim, ylim,zData,style.SurfStyle{:}); % 'ZDataSource',zLabel;
        zcurr = get(hSurf(f,p),'ZData');
        %[pX pY pZ] = meshgrid(xlim, ylim, 1);
%         hSurf(f,p) = surf(pZ.*zData,style.SurfStyle{:});        
        set(hSurf(f,p),'ZData', pZ.*zData);
      end      
      
%       cmap = cmaps{f,p};
      csteps = size(cmap,1);
      cx = interp1([1 csteps], [cmin cmax],1:csteps);%cmin:cdiff/(csteps-1):cmax;
      
      zLabel = ['zData' upper(plotType(1)) lower(plotType(2:end)) field];
      eval([zLabel '=zData;']);
      
      nMasks = surfData(f,p).masks;%size(stats.(plotType).Masks,1);
      
      for m = 1:nMasks
        set(hText(f,p,m),'String', char(tStrings(f,p,m,s)));
        set(hText(f,p,m),'Units','data');
        tPos = get(hText(f,p,m),'Position');
        tC = 'k';
        try
          tV = floor(surfData(f,p).regionMean(m,s));
          
          zX = round(pText(f,p,m,2));        % surfData(f,p).regionCentres(m,1); % tPos(2)
          zY = round(pText(f,p,m,1));       % surfData(f,p).regionCentres(m,2); % tPos(1)
          
          zV = tV; %floor(zData(zX,zY));

          zC = interp1(cx(:),cmap(:,1),zV);
          zT = 0.33; % 0.33
          when [zC<zT] tC = "w";
         catch err
           disp(err);
        end
        set(hText(f,p,m),'color', tC);
      end
      
    end
  end
  
  refreshdata;
  
  if (exportVideo || exportPng)
    
    imgSrc = print2array(hFig, exporting.Scale);
    imgSrc = imgSrc(iY1:iY2,iX1:iX2,:);
    img = imgSrc;

    img = imresize(img,1/exporting.Scale,'Dither',true, 'Method', 'lanczos3'); %, 'Antialiasing', false);
    frm = im2frame(img);
  end
  
  if (exportVideo)
    if (isnumeric(sIndex))
      for fIndex = sIndex+1:sheetIndex(s)
        M(fIndex) = frm;
      end
    else
      M(numel(M)) = frm;
    end
  end
  
  if (exportPng | exportEps)
    if (isnumeric(sIndex))    
      exporting.imagename = [exporting.name '-' sprintf('%03i',sheetIndex(s)  )];
    else
      exporting.imagename = [exporting.name '-' sName];
    end
  end
  
  if (exportPng)
    imwrite(imgSrc, fullfile(exporting.file, [exporting.imagename '.png']),'png');
    exporting.imagehtml = strcat('<img src="', [exporting.imagename '.png'], '" />', '<br />', '\n');
    
    if (isnumeric(sIndex))
      htmlIndex = strcat(htmlIndex,exporting.imagehtml);
    else
      htmlIndex = strcat(exporting.imagehtml, htmlIndex);
    end
  end
  
  if (exportEps)
    print2eps(fullfile(exporting.file,[exporting.imagename]),hFig); %, '-dpdf');
  end
  
  if (~isExporting)
    pause(0.001);
%     drawnow;
  end
  
  if (s>=numel(sheetIndex))
    sIndex = 'sum';
  else
    sIndex=sheetIndex(s);
  end
  
end

runlog(repmat('\b',1,numel(fstring)));
fstring = '';

runlog(['... OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);



if (exportPng)
  stepTimer = tic; runlog([TABS 'Exporting HTML Index ...']);
%   htmlIndex = '<html><body>\n';
%   for s = 1:nSheets
%     exporting.imagename = [exporting.name '-' sprintf('%03i',sheetIndex(s)  )];
%     htmlIndex = strcat(htmlIndex,[exporting.imagename '.png'],'\n');
%   end
  htmlIndex = strcat('<html><body>\n', htmlIndex,'<html><body>');

  % call fprintf to print the updated text strings
  exporting.indexfile = fullfile(exporting.file, 'index.html');
  fid = fopen(exporting.indexfile,'wt');
  fprintf(fid, htmlIndex);
  fclose(fid);
  runlog([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
end

if (exportVideo)
  stepTimer = tic; runlog([TABS 'Exporting ']); % int2str(nSheets) ' sheets / ' int2str(numel(M)) ' frames to ' exporting.aviName ' ']);
  
  %   try
%   err = opt('close(mVideoWriter)');
%   
%   mVideoWriter = VideoWriter(exporting.file,'Motion JPEG AVI');  % runlog(['.']);
% %   pause(3);
%   mVideoWriter.FrameRate = 10;
%   mVideoWriter.Quality = 100;
%   open(mVideoWriter); % runlog(['.']);
%   
%   nFrames = numel(M);
%   for m = 1:numel(M)
%     fupdate = ['frame ' int2str(m) ' of ' int2str(nFrames)];
%     runlog(repmat('\b',1,numel(fstring)));
%     fstring = fupdate;
%     runlog(fstring);
%     
%     writeVideo(mVideoWriter,M(m)); %runlog(['.']);
%     
%   end
%   close(mVideoWriter);
%   
%   runlog(repmat('\b',1,numel(fstring)));

  mVideoWriter = Video.writeVideo(exporting.file, M);
  
  runlog([int2str(nSheets) ' sheets / ' int2str(numel(M)) ' frames to ' exporting.name ' ']);
  
  
  runlog([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
  
  if (ismac)
    stepTimer = tic; runlog([TABS 'Encoding QuickTime Movie ...']);
    avifile = fullfile(mVideoWriter.Path, mVideoWriter.Filename);
    if (Video.encodeMov(avifile)==0)
      trashpath=fullfile(getenv('HOME'),'.Trash');
      movefile(avifile,[trashpath filesep]);
    end
    runlog([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
  end
  
  
  close gcf;
end

runlog([TABS '>> ' runMode ' ' strPlotType ' Successful! \t\t' num2str(toc(roundTimer)) '\t seconds\n']);

