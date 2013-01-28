classdef UniformityPlotComponent < PrintUniformityBeta.Data.PlotDataEventHandler & GrasppeAlpha.Core.MouseEventHandler
  %UNIFORMITYPLOTOBJECT Co-superclass for printing uniformity plot objects
  %   Detailed explanation goes here
  
  properties (Dependent, SetObservable, GetObservable)
    DataSource
  end
  
  properties (Access=protected)
    dataSource
  end
  
  properties (Transient, Hidden)
    
    UniformityPlotComponentProperties = {
      'ALim',       'Alpha Map Limits', 'Data Limits',      'limits',   '';   ...
      'CLim',       'Color Map Limits', 'Data Limits',      'limits',   '';   ...
      'XLim',       'X Axes Limits',    'Data Limits',      'limits',   '';   ...
      'YLim',       'Y Axes Limits',    'Data Limits',      'limits',   '';   ...
      'ZLim',       'Z Axes Limits',    'Data Limits',      'limits',   '';   ...
      };
  end
  
  
  properties (Dependent)
    %     IsLinked;
  end
  
  methods
    function obj = UniformityPlotComponent(dataSource, varargin)
      obj                       = obj@PrintUniformityBeta.Data.PlotDataEventHandler(varargin{:});
      obj.DataSource            = dataSource;
    end
  end
  
  methods
    
    function attachDataSource(obj, dataSource)
      try 
        obj.dataSource          = dataSource;
        dataSource.attachPlotObject(obj);
        
        obj.OnPlotChange(dataSource);
        
      catch err
        debugStamp(err, 1, obj);
      end
      %value.attachPlotObject(obj);
      %       try value.attachPlotObject(obj); end
      
      %       obj.resetPlotLimits;
      %       obj.DataSource.attachPlotObject(obj);
      %
      if isempty(obj.ParentFigure.DataSources) || ~iscell(obj.ParentFigure.DataSources)
        obj.ParentFigure.DataSources = {};
      end
      
      obj.ParentFigure.DataSources{end+1} = obj.DataSource;
    end
    
    %     function resetPlotLimits(obj)
    %       try obj.ParentAxes.XLim = 'auto'; end
    %       try obj.ParentAxes.YLim = 'auto'; end
    %       try obj.ParentAxes.ZLim = 'auto'; end
    %       try obj.ParentAxes.CLim = 'auto'; end
    %     end
    
    function updatePlotTitle(obj, base, sheetName)
      
      sheetName = '';      
      
      try caseName  = obj.DataSource.CaseName;  end
      try setName   = obj.DataSource.SetName;   end
      try if nargin<2, sheetName = obj.DataSource.SheetName; end; end
      
      try obj.ParentFigure.BaseTitle    = [caseName ' ' setName]; end;
      try obj.ParentFigure.SampleTitle  = sheetName; end;
      
%       obj.ParentFigure.IsVisible = 'on';
%       obj.ParentFigure.TitleText.IsVisible = 'off';
%       
%       try
%         set(obj.ParentAxes.handleGet('Title'), 'String', obj.ParentFigure.Title);
%         set(obj.ParentAxes.handleGet('Title'), 'Visible', 'on');
%         set(obj.ParentAxes.handleGet('Title'), 'Tag', '@Print');
%       end
    end    
    
  end
  
  methods
    function set.DataSource(obj, dataSource)
      obj.attachDataSource(dataSource);
    end
    
    function dataSource = get.DataSource(obj)
      dataSource                = obj.dataSource;
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
    
    function OnPlotChange(obj, source, event)            % Plot object has changed
      try debugStamp(event.EventName, 1, obj); end % disp(event);
      
      obj.OnPlotAxesChange(source);
      obj.OnPlotMapChange(source);
      obj.OnPlotViewChange(source);
      obj.OnPlotDataChange(source);      
    end
    
    function OnPlotDataChange(obj, source, event)        % Plot data has changed (need to refresh plot)
      try debugStamp(event.EventName, 1, obj); end % disp(event);
      
      try set(obj.Handle, 'XData', source.XData, 'YData', source.YData, 'ZData', source.ZData, 'CData', source.CData); end
      
      obj.updatePlotTitle();
    end
    
    function OnPlotAxesChange(obj, source, event)        % Plot axes (lim, label... etc.) has changed
      try debugStamp(event.EventName, 1, obj); end % disp(event);
      
      plotAxes                  = obj.ParentAxes;
      try plotAxes.XLim         = source.XLim;        end
      try plotAxes.YLim         = source.YLim;        end
      try plotAxes.ZLim         = source.ZLim;        end
      try plotAxes.CLim         = source.ZLim;        end
      try plotAxes.AspectRatio  = source.AspectRatio; end
      
    end
    
    function OnPlotMapChange(obj, source, event)         % Plot map (colormap, clim... etc.) has changed
      try debugStamp(event.EventName, 1, obj); end % disp(event);
      try obj.ParentAxes.CLim = source.ZLim; end
      try colormap(obj.ParentAxes.Handle, source.ColorMap); end
    end
    
    function OnPlotViewChange(obj, source, event)        % Plot view has changed
      try debugStamp(event.EventName, 1, obj); end % disp(event);
    end
    
  end
  
end

