classdef FigureObject < HandleGraphicsObject & EventHandlerObject
  %UPFIGUREOBJECTSMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient)
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
  
  methods
    function obj = FigureObject(varargin)
      obj = obj@HandleGraphicsObject(varargin{:});
    end
  end
  
  properties
    
    %% Figure
    WindowTitle, Renderer, Toolbar, Menubar, WindowStyle
    
    %% Labels
%     Title
%     
    %% Style
    Color, Units
    
  end
  
  %% Hooks
  properties (Hidden=false)
    ResizeFcn, CloseRequestFcn,  % CreateFcn, DeleteFcn,
    ButtonUpFcn, ButtonMotionFcn
    KeyPressFcn, KeyReleaseFcn
  end
  
  
  methods(Static)   
    options  = DefaultOptions()
  end
  
end

