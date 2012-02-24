classdef upPlotFigure < grasppeHandle
  %UPPLOTFIGURE Printing Uniformity Plot Figure
  %   Detailed explanation goes here
  
  properties (SetAccess = protected, GetAccess = protected)
    Primitive     % HG primitive handle
    AxesHandle    % Axes handle
    TitleHandle   % Handle to title text
  end
  
  properties
    
    %% Figure Window
    Name, Renderer, Visible, Toolbar, Menubar
    
    %% Figure Contents
    Title
    
    %% Figure Style
    Color
    Units
    
    %% Defaults
    
  end
  
  properties (Dependent = true)
    Styles
    Defaults
  end
  
  properties (Constant = true, Transient = true)
    ClassName = eval(CLASS); ClassPath = eval(FILE);
    
    FigureProperties  = { 'Name', 'Renderer', 'Visible', 'Toolbar', 'Menubar', 'Color', 'Units' };
    TitleProperties   = {{'Title', 'String'}};
  end
  
  
  methods
    
    function obj = upPlotFigure(varargin)
           
      [args values paired pairs] = grasppeHandle.parseOptions(obj, obj.Defaults, varargin{:});
      
      obj.setOptions(obj.Defaults, varargin{:});
      obj.createFigure;
      
%       makeVisible = strcmpi(pairedValue('Visible',[], args, values),'on');
      
