function [ output_args ] = supVideo(sourceData, fview, fName, fSet )
  
  import Alpha.*;
  
  % [pathstr, name, ext] = fileparts(mfilename('fullpath')); %cd(pathstr);
  exportMovie=true; exportMJPG=true; exportFIG=true;
  
  % if exist('output','dir')==0
  %   mkdir('output');
  % end
  
  
  if ~exist('fName','var')
    fName = '';
  end
  
  if ~exist('fSet','var')
    fSet = 'u';
  end
  
  if ischar(fName) && isempty(fName)
    fName = fullfile('output','video','supVideo.avi');
  end
  
  [pathstr filename ext] = fileparts(fName);
  
  if fName == false
    exportMovie = false;
    exportMJPG  = false;
    fName       = [];
    aviName     = [];
  else
    
    if ~isempty(pathstr) && exist(pathstr, 'dir') == 0
      mkdir(pathstr);
    end
    
    aviName = fullfile(pathstr, filename);
  end
  
  if ~exist('fview','var'), fview = 1; end
  
  try
    supData = sourceData.Data; %evalin('base','supData');
    sheetSequence = supData.sheetIndex; %supRITSM74{1,2}{1,1};
    dframes = numel(sheetSequence); %max(sheetSequence);
  catch ex
    error(['Could not read from supData: ' ex.message]);
  end
  
  try
    sourceData.Sheet = 1;
    %   assignin('base','supSheet', 1);
  catch ex
    error(['Could not write to supSheet: ' ex.message]);
  end
  %dframes = 18;
  
  %% Determin Plot Dimensions
  try
    if exportMovie
      sM = [500 500];
      fig = figure('Name', 'Spatial-Temporal Plot', 'units','pixels', ...
        'Color', 'w', 'Toolbar', 'none', ... %'WindowStyle', 'modal', ...
        'MenuBar', 'none', 'Renderer', 'OpenGL', 'Visible', 'off','Position',[0 0 sM]);
    else
      fig = figure('Name', 'Spatial-Temporal Plot', 'units','pixels', ...
        'Color', 'w', 'Toolbar', 'none', ... %'WindowStyle', 'modal', ...
        'MenuBar', 'none', 'Renderer', 'OpenGL', 'Visible', 'on');
      
      
      MonitorUsed = 1;
      displays = get(0,'MonitorPositions');
      dPos = displays(MonitorUsed,:);
      xF = dPos(1);
      yF = dPos(2);
      
      if exportFIG
        sM = [600 600];
        sI = sM;
      else
        sM = [850 850];
        sI = [600 600]; %fliplr(sM);
      end
      sF = sM; % .* 1.5; % figure size
      set(fig,'Position',[xF yF sF]);
    end
    
    
    clf;
    fP = get(fig,'Position');
  catch ex
    error(['Could not create figure: ' ex.message]);
  end
  
  %% Determin Color Bar Bottom
  % if ~exist('cpBottom','var') || ~isnumeric(cpBottom) || cpBottom > sI(2)
  %   cpBottom = sI(2)-110;
  % end
  
  %% Create supSurf Plot
  fig = supSurf(sourceData, fig, fview); %, cpBottom);
  drawnow;
  
  
  %% Create Movie Struct
  M(1:dframes) = struct('cdata', [], 'colormap', []);
  
  %clear zl;  % capture = true;
  
  iMd = 'lanczos3';
  if exportMovie
    exportFun = @(fh,sz,md) imresize( print2array(fh, 1.25), sz, md);
    sI = sM;
    
    selectZData(sourceData, 1, fSet);
    drawnow;
    img = exportFun(fig, sI, iMd);
    
    exporting.Border = 15;
    
    mImg = mean(img,3);
    mIX = mean(mImg,1);
    mIY = mean(mImg,2);
    
    iY1 = find(mIY~=255, 1, 'first');
    iX1 = find(mIX~=255, 1, 'first');
    iY2 = find(mIY~=255, 1, 'last');
    iX2 = find(mIX~=255, 1, 'last');
    
    iY1 = max(iY1-exporting.Border,1);
    iX1 = max(iX1-exporting.Border,1);
    iY2 = min(iY2+exporting.Border,size(img,1));
    iX2 = min(iX2+exporting.Border,size(img,2));
  end
  
  
  t=tic;
  statusUpdate(['Rendering ' filename ' frames... '], 1);
  
  
  %% Capture Movie Frames
  % try
  for vI = 1:dframes
    
    selectZData(sourceData, vI, fSet);
    %     if vI == 1
    %       assignin('base','supSheet', 1);
    %       selectZData(1);   % capture = selectZData(1,1);
    %     else
    %       selectZData();      % capture = selectZData();
    %     end
    
    drawnow;
    
    
    
    imgSrc = exportFun(fig, sI, iMd);
    
    img = imgSrc(iY1:iY2,iX1:iX2,:);
    
    %     if exportFIG
    %       A = print2array(fig,1.25);
    %       img = imresize(A, sM, 'lanczos3');
    %     else
    %       [A, Map] = frame2im(getframe(fig));
    %       img = imresize(A, sI, 'lanczos3');
    %     end
    
    M(vI)= im2frame(img);
    
  end
  % catch ex
  %   error(['Could capture frame ' int2str(vI) ' of ' int2str(dframes) ': ' ex.message]);
  % end
  toc(t);
  
  % if exportAVI, mov = close(mov); end
  if exportMovie
    t=tic;
    statusUpdate(['Exporting ' filename ' movie... '], 1);
    Video.writeVideo(aviName, M, sourceData.Data.sheetIndex);
    toc(t);
  end
  
  statusUpdate();
  
  % if exportMovie
  %   movie2avi(M, aviName, 'fps', 10.0); %, 'compression', 'None');
  % elseif exportMJPG
  %   mVideoWriter = VideoWriter(aviName,'Motion JPEG AVI');
  %   mVideoWriter.FrameRate = 10.0;
  %   open(mVideoWriter);
  %   writeVideo(mVideoWriter,M);
  %   close(mVideoWriter);
  % end
  
  close all;
  
