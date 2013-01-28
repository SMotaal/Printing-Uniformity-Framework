function [ output_args ] = supVideo(sourceData, fview, fName, fSet, exportMovie )
  
  import PrintUniformityAlpha.*;
  
  default fView 1;
  default fName '';
  default fSet 'u';
  default exportMovie true;
  

  if ischar(fName) && isempty(fName)
    fName = fullfile('Output','video','supVideo.avi');
  end
  
  [pathstr filename ext] = fileparts(fName);
  
  if fName == false
    exportMovie = false;
    fName       = [];
    aviName     = [];
  else
    if ~isempty(pathstr) && (exist(pathstr, 'dir')==0)
      mkdir(pathstr);
    end
    
    aviName = fullfile(pathstr, filename);
  end
    
  try
    supData = sourceData.Data;
    sheetSequence = supData.sheetIndex;
    dframes = numel(sheetSequence);
  catch ex
    error(['Could not read from supData: ' ex.message]);
  end
  
  try
    sourceData.Sheet = 1;
  catch ex
    error(['Could not write to supSheet: ' ex.message]);
  end
  
  %% Determin Plot Dimensions
  try
    if exportMovie
      sM = [500 500];
      hFig = figure('Name', 'Spatial-Temporal Plot', 'units','pixels', ...
        'Color', 'w', 'Toolbar', 'none', 'MenuBar', 'none',  ...
        'Renderer', 'OpenGL', 'Visible', 'off','Position',[0 0 sM]);
    else
      monitorPositions = get(0,'MonitorPositions'); % MonitorUsed = 1;
      xF = monitorPositions(1,1); yF = dPos(1,2);
      sM = [850 850];
      sF = sM;
      
      hFig = figure('Name', 'Spatial-Temporal Plot', 'units','pixels', ...
        'Color', 'w', 'Toolbar', 'none', 'MenuBar', 'none', ...
        'Renderer', 'OpenGL', 'Visible', 'on', 'Position',[xF yF sF]);
      
    end
    clf;
  catch ex
    error(['Could not create figure: ' ex.message]);
  end
  
  
  %% Create supSurf Plot
  [hFig hSurf] = supSurf(sourceData, hFig, fview);
      
  iMd = 'lanczos3';
  if exportMovie
    exportFun = @(fh,sz,md) imresize( print2array(fh, 1.25), sz, md);
    sI = sM;
    
    selectZData(sourceData, 1, fSet, hFig);
    drawnow;
    img = exportFun(hFig, sI, iMd);
    
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
  
  drawnow;
  
  t=tic;
  statusUpdate(['Rendering ' filename ' frames... '], 1);
  
    
  %% Create Movie Struct
  M(1:dframes) = struct('cdata', [], 'colormap', []);
  
  %% Capture Movie Frames
  % try
  for vI = 1:dframes
    
    selectZData(sourceData, vI, fSet, hFig);

    drawnow;
    
    imgSrc = exportFun(hFig, sI, iMd);
    
    img = imgSrc(iY1:iY2,iX1:iX2,:);
    
    M(vI)= im2frame(img);
    
  end
  toc(t);
  
  if exportMovie
    t=tic;
    statusUpdate(['Exporting ' filename ' movie... '], 1);
    Video.writeVideo(aviName, M, sourceData.Data.sheetIndex);
    toc(t);
  end
  
  statusUpdate();
  
  close(hFig);
  
end



function out = setZData(sourceData, sheet, fSet, hFig)
  
  source = 'ZData';
  
  ZData = sourceData.PlotData(sheet).(fSet); % evalin('base',['supPlotData(' int2str(sheet) ').' fSet]);
  
  hAxes = get(hFig, 'CurrentAxes');
  hSurf = findobj(hAxes, 'type', 'surface');
  
  surfSource = get(hSurf, 'ZDataSource');
  
  if ~isequal(source, surfSource)
    set(hSurf, 'ZDataSource', 'ZData');
    set(hSurf, 'CDataSource', 'ZData');
  end
  
  refreshdata(hSurf, 'caller');
  
end

function out = selectZData(sourceData, sheet, fSet, hFig)
  
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
  
  hAxes = get(hFig, 'CurrentAxes');
  setPlotTitle(sourceData, hAxes);
  
  setZData(sourceData, thisSheet, fSet,hFig);
  
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
    
  %% Update the title
  supTitleText  = strtrim([supNameText supSheetText supPatchText]);
  title(hPlot, supTitleText);
  
end
