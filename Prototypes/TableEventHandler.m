classdef TableEventHandler < EventHandler
  %MOUSEEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    TableEventHandlers
  end
  
  methods
    
    function registerTableEventHandlers(obj, handler)
      obj.registerEventHandler('TableEventHandlers', handler);
    end
    
    
    function cellEdit(obj, event, source)
      handlers = obj.TableEventHandlers;
      if iscell(handlers) && ~isempty(handlers)
        for i = 1:numel(handlers)
          try
            handlers{i}.cellEdit(event, obj);
          end
        end
      end
    end
    
    function cellSelect(obj, event, source)
      handlers = obj.TableEventHandlers;
      if iscell(handlers) && ~isempty(handlers)
        for i = 1:numel(handlers)
          try
            handlers{i}.cellSelect(event, obj);
          end
        end
      end
    end
    
  end
  
  
  
  
end

