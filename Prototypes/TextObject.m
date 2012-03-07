classdef TextObject < InAxesObject
  %TEXTOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient)
    ComponentType = 'text';
    
    ComponentProperties = { ...
     {'Text', 'String'}, 'Position', 'Color', 'Units'};
    
    ComponentEvents = { ...
      };
    
  end
  
  
  properties
    Text
  end
  
  properties
    Color, Units, Position
  end
  
%   properties (Dependent)
%     Position
%   end

  methods
    function set.Text(obj, value)
      obj.Text = value;
      obj.set('String', value);
    end
  end

  methods (Access=protected)
    
    function obj = TextObject(varargin)
      obj = obj@InAxesObject(varargin{:});
    end
    
  end

  
  
  methods(Abstract, Static)
    options  = DefaultOptions()
    obj = createTextObject()
  end

  
end

