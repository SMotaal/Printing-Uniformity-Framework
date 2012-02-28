classdef upPlotAxes < Plots.upAxes
  %UPPLOTAXES Printing Uniformity Plot Axes Object
  %   Detailed explanation goes here
  
  properties (Constant = true, Transient = true)
    ComponentType = 'axes';
    ComponentProperties = Plots.upGrasppeHandle.PlotAxesProperties;
  end
    
  methods
    function obj = upPlotAxes(parentFigure, varargin)
      obj = obj@Plots.upAxes(parentFigure, varargin{:});
      obj.createComponent();
    end
    
    function obj = resizeComponent(obj)
      hObj = obj.Primitive;
      hFig = obj.ParentFigure;
      
      fUnits = obj.Get(hFig, 'Units');
      obj.Set(hFig, 'Units', 'Pixels');
      fPos   = obj.Get(hFig, 'Position');
      obj.Set(hFig, 'Units', fUnits);
      
      oUnits = obj.Get('Units');
      obj.Set('Units', 'Pixels');
      oPos   = obj.Get('OuterPosition');
      oPad = 50;
      oPos = [oPad oPad fPos(3)-oPad*2 fPos(4)-oPad*3];
      obj.Set('OuterPosition', oPos);
      obj.Set('Units', oUnits);      
      
    end
  end
  
  methods(Static)
    function options  = DefaultOptions()
      HitTest   = 'on';
      options = WorkspaceVariables(true);
    end
  end
  
  
end

