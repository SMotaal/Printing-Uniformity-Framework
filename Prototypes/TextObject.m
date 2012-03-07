classdef TextObject < InAxesObject
  %TEXTOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    ComponentType = 'text';
    
    ComponentProperties = { ...
     {'Text', 'String'}, 'Position', 'Color', 'Units'};
    
    ComponentEvents = {};
  end
  
  
  properties  (SetObservable) 
    Text, Color, Units, Position    
  end

  methods
    function set.Text(obj, value)
      obj.Text = value;
      obj.set('String', value);
    end
  end

  methods (Access=protected, Hidden)
    
    function obj = TextObject(varargin)
      obj = obj@InAxesObject(varargin{:});
    end
    
  end

  
  
  methods(Abstract, Static, Hidden)
    options  = DefaultOptions()
    obj = createTextObject()
  end

  
end

