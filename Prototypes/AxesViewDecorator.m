classdef AxesViewDecorator < GrasppeDecorator
  %AXESVIEWDECORATOR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    DecoratingProperties = {'View'};
  end
  
  properties (SetObservable, GetObservable)
    View
  end
  
  methods
    function obj = AxesViewDecorator(component)
      obj@GrasppeDecorator(component);
    end
    
    function value = getView(obj)
    end
    function setView(obj, value)
    end
  end
  
  methods(Static, Hidden)
    function options  = DefaultOptions()
      options = [];
    end
  end
  
  
end

