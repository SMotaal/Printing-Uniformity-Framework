classdef upPlotFigure < Plots.upViewComponent & Graphics.PlotFigureObject
  %UPPLOTFIGURE Printing Uniformity Plot Figure
  %   Detailed explanation goes here


  methods
    %
    function obj = upPlotFigure(varargin)
      obj = obj@Plots.upViewComponent(varargin{:});
    end
    
    %% Figure Operations
    function obj = resizeComponent(obj)
%       try
%         obj.PlotAxesObject.resizeComponent;
%       end
    end
    
    function hAxes = getPlotAxes(obj)
      
%       hAxes = obj.PlotAxes;
    end
    
    
    function hOverlay = getOverlayAxes(obj)
      
      hFigure   = obj.Primitive;

      tOverlay  = obj.componentTag('Figure Overlay');
      
      hOverlay  = obj.getHandle(tOverlay, 'axes', hFigure);
      
      if (isempty(hOverlay) || numel(hOverlay)~=1)
        delete(hOverlay);
        hOverlay = axes('parent', hFigure, 'position', [0,0,1,1], ...
          'Visible', 'off', 'Tag', tOverlay, 'HitTest', 'off', ...
          'Color', 'none');
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
        hOverlay  = obj.getOverlayAxes;
        
        tText   = obj.componentTag('Figure Title');
        hText   = obj.getHandle(tText, 'text', hOverlay);
        
        %       if (isempty(obj.Title))
        %         delete(hText);
        %         return;
        %       end
        
        if ~isValidHandle(hText)         % http://www.mathworks.com/matlabcentral/newsreader/view_thread/153708
          obj.Set(hOverlay,'Visible', 'on');
          hText = obj.createHandleObject('text', tText, hOverlay, 0.5, 0.95, obj.Title);
          obj.Set(hText, obj.Styles.TitleStyle{:});
        end
        
        try
          options = obj.getOptions(Graphics.Properties.Title);
          obj.Set(hText, options{:});
        catch err
          warning(err.identifier, err.message);
        end
        
      catch err
        dealwith(err);
      end
      
    end
    
    function obj = set.Title(obj, value)
      if ischar(value)
        obj.BaseTitle = value;
        obj.Title = value;
      else
        obj.Title = char(value);
      end
      obj.Title = value;
      obj.updateTitle();
    end
    
    function obj = appendTitle(obj, value)
%       persistent title;
      
      if isempty(obj.BaseTitle) || isequal(value, false)
        obj.BaseTitle = obj.Title;
      end
      
      if ischar(value)
        obj.Title = {sprintf('<html><b>%s</b>%s</html>', obj.BaseTitle, value)};
      end
      
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

