classdef MouseEventHandler < GrasppePrototype & EventHandler
  %MOUSEEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    MouseEventHandlers
    MouseButtonState;
    %     MouseDownStartPosition = [];
    %     MousePosition = [];
  end
  
  properties (Constant)
    %
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
      %       disp(sprintf('%s <== %s', obj.ID, 'MouseUp'));
      consumed = obj.callEventHandlers('Mouse', 'mouseUp', source, event);
      %       notify(obj, 'MouseUp', event);
    end
    
    function consumed = mouseDown(obj, source, event)
      %       disp(sprintf('%s <== %s', obj.ID, 'MouseDown'));
      consumed = obj.callEventHandlers('Mouse', 'mouseDown', source, event);
      %       notify(obj, 'MouseDown', event);
    end
    
    function consumed = mouseWheel(obj, source, event)
      %       disp(sprintf('%s <== %s', obj.ID, 'MouseWheel'));
      %       if ~event.ScrollingMomentum
      %         disp(toString(event));
      %       end
      consumed = obj.callEventHandlers('Mouse', 'mouseWheel', source, event);
      %       notify(obj, 'MouseWheel', event);
    end
    
    function consumed = mouseMotion(obj, source, event)
      %       obj.processMouseEvent(source, 'motion');
      consumed = obj.callEventHandlers('Mouse', 'mouseMotion', source, event);
      %       notify(obj, 'MouseMotion', event);
    end
    
    function mouseClickCallback(obj, src, evt, source, event)
      try consumed = obj.mouseClick(source, event); end
    end
    
    function consumed = mouseClick(obj, source, event)
      %       disp(sprintf('%s <== %s', obj.ID, 'MouseClick'));
      consumed = obj.callEventHandlers('Mouse', 'MouseClick', source, event);
      %       notify(obj, 'MouseClick', event);
    end
    
    function consumed = mouseDoubleClick(obj, source, event)
      %       disp(sprintf('%s <== %s', obj.ID, 'MouseDoubleClick'));
      consumed = obj.callEventHandlers('Mouse', 'mouseDoubleClick', source, event);
      %       notify(obj, 'MouseDoubleClick', event);
    end
    
    function consumed = mousePan(obj, source, event)
      consumed = obj.callEventHandlers('Mouse', 'mousePan', source, event);
      %       notify(obj, 'MousePan', event);
    end
    
    function processMouseEvent(obj, source, type, event)
      persistent lastDownTic lastUpTic ...
        lastDownID lastUpID ...
        lastDownXY lastUpXY ...
        lastPanTic lastScrollSwipeTic lastScrollSwipeToc  ...
        fireClickTimer lastMouseStateHandle MouseButtonState;
      
      doubleClickRate     = 0.5;
      
      scrollingThreshold  = 0.275;
      
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
      
      event = varStruct(event, type, doubleClickRate, ...
        currentXY, lastDownDeltaXY, lastDownToc, lastUpToc, lastDownSameID, lastUpSameID);
      
      
      figureObject = [];
      try
        if isequal(obj.ComponentType,  'figure')
          figureObject = obj;
          %           selectionType = obj.handleGet('SelectionType');
          %           currentObject = obj.handleGet('CurrentObject');
        else
          figureObject = obj.ParentFigure;
          %           selectionType = obj.ParentFigure.handleGet('SelectionType');
          %           currentObject = obj.ParentFigure.handleGet('CurrentObject');
        end
      end
      
      switch lower(type)
        case 'down'
          MouseButtonState = 'down';
          try lastMouseStateHandle = figureObject.handleGet('CurrentObject');
          catch, lastMouseStateHandle = []; end
          lastDownTic = tic;
          
          lastDownID  = obj.ID;
          lastDownXY  = currentXY;
          
          obj.mouseDown(source, MouseEventData('down'));
          
          %           disp(sprintf('Down type is %s.', figureObject.handleGet('SelectionType')));
          
        case 'up'
          
          MouseButtonState = 'up';
          %           try lastMouseStateHandle = figureObject.handleGet('CurrentObject'); end
          %           catch, lastMouseStateHandle = []; end
          lastMouseStateHandle = [];
          lastUpTic = tic;
          lastUpID  = obj.ID;
          lastUpXY  = currentXY;
          lastPanTic = [];
          
          selectionType = obj.handleGet('SelectionType');
          if isequal(selectionType, 'normal') && lastDownToc < doubleClickRate
            obj.mouseClick(source, event);
          elseif isequal(selectionType, 'open')
            obj.mouseDoubleClick(source, event);
          end
          
        case 'motion'
          isPanning = true;
          try isPanning = isequal(lastMouseStateHandle, figureObject.handleGet('CurrentObject')); end
          try isPanning = isPanning && isequal(MouseButtonState, 'down'); end
          if isPanning
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
            obj.mousePan(source, event);
          else
            obj.mouseMotion(source, event);
          end
        case 'wheel'
          lastScrollToc = 0;
          try lastScrollToc = toc(lastScrollSwipeTic); end;
          
          % try disp([lastScrollToc lastScrollSwipeToc lastScrollToc/lastScrollSwipeToc]); end
          
          lastScrollSwipeTic = tic;
          % lastScrollSwipeToc = lastScrollToc;
          
          event.Scrolling.Length        = lastScrollToc;
          % event.Scrolling.Swipe         = lastScrollSwipeToc;
          event.Scrolling.Vertical      = [event.event.VerticalScrollCount event.event.VerticalScrollAmount];
          event.Scrolling.Momentum      = lastScrollToc < scrollingThreshold;
          
          obj.mouseWheel(source, event);
          
        otherwise
      end
      
    end
    
  end
  
  
  
  
end

