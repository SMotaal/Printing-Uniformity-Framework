roundTimer = tic; roundActions=0; close all;

%% Prepare Log
runlog(fullfile('output','testStats.log'),'optional');
runlog('\n');

%% Constants
TAB          = '     ';
TABS = TAB;

%% Load & Interpolate Source Uniformity Data
when [~exists('supData') && ~exists('source')] source = "ritsm7402a";

try
  if(exists('source'))
    supFilePath = datadir('uniprint',source);
    runName = whos('-file', supFilePath);
    runName = runName.name;
    stepTimer = tic; runlog(['Loading ' runName ' uniformity data ...']);
    supLoad(supFilePath); click roundActions;
    runlog([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
    newPatchValue = 100;
    clear source;
  end
  
  runName = supMat.sourceTicket.folder.name;
catch err
  warning('UPStats:UPMatrix', 'Invalid uniformity data structure.');
end

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
  supInterp; click roundActions;
  runlog([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
  
  clear supStatPlots;
end

%% Defaults & Settings
default exportVideo false;
default exportPng false;
default exportEps false;
default plotType "region";  % 'z;one';  % 'axial';
default plotMode "single";

clear plotting stats;

isRegionMode = (strcmpi(plotMode,'regions'));
if isRegionMode
  plotTypes = {'region', 'axial', 'circumferential', 'sheet'};
  plotUnits = 'pixels';
  plotting.Specs = struct( ...
    'Dimensions',   {[0, 0],          [0,50],     [50, 0],    [50, 50]        }, ...
    'Offset',       {[0,0,-50,-50],   [],         [],         []              }, ...
    'Placement',    {[0,0],           [0,1],      [1,0],      [1,1]           }, ...
    'ColorBar',     {[],              [],         [],         'SouthOutside'  }, ...
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
  supStatPlots = supPlotStats(supPlotData, supData); click roundActions;
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

isExporting = (exportVideo || exportEps || exportPng);
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

def.GridColor    = [1,1,1].*0.5;

def.TextFont   = 'Helvetica'; %'Gill Sans';
def.BoldFont   = 'Helvetica Bold'; %defTextFont;
def.BoldWeight = 'bold';
def.TextColor  = 'k';

style.TextFont     = {'FontName',   def.TextFont};
style.TextColor    = {'Color', def.TextColor};
style.BoldFont     = {'FontName',   def.BoldFont}; %[style.TextFont ' Bold']; %'Helvetica Bold'
style.BoldWeight   = {'FontWeight', def.BoldWeight};
style.LabelAlignment = {'HorizontalAlignment','center','VerticalAlignment','middle'};

style.TitleStyle   = {style.BoldFont{:}, 'FontSize', 12, style.BoldWeight{:}, style.TextColor{:}};
style.LabelStyle   = {style.LabelAlignment{:}, style.BoldFont{:}, 'FontSize', 11, style.BoldWeight{:}, style.TextColor{:}}; %...

style.BarStyle     = {style.BoldFont{:}, 'FontSize', 10, style.BoldWeight{:}, 'Projection', 'Perspective'};
style.GridStyle    = {'GridLineStyle', ':', 'MinorGridLineStyle','-', ...
  'XColor',def.GridColor, 'YColor',def.GridColor, 'ZColor',def.GridColor};
style.AxesStyle    = {style.BoldFont{:}, 'FontSize', 12, style.BoldWeight{:}, style.GridStyle{:}};
style.SurfStyle    = {'EdgeColor', 'none'};
style.PlotStyle  = {'LineSmoothing','on'};
style.ZoneStyle    = {'LineStyle',':', 'FaceColor', 'none', 'LineWidth', 0.25};

exporting.Scale        = 1.25;
exporting.Border = 20;

if (~isExporting)
  jFrame = get(handle(gcf),'JavaFrame');
  jFrame.setMaximized(true);
else
  set(hFig,'position',[0 0 1600 1600]);
end

fields = {'LowerLimit', 'UpperLimit', 'Mean', 'DeltaLimit'};

runName = supMat.sourceTicket.folder.name;

clear zData*

dint = 1.5;

amin(1:numel(fields)) = 100;
amax(1:numel(fields)) = 0;

iX1 = 0; iX2 = 0; iY1 = 0; iY2 = 0;

nSheets   = supStatPlots.sheets;
nFields   = numel(fields);
% nMasks    = size(statMasks,1);

sheetIndex    = evalin('base','supData.sheetIndex');
sheetMax = max(supData.sheetIndex(:));

if (isExporting)
  clear M;
  M(1:sheetMax) = struct('cdata', [], 'colormap', []);
end


stepTimer = tic; runlog([TABS 'Preparing ']);  fstring = '';

surfDataStruct = struct('fieldName', {}, ...
  'sheets', {},'masks', {},'rows', {},'columns', {}, ...
  'data', {},'dataMean', {},'dataStDev', {},'dataLimit', {},'dataRange', {}, ...
  'regionMean', {},'regionStDev', {},'regionCentres', {},'regionAreas', {}, ...
  'regionMasks', {}, ...
  'summaryData', {}, ...
  'patchData', {});

tStrings = cell(nFields, nPlotTypes); %, nMasks, nSheets);

hText = zeros(nFields, nPlotTypes);
hCB   = zeros(nFields, nPlotTypes);
hAxes = zeros(nFields, nPlotTypes);
hSurf = zeros(nFields, nPlotTypes);

dLims = zeros(nFields, nPlotTypes, 2);
cLims = zeros(nFields, nPlotTypes, 2);

surfData = surfDataStruct;

for f = 1:nFields
  for p = 1:nPlotTypes %plotType = plotTypes
    plotType = plotTypes{p}; %char(plotType);
    isLastPlotType   = p==nPlotTypes; % strcmpi(plotType, plotTypes(end));
    
    nMasks    = size(stats.(plotType).Masks,1);
    
    try
      plotSpecs = plotting.Specs(p);
    end
    
    field = char(fields(f));
    
    fupdate = [plotType ' ' field ' ' int2str(f) ' / ' int2str(nFields)] ;
    runlog(repmat('\b',1,numel(fstring)));
    fstring = fupdate;
    runlog(fstring);
    
    surfData(f,p) = supMergeSurfs( stats.(plotType).Surfs, stats.(plotType).Masks, field);
    
    fMean = nanmean(surfData(f,p).regionMean(:));
    fStd = nanmean(surfData(f,p).regionStDev(:));
    
    isDelta  = numel(field)>=5 && strcmpi(field(1:5),'Delta');
    isMean   = strcmpi(field,'Mean');
    isUpperLimit   = strcmpi(field,'UpperLimit');
    isLowerLimit   = strcmpi(field,'LowerLimit');
    
    isLabelField  = true;
    
    
    %     zLabel = [plotType 'ZData' field];
    zLabel = ['zData' upper(plotType(1)) lower(plotType(2:end)) field];
    zData = surfData(f,p).data(:,:,1);
    
    if(isDelta)
      dlim = [0 10];
      clim = [0 10];
      
      dLims(f,p,:) = NaN;
      cLims(f,p,:) = NaN;
      
    elseif isMean || isUpperLimit || isLowerLimit
      dlim        = surfData(f,p).dataRange;
      clim        = surfData(f,p).dataRange;
      
      dLims(f,p,:)  = dlim;
      cLims(f,p,:) 	= clim;
    else
      clear('clim', 'dlim');
    end
    
    eval([zLabel '=zData;']);
    
    subplot(nPlotTypes,nFields,((p-1) * nFields) + f); ...
      hold off;
    
    hSurf(f,p) = surf(zData,'ZDataSource',zLabel, style.SurfStyle{:}); ...
      hold on;
    
    hAxes(f,p) = gca;
    
    title([runName TAB field TAB int2str(supPatchValue) '%'  TAB int2str(1)], style.TitleStyle{:});
    
    set(gca,style.AxesStyle{:});
    daspect([100 100 20]);
    view([0, 90]);
    
    xlim([1 surfData(f,p).columns]);
    ylim([1 surfData(f,p).rows]);
    
    opt zlim(dlim);
    opt caxis(clim);
    
    colormap('Jet');
    
    try
      cbSpec = plotting.Specs(p).ColorBar;
      
      if ~isempty(cbSpec)
        
        hCB(f,p) = colorbar(cbSpec, style.BarStyle {:}); %, 'LineWidth', def.LineWidth + 0.5);
        
        cbUnits = get(hCB(f,p),'Units');
        set(hCB(f,p),'Units','pixels');
        cbPos = get(hCB(f,p),'Position');
        cbPos(2) = cbPos(2) - 40; ...
          cbPos(4) = 5; ...
          cbPos(3) = cbPos(3)-2;
        set(hCB(f,p),'Position', cbPos); ...
          set(hCB(f,p), 'Units', cbUnits);
      end
    end
    
    opt grid(plotting.Specs(p).Grid);
    
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
          tStrings(f,p,m,s) = {strtrim(strrep(int2str(tMean),'NaN',''))};
        end
        
        set(hText(f,p,m),'String', char(tStrings(f,p,m,1)));
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

plotting.tStrings = tStrings;
plotting.hText    = hText;
plotting.hSurf    = hSurf;
plotting.hAxes    = hAxes;
plotting.hCB      = hCB;
plotting.dLims    = dLims;
plotting.cLims    = cLims;
plotting.surfData = surfData;

runlog(['... OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);

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
clim = [floor(nanmin(cLims(:)))-1 ceil(nanmax(cLims(:)))+1];

dMean = nanmean(dLims(:));
clim = [round(dMean)-5 round(dMean)+5];

cform = makecform('srgb2xyz');
cmaps = cell(nFields,1);

for f = 1:nFields
  
  for p = 1:nPlotTypes
    
    
    %% Set range for non-delta
    field = char(fields(f));
    
    subplot(nPlotTypes,nFields,((p-1) * nFields) + f); ...
      hold on;
    
    try
      cmap      = get(gcf,'Colormap');
      cmap      = applycform(cmap,cform);
      cmaps{f,p}  = cmap;
    catch err
      disp(err);
    end
    
    
    isMean   = strcmpi(field,'Mean');
    isUpperLimit   = strcmpi(field,'UpperLimit');
    isLowerLimit   = strcmpi(field,'LowerLimit');
    
    if (isMean || isUpperLimit || isLowerLimit)
      zlim(dlim);
      caxis(clim);
    end
    
    try
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
    catch err
%       disp(err);
    end
  end
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
  
  iY1 = max(iY1-exporting.Border,0);
  iX1 = max(iX1-exporting.Border,0);
  iY2 = min(iY2+exporting.Border,size(img,1));
  iX2 = min(iX2+exporting.Border,size(img,2));
  runlog([' ' int2str(iX2-iX1) 'x' int2str(iY2-iY1) '/' num2str(exporting.Scale) ' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
end

if (isExporting)
  exporting.path = fullfile('output','statsVideo');
  exporting.name = lower([runName '-' plotMode '-' int2str(supPatchValue)]);
  exporting.file = fullfile(exporting.path, exporting.name);
end

if (exportPng || exportEps)
  warning off MATLAB:MKDIR:DirectoryExists;
  opt mkdir (exporting.file);
  warning on MATLAB:MKDIR:DirectoryExists;
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
for s = 1:nSheets
  
  fupdate = [int2str(s) ' / ' int2str(nSheets)] ;
  runlog(repmat('\b',1,numel(fstring)));
  fstring = fupdate;
  runlog(fstring);
  
  for p = 1:nPlotTypes
    plotType = plotTypes{p};
    isLastPlotType   = p==nPlotTypes;
    
    for f = 1:nFields
      field = char(fields(f));
      
      subplot(nPlotTypes,nFields,((p-1) * nFields) + f); ...
        hold on;
      
      title([runName TAB field TAB int2str(supPatchValue) '%'  TAB int2str(sIndex+1)], style.TitleStyle{:});
      
      zData = surfData(f,p).data(:,:,s);
      
      clim = caxis;
      cmin = min(clim);
      cmax = max(clim);
      cdiff = abs(cmax-cmin);
      
      zData(zData>cmax) = cmax;
      zData(zData<cmin) = cmin;
      
      cmap = cmaps{f,p};
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
          zX = tPos(2);       % surfData(f,p).regionCentres(m,1);
          zY = tPos(1);       % surfData(f,p).regionCentres(m,2);
          zV = floor(zData(zX,zY));
          zC = interp1(cx(:),cmap(:,1),zV);
          when [zC<0.33] tC = "w";         
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
    %     img = imfilter(img,imgf,'replicate');
    img = imresize(img,1/exporting.Scale,'Dither',false);
    frm = im2frame(img);  % img(iY1:iY2,iX1:iX2,:));
  end
  
  if (exportVideo)
    for fIndex = sIndex+1:sheetIndex(s)
      M(fIndex) = frm;
    end
  end
  
  if (exportPng)
    exporting.imagename = [exporting.name '-' sprintf('%03i',(sIndex+1))];
    imwrite(imgSrc, fullfile(exporting.file, [exporting.imagename '.png']),'png');
  end
  
  if (exportEps)
    exporting.imagename = [exporting.name '-' sprintf('%03i',(sIndex+1))];
    print2eps(fullfile(exporting.file,[exporting.imagename]),hFig); %, '-dpdf');
  end
  
  if (~isExporting)
    pause(0.001);
    drawnow;
  end
  
  
  sIndex=sheetIndex(s);
  
end

runlog(repmat('\b',1,numel(fstring)));
fstring = '';

runlog(['... OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);

% if (exportPng)
%
%   nFrames = numel(M);
%   for m = 1:numel(M);
%     fupdate = ['frame ' int2str(m) ' of ' int2str(nFrames)];
%     runlog(repmat('\b',1,numel(fstring)));
%     fstring = fupdate;
%     runlog(fstring);
%
%     exporting.imagename = [exporting.name '-' sprintf('%03i',(m)) '.png'];
%
%     imwrite(frame2im(M(m)), fullfile(exporting.file, exporting.imagename),'png');
%   end
% end

if (exportVideo)
  stepTimer = tic; runlog([TABS 'Exporting ']); % int2str(nSheets) ' sheets / ' int2str(numel(M)) ' frames to ' exporting.aviName ' ']);
  
  %   try
  opt close(mVideoWriter);
  %   end
  
  mVideoWriter = VideoWriter(exporting.file,'Motion JPEG AVI');  % runlog(['.']);
  mVideoWriter.FrameRate = 10.0;
  mVideoWriter.Quality = 100;
  open(mVideoWriter); % runlog(['.']);
  
  nFrames = numel(M);
  for m = 1:numel(M)
    fupdate = ['frame ' int2str(m) ' of ' int2str(nFrames)];
    runlog(repmat('\b',1,numel(fstring)));
    fstring = fupdate;
    runlog(fstring);
    
    writeVideo(mVideoWriter,M(m)); %runlog(['.']);
    
  end
  close(mVideoWriter);
  
  runlog(repmat('\b',1,numel(fstring)));
  
  runlog([int2str(nSheets) ' sheets / ' int2str(numel(M)) ' frames to ' exporting.name ' ']);
  
  
  runlog([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
  
  close gcf;
end

runlog([TABS '>> ' runMode ' ' strPlotType ' Successful! \t\t' num2str(toc(roundTimer)) '\t seconds\n']);

