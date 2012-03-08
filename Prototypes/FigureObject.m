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
      {'ButtonMotionFcn', 'WindowButtonMotionFcn'}};
  end
  
  methods (Hidden)
    function obj = FigureObject(varargin)
      obj = obj@GraphicsObject(varargin{:});
    end
  end
  
  properties (SetObservable)
    
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
    ButtonUpFcn, ButtonMotionFcn
    KeyPressFcn, KeyReleaseFcn
  end
  
  
  methods(Static, Hidden)   
    options  = DefaultOptions()
  end
  
end

