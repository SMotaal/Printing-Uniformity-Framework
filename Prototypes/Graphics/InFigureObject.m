classdef InFigureObject < GrasppePrototype & GraphicsObject
  %INFIGUREOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (SetObservable, GetObservable)
    ParentFigure
  end
  
  properties
    Padding = [20 20 20 20]
  end
  
  properties (Dependent)
%     HasParentFigure
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
      obj = obj@GrasppePrototype;
      obj = obj@GraphicsObject(varargin{:});
    end
    
%     function check = get.HasParentFigure(obj)
%       check = false;
%       try check = InFigureObject.checkInheritence(obj.ParentFigure, 'FigureObject'); end
%     end
    
    function set.ParentFigure(obj, parentFigure)
      try  
        if isempty(parentFigure), return; end
        if ~InFigureObject.checkInheritence(parentFigure, 'FigureObject')
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

