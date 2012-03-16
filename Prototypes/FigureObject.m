classdef FigureObject < GraphicsObject & EventHandler
  %UPFIGUREOBJECTSMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    ComponentType = 'figure';
    
    ComponentProperties = { ...
      {'WindowTitle', 'Name'}, 'Renderer', {'Toolbar', 'ToolBar'}, {'Menubar', 'MenuBar'}, 'WindowStyle', ...
      'Color', 'Units'};
    
    ComponentEvents = { ...
      'CloseRequestFcn', 'ResizeFcn', 'CreateFcn',    'DeleteFcn', ...
      {'KeyPressFcn', 'WindowKeyPressFcn'}, {'KeyReleaseFcn', 'WindowKeyReleaseFcn'}, ...
      {'ButtonDownFcn', 'WindowButtonDownFcn'}, {'ButtonUpFcn', 'WindowButtonUpFcn'}, ...
      {'ButtonMotionFcn', 'WindowButtonMotionFcn'}, {'ScrollWheelFcn', 'WindowScrollWheelFcn'}};
    
  end
  
  properties %(Dependent)
    ActivePlot, ActiveObject
  end
  
  methods (Hidden)
    function obj = FigureObject(varargin)
      obj = obj@GraphicsObject(varargin{:});
    end
    
    function consumed = mouseDoubleClick(obj, source, event)
      try
        activeObject      = obj.handleGet('CurrentObject');
        if ishandle(activeObject) && isobject(get(activeObject, 'UserData'))
          try obj.ActiveObject  = get(activeObject, 'UserData'); end
          try obj.ActivePlot    = obj.ActiveObject.ParentAxes; end
%         else
%           obj.ActiveObject      = activeObject;
%           obj.ActivePlot        = obj.handleGet('CurrentAxes');
        end
      end
%       %       try
%       %         activeAxes        = obj.handleGet('CurrentAxes');
%       %         if ishandle(activeAxes) && isobject(get(activeAxes, 'UserData'))
%       %           activeAxes      = get(activeAxes, 'UserData');
%       %         end
%       %         obj.ActiveAxes    = activeAxes;
%       %       end
      obj.mouseDoubleClick@GraphicsObject(source, event);
    end
    
    function consumed = mousePan(obj, source, event)
      persistent lastPanTic lastPanXY
      %       disp(sprintf('%s <== %s (%s)', obj.ID, 'MousePan', toString(event.PanVector)));
      
      panMultiplierRate   = 45;     % per second
      panStickyThreshold  = 5;
      panStickyAngle      = 45/2;
      
      lastPanToc  = 0;
      try lastPanToc = toc(lastPanTic); end
      
      if isempty(lastPanXY) || event.PanVector.Length==0;
        deltaPanXY  = [0 0];
      else
        deltaPanXY  = event.PanVector.Current - lastPanXY;
      end
      
      plotAxes = get(obj.handleGet('CurrentAxes'), 'UserData');
      
      try
        newView = plotAxes.View - deltaPanXY;
        
        if panStickyAngle-mod(newView(1), panStickyAngle)<panStickyThreshold || ...
            mod(newView(1), panStickyAngle)<panStickyThreshold
          newView(1) = round(newView(1)/panStickyAngle)*panStickyAngle;
        end
        if panStickyAngle-mod(newView(2), panStickyAngle)<panStickyThreshold || ...
            mod(newView(2), panStickyAngle)<panStickyThreshold
          newView(2) = round(newView(2)/panStickyAngle)*panStickyAngle; % - mod(newView(2), 90)
        end
        plotAxes.View = newView;
      end
      
      lastPanXY   = event.PanVector.Current;
      lastPanTic  = tic;
      consumed = true;
      consumed = obj.mousePan@GraphicsObject(source, event);
    end
    
  end
  
  methods
    function plotAxes = get.ActivePlot(obj)
%       if isempty(obj.ActivePlot)
%         try plotHandle = obj.handleGet('CurrentAxes'); end
%         if isempty(plotHandle)
%           try
%             plotHandle = findobj(obj.Handle, 'Type', 'axes');
%             plotHandle = plotHandle(1);
%           end
%         end
%         try obj.ActivePlot = get(plotHandle, 'UserData'); end
%       end
      plotAxes = obj.ActivePlot;
    end
    
    function plotObject = get.ActiveObject(obj)
%       if isempty(obj.ActiveObject)
%         try obj.ActiveObject  = get(x, 'UserData'); end
%       end
      plotObject = obj.ActiveObject;
    end
    
  end
  
  methods (Access=protected, Hidden=false)
    function createComponent(obj, type, varargin)
      obj.createComponent@GraphicsObject(type);
      obj.JavaObject = get(handle(obj.Handle), 'JavaFrame');
    end
  end
  
  properties (SetObservable, GetObservable)
    
    %% Figure
    WindowTitle, Renderer, Toolbar, Menubar, WindowStyle
    
    %% Labels
    %     Title
    %
    %% Style
    Color, Units
    
  end
  
  %% Hooks
  properties (Hidden)
    ResizeFcn, CloseRequestFcn,  % CreateFcn, DeleteFcn,
    ButtonUpFcn, ButtonMotionFcn, ScrollWheelFcn,
    KeyPressFcn, KeyReleaseFcn
  end
  
  
  methods(Static, Hidden)
    options  = DefaultOptions()
  end
  
end

