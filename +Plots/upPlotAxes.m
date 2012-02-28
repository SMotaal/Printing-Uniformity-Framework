classdef upPlotAxes < Plots.upAxes
  %UPPLOTAXES Printing Uniformity Plot Axes Object
  %   Detailed explanation goes here
  
  properties (Constant = true, Transient = true)
    ComponentType = 'axes';
    ComponentProperties = Plots.upGrasppeHandle.PlotAxesProperties;
  end
    
  methods
%     function obj = upPlotAxes(varargin)
%       obj = obj@Plots.upAxes(varargin{:}, 'Visible', 'on');
%     end    
    function obj = upPlotAxes(parentFigure, varargin)
      obj = obj@Plots.upAxes(parentFigure, varargin{:});
      obj.createComponent();
    end
    
    function obj = resizeComponent(obj)
      hObj = obj.Primitive;
      hFig = obj.ParentFigure;
      
      fUnits = get(hFig, 'Units');
      set(hFig, 'Units', 'Pixels');
      fPos   = get(hFig, 'Position');
      set(hFig, 'Units', fUnits);
      
      oUnits = get(hObj, 'Units');
      set(hObj, 'Units', 'Pixels');
      oPos   = get(hObj, 'OuterPosition');
      oPad = 50;
      oPos = [oPad oPad fPos(3)-oPad*2 fPos(4)-oPad*3];
      set(hObj, 'OuterPosition', oPos);
      set(hObj, 'Units', oUnits);      
      
    end
  end
  
  methods(Static)
    function options  = DefaultOptions()
      HitTest   = 'on';
      options = WorkspaceVariables(true);
    end
  end
  
  
end

