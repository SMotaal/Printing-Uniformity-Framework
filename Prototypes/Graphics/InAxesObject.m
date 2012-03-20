classdef InAxesObject < GrasppePrototype & GraphicsObject
  %INAXESOBJECT Superclass for plot and annotation objects
  %   Detailed explanation goes here
  
  properties (SetObservable, GetObservable)
    ParentAxes
  end
  
  properties (Dependent)
    ParentFigure
%     HasParentAxes
  end
  
  
  methods (Hidden)
    function obj = InAxesObject(varargin)
      obj = obj@GrasppePrototype;
      obj = obj@GraphicsObject(varargin{:});
    end
  end
  
  methods
    function set.ParentAxes(obj, parentAxes)
      try
        if isempty(parentAxes), return; end        
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
    
%     function check = get.HasParentFigure(obj)
%       check = false;
%       try check = HasParentAxes && InAxesObject.checkInheritence(obj.ParentAxes.ParentFigure, 'FigureObject'); end
%     end    
%     
%     function check = get.HasParentAxes(obj)
%       check = false;
%       try check = InAxesObject.checkInheritence(obj.ParentAxes, 'AxesObject'); end
%     end
    
    function parentFigure = get.ParentFigure(obj)
      parentFigure = [];       
      if ~obj.HasParentAxes return; end
      try parentFigure = obj.ParentAxes.ParentFigure; end
    end
    
  end
  
end

