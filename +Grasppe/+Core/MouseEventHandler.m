classdef MouseEventHandler < Grasppe.Core.Prototype & Grasppe.Core.EventHandler
  %KEYEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    MouseEventHandlers
    MousePressEvents = 0;
  end
  
  properties
  end
  
  events
    MouseDown
    MouseUp
    MouseMotion
    MouseWheel
    
    MouseClick
    MouseDoubleClick
    MousePan
    
  end
  
  methods
    
    function obj = MouseEventHandler()
      obj = obj@Grasppe.Core.EventHandler;
      obj.attachMouseEvents;
    end
    
    function attachMouseEvents(obj)
      events = {'MouseDown', 'MouseUp', 'MouseMotion', 'MouseWheel'};
      for m = 1:numel(events)
        obj.addlistener(events{m}, @obj.triggerMouseEvent);
      end
    end
    
    function registerMouseEventHandler(obj, handler)
      obj.registerEventHandler('MouseEventHandlers', handler);
    end
    
    function triggerMouseEvent(obj, source, event, eventName)
      try if nargin<4, eventName = event.EventName; end; end
      disp(WorkspaceVariables);
      
      try
        switch (event.EventName)
          case 'MouseUp'
            obj.processMouseEvent(source, 'up', event);       % object.mouseUp(source, event);
          case 'MouseDown'
            obj.processMouseEvent(source, 'down', event);     % object.mouseDown(source, event);
          case 'MouseMotion'
            obj.processMouseEvent(source, 'motion', event);   % object.mouseMotion(source, event);
          case 'MouseWheel'
            obj.processMouseEvent(source, 'wheel', event);    % object.mouseWheel(source, event);
        end
      catch err
        disp(err.message);
      end
      
      %disp(event.Sou);
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
          try lastMouseStateHandle = figureObject.handleGet('CurrentObject')
          catch, lastMouseStateHandle = []; end
          
          lastDownTic = tic;
          
          lastDownID  = obj.ID;
          lastDownXY  = currentXY;
          
          %obj.mouseDown(source, Grasppe.Core.MouseEventData('down'));
          
          %           dispf('Down type is %s.', figureObject.handleGet('SelectionType'));
          
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
            % obj.mouseClick(source, event);
          elseif isequal(selectionType, 'open')
            % obj.mouseDoubleClick(source, event);
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
            
            try
              currentObject = get(lastMouseStateHandle, 'UserData');
              dispf('Panning %s', currentObject);
            end
              %notify(currentObject, 'MousePan'
            % obj.mousePan(source, event);
          else
            % obj.mouseMotion(source, event);
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
          
          % obj.mouseWheel(source, event);
          
        otherwise
      end
      
    end
    
    
    %     function consumed = OnKeyPress(obj, source, event)
    %       disp (['KeyPress for ' obj.ID]);
    %       if obj.KeyPressEvents >5
    %         return;
    %       end
    %       obj.KeyPressEvents = obj.KeyPressEvents + 1;
    %       consumed = obj.callEventHandlers('Key', 'KeyPress', source, event);
    %       obj.KeyPressEvents = obj.KeyPressEvents - 1;
    %     end
    %
    %     function consumed = OnKeyRelease(obj, source, event)
    %       disp (['KeyRelease for ' obj.ID]);
    %       consumed = obj.callEventHandlers('Key', 'KeyRelease', source, event);
    %     end
    
  end
  
end

