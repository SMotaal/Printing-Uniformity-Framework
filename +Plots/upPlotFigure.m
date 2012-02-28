classdef upPlotFigure < Plots.upViewComponent
  %UPPLOTFIGURE Printing Uniformity Plot Figure
  %   Detailed explanation goes here
  
  properties (Constant = true, Transient = true)
    ComponentType = 'figure';
    ComponentProperties = Plots.upGrasppeHandle.FigureProperties;
  end
  
  properties (SetAccess = protected, GetAccess = public)
    AxesHandle    % Axes handle
    TitleHandle   % Handle to title text
    
    PlotAxesObject
    OverlayAxesObject
  end
  
  properties (Dependent = true)
    PlotAxes
    OverlayAxes
  end
  
  properties   % Test.testStats
    
    %% Figure
    Renderer, Toolbar, Menubar, WindowStyle
    
    %% Labels
    Title
    
    %% Style
    Color, Units
    
    %% Defaults
    
  end
  
  methods
    %
    function obj = upPlotFigure(varargin)
      obj = obj@Plots.upViewComponent(varargin{:});
      obj.createComponent();
      obj.getPlotAxes();
      obj.getOverlayAxes();
    end
    
    %% Figure Operations   
    function options = getFigureOptions(obj)
      properties = obj.FigureProperties;
      options = obj.getOptions(properties);
    end
    
    function hAxes = get.PlotAxes(obj)
      if isValid(obj.PlotAxesObject, 'Plots.upPlotAxes')
        hAxes = obj.PlotAxesObject.Primitive;
      else
        hAxes = [];
      end
    end    
    
    function hOverlay = get.OverlayAxes(obj)
      if isValidHandle('obj.OverlayAxes.Primitive')
        hOverlay = obj.OverlayAxes.Primitive;
      else
        hOverlay = [];
      end
    end
    
        
    function hFigure = getFigure(obj)
      
      if (isempty(obj.Primitive))
        obj.createComponent();
      end
      
      hFigure = obj.Primitive;
      
    end

    function obj = resizeComponent(obj)
      try
        obj.PlotAxesObject.resizeComponent;
      end
    end
    
    function hAxes = getPlotAxes(obj)
      if ~isValidHandle('obj.PlotAxesObject.Primitive')
        obj.PlotAxesObject = Plots.upPlotAxes(obj, 'Parent', obj.Primitive);

      end
      
      hAxes = obj.PlotAxes;
    end
    
    
    function hOverlay = getOverlayAxes(obj)
      
      hFigure   = obj.getFigure;

      tOverlay  = obj.componentTag('Figure Overlay');
      
      hOverlay  = obj.getHandle(tOverlay, 'axes', hFigure);
      
      if (isempty(hOverlay) || numel(hOverlay)~=1)
        delete(hOverlay);
        hOverlay = axes('parent', hFigure, 'position', [0,0,1,1], ...
          'Visible', 'off', 'Tag', tOverlay, 'HitTest', 'off');
      end
      
    end
    
    
    %% Window Operations
    
    %% Update Operations
    
    function obj = updateComponent(obj)
      if (obj.Busy)
        return;
      end
      obj.updateTitle;
      obj.updateComponent@Plots.upViewComponent();
    end
    
%     function obj = enableRotation(obj)
%       try
%         rotate3d(obj.Primitive);
%       end
%     end
    
    function obj = updateTitle(obj)
      if (obj.Busy)
        return;
      end
      try
        hOverlay  = obj.OverlayAxes;
        
        tText   = obj.componentTag('Figure Title');
        hText   = obj.getHandle(tText, 'text', hOverlay);
        
        %       if (isempty(obj.Title))
        %         delete(hText);
        %         return;
        %       end
        
        if ~isValidHandle(hText)         % http://www.mathworks.com/matlabcentral/newsreader/view_thread/153708
          set(hOverlay,'Visible', 'on');
          hText = obj.createHandleObject('text', tText, hOverlay, 0.5, 0.95, obj.Title);
          set(hText, obj.Styles.TitleStyle{:});
        end
        
        try
          options = obj.getOptions(obj.TitleProperties);
          set(hText, options{:});
        catch err
          warning(err.identifier, err.message);
        end
        
      catch err
        disp(err);
      end
      
    end
    
    function obj = set.Title(obj, value)
      obj.Title = value;
      obj.updateTitle();
    end
  end
  
  methods(Static)
    function options  = DefaultOptions( )
      
      Name      = 'Printing Uniformity Plot';
      Title     = 'Printing Uniformity';
      Color     = 'white';
      Toolbar   = 'none';  Menubar = 'none';
      Renderer  = 'opengl';
      Parent    = 0;
      
      options = WorkspaceVariables(true);
    end
  end
end

