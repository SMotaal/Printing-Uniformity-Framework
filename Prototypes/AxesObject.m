classdef AxesObject < InFigureObject
  %AXESOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  properties (Transient, Hidden)
    ComponentType = 'axes';
    
    ComponentProperties = { ...
     'Box', 'Color', 'Units'}; %, 'Position'
   
   %{'PositionMode', 'ActivePositionProperty'}, 
   
   
    ComponentEvents = { ...
      };
    
  end
  
  properties
    Color, Units, Box, PositionMode
  end
  
  properties
    Position, OuterPosition
  end
  
  methods (Access=protected)
    
    function obj = AxesObject(varargin)
      obj = obj@InFigureObject(varargin{:});
    end
    
  end
  
  methods
        
    function position = get.Position(obj)
      position = obj.get('Position');
    end
    
    function set.Position(obj, value)
      obj.setPosition(value, 'position');
      obj.Position = value;
    end
    
    function set.OuterPosition(obj, value)
      obj.setPosition(value, 'outerposition');
      obj.OuterPosition = value;
    end
    
  end
  
  methods (Hidden=true)
    
    function setPosition(obj, value, mode)
      
      if ~obj.IsHandled
        return;
      end
      
      if ~exist('mode', 'var')
        if isempty(obj.PositionMode)
          mode = 'outerposition';
        else
          mode = obj.PositionMode;
        end
      end
      
%       obj.set('ActivePositionProperty', mode);
      
      numeric   = isnumeric(value);
      relative  = ~isinteger(value) && numeric && all(value>=0) && all(value<=1);      
      integer   = isinteger(value) || isInteger(value);
      double    = numeric && ~relative;
      
      currentUnits = obj.get('Units');
      
      try
        if relative
          obj.set('ActivePositionProperty', mode, 'Units', 'normalized', 'Position', value);
        elseif integer
          obj.set('ActivePositionProperty', mode, 'Units', 'pixels', 'Position', value);
        end
      end
      
      obj.set('Units', currentUnits);      
    end
    
  end
  
  
  methods(Abstract, Static, Hidden)
    options  = DefaultOptions()
    obj = createAxesObject()
  end

  
end

