classdef UniformityPlotComponent < PrintUniformityBeta.Data.PlotDataEventHandler & PrintUniformityBeta.Data.OverlayDataEventHandler & GrasppeAlpha.Core.MouseEventHandler
  %UNIFORMITYPLOTOBJECT Co-superclass for printing uniformity plot objects
  %   Detailed explanation goes here
  
  properties (Dependent, SetObservable, GetObservable)
    DataSource
    Overlay                     = PrintUniformityBeta.Graphics.UniformityPlotOverlay.empty();
  end
  
  properties (Access=protected)
    dataSource
    sourceState
    overlay
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
      obj                       = obj@PrintUniformityBeta.Data.OverlayDataEventHandler();
      obj                       = obj@PrintUniformityBeta.Data.PlotDataEventHandler(varargin{:});
      obj.DataSource            = dataSource;
      
      %       obj.Overlay               = PrintUniformityBeta.Graphics.UniformityPlotOverlay; ...
      %         obj.registerHandle(obj.Overlay);
      %
      %       obj.Overlay.attachPlot(obj);

    end
    
    function updatePlotOverlay(obj)
      
      try debugStamp(obj.ID, 4); catch, debugStamp(); end;
      
      try
        if ~isscalar(obj.Overlay) || ...
            ~isa(obj.Overlay, 'PrintUniformityBeta.Graphics.UniformityPlotOverlay') ...
            ~isobject(obj.Overlay) || ~isvalid(obj.Overlay)
          obj.Overlay               = PrintUniformityBeta.Graphics.UniformityPlotOverlay; ...
            obj.registerHandle(obj.Overlay);
          
          obj.Overlay.attachPlot(obj);
        end
        
        
        if ~isscalar(obj.DataSource) || ...
            ~isa(obj.DataSource, 'PrintUniformityBeta.Data.OverlayDataEventHandler') ||...
            ~isa(obj.DataSource, 'PrintUniformityBeta.Data.PlotDataSource') || ...
            ~isobject(obj.DataSource) || ~isvalid(obj.DataSource)
          try obj.Overlay.deleteLabels(); end
          
          return;
        end
        
        try
          %           if ~isempty(obj.DataSource.RegionData{obj.SheetID})
          %             obj.DataSource.PlotValues  = obj.RegionData{obj.SheetID};
          %           end
          %           if ~isempty(obj.DataSource.RegionLabels{obj.SheetID})
          %             obj.DataSource.PlotStrings = obj.RegionLabels{obj.SheetID};
          %           end
        end
        obj.Overlay.MarkerIndex   = obj.DataSource.SheetID;
        obj.Overlay.defineLabels(obj.DataSource.PlotRegions, obj.DataSource.PlotValues, obj.DataSource.PlotStrings);
        obj.Overlay.SubPlotData   = obj.DataSource.RegionData;
        obj.Overlay.SubPlotStats  = obj.DataSource.Statistics;
        obj.Overlay.createLabels;

      catch err
        debugStamp(err, 1, obj);
      end
      
    end
    
  end
  
  methods
    
    function attachDataSource(obj, dataSource)
      
      if nargin<2, return; end
      
      try 
        obj.dataSource          = dataSource;
        dataSource.attachPlotObject(obj);
        
        try setappdata(obj, 'PlotDataSource', dataSource); end
        
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
    
    function updatePlotTitle(obj, base, sheetName, state)
      
      sheetName = '';      
      
      try caseName  = obj.DataSource.Reader.GetCaseTag;  end
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
    
    function set.Overlay(obj, overlay)
      obj.overlay               = overlay;
    end
    
    function overlay = get.Overlay(obj)
      overlay                   = obj.overlay;
    end
    
    
        
    function setSheet(obj, varargin)
      try obj.DataSource.setSheet(varargin{:}); end
      try obj.ParentFigure.StatusText = obj.DataSource.GetSheetName(obj.DataSource.NextSheetID); end % int2str(obj.DataSource.NextSheetID)
      GrasppeKit.Utilities.DelayedCall(@(s, e)drawnow('update',  'expose'), 0.5,'start');
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
    
    function OnOverlayPlotsDataChange(obj, source, event)        % Plot data has changed (need to refresh plot)
      obj.updatePlotOverlay;
      try obj.Overlay.updateSubPlots(); end
    end
    
    function OnOverlayLabelsDataChange(obj, source, event)        % Plot data has changed (need to refresh plot)
      obj.updatePlotOverlay;
    end    
    
    function OnPlotChange(obj, source, event)            % Plot object has changed
      % try debugStamp(event.EventName, 1, obj); end % disp(event);
      
      obj.OnPlotAxesChange(source);
      obj.OnPlotMapChange(source);
      obj.OnPlotViewChange(source);
      obj.OnPlotDataChange(source);      
    end
    
    function OnPlotDataChange(obj, source, event)        % Plot data has changed (need to refresh plot)
      % try debugStamp(event.EventName, 1, obj); end % disp(event);
      
      try set(obj.Handle, 'XData', source.XData, 'YData', source.YData, 'ZData', source.ZData, 'CData', source.CData); end
      
      obj.updatePlotTitle();
    end
    
    function OnPlotAxesChange(obj, source, event)        % Plot axes (lim, label... etc.) has changed
      % try debugStamp(event.EventName, 1, obj); end % disp(event);
      
      plotAxes                  = obj.ParentAxes;
      try plotAxes.XLim         = source.XLim;        end
      try plotAxes.YLim         = source.YLim;        end
      try plotAxes.ZLim         = source.ZLim;        end
      try plotAxes.CLim         = source.ZLim;        end
      try plotAxes.AspectRatio  = source.AspectRatio; end
      
      setappdata(plotAxes.Handle, 'PlotComponent', obj);
      setappdata(plotAxes, 'PlotComponent', obj);
      
      %setappdata(plotAxes.Handle, 'DataSource', obj.DataSource);
      
      try 
        obj.ParentFigure.ColorBar.createPatches; obj.ParentFigure.ColorBar.createLabels;
      end
      
    end
    
    function OnPlotMapChange(obj, source, event)         % Plot map (colormap, clim... etc.) has changed
      % try debugStamp(event.EventName, 1, obj); end % disp(event);
      try obj.ParentAxes.CLim   = source.ZLim; end
      try colormap(obj.ParentAxes.Handle, source.ColorMap); end
    end
    
    function OnPlotViewChange(obj, source, event)        % Plot view has changed
      % try debugStamp(event.EventName, 1, obj); end % disp(event);
    end
    
    function OnPlotStateChange(obj, source, event)
      try
        obj.sourceState         = source.State;
      catch err
        obj.sourceState         = GrasppeAlpha.Core.Enumerations.TaskStates.Ready;
      end
      
      if isequal(obj.sourceState, GrasppeAlpha.Core.Enumerations.TaskStates.Ready) % || isequal(obj.DataSource.NextSheetID, obj.DataSource.SheetID)
        try obj.ParentFigure.StatusText = ''; end
      else
        try obj.ParentFigure.StatusText = obj.DataSource.GetSheetName(obj.DataSource.NextSheetID); end % int2str(obj.DataSource.NextSheetID)
        GrasppeKit.Utilities.DelayedCall(@(s, e)drawnow('update',  'expose'), 0.5,'start');
      end
      
    end
    
    %     function set.sourceState(obj, state)
    %       if isequal(state, GrasppeAlpha.Core.Enumerations.TaskStates.Ready)
    %         obj.hideProgress;
    %       else
    %         obj.showProgress;
    %       end
    %     end
    %
    %     function showProgress(obj)
    %     end
    %
    %     function hideProgress(obj)
    %     end
    
  end
  
end

