classdef TextObject < GrasppePrototype & InAxesObject & DecoratedObject
  %TEXTOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    ComponentType = 'text';
    
    ComponentProperties = { ...
      {'Text', 'String'}, 'Position', 'Color', 'Units'};
    
    ComponentEvents = {};
  end
  
  
  properties (SetObservable, GetObservable)
    Text, Color, Units, Position
  end
  
    methods (Access=protected, Hidden)
    
    function obj = TextObject(varargin)
      obj = obj@GrasppePrototype;
      obj = obj@DecoratedObject();
      obj = obj@InAxesObject(varargin{:});
      
%       FontDecorator(obj);
    end
end
  
  methods
    function set.Text(obj, value)
      obj.Text = value;
      obj.handleSet('String', value);
    end
  end
  
  methods (Access=protected, Hidden)    
    function decorateComponent(obj)
      obj.decorateComponent@DecoratedObject();
      FontDecorator(obj);
    end
  end
  
  
  
  methods(Abstract, Static, Hidden)
    options  = DefaultOptions()
    obj = Create()
  end
  
  
end

