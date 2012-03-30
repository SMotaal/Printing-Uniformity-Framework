classdef OverlayAxes < Grasppe.Graphics.Axes
  %OVERLAYAXES Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    
    function obj = OverlayAxes(varargin)
      obj = obj@Grasppe.Graphics.Axes(varargin{:});
    end    
  end
  
  
  methods(Static, Hidden=true)
    function options  = DefaultOptions( )
      
      IsVisible     = false;
      IsClickable   = false;
      Box           = 'off';
      Units         = 'normalized';
      Position      = [0 0 1 1];
      Color         = 'none';
      
      options       = WorkspaceVariables(true);
    end
    
  end
  
  
end

