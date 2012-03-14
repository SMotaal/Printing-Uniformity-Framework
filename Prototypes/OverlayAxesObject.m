classdef OverlayAxesObject < AxesObject
  %OVERLAYAXESOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    ComponentType = 'axes';
    ComponentProperties = { };
    ComponentEvents = { };
  end
  
  methods (Access=protected, Hidden)
    function obj = OverlayAxesObject(parentFigure, varargin)
      obj = obj@AxesObject(varargin{:},'ParentFigure', parentFigure );
    end
    
    function createComponent(obj, type)
      obj.createComponent@AxesObject(type);
      
      obj.Position = [0.1 0.1 0.8 0.8];
      
      obj.handleSet('XTick', [], 'YTick' ,[]);
    end
    
  end
  
  methods (Hidden)
    function obj = resizeComponent(obj)
      parentPosition  = pixelPosition(obj.ParentFigure.Handle);
      padding=20;
      obj.handleSet('Units', 'pixels', 'position', ...
        [padding padding parentPosition([3 4])-2*padding]);
    end    
  end
  
  methods (Static, Hidden)
    function options  = DefaultOptions( )
      
      IsVisible     = false;
      IsClickable   = false;
      Box           = 'off';
%       Position      = [0 0 1 1];
%       Parent        = 0;
      Color         = 'none';
      
      options = WorkspaceVariables(true);
    end
    
  end
  
  methods (Static)
    function obj = Create(parentFigure, varargin)
      obj = OverlayAxesObject(parentFigure, varargin{:});
    end    
  end
  
  
end

