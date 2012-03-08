classdef UniformitySurfaceObject < SurfaceObject
  %UNIFORMITYSURFACEPLOT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    DataSource
  end
  
  properties (Dependent)
    SampleNumber
  end
  
  methods (Access=protected)
    function obj = UniformitySurfaceObject(parentAxes, varargin)
      obj = obj@SurfaceObject(parentAxes, varargin{:});
    end
    function createComponent(obj, type)
      obj.createComponent@SurfaceObject(type);
      
      obj.DataSource = SheetUniformityDataSource.createDataSource(obj);
    end
  end
  
  
  methods
  end
  
  methods (Static)
    function obj = createPlotObject(parentAxes, varargin)
      obj = UniformitySurfaceObject(parentAxes, varargin{:});
    end
  end
  
  
end

