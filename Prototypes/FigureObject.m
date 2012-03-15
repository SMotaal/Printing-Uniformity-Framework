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
  
  methods (Hidden)
    function obj = FigureObject(varargin)
      obj = obj@GraphicsObject(varargin{:});
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

