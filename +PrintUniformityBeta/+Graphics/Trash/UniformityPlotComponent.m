classdef UniformityPlotComponent < GrasppeAlpha.Core.Prototype & GrasppeAlpha.Core.MouseEventHandler
  %UNIFORMITYPLOTOBJECT Co-superclass for printing uniformity plot objects
  %   Detailed explanation goes here
  
  properties (SetObservable, GetObservable)
    DataSource
    LinkedProperties
    
  end
  
  properties (Transient, Hidden)
    
    UniformityPlotComponentProperties = {
      'ALim',       'Alpha Map Limits', 'Data Limits',      'limits',   '';   ...
      'CLim',       'Color Map Limits', 'Data Limits',      'limits',   '';   ...
      'XLim',       'X Axes Limits',    'Data Limits',      'limits',   '';   ...
      'YLim',       'Y Axes Limits',    'Data Limits',      'limits',   '';   ...
      'ZLim',       'Z Axes Limits',    'Data Limits',      'limits',   '';   ...
      };%     HANDLEPROPERTIES  = {};
  end
  
  
  properties (Dependent)
    %     IsLinked;
  end
  
  methods
    function obj = UniformityPlotComponent(dataSource, varargin)
      obj = obj@GrasppeAlpha.Core.Prototype;
      obj.DataSource = dataSource;
    end
  end
  
  methods
    
    function attachDataSource(obj)
      obj.resetPlotLimits;
      obj.DataSource.attachPlotObject(obj);
      
      if isempty(obj.ParentFigure.DataSources) || ~iscell(obj.ParentFigure.DataSources)
        obj.ParentFigure.DataSources = {};
      end
      
      obj.ParentFigure.DataSources{end+1} = obj.DataSource;
    end
    
    function resetPlotLimits(obj)
      try obj.ParentAxes.XLim = 'auto'; end
      try obj.ParentAxes.YLim = 'auto'; end
      try obj.ParentAxes.ZLim = 'auto'; end
      try obj.ParentAxes.CLim = 'auto'; end
    end
  end
  
  methods
    function set.DataSource(obj, value)
      try 
        obj.DataSource = value;
        %obj.attachDataSource;
        value.attachPlotObject(obj);
      end
      %value.attachPlotObject(obj);
      %       try value.attachPlotObject(obj); end
    end
        
    function setSheet(obj, varargin)
      try obj.DataSource.setSheet(varargin{:}); end
    end
    
  end
  
  
  methods % (Hidden)
    function OnMouseScroll(obj, source, event)
      %       if ~isequal(obj.Handle, hittest)
      %         consumed = false;
      %         return;
      %       end
      
      if ~event.Data.Scrolling.Momentum && event.Data.Scrolling.Length<2
        %disp(toString(event.Data.Scrolling));
        % plotAxes = get(obj.handleGet('CurrentAxes'), 'UserData');
%         if event.Data.Scrolling.Length>1.5 && event.Data.Scrolling.Length<2
%           obj.setSheet('sum');
%         else
        if event.Data.Scrolling.Vertical(1) > 0
          obj.setSheet('-1');
        elseif event.Data.Scrolling.Vertical(1) < 0
          obj.setSheet('+1');
        end
      end
    end   
  end
  
end

