classdef GrasppeEventHandler < GrasppePrototype
  %GRASPPEEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  events %(Hidden, ListenAccess=private, NotifyAccess=public)
    Test
  end
  
  methods
    
    function obj = GrasppeEventHandler()
      obj.attachEventFunctions;
    end
    
    function attachEventFunctions(obj)
      
      eventsMeta    = obj.MetaClass.EventList;    
      propertyNames = {obj.MetaClass.PropertyList.Name};
      
      for m = 1:numel(eventsMeta)
        eventMeta     = eventsMeta(m);
        
        % Ignore low-level "native" events
        definingClass = eventMeta.DefiningClass.Name;
        if ~any(strcmpi('GrasppePrototype', superclasses(definingClass)))
          continue;
        end
        
        % Define aspect names
        eventName     = eventMeta.Name;
        eventFunction = [eventName 'Function'];
        eventCallback = {@GrasppeEventHandler.callbackEvent, obj, eventName};
        
        if ~any(strcmpi(eventFunction, propertyNames))
          addprop(obj, eventFunction);
          
          propertyMeta  = findprop(obj, eventFunction);
          % propertyMeta.Hidden         = true;
          propertyMeta.SetObservable  = true;
          propertyMeta.GetObservable  = true;
          propertyMeta.AbortSet       = true;
        end
        
        obj.(eventFunction) = eventCallback; %str2func(['@obj.' eventCallback]);
        
        obj.addlistener(eventName, @obj.callbackEvent);
        
      end
      
    end
    
    function registerEventHandler(obj, group, handler)
      handlers = obj.([group 'EventHandlers']);
      
      if ~iscell(handlers)
        handlers = {};
      end
      
      if ~any(handlers==handler)
        handlers{end+1} = handler;
        obj.([group 'EventHandlers']) = handlers;
      end
    end
    
    function consumed = callEventHandlers(obj, group, name, source, event)
      try
        consumed = false;
        try consumed = event.consumed; end
        
        handlers = obj.([group 'EventHandlers']);
        if iscell(handlers) && ~isempty(handlers)
          for i = 1:numel(handlers)
            try
              consumed = eval([ 'handlers{i}.' name '(obj, event);']);
              event.consumed = event.consumed || consumed;
            end
          end
        end
        consumed = event.consumed;
      end
    end
    
%     function callbackEvent(obj, source, event)
%       disp(toString(event));
%       
%       eventFunction = [event.EventName 'Function'];
%       
%       try
%         feval(str2func(['@' obj.(eventFunction)]), obj, event);
%       catch err
%         disp(['Function callback error ' err.identifier ': ' err.message]);
%       end
%     end
    
    function OnTest(obj, event)
      disp(event);
    end
  end
  
  methods (Static)
    function callbackEvent(source, event, obj, eventName)
      disp(event);
      
      if nargin==2 && isa(source, 'GrasppeEventHandler')
        obj = source;
        eventFunction = ['On' event.EventName];      
      elseif nargin==4 && isa(obj, 'GrasppeEventHandler')
        eventFunction = ['On' eventName];
      else
        return;
      end
          
      try
        feval(str2func(eventFunction), obj, event);
      catch err
        disp(['Function callback error ' err.identifier ': ' err.message]);
      end
    end
        
  end
  
end

