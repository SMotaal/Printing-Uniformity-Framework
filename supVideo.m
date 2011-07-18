function [ output_args ] = supVideo( fview, fName, input_args )

[pathstr, name, ext, ver] = fileparts(mfilename('fullpath')); cd(pathstr);
exportAVI=false;

if ~exist('fName')
  fName = 'supVideo.avi';
else
  
end

aviName = fullfile(pathstr,'output', fName);
exportMovie=true;

%close all;

if ~exist('fview','var'), fview = 1; end

supData = evalin('base','supData');

sheetSequence = supData.sheetIndex; %supRITSM74{1,2}{1,1};

%dframes = 18;

dframes = numel(sheetSequence); %max(sheetSequence);

dim = 600;

%% Create Scatter Plot
fig = figure('Name', 'Spatial-Temporal Plot', 'units','pixels', ...
  'Color', 'w', 'Toolbar', 'none', 'WindowStyle', 'modal', ...
  'MenuBar', 'none', 'Renderer', 'zbuffer');

MonitorUsed = 1;
displays = get(0,'MonitorPositions');
dPos = displays(MonitorUsed,:);
xF = dPos(1);
yF = dPos(2);

sM = [dim dim];
sI =  fliplr(sM);
sF = sM .* 1.5; % figure size
set(fig,'Position',[xF yF sF]);

clf;
fP = get(fig,'Position');

[fig, c] = supSurf(fig, fview);

drawnow;
s = 0;
M(1:dframes) = struct('cdata', [], 'colormap', []);
clear zl;

capture = true;

for i = 1:dframes
  
  if i == 1
    capture = selectZData(1);
  else
    capture = selectZData();
  end
  %caxis
  %caxis = c;
    
%  if capture
    drawnow;
    [A, Map] = frame2im(getframe(fig));
    img = imresize(A, sI);
    M(i)=im2frame(img, Map);
%  else

%  end    
end

% if exportAVI, mov = close(mov); end
if exportMovie, 
  movie2avi(M, aviName, 'fps', 10.0); %, 'compression', 'None');
end

close all;

end


function out = setZData(sheet)

  ZData = evalin('base',['supPlotData(' int2str(sheet) ').u']);
  assignin('base','supZData', ZData);
  refreshdata;
  out = true;

end


function out = selectZData(sheet, time)

  persistent thisSheet;
  
  if exist('sheet','var')
    thisSheet = sheet;
  end

  supData = evalin('base','supData');

  snum = numel(supData.sheetIndex);

  out = true;

  if isempty(thisSheet)
    thisSheet = 1;
  else
    thisSheet = thisSheet +1;
    if thisSheet == snum + 1;
      thisSheet = 1;
      out = false;
    end
  end

  %s;

  assignin('base', 'supCA', gca);
  mca = evalin('base', 'supCA');
  title(mca,['Sample Sheet #' num2str(supData.sheetIndex(thisSheet))]);

  setZData(thisSheet);

end
