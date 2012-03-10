classdef KeyEventHandler < EventHandler
  %KEYEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    KeyEventHandlers
    
    LastKeyEvent
  end
  
  methods
    
    function registerKeyEventHandler(obj, handler)
      obj.registerEventHandler('KeyEventHandlers', handler);
    end
    
    function consumed = keyPress(obj, event, source)
      event.id = cputime;
      consumed = false; event.consumed = false;
      handlers = obj.KeyEventHandlers;
      if iscell(handlers) && ~isempty(handlers)
        for i = 1:numel(handlers)
          try
            consumed = handlers{i}.keyPress(event, obj);
            if consumed
              event.consumed = consumed;
            end
%               return; end
          end
        end
      end
      consumed = event.consumed;
    end
    
    function consumed = keyRelease(obj, event, source)
      consumed = false;
      handlers = obj.KeyEventHandlers;
      if iscell(handlers) && ~isempty(handlers)
        for i = 1:numel(handlers)
          try
            consumed = handlers{i}.keyRelease(event, obj);
            if consumed, return; end
          end
        end
      end
    end
    
  end
  
end

