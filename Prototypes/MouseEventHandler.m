classdef MouseEventHandler < EventHandler
  %MOUSEEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    MouseEventHandlers
    MouseDownStartPosition = [];
    MousePosition = [];
    MouseButtonState = [];
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
    
    function consumed = mouseUp(obj, source, event)
      disp(sprintf('%s <== %s', obj.ID, 'MouseUp'));
      notify(obj, 'MouseUp', event);
      consumed = obj.callEventHandlers('Mouse', 'mouseUp', source, event);
    end
    
    function consumed = mouseDown(obj, source, event)
      disp(sprintf('%s <== %s', obj.ID, 'MouseDown'));
      notify(obj, 'MouseDown', event);
      consumed = obj.callEventHandlers('Mouse', 'mouseDown', source, event);
    end    
    
    function consumed = mouseWheel(obj, source, event)
      disp(sprintf('%s <== %s', obj.ID, 'MouseWheel'));
      notify(obj, 'MouseWheel', event);
      consumed = obj.callEventHandlers('Mouse', 'mouseWheel', source, event);
    end
    
    function consumed = mouseMotion(obj, source, event)
      notify(obj, 'MouseMotion', event);
      obj.processMouseEvent(source, 'motion');
      consumed = obj.callEventHandlers('Mouse', 'mouseMotion', source, event);
    end
    
    function mouseClickCallback(obj, src, evt, source, event)
      consumed = obj.mouseClick(source, event);
    end
    
    function consumed = mouseClick(obj, source, event)
      disp(sprintf('%s <== %s', obj.ID, 'MouseClick'));
      try
        notify(obj, 'MouseClick', event);
      end
      consumed = obj.callEventHandlers('Mouse', 'mouseMotion', source, event);
    end
    
    function consumed = mouseDoubleClick(obj, source, event)
      disp(sprintf('%s <== %s', obj.ID, 'MouseDoubleClick'));
      notify(obj, 'MouseDoubleClick', event);
      consumed = obj.callEventHandlers('Mouse', 'mouseDoubleClick', source, event);
    end
    
    function consumed = mousePan(obj, source, event)
      persistent lastPanTic lastPanXY
%       disp(sprintf('%s <== %s (%s)', obj.ID, 'MousePan', toString(event.PanVector)));

      panMultiplierRate   = 45;     % per second
      panStickyThreshold  = 5;
      panStickyAngle      = 45;
      
      lastPanToc  = 0;
      try lastPanToc = toc(lastPanTic); end
      
      if isempty(lastPanXY) || event.PanVector.Length==0;
        deltaPanXY  = [0 0];
      else
        deltaPanXY  = event.PanVector.Current - lastPanXY;
      end
      
      try
        newView = obj.PlotAxes.View - deltaPanXY;
        
        if panStickyAngle-mod(newView(1), panStickyAngle)<panStickyThreshold || ...
          mod(newView(1), panStickyAngle)<panStickyThreshold
          newView(1) = round(newView(1)/panStickyAngle)*panStickyAngle;
        end
        if panStickyAngle-mod(newView(2), panStickyAngle)<panStickyThreshold || ...
          mod(newView(2), panStickyAngle)<panStickyThreshold
          newView(2) = round(newView(2)/panStickyAngle)*panStickyAngle; % - mod(newView(2), 90)
        end
          obj.PlotAxes.View = newView;
      end
      
      lastPanXY   = event.PanVector.Current;
      lastPanTic  = tic;
      
      notify(obj, 'MousePan', event);
      consumed = obj.callEventHandlers('Mouse', 'mousePan', source, event);
    end
    
    function processMouseEvent(obj, source, type)
      persistent lastDownTic lastUpTic ...
        lastDownID lastUpID ...
        lastDownXY lastUpXY ...
        lastPanTic ...
        fireClickTimer;
      
      doubleClickRate     = 0.5;
      
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
      
      
      if isempty(fireClickTimer) || ~isvalid(fireClickTimer)
        fireClickTimer = timer( 'StartDelay', doubleClickRate);
      end
      
      event = varStruct(type, doubleClickRate, ...
        currentXY, lastDownDeltaXY, lastDownToc, lastUpToc, lastDownSameID, lastUpSameID);
      
      switch lower(type)
        case 'down'
          obj.MouseButtonState = 'down';
          if isempty(lastDownTic) || lastDownToc>1
            lastDownTic = tic;
          end

          try stop(fireClickTimer); end
          
          lastDownID  = obj.ID;
          lastDownXY  = currentXY;
          
          try
            if isequal(obj.ComponentType,  'figure')
              disp(sprintf('Selection type is %s.', obj.handleGet('SelectionType')));
            else
              disp(sprintf('Selection type is %s.', obj.ParentFigure.handleGet('SelectionType')));
            end
          end
          
          
          obj.mouseDown(source, MouseEventData('down'));
        case 'up'
          obj.MouseButtonState = 'up';
          lastUpTic = tic;
          lastUpID  = obj.ID;
          lastUpXY  = currentXY;
          lastPanTic = [];          
          
%           x.ldt = lastDownToc;
%           x.dcr = doubleClickRate;
%           x.lut = lastUpToc;
%           x.cca = lastDownToc < doubleClickRate;
%           x.ccb = lastUpToc > doubleClickRate;
%           x.dca = lastDownToc < doubleClickRate;
%           x.dcb = lastUpToc < doubleClickRate;
%           disp(toString(x));
          
          if lastDownToc < doubleClickRate && lastUpToc > doubleClickRate;
            lastDownTic = [];
            fireClickTimer.TimerFcn = {@obj.mouseClickCallback, source, event};            
            try start(fireClickTimer); end
          elseif lastDownToc < doubleClickRate && lastUpToc < doubleClickRate &&  lastUpToc>0;
            lastDownTic = [];
            obj.mouseDoubleClick(source, event);
          end
        case 'motion'
          if isequal(obj.MouseButtonState, 'down')
            if isempty(lastPanTic)
              lastPanTic = tic;
              event.PanVector.Length  = 0;
            else
              lastPanToc = 0;
              try lastPanToc = toc(lastPanTic); end
              event.PanVector.Length  = lastPanToc;              
            end
            event.PanVector.Start   = lastDownXY;
            event.PanVector.Current = currentXY;
            event.PanVector.Delta   = lastDownDeltaXY;
%             event.PanVector.Rate    = panMultiplierRate;
            obj.mousePan(source, event);
          else
            obj.mouseMotion(source, event);
          end
        case 'wheel'
          obj.mouseWheel(source, event);
        otherwise
      end
      
    end
    
  end
  
  
  
  
end

