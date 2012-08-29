function [ sourceData ] = supAnimate( sourceData )
%SUPANIMATE Animates supData
%   Z-Data animation for spatial uniformity using supData and ZData in 
%   base workspace. Currently, supZData frames are copied in to ZData and
%   the function assumes that the data and plot are ready.
%
%   Last working commands in base:
%       supLoad;
%       supPatchValue = 50;
%       supPatchSet   = supData.patchMap == supPatchValue
%       supPatchValue; supInterp;
%       supSurf;
%       supAnimate;
%
% % %   Video output 
% % 
% % %% Optional Arguments
% % % Based on
% % % http://www.mathworks.com/matlabcentral/fileexchange/13082-tex-table?
% % 
% % ExtraInput  = (nargin-0);
% % if(ExtraInput>0)                % loop through all optional arguments
% %     for j = 1:1:ExtraInput
% %         switch lower(varargin{j})
% %             case 'videoout'     % video will be saved in output
% %                 %videoPath = varargin{j+1};
% %                 exportMovie=true;
% %         end        
% %     end
% % end
% % 
% % %% My quick functions
% % isTrue = @(obj) exist('obj','var') && eval(['eq(obj,true)']);
% % 
% % %% Video Preparation
% % if isTrue(exportMovie)
% %   [pathstr, name, ext, ver] = fileparts(mfilename('fullpath')); cd(pathstr);
% %   exportAVI=false; aviName = fullfile(pathstr,'Output','supVideo.avi');
% %   
% %   %sheetSequence = supRITSM74{1,2}{1,1};
% %   with 
% %   dim = 600;
% %   fig = figure('Name', 'Spatial-Temporal Plot', 'units','pixels', ...
% %     'Color', 'w', 'Toolbar', 'none', 'WindowStyle', 'modal', ...
% %     'MenuBar', 'none', 'Renderer', 'zbuffer');
% %   
% %   MonitorUsed = 1;
% %   displays = get(0,'MonitorPositions');
% %   dPos = displays(MonitorUsed,:);
% %   xF = dPos(1);
% %   yF = dPos(2);
% % 
% %   sM = [dim dim];
% %   sI =  fliplr(sM);
% %   sF = sM .* 1.5; % figure size
% %   set(fig,'Position',[xF yF sF]);
% % 
% %   clf;
% %   fP = get(fig,'Position');
% % 
% %   drawnow;  
% %   
% % end

import Alpha.*;

%% Main Function
persistent ghandle;

hplot   = findobj('type','figure','name','SUP Plot');

if isempty(hplot) % figure is closed, reopen it
  supSurf(sourceData);
end

delete(timerfind('name','timer-sup'));

t = timer('name','timer-sup', 'TimerFcn',{@callbackSelect, sourceData}, 'Period', 0.5, ...
  'ExecutionMode', 'fixedDelay');

start(t);

end

function out = setZData(sheet, sourceData)
  
  import Alpha.*;

  ZData = sourceData.PlotData(sheet).u; %ZData = sourceData.(['PlotData(' int2str(sheet) ').u']); %%evalin('base',['supPlotData(' int2str(sheet) ').u']);
  assignin('base','supZData', ZData);
  refreshdata;
  drawnow;
end

function out = callbackSelect(source, event, sourceData)
  selectZData(sourceData);
end

function out = selectZData(sourceData, time, sheet)
  
  import Alpha.*;

  persistent thisSheet;
  
  hplot   = findobj('type','figure','name','SUP Plot');
  
  if isempty(hplot) % figure is closed, timer stops
    stop(timerfind('name','timer-sup'));
    delete(timerfind('name','timer-sup'));
    return
  end
    
  
  haxis   = get(hplot,'CurrentAxes');

  supData = sourceData.Data;

  snum = numel(supData.sheetIndex);

  out = true;

  if isempty(thisSheet)
    thisSheet = 1;
  else
    thisSheet = thisSheet +1;
    if thisSheet == snum
      thisSheet = 1;
      out = false;
    end
  end

  title(gca, ['Sample #' num2str(thisSheet)]);

  sheet = thisSheet; %csupData.sheetIndex(thisSheet);
  setZData(sheet, sourceData);

end

