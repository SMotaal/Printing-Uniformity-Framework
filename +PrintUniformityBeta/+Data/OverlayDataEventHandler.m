classdef OverlayDataEventHandler < PrintUniformityBeta.Data.DataEventHandler
  %OVERLAYDATALISTENER Overlay Data Event Handler Superclass
  %   Detailed explanation goes here
  
  properties
  end
  
  events
    OverlayChange             % Overlay object has changed (not used!)
    
    OverlayDataChange         % Overlay data has changed (predicate to labels or plots change)
    OverlayStyleChange        % Overlay style has changed (predicate to labels or plots change)
    
    OverlayPlotsDataChange    % Overlay plots data has changed (need to refresh overlay plots)
    OverlayPlotsStyleChange   % Overlay style has changed
    
    OverlayLabelsDataChange   % Overlay labels data has changed (overlay labels)
    OverlayLabelsStyleChange  % Overlay style has changed
  end
  
  methods
    function obj = OverlayDataEventHandler()
      obj = obj@PrintUniformityBeta.Data.DataEventHandler;  % Calls obj.attachDataEvents;
      
      obj.attachSelfEventListeners('OverlayDataEventHandlers', {'OverlayChange', ...
        'OverlayDataChange',        'OverlayStyleChange', ...
        'OverlayPlotsDataChange',   'OverlayPlotsStyleChange', ...
        'OverlayLabelsDataChange',  'OverlayLabelsStyleChange', ...
        });
      
      % obj.attachSelfPropertyListeners('OverlayDataEventHandlers', {});
    end
    
    function registerOverlayDataEventHandler(obj, handler)
      obj.registerEventHandler('OverlayDataEventHandlers', handler);
    end
    
  end
  
  methods (Abstract)
    % consumed = OnOverlayDataChange(obj, source, event)
    % consumed = OnOverlayStyleChange(obj, source, event)
    
    % consumed = OnOverlayPlotsDataChange(obj, source, event)
    % consumed = OnOverlayPlotsStyleChange(obj, source, event)
    
    % consumed = OnOverlayLabelsDataChange(obj, source, event)
    % consumed = OnOverlayLabelsStyleChange(obj, source, event)
  end
  
  
end

