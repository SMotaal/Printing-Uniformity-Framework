classdef OverlayAxesObject < AxesObject
  %OVERLAYAXESOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods (Access=protected)
    function obj = OverlayAxesObject(parentFigure, varargin)
      obj = obj@AxesObject(varargin{:},'ParentFigure', parentFigure );
    end
    
    function createComponent(obj, type)
      obj.createComponent@GrasppeComponent(type);
      
      obj.Position = [0.1 0.1 0.8 0.8];
      
      obj.set('XTick', [], 'YTick' ,[]);
    end
    
  end
  
  methods
    function obj = resizeComponent(obj)
      parentPosition  = pixelPosition(obj.ParentFigure.Handle);
      padding=20;
      obj.set('Units', 'pixels', 'position', ...
        [padding padding parentPosition([3 4])-2*padding]);
    end    
  end
  
  methods (Static)
    function options  = DefaultOptions( )
      
      IsVisible     = false;
      IsClickable   = false;
      Box           = 'off';
%       Position      = [0 0 1 1];
%       Parent        = 0;
      Color         = 'none';
      
      options = WorkspaceVariables(true);
    end
    
    function obj = createAxesObject(parentFigure, varargin)
      obj = OverlayAxesObject(parentFigure, varargin{:});
    end    
  end
  
  
end

