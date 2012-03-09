classdef TextObject < InAxesObject
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

  methods
    function set.Text(obj, value)
      obj.Text = value;
      obj.handleSet('String', value);
    end
  end

  methods (Access=protected, Hidden)
    
    function obj = TextObject(varargin)
      obj = obj@InAxesObject(varargin{:});
    end
    
  end

  
  
  methods(Abstract, Static, Hidden)
    options  = DefaultOptions()
    obj = Create()
  end

  
end

