function [ output_args ] = supVideo( fview, fName, fSet, input_args )

[pathstr, name, ext] = fileparts(mfilename('fullpath')); cd(pathstr);
exportMovie=false; exportMJPG=true; exportFIG=true;

if exist('output','dir')==0
  mkdir('output');
end

viddir = fullfile('output','video');
if exist(viddir, 'dir') == 0
  mkdir(viddir)
end

if ~exist('fName','var')
  fName = '';
end

if ~exist('fSet','var')
  fSet = 'u';
end

if ischar(fName) && isempty(fName)
    fName = 'supVideo.avi';
end

if fName == false
    exportMovie = false;
    exportMJPG  = false;
    fName       = [];
    aviName     = [];
else
    aviName = fullfile(pathstr, viddir, fName);
end

if ~exist('fview','var'), fview = 1; end

try
  supData = evalin('base','supData');
  sheetSequence = supData.sheetIndex; %supRITSM74{1,2}{1,1};
  dframes = numel(sheetSequence); %max(sheetSequence);
catch ex
  error(['Could not read from supData: ' ex.message]);
end

try
  assignin('base','supSheet', 1); 
catch ex
  error(['Could not write to supSheet: ' ex.message]);
end
%dframes = 18;

%% Determin Plot Dimensions
try
  fig = figure('Name', 'Spatial-Temporal Plot', 'units','pixels', ...
    'Color', 'w', 'Toolbar', 'none', ... %'WindowStyle', 'modal', ...
    'MenuBar', 'none', 'Renderer', 'OpenGL');

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
fig = supSurf(fig, fview); %, cpBottom);
drawnow;


%% Create Movie Struct
M(1:dframes) = struct('cdata', [], 'colormap', []); 

%clear zl;  % capture = true;

iMd = 'lanczos3';
if exportFIG
  exportFun = @(fh,sz,md) imresize( print2array(fh, 1.25)   , sz, md);
  sI = sM;
else
  exportFun = @(fh,sz,md) imresize( frame2im(getframe(fh))  , sz, md);
end

%% Capture Movie Frames
% try
  for vI = 1:dframes
    
    selectZData(vI, fSet);
%     if vI == 1
%       assignin('base','supSheet', 1);    
%       selectZData(1);   % capture = selectZData(1,1);
%     else
%       selectZData();      % capture = selectZData(); 
%     end

    drawnow;
    
    img = exportFun(fig, sI, iMd);

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

% if exportAVI, mov = close(mov); end
if exportMovie
  movie2avi(M, aviName, 'fps', 10.0); %, 'compression', 'None');
elseif exportMJPG
  mVideoWriter = VideoWriter(aviName,'Motion JPEG AVI');
  mVideoWriter.FrameRate = 10.0;
  open(mVideoWriter);
  writeVideo(mVideoWriter,M);
  close(mVideoWriter);
end

close all;

end



function out = setZData(sheet, fSet)

  ZData = evalin('base',['supPlotData(' int2str(sheet) ').' fSet]);
  assignin('base','supZData', ZData);
  refreshdata;

end

function out = selectZData(sheet, fSet)

  persistent thisSheet;
  
  hplot   = findobj('type','figure','name','SUP Plot');
    
  haxis   = get(hplot,'CurrentAxes');

  supData = evalin('base','supData');

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
  
  assignin('base','supSheet', thisSheet); 

  setPlotTitle();

  setZData(thisSheet, fSet);

end

function [output] = setPlotTitle(hPlot)
  supNameFormat   = '%s ';
  supSheetFormat  = '- Sheet #%d ';
  supPatchFormat  = '- %d%% ';

  supTitleText    = '';

  %% Format Data Set String
  try
    supName       = evalin('base','supFileName');
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
