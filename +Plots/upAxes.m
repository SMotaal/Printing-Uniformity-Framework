classdef upAxes < Plots.upFigureObject
  %UPAXES Summary of this class goes here
  %   Detailed explanation goes here
    
  properties
  end
  
  properties (Dependent=true)
  end
  
  methods
    function obj = upAxes(parentFigure, varargin)
      obj = obj@Plots.upFigureObject(parentFigure, varargin{:});
    end
    
  end
  
  methods(Abstract, Static)
    options  = DefaultOptions()
  end
  
end


