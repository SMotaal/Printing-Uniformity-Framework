classdef UniformityPatch < GrasppeAlpha.Graphics.Patch & PrintUniformityBeta.Graphics.UniformityPlotComponent
  %UNIFORMITYSURFACEPLOT R2013-01
  %   Detailed explanation goes here
  
  properties
    ExtendedDataProperties = {};
  end
  
  properties (Dependent)
  end
  
  methods
    function obj = UniformityPatch(parentAxes, dataSource, varargin)
      obj                       = obj@GrasppeAlpha.Graphics.Patch(parentAxes, varargin{:});
      obj                       = obj@PrintUniformityBeta.Graphics.UniformityPlotComponent(dataSource);
    end
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      try
        if ~(isempty(obj.Handle) || ~isvalid(obj.Handle)), return; end;
        obj.createComponent@GrasppeAlpha.Graphics.Patch();
      end
      % obj.createComponent@PrintUniformityBeta.Graphics.UniformityPlotComponent();
      
      % obj.ParentFigure.registerMouseEventHandler(obj);
      obj.ParentAxes.AspectRatio = [20 20 1];
      % grid(obj.ParentAxes.Handle, 'off');
      % obj.handleSet('EdgeAlpha', 0.5);
      % obj.handleSet('LineWidth', 0.25);
    end
  end
  
  
  methods
    
    function consumed = mouseWheel(obj, source, event)
      consumed = true;
      
      try if ~obj.HasParentFigure || ~obj.HasParentAxes, return; end; end
      try if event.Consumed, consumed = event.Consumed; return; end; end
      
      if ~isequal(obj.Handle, hittest)
        consumed = false;
        return;
      end
      
    end
    
  end
  
  methods (Static)
    %     function obj = Create(parentAxes, varargin)
    %       obj = UniformitySurfaceObject(parentAxes, varargin{:});
    %     end
  end
  
  
  methods (Static, Hidden)
    function OPTIONS  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = true;
      EdgeColor     = 'none';
      Clipping      = 'off';
      
      GrasppeAlpha.Utilities.DeclareOptions;
    end
    
  end
  
end

