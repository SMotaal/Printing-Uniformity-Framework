classdef upFigureObject < Plots.upViewComponent
  %UPFIGUREOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    ParentFigureObject
  end
  
  properties (Dependent=true)
    ParentFigure
  end
  
  methods
    function obj = upFigureObject(parentFigure, varargin)
      obj = obj@Plots.upViewComponent('ParentFigureObject', parentFigure, varargin{:});
    end
    
    function PlotFigure = get.ParentFigureObject(obj)
      PlotFigure = obj.ParentFigureObject;
    end
    
    function obj = set.ParentFigureObject(obj, parentFigure)
      if isValid('parentFigure', 'Plots.upPlotFigure')
        obj.ParentFigureObject = parentFigure;
        obj.Parent = obj.ParentFigureObject.Primitive;
      else
        error('Grasppe:upAxesObject:InvalidParent', ...
          'Could not obtain a valid plot figure to hold this %s object.', obj.ClassName);
      end
    end
    
    function hFigure = get.ParentFigure(obj)
      if isValid(obj.ParentFigureObject, 'Plots.upPlotFigure')
        hFigure = obj.ParentFigureObject.Primitive;
      else
        hFigure = [];
      end
    end    
    
    function obj = set.ParentFigure(obj, hFigure)
      parentFigure = getUserData(hFigure);
      if isValidHandle('hFigure') && isValid(parentFigure, 'Plots.upPlotFigure')
          obj.setParentFigure(parentFigure);
          return;
      else
        error('Grasppe:upAxesObject:InvalidParent', ...
          'Could not obtain a valid plot figure to hold this %s object.', obj.ClassName);
      end
    end
  end
  
  methods(Abstract, Static)
    options  = DefaultOptions()
  end
  
end