end



function out = setZData(sourceData, sheet, fSet)
  
  ZData = sourceData.PlotData(sheet).(fSet); % evalin('base',['supPlotData(' int2str(sheet) ').' fSet]);
  assignin('base','supZData', ZData);
  refreshdata;
  
end

function out = selectZData(sourceData, sheet, fSet)
  
  persistent thisSheet;
  
  hplot   = findobj('type','figure','name','SUP Plot');
  
  haxis   = get(hplot,'CurrentAxes');
  
  supData = sourceData.Data; % evalin('base','supData');
  
  
  snum = numel(supData.sheetIndex);
  
  out = true;
  
  if exist('sheet','var')
    thisSheet = sheet;
  else
    thisSheet = thisSheet + 1;
  end
  
  if thisSheet > snum
    clear(thisSheet); % = snum;
    out = false;
  end
  
  %   assignin('base','supSheet', thisSheet);
  sourceData.Sheet = thisSheet;
  
  setPlotTitle(sourceData);
  
  setZData(sourceData, thisSheet, fSet);
  
end

function [output] = setPlotTitle(sourceData, hPlot)
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
    sheetIndex    = sourceData.Data.sheetIndex; % evalin('base','supData.sheetIndex');
    supSheet      = sourceData.Sheet; %evalin('base','supSheet');
    supSheetIndex = sheetIndex(supSheet);
    supSheetText  = sprintf(supSheetFormat, supSheetIndex);
  catch
    supSheetText  = sprintf(supSheetFormat, 0);
  end
  
  %% Format Patch String
  try
    supPatch      = sourceData.PatchValue; % evalin('base','supPatchValue');
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
  
  if exist('hPlot','var')
    mca = hPlot;
  else
    mca = gca;
  end
  
  % assignin('base', 'supCA', mca);
  
  %% Update the title
  supTitleText  = strtrim([supNameText supSheetText supPatchText]);
  title(mca,supTitleText);
  
end
