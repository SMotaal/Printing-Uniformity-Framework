classdef Figure < Grasppe.Core.DecoratedComponent & Grasppe.Graphics.HandleGraphicsComponent ...
    & Grasppe.Core.EventHandler & Grasppe.Core.KeyEventHandler
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
      };
%       {'ButtonDownFunction', 'WindowButtonDownFunction'}, {'ButtonUpFunction', 'WindowButtonUpFcn'}, ...
%       {'ButtonMotionFunction', 'WindowButtonMotionFcn'}, {'ScrollWheelFunction', 'WindowScrollWheelFcn'}};
    
    
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
      obj = obj@Grasppe.Core.DecoratedComponent();
      obj = obj@Grasppe.Core.EventHandler();
      obj = obj@Grasppe.Graphics.HandleGraphicsComponent(varargin{:});
    end
    
  end
  
  methods (Hidden=true)
    function OnClose(obj, source, event)
      disp(event);
      obj.handleSet('Visible', 'off');
    end
    
    function OnResize(obj, source, event)
      
    end    
  end
  
  methods (Access=protected)
    
    function createHandleObject(obj)
      obj.Handle = figure('Visible', 'off');
    end
    
    function decorateComponent(obj)
      %obj.decorateComponent@HandleGraphicsComponent();
      %Grasppe.Graphics.Decorators.FontDecorator(obj);
    end    
    
  end
  
  
  methods(Static, Hidden=true)
    function options  = DefaultOptions()
      WindowTitle   = 'Printing Uniformity Plot';
%       BaseTitle     = 'Printing Uniformity';
      Color         = 'white';
      Toolbar       = 'none';  Menubar = 'none';
      WindowStyle   = 'normal';
      Renderer      = 'opengl';
      
      options = WorkspaceVariables(true);
    end
  end
  
  
end