%       if (makeVisible)
%         obj.showFigure();
%       end
    end
    
    %% Figure Operations
    
    function obj = createFigure(obj)
      % http://www.mathworks.com/help/techdoc/matlab_oop/brgxk22-1.html
      
      figureOptions = getFigureOptions(obj);
      
      hfig = figure(figureOptions{:}, 'Visible', 'off');
      
      if (strcmpi(obj.Visible,'on'))
        obj.showFigure();
      end
      
      obj.Primitive = hfig;
      
      obj.updateView;
    end
    
    function handle = getFigure(obj)
      
      if (isempty(obj.Primitive))
        obj.createFigure;
      end
      
      handle = obj.Primitive;
      try
        set(0,'CurrentFigure',handle);
      catch
        obj.createFigure;
        handle = obj.getFigure;
      end
      
    end
    
    function options = getFigureOptions(obj)
      properties = obj.FigureProperties;
      options = obj.getOptions(properties);
    end
    
    
    %% Window Operations
    
    function obj = showFigure(obj)
      hFigure = obj.getFigure;
      
      obj.setOptions('Visible', 'on');
      
      obj.updateView;
      
      figure(hFigure);
    end
    
    %% Update Operations
    
    function obj = updateView(obj)
      persistent updating delayTimer;
      
      if isVerified('updating',true)
        if ~isVerified('class(delayTimer)','timer');
          delayTimer = timer('Name','DelayTimer','ExecutionMode', 'singleShot', 'StartDelay', 1, ...
            'TimerFcn', {@Plots.upPlotFigure.callbackEvent,obj});
          start(delayTimer);
        else
          stop(delayTimer);
          start(delayTimer);
        end
        return;
      end
      
      updating = true;
      
      obj.updateFigure;
      
      updating = false;
    end
    
    
    function obj = updateFigure(obj)
      obj.updateTitle;
    end
    
    function obj = updateTitle(obj)
      
      hFigure = obj.getFigure;
      
      hAxes   = obj.getObjects('Figure Overlay', 'axes', hFigure);
      
      if (isempty(hAxes) || numel(hAxes)~=1)
        delete(hAxes);
        hAxes = axes('position', [0,0,1,1], 'visible', 'off', 'Tag', 'Title Axes');
      end
      
      hText   = obj.getObjects('Figure Title', 'text', hAxes);
      
      pTitle  = obj.Title;
      
      if (isempty(pTitle))
        delete(hText);
        return;
      end
      
      if (isempty(hText) || numel(hText)~=1)
        delete(hText);
        
        set(hFigure, 'CurrentAxes', hAxes);
        
        hText = text(0.5, 0.95, obj.Title);  % set(tx,'fontweight','bold');
        
        titleStyle = obj.Styles.TitleStyle;
        
        set(hText, titleStyle{:});
        
        % http://www.mathworks.com/matlabcentral/newsreader/view_thread/153708
      end
      
      
      %         properties = obj.TitleProperties;
      try
        options = obj.getOptions(obj.TitleProperties);
        set(hText, options{:});
      catch err
        disp(err);
      end
      
    end
    
    %% Shared Properties
    
    function [options] = get.Defaults(obj)
      persistent DefinedOptions;
      
      if isempty(DefinedOptions)
        DefinedOptions = obj.getStatic('DefaultOptions'); %  %eval([obj.ClassName '.getDefaultStyles']);
      end
      
      options = DefinedOptions;      
    end
    function [styles] = get.Styles(obj)
      persistent DefinedStyles;
      
      if isempty(DefinedStyles)
        DefinedStyles = obj.getStatic('DefaultStyles'); %  %eval([obj.ClassName '.getDefaultStyles']);
      end

      styles = DefinedStyles;
    end
    
    function obj = set.Title(obj, value)
      obj.Title = value;
      obj.updateTitle();
    end
  end
  
  methods(Static)
    
    function options = DefaultOptions()
      
      Name      = 'Printing Uniformity Plot';
      Title     = 'Printing Uniformity';
      Color     = 'white';
      Toolbar   = 'none';  Menubar = 'none';
      Renderer  = 'opengl';
      
      options = WorkspaceVariables(true);
    end
    
    function styles   = DefaultStyles()
      
      %% Declarations
      Define            = @horzcat;
      
      %% Font Declarations
      Type.Face           = 'FontName';
      Type.Angle          = 'FontAngle';
      Type.Weight         = 'FontWeight';
      Type.Unit           = 'FontUnits';
      Type.Size           = 'FontSize';
      
      Type.SansSerif      = {Type.Face,     'Gill Sans'};  % 'Linotype Syntax Com Medium'
      Type.Serif          = {Type.Face,     'Bell MT'};
      Type.MonoSpaced     = {Type.Face,     'Lucida Sans Typewriter'};
      
      Type.BookWeight     = {Type.Weight,   'Normal'};
      Type.BoldWeight     = {Type.Weight,   'Bold'};
      
      Type.StraightAngle  = {Type.Angle,    'Normal'};
      Type.ObliqueAngle   = {Type.Angle,    'Italic'};
      
      Type.PointSize      = {Type.Unit,     'Point'};
      
      Type.Tiny           = Define(Type.PointSize,    Type.Size,  8       );
      Type.Small          = Define(Type.PointSize,    Type.Size,  10      );
      Type.Medium         = Define(Type.PointSize,    Type.Size,  12      );
      Type.Large          = Define(Type.PointSize,    Type.Size,  14      );
      Type.Huge           = Define(Type.PointSize,    Type.Size,  16      );
      
      Type.Regular        = Define(Type.BookWeight,   Type.StraightAngle  );
      Type.Bold           = Define(Type.BoldWeight,   Type.StraightAngle  );
      Type.Italic         = Define(Type.BoldWeight,   Type.ObliqueAngle   );
      Type.BoldItalic     = Define(Type.BoldWeight,   Type.ObliqueAngle   );
      
      %% Font Styles
      TextFont        = Define(Type.Serif,        Type.Italic,    Type.Medium );
      EmphasisFont    = Define(Type.Serif,        Type.Regular,   Type.Medium );
      LabelFont       = Define(Type.SansSerif,    Type.Regular,   Type.Medium );
      TitleFont       = Define(Type.SansSerif,    Type.Bold,      Type.Huge   );
      HeadingFont     = Define(Type.SansSerif,    Type.Bold,      Type.Large  );
      LegendFont      = Define(Type.SansSerif,    Type.Regular,   Type.Small  );
      OverlayFont     = Define(Type.SansSerif,    Type.Regular,   Type.Tiny   );
      TableFont       = Define(Type.MonoSpaced,   Type.Regular,   Type.Medium );
      CodeFont        = Define(Type.MonoSpaced,   Type.Regular,   Type.Small  );
      
      %% Layout Styles
      Layout.Horizontal   = 'HorizontalAlignment';
      Layout.Vertical     = 'VerticalAlignment';
      
      Layout.Left         = {Layout.Horizontal, 'Left'      };
      Layout.Center       = {Layout.Horizontal, 'Center'    };
      Layout.Right        = {Layout.Horizontal, 'Right'     };
      Layout.Top          = {Layout.Vertical,   'Top'       };
      Layout.Middle       = {Layout.Vertical,   'Middle'    };
      Layout.Bottom       = {Layout.Vertical,   'Bottom'    };
      Layout.Caps         = {Layout.Vertical,   'Cap'       };
      Layout.Baseline     = {Layout.Vertical,   'Baseline'  };
      
      
      
      %% Graphic Styles
      Axes.SmoothLines    = {'LineSmoothing', 'on'};
      
      Axes.Orthographic   = {'Projection', 'Orthographic'};
      Axes.Perspective    = {'Projection', 'Perspective'};
      
      Axes.BoxClipped     = {'Box','on'};
      Axes.Clipped        = {'Box','off', 'Clipping', 'on'};
      Axes.Unclipped      = {'Box','off', 'Clipping', 'off'};
      
      
      Grid.MajorLine      = 'GridLineStyle';
      Grid.MinorLine      = 'MinorGridLineStyle';
      Grid.XColor         = 'XColor';
      Grid.YColor         = 'YColor';
      Grid.ZColor         = 'YColor';
      
      Line.None           = {'LineStyle', 'none'; 'LineWidth', 0.00};
      
      Line.Hairline       = {'LineWidth', 0.25};
      Line.Thin           = {'LineWidth', 0.50};
      Line.Medium         = {'LineWidth', 0.50};
      Line.Thick          = {'LineWidth', 1.50};
      
      Line.Solid          = {'LineStyle', 'none'};
      Line.Dotted         = {'LineStyle', 'none'};
      Line.Dashed         = {'LineStyle', 'none'};
      Line.Mixed          = {'LineStyle', 'none'};
      
      
      %% Defined Styles
      NormalStyle         = Define(TextFont);
      AxesStyle           = Define(LegendFont);
      DataStyle           = Define(OverlayFont);
      TitleStyle          = Define(TitleFont, Layout.Center, Layout.Middle);
      
      clear Define;
      styles           = WorkspaceVariables(true);
      
    end
    
    function callbackEvent(source, event, varargin)
      
      objectFound = false;
      
      if isValid(varargin{1}, eval(CLASS));
        object = varargin{1};
        objectFound = true;
      end
      
      if isVerified('ischar(obj.Name) && ~isempty(obj.Name)', true)
        caller = source.Name;
      else
        return;
      end
      switch caller
        case 'DelayTimer'
          if (objectFound)
            object.updateView();
            stop(source); delete(source);
          end
      end
    end
  end
end

