classdef TitleTextObject < TextObject
  %TITLETEXTOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  
  methods (Access=protected)
    function obj = TitleTextObject(parentAxes, varargin)
      obj = obj@TextObject(varargin{:},'ParentAxes', parentAxes);
    end
    function createComponent(obj, type)
      obj.createComponent@GrasppeComponent(type);
      
      position = obj.Position;
      position([1 2]) = [0.5 1];
      obj.set('Position', position);
      obj.set('HorizontalAlignment', 'center');
    end
  end
  
  methods
    
    function updateTitle(obj)
      obj.Text = obj.ParentFigure.Title;
    end
  end
  
  methods (Static)
    function options  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = false;
      Text          = 'Title';
      Parent        = 0;
      
      options = WorkspaceVariables(true);
    end
    
    function obj = createTextObject(parentAxes, varargin)
      obj = TitleTextObject(parentAxes, varargin{:});
    end
  end
  
end

