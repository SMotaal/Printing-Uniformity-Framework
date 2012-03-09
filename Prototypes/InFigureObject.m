classdef InFigureObject < GraphicsObject
  %INFIGUREOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (SetObservable, GetObservable)
    ParentFigure
  end
  
  properties
    Padding = [20 20 20 20]
  end
  
  methods
    function value = get.Padding(obj)
      value = obj.Padding;
    end
    
    function set.Padding(obj, value)
      obj.Padding = changeSet(obj.Padding, value);
      try obj.resizeComponent; end
    end
  end
  
  methods
    function obj = InFigureObject(varargin)
      obj = obj@GraphicsObject(varargin{:});
    end
    
    function set.ParentFigure(obj, parentFigure)
      try
        if ~AxesObject.checkInheritence(parentFigure, 'FigureObject')
          error('Grasppe:ParentFigure:NotFigure', 'Attempt to set parent figure to a non-figure object.');
        end
        obj.ParentFigure = parentFigure;
        obj.Parent = parentFigure.Handle;
      catch err
        try debugStamp(obj.ID); end
        disp(err);
        obj.ParentFigure = [];
      end
      
    end
  end
  
end

