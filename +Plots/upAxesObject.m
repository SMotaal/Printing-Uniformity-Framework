classdef upAxesObject < Plots.upFigureObject
  %UPAXESOBJECT Printing Uniformity Axes Superclass
  %   Detailed explanation goes here
  
  properties
  end
  
  properties (Dependent=true)
    PlotAxesObject
    PlotAxes    
  end
  
  methods
    function obj = upAxesObject(parentFigure, varargin)
      obj = obj@Plots.upFigureObject(parentFigure, varargin{:});
    end
    
    
    function hAxes = get.PlotAxes(obj)
      if validCheck(obj.ParentFigureObject, 'Plots.upPlotFigure')
        hAxes = obj.ParentFigureObject.PlotAxes;
      else
        hAxes = [];
      end
    end    
    
    function hParent = getParent(obj)
      hParent = obj.PlotAxes;    
%       if isValidHandle(obj.Primitive) && isValidHand(get(obj.Primitive,'Parent'))
%         hParent = get(obj.Primitive,'Parent');
%       else
%         hParent = obj.PlotAxes;
%       end
    end
    
  end
  
  methods(Abstract, Static)
    options  = DefaultOptions()
  end
  
end

