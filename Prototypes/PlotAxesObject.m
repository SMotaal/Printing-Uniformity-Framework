classdef PlotAxesObject < AxesObject
  %PLOTAXESOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods (Access=protected)
    function obj = PlotAxesObject(parentFigure, varargin)
      obj = obj@AxesObject(varargin{:},'ParentFigure', parentFigure );
    end
    
    function createComponent(obj, type)
      obj.createComponent@GrasppeComponent(type);
      
      obj.OuterPosition = [0.1 0.1 0.8 0.8];
    end
    
  end
  
  methods
    function obj = resizeComponent(obj)
      parentPosition  = pixelPosition(obj.ParentFigure.Handle);
      padding=20;
      obj.set('Units', 'pixels', 'outerposition', ...
        [padding padding parentPosition([3 4])-2*padding]);
    end    
  end
  
  methods (Static)
    function options  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = true;
      Box           = 'on';
      Color         = 'none';
      
      options = WorkspaceVariables(true);
    end
    
    function obj = createAxesObject(parentFigure, varargin)
      obj = PlotAxesObject(parentFigure, varargin{:});
    end    
  end
  
  
end

