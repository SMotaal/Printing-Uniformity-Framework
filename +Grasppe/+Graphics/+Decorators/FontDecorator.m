classdef FontDecorator < Grasppe.Core.Prototype & Grasppe.Core.Decorator
  %AXESVIEWDECORATOR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    DecoratingProperties = {'FontAngle', 'FontName', 'FontSize', 'FontUnits', 'FontWeight'};
  end
  
  properties (SetObservable, GetObservable)
    FontAngle, FontName, FontSize, FontUnits, FontWeight
  end
  
  methods
    function obj = FontDecorator(varargin)
      obj = obj@Grasppe.Core.Prototype;
      obj = obj@Grasppe.Core.Decorator(varargin{:});
    end
    
  end
  
  methods(Static, Hidden)
    function options  = DefaultOptions()
      options = [];
    end
  end
  
  
end

