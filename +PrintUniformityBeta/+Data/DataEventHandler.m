classdef DataEventHandler < GrasppeAlpha.Core.EventHandler
  %DATAEVENTHANDLER Data Event Handler Superclass
  %   Detailed explanation goes here
  
  properties
    % DataSource            % Handlers-to-DataSource
  end
  
  events
    DataChange
    DataSourceChange
  end
  
  methods
    function obj = DataEventHandler()
      obj                       = obj@GrasppeAlpha.Core.EventHandler;
      
      obj.attachSelfEventListeners('DataEventHandlers', {'DataChange', 'DataSourceChange'});
      % obj.attachSelfPropertyListeners('DataEventHandlers', {'DataSource'});   % 'Change' suffix implied
    end
    
    function registerDataEventHandler(obj, handler)
      obj.registerEventHandler('DataEventHandlers', handler);
    end
    
  end
  
  methods (Abstract)
    % consumed = OnDataChange(obj, source, event)
    % consumed = OnDataSourceChange(obj, source, event)
  end
  
end

