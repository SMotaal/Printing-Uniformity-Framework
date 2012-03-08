classdef PlotFigureObject < FigureObject
  %UPFIGUREOBJECTSMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  %#ok<*MCSUP>
  
  properties (Transient, Hidden)
    BaseTitle, SampleTitle
  end
  
  %% Functional Properties
  properties (SetObservable)
    Title
  end
  
  methods (Hidden)
    function obj = PlotFigureObject(varargin)
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
      obj.createComponent@GrasppeComponent(type);
      obj.OverlayAxes = OverlayAxesObject.Create(obj);
      obj.TitleText   = TitleTextObject.createTextObject(obj.OverlayAxes);
      obj.PlotAxes    = PlotAxesObject.Create(obj);
      obj.TitleText.updateTitle;
    end
    
  end
  
  %% Plot Objects
  properties (Dependent, Hidden)
    TitleTextHandle, PlotAxesHandle, OverlayAxesHandle, ColorBarHandle
  end
  
  properties
    TitleText, PlotAxes, OverlayAxes, ColorBar
  end
  
  %% Plot Objects Getters / Setters
  methods
    %% Title Text
    function handle = get.TitleTextHandle(obj)
      handle = []; try handle = obj.TitleText.Handle; end
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
    
    function keyPress(obj, event, source)
      if (stropt(event.Modifier, 'control command'))
        switch event.Key
          case 'w'
            obj.closeComponent();
        end
      end
      obj.keyPress@FigureObject(event);   
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

