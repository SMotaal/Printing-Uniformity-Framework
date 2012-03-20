classdef PlotFigureObject < GrasppePrototype & FigureObject
  %UPFIGUREOBJECTSMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  %#ok<*MCSUP>
  
  properties (Transient, Hidden)
    BaseTitle, SampleTitle, Status
  end
  
  %% Functional Properties
  properties (SetObservable, GetObservable)
    Title
  end
  
  %% Plot Objects
  properties (Dependent, Hidden)
    TitleTextHandle, PlotAxesHandle, OverlayAxesHandle, ColorBarHandle
    StatusTextHandle
  end
  
  properties
    TitleText, PlotAxes, OverlayAxes, ColorBar
    StatusText;
  end
  
  methods (Hidden)
    function obj = PlotFigureObject(varargin)
      obj = obj@GrasppePrototype;
      obj = obj@FigureObject(varargin{:});
    end
  end
  
  %% Functional Properties Getters / Setters
  methods
    
    function set.BaseTitle(obj, value)
      obj.BaseTitle = changeSet(obj.BaseTitle, value);
      obj.updatePlotTitle;
    end
    
    function set.SampleTitle(obj, value)
      obj.SampleTitle = changeSet(obj.SampleTitle, value);
      obj.updatePlotTitle;
    end
    
    function updatePlotTitle(obj)
      obj.Title = [obj.BaseTitle ' (' obj.SampleTitle ')'];
    end
    
    function set.Title(obj, value)
      obj.Title = strtrim(value);
      if isValidHandle('obj.TitleTextHandle')
        set(obj.TitleTextHandle, 'String', value);
      end
      try obj.TitleText.updateTitle; end
    end
    
  end
  
  methods (Access=protected, Hidden)
    function createComponent(obj, type)
      obj.createComponent@FigureObject(type);
      obj.preparePlotAxes;
      obj.OverlayAxes = OverlayAxesObject.Create(obj);
      obj.StatusText  = OverlayTextObject.Create(obj.OverlayAxes);
      obj.TitleText   = TitleTextObject.Create(obj.OverlayAxes);
      obj.TitleText.updateTitle;
    end
    
    function preparePlotAxes(obj)
      obj.PlotAxes    = PlotAxesObject.Create(obj);
    end
    
  end
  
  
  %% Plot Objects Getters / Setters
  methods
    %% Title Text
    function handle = get.TitleTextHandle(obj)
      handle = []; try handle = obj.TitleText.Handle; end
    end
    
    function handle = get.StatusTextHandle(obj)
      handle = []; try handle = obj.StatusText.Handle; end
    end
    
    
    function set.PlotAxes(obj, plotAxes)
      obj.PlotAxes = plotAxes;
%       if isempty(obj.ActiveObject) || isempty(obj.ActivePlot)
%         if isobject(plotAxes)
%           if numel(plotAxes)>1
%               try obj.ActivePlot    = plotAxes(1); end % , 'UserData'); end
%               try obj.ActiveObject  = get(obj.ActivePlot.Children(1), 'UserData'); end
%           end
%         end
%       end
    end
    
    %% Plot Axes
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
  
  methods (Hidden)
    function obj = resizeComponent(obj)
      try obj.PlotAxes.resizeComponent; end
      try obj.OverlayAxes.resizeComponent; end
      try obj.TitleText.resizeComponent; end
    end
    
    function consumed = keyPress(obj, source, event)
      consumed = false;
      shiftKey = stropt('shift', event.Modifier);
      commandKey = stropt('command', event.Modifier) || stropt('control', event.Modifier);
      
      if commandKey
        switch event.Key
          case 'w'
            obj.closeComponent();
            consumed = true;
          case 'm'
            if shiftKey
              if strcmp(obj.WindowStyle, 'docked')
                obj.WindowStyle = 'normal';
              end
              try obj.JavaObject.setMaximized(true); end
            else
              try obj.JavaObject.setMinimized(true); end
            end
            consumed = true;
          case 'd'
            try
              if strcmp(obj.WindowStyle, 'docked')
                obj.WindowStyle = 'normal';
              else
                obj.WindowStyle = 'docked';
              end
            end
            consumed = true;
        end
      end
      consumed = obj.keyPress@FigureObject(source, event);
    end
  end
  
  
  methods (Static, Hidden)
    function options  = DefaultOptions( )
      
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

