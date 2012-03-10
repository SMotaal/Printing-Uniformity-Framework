classdef SurfaceObject < PlotObject
  %SURFACEOBJECT Superclass for surface plot objects
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    ComponentType = 'surf';
    
    ComponentProperties = { ...
      'Clipping', ...
      'DisplayName', ...
      'CData', 'CDataMapping', ...
      'XData', 'YData', 'ZData', ...
      'XDataSource', 'YDataSource', 'ZDataSource', ...
      {'AntiAliasing' 'LineSmoothing'} ...
      };    

    ComponentEvents = {};
    
    DataProperties = {'XData', 'YData', 'ZData'}; %, 'CData', 'AData'}; %, 'SampleID', 'SourceID', 'SetID'};

  end
  
  properties (SetObservable, GetObservable)
    XData, YData, ZData
    XDataSource, YDataSource, ZDataSource
    Clipping, DisplayName='', CData, CDataMapping, %
    AntiAliasing = 'on';
  end
    
  methods (Access=protected)
    function obj = SurfaceObject(parentAxes, varargin)
      obj = obj@PlotObject(parentAxes, varargin{:});
    end
    
    function createComponent(obj, type)
      debugStamp(obj.ID);
      obj.createComponent@PlotObject(type);
    end    
    
  end
  
  methods
    function set.ZData(obj, value)
      try
        obj.ZData = value;
        obj.CData = value;
      end
    end
  end
  
  methods (Static, Hidden)
    function options  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = true;
      
      options = WorkspaceVariables(true);
    end
    
  end
  
end

