classdef NewFigureObject < GrasppeHandleComponent
  %NEWFIGUREOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
 
  properties (Transient, Hidden)
    NewFigureObjectProperties = {
      'WindowTitle',    'Plot Title',       'Labels',     'string',   '';   ...
      };
    
    NewFigureObjectHandleProperties = { ...
      {'WindowTitle', 'Name'}, 'Renderer', {'Toolbar', 'ToolBar'}, {'Menubar', 'MenuBar'}, 'WindowStyle', ...
      'Color', 'Units'};
    
    ComponentType = 'figure';    
    
  end
 
  
  properties (SetObservable, GetObservable, AbortSet)
    Color
    WindowTitle, BaseTitle
    Toolbar, Menubar
    WindowStyle
    Renderer
    Units
  end
  
  methods
    function obj = NewFigureObject(varargin)
      obj = obj@GrasppeHandleComponent(varargin{:});
    end
    
  end
  
  methods (Access=protected)
    
    function createHandleObject(obj)
      obj.Handle = figure('Visible', 'off');
    end
    
  end
  
  
  methods(Static, Hidden)
    function options  = DefaultOptions()
      WindowTitle   = 'Printing Uniformity Plot';
      BaseTitle     = 'Printing Uniformity';
      Color         = 'white';
      Toolbar       = 'none';  Menubar = 'none';
      WindowStyle   = 'normal';
      Renderer      = 'opengl';
      Parent        = 0;
      
      options = WorkspaceVariables(true);
    end
  end
  
  
end

