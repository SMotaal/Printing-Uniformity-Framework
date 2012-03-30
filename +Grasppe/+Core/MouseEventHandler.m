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
    MouseScroll
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
      try obj.processMouseEvent(source, eventName, event); end
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
      
      %       eventdata = varStruct(event.Data, type, doubleClickRate, ...
      %         currentXY, lastDownDeltaXY, lastDownToc, lastUpToc, lastDownSameID, lastUpSameID);
      
      sourceData = event.Data;
      
      eventData.Type             = type; ...
        eventData.DoubleClickRate  = doubleClickRate; ...
        eventData.CurrentXY        = currentXY; ...
        eventData.LastDownDeltaXY  = lastDownDeltaXY; ...
        eventData.LastDownToc      = lastDownToc; ...
        eventData.LastUpToc        = lastUpToc; ...
        eventData.LastDownSameID   = lastDownSameID; ...
        eventData.LastUpSameID     = lastUpSameID;
      
      event.Data = eventData;
      
      
      figureObject = [];
      try
        if isequal(obj.ComponentType,  'figure')
          figureObject = obj;
        else
          figureObject = obj.ParentFigure;
        end
      end
      
      try currentObject = get(lastMouseStateHandle, 'UserData'); end
      
      switch lower(type)
        case 'mousedown'
          MouseButtonState = 'down';
          try lastMouseStateHandle = figureObject.handleGet('CurrentObject');
          catch lastMouseStateHandle = [], end
          
          lastDownTic = tic;
          
          lastDownID  = obj.ID;
          lastDownXY  = currentXY;
          
          %obj.mouseDown(source, Grasppe.Core.MouseEventData('down'));
          
          %           dispf('Down type is %s.', figureObject.handleGet('SelectionType'));
          
        case 'mouseup'
          
          MouseButtonState = 'up';
          %           try lastMouseStateHandle = figureObject.handleGet('CurrentObject'); end
          %           catch, lastMouseStateHandle = []; end
          lastMouseStateHandle = [];
          lastUpTic = tic;
          lastUpID  = obj.ID;
          lastUpXY  = currentXY;
          lastPanTic = [];
          try
            if isobject(currentObject)
              selectionType = obj.handleGet('SelectionType');
              if isequal(selectionType, 'normal') && lastDownToc < doubleClickRate
                event.Name = 'MouseClick';
                Grasppe.Core.EventHandler.callbackEvent(obj, event, currentObject, event.Name);
              elseif isequal(selectionType, 'open')
                event.Name = 'MouseMouseDoubleClick';
                Grasppe.Core.EventHandler.callbackEvent(obj, event, currentObject, event.Name);
              end
            end
          end
          
        case 'mousemotion'
          isPanning = true;
          try isPanning = isequal(lastMouseStateHandle, figureObject.handleGet('CurrentObject')); end
          try isPanning = isPanning && isequal(MouseButtonState, 'down'); end
          if isPanning
            if isempty(lastPanTic)
              lastPanTic = tic;
              event.Data.Panning.Length  = 0;
            else
              lastPanToc = 0;
              try lastPanToc = toc(lastPanTic); end
              eventData.Panning.Length  = lastPanToc;
            end
            event.Data.Panning.Start   = lastDownXY;
            event.Data.Panning.Current = currentXY;
            event.Data.Panning.Delta   = lastDownDeltaXY;
            
          try
            if isobject(currentObject)
              event.Name = 'MousePan';
              Grasppe.Core.EventHandler.callbackEvent(obj, event, currentObject, event.Name);
            end
          end
            
            
%             try
%               currentObject = get(lastMouseStateHandle, 'UserData');
%               dispf('Panning %s', currentObject);
%             end
            %notify(currentObject, 'MousePan'
            % obj.mousePan(source, event);
          else
          try
            if isobject(currentObject)
              event.Name = 'MouseMotion';
              Grasppe.Core.EventHandler.callbackEvent(obj, event, currentObject, event.Name);
            end
          end
          end
        case 'mousewheel'
          lastScrollToc = 0;
          try lastScrollToc = toc(lastScrollSwipeTic); end;
          
          % try disp([lastScrollToc lastScrollSwipeToc lastScrollToc/lastScrollSwipeToc]); end
          
          lastScrollSwipeTic = tic;
          % lastScrollSwipeToc = lastScrollToc;
          
          try
            event.Data.Scrolling.Length        = lastScrollToc;
            event.Data.Scrolling.Vertical      = [sourceData.VerticalScrollCount sourceData.VerticalScrollAmount];
            event.Data.Scrolling.Momentum      = lastScrollToc < scrollingThreshold;
            disp(event);
          catch err
            disp(err.message);
            disp(event);
            beep;
          end
          
          try
            if isobject(currentObject)
              event.Name = 'MouseWheel';
              Grasppe.Core.EventHandler.callbackEvent(obj, event, currentObject, event.Name);
            end
          end
          
        otherwise
          disp(type);
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

