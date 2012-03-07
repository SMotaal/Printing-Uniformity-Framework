classdef InFigureObject < HandleGraphicsObject
  %INFIGUREOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    ParentFigure
  end
  
  methods
    function obj = InFigureObject(varargin)
      obj = obj@HandleGraphicsObject(varargin{:});
    end
    
    function set.ParentFigure(obj, parentFigure)
      try
        if ~AxesObject.checkInheritence(parentFigure, 'FigureObject')
          error('Grasppe:ParentFigure:NotFigure', 'Attempt to set parent figure to a non-figure object.');
        end
        obj.ParentFigure = parentFigure;
        obj.Parent = parentFigure.Handle;
      catch err
        disp(err);
        obj.ParentFigure = [];
      end
      
    end
  end
  
end

