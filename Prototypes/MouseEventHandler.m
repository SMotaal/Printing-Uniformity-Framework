classdef MouseEventHandler < EventHandler
  %MOUSEEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    MouseEventHandlers
    MouseDownStartPosition = [];
    MousePosition = [];
  end
  
  events
    MouseDown
    MouseUp
    MouseWheel
    MouseMotion
    
    MouseClick
    MouseDoubleClick
    
    MousePan
  end
  
  methods
    
    function registerMouseEventHandler(obj, handler)
      obj.registerEventHandler('MouseEventHandlers', handler);
    end
    
    function mouseUp(obj, source, event)
      notify(obj, 'MouseUp', event);
      callEventHandlers('Mouse', 'mouseUp', source, event);
    end
    
    function mouseWheel(obj, source, event)
      notify(obj, 'MouseWheel', event);
      callEventHandlers('Mouse', 'mouseWheel', source, event);
    end
    
    function mouseDown(obj, source, event)
      notify(obj, 'MouseDown', event);
      callEventHandlers('Mouse', 'mouseDown', source, event);
    end
    
    function mouseMotion(obj, source, event)
      notify(obj, 'MouseMotion', event);
      obj.processMouseEvent(source, 'motion');
      callEventHandlers('Mouse', 'mouseMotion', source, event);
    end
    
    function mouseClick(obj, source, event)
      notify(obj, 'MouseClick', event);
      callEventHandlers('Mouse', 'mouseMotion', source, event);
    end
    
    function mouseDoubleClick(obj, source, event)
      notify(obj, 'MouseDoubleClick', event);
      callEventHandlers('Mouse', 'mouseDoubleClick', source, event);
    end
    
    function mousePan(obj, source, event)
      notify(obj, 'MouseDown', event);
      callEventHandlers('Mouse', 'mousePan', source, event);
    end
    
    function processMouseEvent(obj, source, type)
      persistent lastDownTic lastUpTic ...
        lastDownID lastUpID ...
        lastDownXY lastUpXY ...
        fireClickTimer;
      
      doubleClickRate     = 0.25;
      panMultiplierRate   = 45;     % per second
      
      currentXY           = get(0,'PointerLocation');
      
      lastDownDeltaXY     = [0 0];
      try lastDownDeltaXY = currentXY - lastDownXY; end
      
      lastDownToc         = 0;
      try lastDownToc     = toc(lastDownTic); end
      
      lastUpToc           = 0;
      try lastUpToc       = toc(lastUpTic); end
      
      lastDownSameID      = false;
      try lastDownSameID  = isequal(lastDownID, obj.ID); end
      
      lastUpSameID        = false;
      try lastUpSameID    = isequal(lastUpID, obj.ID); end
      
      try
        if isequal(obj.ComponentType,  'figure')
          disp(sprintf('Selection type is %s.', obj.handleGet('SelectionType')));
        else
          disp(sprintf('Selection type is %s.', obj.ParentFigure.handleGet('SelectionType')));
        end
      end
      
      if isempty(fireClickTimer) || ~isvalid(fireClickTimer)
        fireClickTimer = timer( 'StartDelay', doubleClickRate);
      end
      
      event = varStruct(type, doubleClickRate, panMultiplierRate, ...
        currentXY, lastDownDeltaXY, lastDownToc, lastUpToc, lastDownSameID, lastUpSameID);
      
      switch lower(type)
        case 'down'
          if isempty(lastDownTic)
            lastDownTic = tic;
          end

          try stop(fireClickTimer); end
          
          lastDownID  = obj.ID;
          lastDownXY  = currentXY;
          
          obj.mouseDown(source, MouseEventData('down'));
        case 'up'
          lastUpTic = tic;
          lastUpID  = obj.ID;
          lastUpXY  = currentXY;
          
          if lastDownToc < doubleClickRate && lastUpToc > doubleClickRate;
            try start(fireClickTimer); end
            fireClickTimer.TimerFcn = {@obj.mouseClick, source, event};
            lastDownTic = [];
          elseif lastDownToc < doubleClickRate && lastUpToc < doubleClickRate;
            obj.mouseDoubleClick(source, event);
            lastDownTic = [];
          end
        case 'motion'
          if lastDownToc > lastUpToc
            obj.mousePan(obj, source, event)
          end
          obj.mouseMotion(obj, source, event)
        case 'wheel'
          obj.mouseWheel(obj, source, event)
        otherwise
      end
      
    end
    
  end
  
  
  
  
end

