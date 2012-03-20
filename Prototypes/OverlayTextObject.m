classdef OverlayTextObject < GrasppePrototype & TextObject
  %TITLETEXTOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  
  methods (Access=protected)
    function obj = OverlayTextObject(parentAxes, varargin)
      obj = obj@GrasppePrototype;
      obj = obj@TextObject(varargin{:},'ParentAxes', parentAxes);
    end
    function createComponent(obj, type)
      obj.createComponent@GrasppeComponent(type);
      
      position = obj.Position;
      position([1 2]) = [0 0];
      obj.handleSet('Position', position);
      obj.handleSet('HorizontalAlignment', 'Left');
      
      obj.FontSize = 8;
    end
  end
  
  methods
  end
  
  methods (Static)
    function options  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = false;
      Text          = '';
      Parent        = 0;
      
      options = WorkspaceVariables(true);
    end
    
    function obj = Create(parentAxes, varargin)
      obj = OverlayTextObject(parentAxes, varargin{:});
    end
  end
  
end

