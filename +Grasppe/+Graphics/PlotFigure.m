classdef PlotFigure < Grasppe.Graphics.Figure
  %PLOTFIGURE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    PlotFigureProperties = {
      'BaseTitle',    'Plot Title',       'Labels',     'string',   '';   ...
      };
  end
  
  properties (SetObservable, GetObservable, AbortSet)
    Title, BaseTitle, SampleTitle, Status
    TitleText, PlotAxes, OverlayAxes, ColorBar
    StatusText;
    
  end
  
  properties (Dependent, Hidden)
    TitleTextHandle, PlotAxesHandle, OverlayAxesHandle, ColorBarHandle
    StatusTextHandle
  end
  
  
  methods
    
    function obj = PlotFigure(varargin)
      obj = obj@Grasppe.Graphics.Figure(varargin{:});
    end
    
    
    %% Title
    function set.Title(obj, value)
      % obj.Title = strtrim(value);
      % if isValidHandle('obj.TitleTextHandle')
      %   set(obj.TitleTextHandle, 'String', value);
      % end
      % try obj.TitleText.updateTitle; end
    end
    
    
    %% BaseTitle
    function set.BaseTitle(obj, value)
      obj.BaseTitle = changeSet(obj.BaseTitle, value);
      obj.updatePlotTitle;
    end
    
    %% SampleTitle
    function set.SampleTitle(obj, value)
      obj.SampleTitle = changeSet(obj.SampleTitle, value);
      obj.updatePlotTitle;
    end
    
    %% Title Text
    function handle = get.TitleTextHandle(obj)
      handle = []; try handle = obj.TitleText.Handle; end
    end
    
    function handle = get.StatusTextHandle(obj)
      handle = []; try handle = obj.StatusText.Handle; end
    end
    
    %% Plot Axes
    function set.PlotAxes(obj, plotAxes)
      obj.PlotAxes = plotAxes;
    end
    
    function handle = get.PlotAxesHandle(obj)
      handle = []; try handle = obj.PlotAxes.Handle; end
    end
    
    %% Overlay Axes
    function handle = get.OverlayAxesHandle(obj)
      handle = []; try handle = obj.OverlayAxes.Handle; end
    end
    
    %% ColorBar
    function handle = get.ColorBarHandle(obj)
      handle = []; try handle = obj.ColorBar.Handle; end
    end
    
  end
  
  
  methods (Access=protected, Hidden)
    function createComponent(obj)
      obj.createComponent@Grasppe.Graphics.Figure();
      obj.preparePlotAxes;
      obj.OverlayAxes = Grasppe.Graphics.OverlayAxes('ParentFigure', obj);  %OverlayAxesObject.Create(obj);
      % obj.StatusText  = OverlayTextObject.Create(obj.OverlayAxes);
      obj.TitleText   = Grasppe.Graphics.TextObject(obj.OverlayAxes, 'Text', 'tada');
      % obj.TitleText.updateTitle;
    end
    
    function preparePlotAxes(obj)
      obj.PlotAxes    = Grasppe.Graphics.PlotAxes('ParentFigure', obj);
    end
    
    function updatePlotTitle(obj)
      obj.Title = [obj.BaseTitle ' (' obj.SampleTitle ')'];
    end
    
    
    
  end
  
  
  
  methods(Static, Hidden=true)
    function options  = DefaultOptions()
      WindowTitle   = 'Printing Uniformity Plot';
      BaseTitle     = 'Printing Uniformity';
      Color         = 'white';
      Toolbar       = 'none';  Menubar = 'none';
      WindowStyle   = 'normal';
      Renderer      = 'opengl';
      
      options = WorkspaceVariables(true);
    end
  end
  
  
end

