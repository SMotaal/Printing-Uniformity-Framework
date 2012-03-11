classdef SurfaceObject < PlotObject
  %SURFACEOBJECT Superclass for surface plot objects
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    ComponentType = 'surf';
    
    ComponentProperties = { 'Clipping', 'DisplayName', {'AntiAliasing' 'LineSmoothing'}};
    ComponentEvents = {};
    
    DataProperties = {'AData', 'CData', 'XData', 'YData', 'ZData'}; %, 'CData', 'AData'}; %, 'SampleID', 'SourceID', 'SetID'};

  end
  
  properties (SetObservable, GetObservable)
    Clipping, DisplayName='', AntiAliasing = 'on', CDataMapping;    
  end
  
  properties (GetObservable, SetObservable)
    AData, CData, XData, YData, ZData
  end
    
  methods (Access=protected)
    function obj = SurfaceObject(parentAxes, varargin)
      obj = obj@PlotObject(parentAxes, varargin{:});
    end
    
    function createComponent(obj, type)
      debugStamp(obj.ID);
      obj.attachDataListeners;
      obj.createComponent@PlotObject(type);
    end
  end
  
  methods
    %AData, CData, XData, YData, ZData
    function value = get.AData(obj)
      debugStamp(obj.ID);
      value = obj.dataGet('AData');
    end
    function set.AData(obj, value)
      debugStamp(obj.ID);
      obj.dataSet('AData', value);
    end
    
    function value = get.CData(obj)
      debugStamp(obj.ID);
      value = obj.dataGet('CData');
    end
    function set.CData(obj, value)
      debugStamp(obj.ID);
      obj.dataSet('CData', value);
    end
        
    function value = get.XData(obj)
      debugStamp(obj.ID);
      value = obj.dataGet('XData');
    end
    function set.XData(obj, value)
      debugStamp(obj.ID);
      obj.dataSet('XData', value);
    end
    
    function value = get.YData(obj)
      debugStamp(obj.ID);
      value = obj.dataGet('YData');
    end
    function set.YData(obj, value)
      debugStamp(obj.ID);
      obj.dataSet('YData', value);
    end
    
    function value = get.ZData(obj)
      debugStamp(obj.ID);
      value = obj.dataGet('ZData');
    end
    function set.ZData(obj, value)
      debugStamp(obj.ID);
      obj.dataSet('ZData', value);
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

