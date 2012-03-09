classdef PlotFigureObject < PlotFigureObject
  %UPFIGUREOBJECTSMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  %#ok<*MCSUP>
  
  
  methods (Hidden)
    function obj = PlotFigureObject(varargin)
      obj = obj@PlotFigureObject(varargin{:});
    end
  end
  
  %% Functional Properties Getters / Setters
  methods
    
    function updatePlotTitle(obj)
      obj.Title = [obj.BaseTitle ' (' obj.SampleTitle ')']; 
    end
    
  end
  
  methods (Access=protected, Hidden)
    function createComponent(obj, type)
      obj.createComponent@GrasppeComponent(type);
      obj.OverlayAxes = OverlayAxesObject.Create(obj);
      obj.TitleText   = TitleTextObject.Create(obj.OverlayAxes);
      obj.PlotAxes    = PlotAxesObject.Create(obj);
      obj.TitleText.updateTitle;
    end
    
    function plotAxes = getPlotAxes(obj, index)
      
    end
    
  end
  
  %% Plot Objects Getters / Setters
  methods
    
  end
  
  methods (Hidden)
    function obj = resizeComponent(obj)
      try obj.PlotAxes.resizeComponent; end
      try obj.OverlayAxes.resizeComponent; end
      try obj.TitleText.resizeComponent; end
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

