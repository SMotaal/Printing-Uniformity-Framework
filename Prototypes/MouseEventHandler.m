classdef MouseEventHandler < EventHandler
  %MOUSEEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    MouseEventHandlers
  end
  
  methods
    
    function registerMouseEventHandler(obj, handler)
      obj.registerEventHandler('MouseEventHandlers', handler);
    end
    
    function mouseUp(obj, event, source)
      handlers = obj.MouseEventHandlers;
      if iscell(handlers) && ~isempty(handlers)
        for i = 1:numel(handlers)
          try
            handlers{i}.mouseUp(event, obj);
          end
        end
      end
    end
    
    function mouseDown(obj, event, source)
      handlers = obj.MouseEventHandlers;
      if iscell(handlers) && ~isempty(handlers)
        for i = 1:numel(handlers)
          try
            handlers{i}.mouseDown(event, obj);
          end
        end
      end
    end    
    
  end
  
  
  
  
end

