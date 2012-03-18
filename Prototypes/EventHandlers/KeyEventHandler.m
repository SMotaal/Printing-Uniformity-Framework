classdef KeyEventHandler < EventHandler
  %KEYEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    KeyEventHandlers
    LastKeyEvent
    KeyPressEvents = 0;
  end
  
  properties
    IsAltDown
    IsControlDown
    IsCommandDown
    IsShiftDown
  end
  
  methods
    
    function registerKeyEventHandler(obj, handler)
      obj.registerEventHandler('KeyEventHandlers', handler);
    end
    
    function consumed = keyPress(obj, source, event)
      if obj.KeyPressEvents >5
        return;
      end
      obj.KeyPressEvents = obj.KeyPressEvents + 1;
      consumed = obj.callEventHandlers('Key', 'keyPress', source, event);
      obj.KeyPressEvents = obj.KeyPressEvents - 1;
    end
    
    function consumed = keyRelease(obj, source, event)
      
      consumed = obj.callEventHandlers('Key', 'keyRelease', source, event);
%       consumed = false;
%       handlers = obj.KeyEventHandlers;
%       if iscell(handlers) && ~isempty(handlers)
%         for i = 1:numel(handlers)
%           try
%             consumed = handlers{i}.keyRelease(obj, event);
%             if consumed, return; end
%           end
%         end
%       end
    end
    
  end
  
end

