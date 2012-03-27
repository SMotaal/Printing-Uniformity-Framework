classdef GrasppeEventHandler < GrasppePrototype
  %GRASPPEEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  events
    Test
  end
  
  methods
    
    function defineDynamicEventFunctions(obj, eventMeta) % functionName, functionCallback)
%       propertyNames = properties(obj);
%       
%       eventMeta     = eventsMeta(m);
%       %definingClass = eventMeta.DefiningClass.Name;
%       
%       % Define aspect names
%       eventName     = eventMeta.Name;
%       eventFunction = [eventName 'Function'];
%       eventCallback = ['On' eventName];
%       
%       % Tally undefined event function properties
%       if ~any(strcmpi(eventFunction, propertyNames))
%         n = n + 1;
%         newFunctions{n} = eventFunction;
%       end
    end
    
    function attachEventFunctions(obj)
      
      eventsMeta    = obj.MetaClass.EventList;    
      propertyNames = properties(obj);
      
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
        eventCallback = ['On' eventName];
        
        
        if ~any(strcmpi(eventFunction, propertyNames))
          addprop(obj, eventFunction);
          
          propertyMeta  = findprop(obj, eventFunction);
          propertyMeta.Hidden = true;
        end
        
        obj.(eventFunction) = eventCallback; %str2func(['@obj.' eventCallback]);
        
        obj.addlistener(eventName, @obj.callbackEvent);
        
      end
      
    end
    
    function callbackEvent(obj, source, event)
      disp(toString(event));
      
      eventFunction = [event.EventName 'Function'];
      
      try
        feval(str2func(['@' obj.(eventFunction)]), obj, event);
      catch err
        disp(['Function callback error ' err.identifier ': ' err.message]);
      end
    end
    
    function OnTest(obj, event)
      disp(toString(event));
    end
  end
  
end

