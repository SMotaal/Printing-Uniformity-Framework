classdef PlotFigureObject < FigureObject
  %UPFIGUREOBJECTSMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  %#ok<*MCSUP>
  
  properties (GetAccess=public, SetAccess=public)
  end
  
  %% Functional Properties
  properties
    Title, BaseTitle, SampleTitle
  end
  
  %% Functional Properties Getters / Setters
  methods
    
    function set.BaseTitle(obj, value)
      obj.BaseTitle = value;
      obj.Title = [obj.BaseTitle obj.SampleTitle];
    end
    
    function set.SampleTitle(obj, value)
      obj.SampleTitle = value;
      obj.Title = [obj.BaseTitle obj.SampleTitle];
    end
    
    function set.Title(obj, value)
      obj.Title = value;
      if isValidHandle('obj.TitleTextHandle')
        set(obj.TitleTextHandle, 'String', value);
      end
      try obj.TitleText.updateTitle; end
    end
    
  end
  
  methods (Access=protected)
    function createComponent(obj, type)
      obj.createComponent@GrasppeComponent(type);
      obj.OverlayAxes = OverlayAxesObject.createAxesObject(obj);
      obj.TitleText   = TitleTextObject.createTextObject(obj.OverlayAxes);
      obj.PlotAxes    = PlotAxesObject.createAxesObject(obj);
      obj.TitleText.updateTitle;
    end
    
  end
  
  %% Plot Objects
  properties (Dependent)
    TitleTextHandle, PlotAxesHandle, OverlayAxesHandle
  end
  
  properties
    TitleText, PlotAxes, OverlayAxes
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
    
    function obj = resizeComponent(obj)
      try obj.PlotAxes.resizeComponent; end
      try obj.OverlayAxes.resizeComponent; end
      try obj.TitleText.resizeComponent; end
    end

  end
  
  
  methods (Static)
    function options  = DefaultOptions( )
      
      WindowTitle   = 'Printing Uniformity Plot';
      Title         = 'Printing Uniformity';
      Color         = 'white';
      Toolbar       = 'none';  Menubar = 'none';
      WindowStyle   = 'docked';
      Renderer      = 'opengl';
      Parent        = 0;
      
      options = WorkspaceVariables(true);
    end    
  end
  
  
end

