classdef KeyEventHandler < EventHandler
  %KEYEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    KeyEventHandlers
  end
  
  methods
    
    function registerKeyEventHandler(obj, handler)
      obj.registerEventHandler('KeyEventHandlers', handler);
    end
    
    function keyPress(obj, event, source)
      handlers = obj.KeyEventHandlers;
      if iscell(handlers) && ~isempty(handlers)
        for i = 1:numel(handlers)
          try
            handlers{i}.keyPress(event, obj);
          end
        end
      end
    end
    
    function keyRelease(obj, event, source)
      handlers = obj.KeyEventHandlers;
      if iscell(handlers) && ~isempty(handlers)
        for i = 1:numel(handlers)
          try
            handlers{i}.keyRelease(event, obj);
          end
        end
      end
    end
    
  end
  
end

