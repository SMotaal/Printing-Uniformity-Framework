function [ output_args ] = supView(source, fSheet, fSet, fView , forceView)

% [pathstr, name, ext] = fileparts(mfilename('fullpath')); cd(pathstr);
% exportMovie=true; exportFIG=true;

persistent mSheet mSet mView;

import Alpha.*;

sourceData = supDataBuffer(source);

mSheet, mSet, mView

if exist('forceView','var') && forceView > 0
  mView = forceView;
  updOnly = false;
end

if isempty(mSet),           mSet    = 'u';      updOnly = false;  end
if isempty(mSheet),         mSheet  = 1;        updOnly = false;  end
if isempty(mView),          mView   = 1;        updOnly = false;  end

if ~exist('fSet','var')   ||  isempty(fSet),    fSet    = mSet;   end
if ~exist('fSheet','var') ||  isempty(fSheet),  fSheet  = mSheet; end
if ~exist('fView','var')  ||  isempty(fView),   fView   = mView;  end

updSet    = ~(strcmpi(fSet,mSet));
updSheet  = ~(fSheet  == mSheet);
updView   = ~(fView   == mView);

mSet      = fSet;
mSheet    = fSheet;
mView     = fView;

mFigName  = 'SUP Plot'; %'Spatial-Temporal Plot';

try
  hFig      = findobj('type', 'figure', 'name', mFigName)
  chkFig    = numel(hFig)==1
  if numel(hFig) > 1
    close(hFig)
  end
catch exception
  chkFig    = false;
end

if ~exist('updOnly','var'), updOnly = true; end

updView   = any([updView ~chkFig])

updOnly   = updOnly && ~updView

%% Update

try
  if any([updSet updSheet updOnly]) && ~updView
    selectZData(sourceData, mSheet, mSet);
    disp('Updating view only.');
    drawnow;
    if updOnly == true
      return;
    end
  end
catch exception
  warning('Figure window will be recreated!');
end

  
%   try
%     supData = evalin('base','supData');
%     sheetSequence = supData.sheetIndex;
%     %   dframes = numel(sheetSequence);
%   catch ex
%     error(['Could not read from supData: ' ex.message]);
%   end
  
%   try
%     assignin('base','supSheet', 1);
%   catch ex
%     error(['Could not write to supSheet: ' ex.message]);
%   end
  %dframes = 18;
  
  %% Determin Plot Dimensions
  try
    if chkFig == 1
      hFig = hFig;
    else
      hFig = figure('Name', mFigName, 'units','pixels', ...
        'Color', 'w', 'WindowStyle', 'docked', ... %'Toolbar', 'none', ...
        'Renderer', 'OpenGL');
    end
    
%     set(hFig, 'WindowStyle', 'docked');
    
    % 'MenuBar', 'none', ... 'WindowStyle', 'modal', ...
    
%     MonitorUsed = 1;
%     displays = get(0,'MonitorPositions');
%     dPos = displays(MonitorUsed,:);
%     xF = dPos(1);
%     yF = dPos(2);
%     
%     if exportFIG
%       sM = [600 600];
%       sI = sM;
%     else
%       sM = [850 850];
%       sI = [600 600]; %fliplr(sM);
%     end
%     sF = sM; % .* 1.5; % figure size
%     set(fig,'Position',[xF yF sF]);
%     
%     clf;
%     fP = get(fig,'Position');
  catch ex
    error(['Could not create figure: ' ex.message]);
  end
  
  %% Create supSurf Plot
  hFig = supSurf(sourceData, hFig, mView); %, cpBottom);
  drawnow;
  
  %% Update Sheet
  selectZData(sourceData, mSheet, mSet);
%     if vI == 1
%       assignin('base','supSheet', 1);    
%       selectZData(1);   % capture = selectZData(1,1);
%     else
%       selectZData();      % capture = selectZData(); 
%     end  

% %% Create Movie Struct
% M(1:dframes) = struct('cdata', [], 'colormap', []); 
% 
% %clear zl;  % capture = true;
% 
% iMd = 'lanczos3';
% if exportFIG
%   exportFun = @(fh,sz,md) imresize( print2array(fh, 1.25)   , sz, md);
%   sI = sM;
% else
%   exportFun = @(fh,sz,md) imresize( frame2im(getframe(fh))  , sz, md);
% end
% 
% %% Capture Movie Frames
% % try
%   for vI = 1:dframes
%     
%     selectZData(vI, fSet);
% %     if vI == 1
% %       assignin('base','supSheet', 1);    
% %       selectZData(1);   % capture = selectZData(1,1);
% %     else
% %       selectZData();      % capture = selectZData(); 
% %     end
% 
%     drawnow;
%     
%     img = exportFun(fig, sI, iMd);
% 
% %     if exportFIG
% %       A = print2array(fig,1.25);
% %       img = imresize(A, sM, 'lanczos3');
% %     else
% %       [A, Map] = frame2im(getframe(fig));
% %       img = imresize(A, sI, 'lanczos3');
% %     end
%     
%     M(vI)= im2frame(img);
%     
%   end
% % catch ex
% %   error(['Could capture frame ' int2str(vI) ' of ' int2str(dframes) ': ' ex.message]);
% % end
% 
% % if exportAVI, mov = close(mov); end
% if exportMovie
%   movie2avi(M, aviName, 'fps', 10.0); %, 'compression', 'None');
% end

end



function out = setZData(sourceData, sheet, fSet)

%   ZData = evalin('base',['supPlotData(' int2str(sheet) ').' fSet]);
%   assignin('base','supZData', ZData);
%   refreshdata;
  
  import Alpha.*;

  ZData = sourceData.PlotData(int2str(sheet)).(fSet);
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
    sheetIndex    = sourceData.SheetIndex; % evalin('base','supData.sheetIndex');
    supSheet    = sourceData.Sheet;  % supSheet      = evalin('base','supSheet');
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
