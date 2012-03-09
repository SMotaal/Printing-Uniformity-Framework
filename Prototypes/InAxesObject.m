classdef InAxesObject < GraphicsObject
  %INAXESOBJECT Superclass for plot and annotation objects
  %   Detailed explanation goes here
  
  properties (SetObservable, GetObservable)
    ParentAxes
  end
  
  properties (Dependent)
    ParentFigure
  end
  
  
  methods (Hidden)
    function obj = InAxesObject(varargin)
      obj = obj@GraphicsObject(varargin{:});
    end
  end
  
  methods
    function set.ParentAxes(obj, parentAxes)
      try
        if ~InAxesObject.checkInheritence(parentAxes, 'AxesObject')
          error('Grasppe:ParentAxes:NotAxes', 'Attempt to set parent axes to a non-axes object.');
        end
        obj.ParentAxes = parentAxes;
        obj.Parent = parentAxes.Handle;
      catch err
        try debugStamp(obj.ID); end
        disp(err);
        obj.ParentAxes = [];
      end
      
    end
    
    function parentFigure = get.ParentFigure(obj)
      parentFigure = [];
      try parentFigure = obj.ParentAxes.ParentFigure; end
    end
    
  end
  
end

