classdef Figure < Grasppe.Graphics.HandleGraphicsComponent ...
    & Grasppe.Core.KeyEventHandler & Grasppe.Core.MouseEventHandler
  %NEWFIGUREOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  
  properties (Transient, Hidden)
    FigureProperties = {
      'WindowTitle',    'Plot Title',       'Labels',     'string',   '';   ...
      };
    
    FigureHandleProperties = { ...
      {'WindowTitle', 'Name'}, 'Renderer', {'Toolbar', 'ToolBar'}, {'Menubar', 'MenuBar'}, 'WindowStyle', ...
      'Color', 'Units'};
    
    %FigureHandleFunctions  = {{'CloseFunction', 'CloseRequestFcn'}};
    
    FigureHandleFunctions = { ...
      {'CloseFunction', 'CloseRequestFcn'}, {'ResizeFunction', 'ResizeFcn'}, ...
      {'KeyPressFunction', 'WindowKeyPressFcn'}, {'KeyReleaseFunction', 'WindowKeyReleaseFcn'}, ...
      {'MouseDownFunction', 'WindowButtonDownFcn'}, {'MouseUpFunction', 'WindowButtonUpFcn'}, ...
      {'MouseMotionFunction', 'WindowButtonMotionFcn'}, {'MouseWheelFunction', 'WindowScrollWheelFcn'}};
    
    ComponentType = 'figure';
    
  end
  
  events
    Close
    Resize
  end
  
  
  properties (SetObservable, GetObservable, AbortSet)
    Color
    WindowTitle
    Toolbar, Menubar
    WindowStyle
    Renderer
    Units
  end
  
  methods
    function obj = Figure(varargin)
      obj = obj@Grasppe.Graphics.HandleGraphicsComponent(varargin{:});
    end
    
  end
  
  methods (Hidden=true)
    function OnClose(obj, source, event)
      disp(event);
      obj.handleSet('Visible', 'off');
    end
    
    function OnResize(obj, source, event)
      disp('Resized Figure');
    end
  end
  
  methods (Access=protected)
    
    function createHandleObject(obj)
      obj.Handle = figure('Visible', 'off');
      
      obj.JavaObject = get(handle(obj.Handle), 'JavaFrame');
    end
    
    function decorateComponent(obj)
    end
    
  end
  
  
  methods(Static, Hidden=true)
    function OPTIONS  = DefaultOptions()
      WindowTitle   = 'Printing Uniformity Plot';
      %       BaseTitle     = 'Printing Uniformity';
      Color         = 'white';
      Toolbar       = 'none';  Menubar = 'none';
      WindowStyle   = 'normal';
      Renderer      = 'opengl';
      
      Grasppe.Utilities.DeclareOptions;
    end
  end
  
  
end

