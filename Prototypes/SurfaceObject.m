classdef SurfaceObject < InAxesObject
  %SURFACEOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    ComponentType = 'surf';
    
    ComponentProperties = { ...
      'Clipping', ...
      'DisplayName', ...
      'CData', 'CDataMapping', ...
      'XData', 'YData', 'ZData' ...
     };
    
    ComponentEvents = { ...
      };
    
  end
   
  properties (SetObservable)
    Clipping, DisplayName, CData, CDataMapping, XData, YData, ZData
  end
  
  properties (Dependent)
    
  end
  
  methods (Access=protected)
    function obj = SurfaceObject(parentAxes, varargin)
      obj = obj@InAxesObject(varargin{:},'ParentAxes', parentAxes);
    end
    function createComponent(obj, type)
      obj.createComponent@GrasppeComponent(type);
    end
  end
  
  
  methods (Static, Hidden)
    function options  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = true;
      
      options = WorkspaceVariables(true);
    end
    
  end
  
  methods (Static)
    function obj = createPlotObject(parentAxes, varargin)
      obj = SurfaceObject(parentAxes, varargin{:});
    end
  end
  
end

