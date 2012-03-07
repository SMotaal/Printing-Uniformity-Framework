classdef upOverlayAxes < Plots.upAxes
  %UPOVERLAYAXES Printing Uniformity Figure Overlay Axes
  %   Holds title and other static labels.
  
  properties (Constant = true, Transient = true)
    ComponentType = 'axes';
    ComponentProperties = Model.Properties.PlotAxes;
  end  
  
  properties
  end
  
  methods
    function obj = upPlotAxes(varargin)
      obj = obj@Plots.upAxesObject(varargin{:}, 'Visible', 'on');
    end
  end
  
  methods(Static)
    function options  = DefaultOptions( )
      HitTest   = 'on';
      options = WorkspaceVariables(true);
    end
  end  
  
end

