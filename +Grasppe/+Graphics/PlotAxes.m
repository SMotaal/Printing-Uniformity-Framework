classdef PlotAxes < Grasppe.Graphics.Axes
  %OVERLAYAXES Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    
    function obj = PlotAxes(varargin)
      obj = obj@Grasppe.Graphics.Axes(varargin{:});
    end
    
  end
  methods (Access=protected)
    
    function createHandleObject(obj)
      obj.createHandleObject@Grasppe.Graphics.Axes;
      obj.handleSet('NextPlot', 'replacechildren');
    end
  end
  
  
  methods(Static, Hidden=true)
    function OPTIONS  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = true;
      Box           = 'off';
      Units         = 'normalized';
      Position      = [0 0 1 1];
      Color         = 'none';
      
      AspectRatio   = [1 1 1];
      View          = [0 90];
      
      OuterPosition = [0.1 0.1 0.8 0.8];
      
      Grasppe.Utilities.DeclareOptions;
    end
    
  end
  
  
end

