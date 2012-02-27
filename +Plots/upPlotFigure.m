classdef upPlotFigure < Plots.upViewComponent
  %UPPLOTFIGURE Printing Uniformity Plot Figure
  %   Detailed explanation goes here
  
  properties (Constant = true, Transient = true)
    ComponentType = 'figure';    
    ComponentProperties = grasppeHandle.FigureProperties;
  end  
  
  properties (SetAccess = protected, GetAccess = protected)
    AxesHandle    % Axes handle
    TitleHandle   % Handle to title text
  end
  
  properties   % Test.testStats
    
    %% Figure
    Renderer, Toolbar, Menubar
    
    %% Labels
    Title
    
    %% Style
    Color, Units
    
    %% Defaults
    
  end
  
  methods
    
    function obj = upPlotFigure(varargin)
           
%       [args values paired pairs] = grasppeHandle.parseOptions(obj, obj.Defaults, varargin{:});
      
      obj.setOptions(obj.Defaults, varargin{:});
%       obj.ComponentProperties = ;
      obj.createComponent('figure');
      

%       obj.updateView;
    end
    
    %% Figure Operations
    
%     function obj = createComponent(obj, type, options)
%       % http://www.mathworks.com/help/techdoc/matlab_oop/brgxk22-1.html
%      
%       obj.createComponent@Plots.upViewComponent('figure', obj.ComponentProperties);
%       
%       obj.updateView;
%     end
    
    function handle = getFigure(obj)
      
      if (isempty(obj.Primitive))
        obj.createComponent();
      end
      
%       try
%         set(0,'CurrentFigure',handle);
%       catch
%         obj.createComponent;
%       end
      
      handle = obj.Primitive;      
      
    end
    
    function options = getFigureOptions(obj)
      properties = obj.FigureProperties;
      options = obj.getOptions(properties);
    end
    
    
    function handle = getOverlay(obj)
      
      hFigure   = obj.getFigure; %obj.Primitive; %obj.getFigure;
%       if isempty(hFigure)
%         hFigure = obj.getFigure;
%       end
      handle  = obj.getHandle('Figure Overlay', 'axes', hFigure);
      
      if (isempty(handle) || numel(handle)~=1)
        delete(handle);
        handle = axes('parent', hFigure, 'position', [0,0,1,1], 'visible', 'off', 'Tag', 'Title Axes', 'HitTest', 'off');
      end
      
    end
    
%     function handle = selectOverlay(obj)
%       handle = obj.getOvarlay;
%       obj.selectAxes(handle);
%     end
    
    
    %% Window Operations
    
%     function obj = show(obj)
%       hFigure = obj.getFigure;
%       
%       obj.setOptions('Visible', 'on');
%       
%       obj.updateView;
%       
%       figure(hFigure);
%     end
    
    %% Update Operations
       
    function obj = updateComponent(obj)
      obj.updateTitle;            
      obj.updateFigure;
    end
    
    function obj = enableRotation(obj)
      try
        rotate3d(obj.Primitive);
      end
    end
    
    
    function obj = updateFigure(obj)
      
    end
    
    function obj = updateTitle(obj)
           try
      hOverlay  = obj.getOverlay();
      
      tText   = 'Figure Title';
      hText   = obj.getHandle(tText, 'text', hOverlay);
      
%       if (isempty(obj.Title))
%         delete(hText);
%         return;
%       end
      
      if ~isValid(hText,'handle')         % http://www.mathworks.com/matlabcentral/newsreader/view_thread/153708
%         try
        set(hText, 'HandleVisibility', 'on');
        
        set(hOverlay,'Visible', 'on');
        
        cla(hOverlay);
        
      set(hOverlay,'Visible', 'off');

        set(hText, 'Visible', 'off');
%         end
%         try
        set(hText, 'String'   , '');
%         end
%         try
        delete(hText);
%         end
%         hText = text(0.5, 0.95, obj.Title, 'parent', hOverlay);       
        hText = obj.createHandleObject('text', hOverlay, 0.5, 0.95, obj.Title,'Tag', tText); % text(0.5, 0.95, obj.Title, 'parent', hOverlay)
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

