classdef SurfaceObject < InAxesObject
  %SURFACEOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    ComponentType = 'surf';
    
    ComponentProperties = { ...
     };
    
    ComponentEvents = { ...
      };
    
  end
   
  properties
  end
  
  methods (Access=protected)
    function obj = SurfaceObject(parentAxes, varargin)
      obj = obj@InAxesObject(varargin{:},'ParentAxes', parentAxes);
    end
    function createComponent(obj, type)
      obj.createComponent@GrasppeComponent(type);
    end
  end
  
  
  methods (Static)
    function options  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = true;
      
      options = WorkspaceVariables(true);
    end
    
    function obj = createPlotObject(parentAxes, varargin)
      obj = SurfaceObject(parentAxes, varargin{:});
    end
  end
  
end

