classdef UniformitySurfaceObject < UniformityPlotObject & SurfaceObject
  %UNIFORMITYSURFACEPLOT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end  
    
  methods (Access=protected)
    function obj = UniformitySurfaceObject(parentAxes, varargin)
      obj = obj@UniformityPlotObject();      
      obj = obj@SurfaceObject(parentAxes, varargin{:});
    end
    function createComponent(obj, type)
      obj.createComponent@PlotObject(type);
      obj.createComponent@UniformityPlotObject(type);      
    end    
  end
  
  
  methods
  end
  
  methods (Static)
    function obj = Create(parentAxes, varargin)
      obj = UniformitySurfaceObject(parentAxes, varargin{:});
    end
  end
  
  
end

