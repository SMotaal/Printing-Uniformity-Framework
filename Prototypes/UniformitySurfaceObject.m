classdef UniformitySurfaceObject < GrasppePrototype & SurfaceObject & UniformityPlotObject
  %UNIFORMITYSURFACEPLOT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    ExtendedDataProperties = {};
  end
  
  properties (Dependent)
  end
  
  methods (Access=protected)
    function obj = UniformitySurfaceObject(parentAxes, varargin)
      obj = obj@GrasppePrototype;
      obj = obj@SurfaceObject(parentAxes, varargin{:});
      obj = obj@UniformityPlotObject();
    end
    function createComponent(obj, type)
      obj.createComponent@SurfaceObject(type);
      obj.createComponent@UniformityPlotObject(type);
      obj.handleSet('EdgeAlpha', 0.5);
    end
  end
  
  
  methods
    function refreshPlot(obj, dataSource)

      if ~obj.HasParentAxes, return; end
      
      try obj.ParentAxes.ZLim = dataSource.ZLim; end
      try obj.ParentAxes.CLim = dataSource.CLim; end
      
    end
    
    function refreshPlotData(obj, source, event)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      try
        dataSource = event.AffectedObject;
        dataField = source.Name;
        obj.handleSet(dataField, dataSource.(dataField));
      catch err
        try debugStamp(obj.ID); end
        disp(err);
      end
    end
  end
  
  methods (Static)
    function obj = Create(parentAxes, varargin)
      obj = UniformitySurfaceObject(parentAxes, varargin{:});
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

