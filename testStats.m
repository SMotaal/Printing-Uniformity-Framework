close all;

fprintf('\n');

default exportVideo false;
default plotType region str;  % 'zone';  % 'axial';

when(~exists('supData') && ~exists('source'), 'source = ''ritsm7402a''');

runMode = resolve(exportVideo, 'Export', 'Display');

TAB          = '     ';
TABS = TAB;

try
  if(exists('source'))
    supFilePath = datadir('uniprint',source);
    runName = whos('-file', supFilePath);
    runName = runName.name;
    stepTimer = tic; fprintf(['Loading ' runName ' uniformity data ...']);
    supLoad(supFilePath);
    fprintf([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
    newPatchValue = 100;
    clear source;
  end

  runName = supMat.sourceTicket.folder.name;
catch err
  warning('UPStats:UPMatrix', 'Invalid uniformity data structure.');
end

when(exists('newPatchValue'),'clear supPatchSet');

if ~exists('supPatchSet')
  default newPatchValue 100;
  
  supPatchValue = newPatchValue;
  supPatchSet = supData.patchMap == supPatchValue;
  
  clear newPatchValue;
  clear supPlotData;
end

if ~exists('supPlotData')
  stepTimer = tic; fprintf(['Interpolating ' int2str(supPatchValue) '%% tone value uniformity data ...']);
  supInterp;
  fprintf([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
  
  clear supStatPlots;
end

generating = false;
if ~exists('supStatPlots')
  stepTimer = tic; fprintf(['Generating ' plotType ' statistics for ' runName ' - ' int2str(supPatchValue) '%% ...']);
  supStatPlots = supPlotStats(supPlotData, supData);
  fprintf([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
  generating = true;
end

try
  statPlots=supStatPlots.([plotType 'Surfs']); masks=[];
  statMasks=supStatPlots.([plotType 'Masks']);
  when [generating] fprintf('\n');
catch err
  return;
end

roundTimer = tic;
fprintf([runMode 'ing ' plotType ' uniformity statistics plots for ' runName ' - ' int2str(supPatchValue) '%%:\n']);

if (exportVideo)
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

if (~exportVideo)
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
nMasks    = size(statMasks,1);

sheetIndex    = evalin('base','supData.sheetIndex');
sheetMax = max(supData.sheetIndex(:));

if (exportVideo)
  clear M;
  M(1:sheetMax) = struct('cdata', [], 'colormap', []);
end


surfData = struct('fieldName', {}, ...
  'sheets', {},'masks', {},'rows', {},'columns', {}, ...
  'data', {},'dataMean', {},'dataStDev', {},'dataLimit', {},'dataRange', {}, ...
  'regionMean', {},'regionStDev', {},'regionCentres', {},'regionAreas', {}, ...
  'regionMasks', {}, ...
  'summaryData', {}, ...
  'patchData', {});

% 1:nSheets

tStrings = cell(nFields,nMasks, nSheets);

hText = zeros(nFields, nMasks);
hCB   = zeros(nFields,1);

dLims = zeros(nFields,2);
cLims = zeros(nFields,2);

stepTimer = tic; fprintf([TABS 'Preparing ']);  fstring = '';
for f = 1:nFields
  
  field = char(fields(f));
  
  fupdate = [plotType ' ' field ' ' int2str(f) ' / ' int2str(nFields)] ;
  fprintf(repmat('\b',1,numel(fstring)));
  fstring = fupdate;
  fprintf(1,fstring);
  
  surfData(f) = supMergeSurfs(statPlots, statMasks, field);
  
  fMean = nanmean(surfData(f).regionMean(:));
  fStd = nanmean(surfData(f).regionStDev(:));
  
  isDelta  = numel(field)>=5 && strcmpi(field(1:5),'Delta');
  isMean   = strcmpi(field,'Mean');
  isUpperLimit   = strcmpi(field,'UpperLimit');
  isLowerLimit   = strcmpi(field,'LowerLimit');
  
  isLabelField  = true;
  
  
  zLabel = ['zData' field];
  zData = surfData(f).data(:,:,1);
  
  if(isDelta)
    dlim = [0 10];
    clim = [0 6];
    
    dLims(f,:) = NaN;
    cLims(f,:) = NaN;
    
  elseif isMean || isUpperLimit || isLowerLimit
    dlim        = surfData(f).dataRange;
    clim        = surfData(f).dataRange;
    
    dLims(f,:)  = dlim;
    cLims(f,:) 	= clim;
  else
    clear('clim', 'dlim');
  end
  
  eval([zLabel '=zData;']);
  
  subplot(1,nFields,f); ...
    hold off;
  
  hSurf = surf(zData,'ZDataSource',zLabel, style.SurfStyle{:}); ...
    hold on;
  
  title([runName TAB field TAB int2str(supPatchValue) '%'  TAB int2str(1)], style.TitleStyle{:});
  
  set(gca,style.AxesStyle{:});
  daspect([100 100 20]);
  view([0, 90]);
  
  xlim([1 surfData(f).columns]);
  ylim([1 surfData(f).rows]);
  
  try
    zlim(dlim);
    caxis(clim);
  end
  
  
  colormap('Jet');
  
  hCB(f) = colorbar('SouthOutside', style.BarStyle {:}); %, 'LineWidth', def.LineWidth + 0.5);
  
  cbUnits = get(hCB(f),'Units');
  set(hCB(f),'Units','pixels');
  cbPos = get(hCB(f),'Position');
  cbPos(2) = cbPos(2) - 40;
  cbPos(4) = 5;
  cbPos(3) = cbPos(3)-2;
  set(hCB(f),'Position', cbPos);
  set(hCB(f), 'Units', cbUnits);
  
  for m = 1:nMasks
    
    fupdate = [plotType ' ' field ' ' int2str(f) ' / ' int2str(nFields) ' subset ' int2str(m) ' / ' int2str(nMasks)] ;
    fprintf(repmat('\b',1,numel(fstring)));
    fstring = fupdate;
    fprintf(1, fstring);
    
    
    tZ        = 101;
    tX        = surfData(f).regionCentres(m,1);
    tY        = surfData(f).regionCentres(m,2);
    tW        = surfData(f).regionAreas(m,1);
    tH        = surfData(f).regionAreas(m,2);
    
    hText(f,m) = text(tX,tY,tZ,'##', style.LabelStyle{:});
    
    tEven = rem(m,2)==1;
    
    try
      tEx = num2cell(get(hText(f,m),'Extent')); % [tl, tb, tw, th]
      [eL, eB, eW, eH] = deal(tEx{:});
      when [eW>tW*1.25] set(hText(f,m),'VerticalAlignment', resolve(tEven,'top','bottom'));
      when [eH>tH*1.25] set(hText(f,m),'HorizontalAlignment', resolve(tEven,'left','right'));
%       if (eW>tW*1.25)
%         if(rem(m,2)==1)
%           set(hText(f,m),'VerticalAlignment','top');
%         else
%           set(hText(f,m),'VerticalAlignment','bottom');
%         end
%       end
%       if (eH>tH*1.25)
%                 
% %         if(rem(m,2)==1)
% %           set(hText(f,m),'HorizontalAlignment','left');
% %         else
% %           set(hText(f,m),'HorizontalAlignment','right');
% %         end
%       end
    end
    
    
    try
      
      for s = 1:nSheets
        tMean           = surfData(f).regionMean(m,s);
        tStDev          = surfData(f).regionStDev(m,s);
        tV              = ['' int2str(tMean)];
        tV = strtrim(strrep(tV,'NaN',''));
        tStrings(f,m,s) = {tV};
      end
      
      set(hText(f,m),'String', char(tStrings(f,m,1)));
    end
    
    
  end
  
  fprintf(repmat('\b',1,numel(fstring)));
  fstring = '';
  
  fprintf([field resolve(f==nFields, ' ', ', ')]);
  
%   if (f==nFields)
%     fprintf([field ' ']);
%   else
%     fprintf([field ', ']);
%   end
end


fprintf(1, ['... OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);

% dlim = [nanmin(dLims(:,1),[],1) nanmax(dLims(:,2),[],1)];
dlim = [floor(nanmin(dLims(:)))-1 ceil(nanmax(dLims(:)))+1];
clim = [floor(nanmin(cLims(:)))-1 ceil(nanmax(cLims(:)))+1];

cform = makecform('srgb2xyz');
cmaps = cell(nFields,1);

stepTimer = tic; fprintf([TABS 'Optimizing plot limits ']);
for f = 1:nFields
  
  %% Set range for non-delta
  field = char(fields(f));
  
  subplot(1,nFields,f); ...
    hold on;
  
  
  isMean   = strcmpi(field,'Mean');
  isUpperLimit   = strcmpi(field,'UpperLimit');
  isLowerLimit   = strcmpi(field,'LowerLimit');
  
  if (isMean || isUpperLimit || isLowerLimit)
    
    zlim(dlim);
    caxis(clim);
  end
  
  cbLims = get(hCB(f), 'XLim');
  cbMin = floor(min(cbLims));
  cbMax = ceil(max(cbLims));
  cbDiff = cbMax-cbMin;
  
  cbTicks = get(hCB(f), 'XTick');
  
  if(cbDiff >= 8) % cbDiff < 20 &&
    cbTicks = cbMin:2:cbMax;
  elseif(cbDiff < 8 && cbDiff >= 4)
    cbTicks = cbMin:1:cbMax;
  elseif(cbDiff < 4 && cbDiff >= 2)
    cbTicks = cbMin:0.5:cbMax;
  elseif (cbDiff < 2)
    cbTicks = cbMin:0.25:cbMax;
  end
  
  set(hCB(f), 'XTick', cbTicks);
  
  cmap      = get(gcf,'Colormap');
  cmap      = applycform(cmap,cform);
  cmaps{f}  = cmap;
  %   csteps    = size(cmap,1);
  
  fprintf(['.']);
end
fprintf([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);

refreshdata;
drawnow;
pause(0.001);

if (exportVideo)
  stepTimer = tic; fprintf([TABS 'Determining video crop box ']);
  img = print2array(hFig, exporting.Scale);
  %   img = imresize(img,1/exporting.Scale);
  fprintf(['.']);
  mImg = mean(img,3);
  mIX = mean(mImg,1);
  mIY = mean(mImg,2);
  fprintf(['.']);
  iY1 = find(mIY~=255, 1, 'first');
  iX1 = find(mIX~=255, 1, 'first');
  iY2 = find(mIY~=255, 1, 'last');
  iX2 = find(mIX~=255, 1, 'last');
  fprintf(['.']);
  iY1 = max(iY1-exporting.Border,0);
  iX1 = max(iX1-exporting.Border,0);
  iY2 = min(iY2+exporting.Border,size(img,1));
  iX2 = min(iX2+exporting.Border,size(img,2));
  fprintf([' ' int2str((iX2-iX1)/exporting.Scale) 'x' int2str((iY2-iY1)/exporting.Scale) ' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
end

stepTimer = tic; fprintf([TABS 'Rendering sheets ']);   % int2str(s) '/' int2str(nSheets)

if (exportVideo)
  imgf = fspecial('unsharp');
end

fstring = '';

sIndex = 0;
for s = 1:nSheets
  
  fupdate = [int2str(s) ' / ' int2str(nSheets)] ;



  fprintf(repmat('\b',1,numel(fstring)));
  
  fstring = fupdate;
  
  fprintf(1, fstring);
  
  
  for f = 1:nFields
    field = char(fields(f));
    
    subplot(1,nFields,f); ...
      hold on;
    
    title([runName TAB field TAB int2str(supPatchValue) '%'  TAB int2str(sIndex+1)], style.TitleStyle{:});
    
    zData = surfData(f).data(:,:,s);
    
    clim = caxis;
    cmin = min(clim);
    cmax = max(clim);
    cdiff = abs(cmax-cmin);
    zData(zData>cmax) = cmax;
    zData(zData<cmin) = cmin;
    
    %     cmap = get(gcf,'Colormap');
    %     cmap = applycform(cmap,cform);
    cmap = cmaps{f};
    csteps = size(cmap,1);
    
    
    zLabel = ['zData' field];
    eval([zLabel '=zData;']);
    
    for m = 1:nMasks
      set(hText(f,m),'String', char(tStrings(f,m,s)));
      tC = 'k';
      try
        zX = surfData(f).regionCentres(m,1);
        zY = surfData(f).regionCentres(m,2);
        zV = zData(zY,zX);
        zI = round((zV-cmin)/cdiff * csteps);
        zC = cmap(zI,1);
        if (zC<0.2)
          tC = 'w';
        end
      end
      set(hText(f,m),'color', tC);
    end
    
  end
  
  refreshdata;
  
  if (exportVideo)
    
    img = print2array(hFig, exporting.Scale);
    img = img(iY1:iY2,iX1:iX2,:);
    %     img = imfilter(img,imgf,'replicate');
    img = imresize(img,1/exporting.Scale,'Dither',false);
    frm = im2frame(img);  % img(iY1:iY2,iX1:iX2,:));
    
    for fIndex = sIndex+1:sheetIndex(s)
      M(fIndex) = frm;
    end
    
  else
    pause(0.001);
    drawnow;
  end
  
  sIndex=sheetIndex(s);
  
  %   fprintf(['.']);
  
end

% for fbacks = 1:numel(fstring)
%   fprintf(['\b']);
% end
  fprintf(repmat('\b',1,numel(fstring)));
fstring = '';

fprintf(1, ['... OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);

if (exportVideo)
  
  exporting.aviName = lower([runName '-' plotType '-' int2str(supPatchValue)]);
  
  stepTimer = tic; fprintf([TABS 'Exporting ']) % int2str(nSheets) ' sheets / ' int2str(numel(M)) ' frames to ' exporting.aviName ' ']);
  
  exporting.aviName = fullfile('output','statsVideo', exporting.aviName);
  
  try
    close(mVideoWriter);
  end
  
  mVideoWriter = VideoWriter(exporting.aviName,'Motion JPEG AVI');  % fprintf(['.']);
  mVideoWriter.FrameRate = 10.0;
  mVideoWriter.Quality = 100;
  open(mVideoWriter); % fprintf(['.']);
  
  nFrames = numel(M);
  for m = 1:numel(M)
    fupdate = ['frame ' int2str(m) ' of ' int2str(nFrames)];
    fprintf(repmat('\b',1,numel(fstring)));
    fstring = fupdate;
    fprintf(1, fstring);
    
    writeVideo(mVideoWriter,M(m)); %fprintf(['.']);
    
  end
  close(mVideoWriter);
  
  fprintf(repmat('\b',1,numel(fstring)));
  
  fprintf([int2str(nSheets) ' sheets / ' int2str(numel(M)) ' frames to ' exporting.aviName ' ']);
  
  
  fprintf([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
  
  close gcf;
end

fprintf([TABS '>> ' runMode ' Successful! \t\t' num2str(toc(roundTimer)) '\t seconds\n']);

