classdef UniformityDataSource < GrasppeComponent
  %UNIFORMITYDATASOURCE Superclass for surface uniformity data sources
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    HandleProperties = {};
    HandleEvents = {};
    ComponentType = 'UniformityDataSource';
    ComponentProperties = '';
    
    DataProperties = {'XData', 'YData', 'ZData', 'SampleID', 'SourceID', 'SetID'};
    
  end
  
  
  properties (Hidden)
    IsRetrieving      = false;
    IsRetrieved       = false;
    IsSettingSource   = false;
    
    LinkedPlotObjects = [];
    LinkedPlotHandles = [];
    PlotObjects       = [];
  end
  
  properties (SetObservable, GetObservable)
    
    ExtendedParameters,
    DataParameters, DataSource, SourceData, SetData, SampleData
    XData, YData, ZData
    SourceID, SetID, SampleID
    SetIndex, SampleIndex,
    SampleSummary = false
    
    %DataAspectRatioMode
    AspectRatio
    
    %CLimMode   ALimMode
    CLim,       ALim
    
    %XLimMode   XTickMode,  XTickLabelMode
    XLim,       XTick,      XTickLabel
    
    %YLimMode   YTickMode,  YTickLabelMode
    YLim,       YTick,      YTickLabel
    
    %ZLimMode   ZTickMode,  ZTickLabelMode
    ZLim,       ZTick,      ZTickLabel
  end
  
  properties (Dependent)
    SourceName, SetName, Sets, SampleName, Samples
    Rows, Columns, Regions, Zones
  end
  
  methods (Hidden)
    function obj = UniformityDataSource(varargin)
      args = varargin;
      plotObject = [];
      try
        if UniformityDataSource.checkInheritence(varargin{1}, 'PlotObject')
          plotObject = varargin{1};
          args = varargin(2:end);
        end
      end
      
      obj = obj@GrasppeComponent(args{:});
    end
    
    function optimizePlotLimits(obj)
      if obj.IsRetrieved
        setData = obj.SetData;
        
        zData   = [setData.data(:).zData];
        zMean   = nanmean(zData);
        zStd    = nanstd(zData,1);
        zSigma  = [-3 +3] * zStd;
        
        
        zMedian = round(zMean*2)/2;
        zRange  = [-3 +3];
        zLim    = zMedian + zRange;
        
        cLim    = zLim;
        
        obj.ZLim  = zLim;
        obj.CLim  = cLim;
      end
    end
    
    function attachPlotObject(obj, plotObject)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      plotObjects = obj.PlotObjects;
      if ~any(plotObjects==plotObject)
        try
          obj.PlotObjects(end+1) = plotObject;
        catch
          obj.PlotObjects = plotObject;
        end
      end
      obj.linkPlotObject(plotObject);
      obj.refreshPlot(plotObject);
    end
    
    function linkPlotObject(obj, plotObject)
      try
        if isobject(plotObject)
          plotObject.XData = 'xData';
          plotObject.YData = 'yData';
          plotObject.ZData = 'zData';
          try
            obj.LinkedPlotObjects(end+1) = plotObject;
          catch
            obj.LinkedPlotObjects = plotObject;
          end
        end
      end
      try
        obj.LinkedPlotObjects = unique(obj.LinkedPlotObjects);
      end
      try
        obj.LinkedPlotHandles = unique([obj.LinkedPlotObjects.Handle]);
      end
    end
    
    function refreshPlot(obj, plotObject)
      plotObject.refreshPlot(obj);
    end
    
    function refreshLinkedPlots(obj, linkedPlots)
      xData = obj.XData; yData = obj.YData; zData = obj.ZData;
      try
        linkedPlots = unqiue(linkedPlots);
      catch err
        obj.linkPlotObject();
        linkedPlots = unique(obj.LinkedPlotHandles);
      end
      linkedPlots = linkedPlots(ishandle(linkedPlots));
      try
        refreshdata(linkedPlots, 'caller');
      catch err
        halt(err, 'obj.ID');
        try debugStamp(obj.ID, 4); end
      end
      %       obj.refreshPlotData();
    end
    
    function refreshPlotData(obj, varargin)
      plotObjects = {};
      
      if isempty(varargin)
        plotObjects = obj.PlotObjects;
      else
        plotObjects = varargin;
      end
      
      obj.refreshLinkedPlots();
      
      if ~isempty(plotObjects), debugStamp(obj.ID); end
      
      for i = 1:numel(plotObjects)
        try
          obj.refreshPlot(plotObjects{i});
        end
      end
    end
  end
  
  %% Configurative Setters
  methods
    function set.SourceID(obj, value)
      obj.SourceID = changeSet(obj.SourceID, value);
      try debugStamp(obj.ID); catch, debugStamp(); end;
      obj.resetSource;
    end
    
    function set.SetID(obj, value)
      obj.SetID = changeSet(obj.SetID, value);
      try debugStamp(obj.ID); catch, debugStamp(); end;
    end
    
    function set.SampleID(obj, value)
      obj.SampleID = changeSet(obj.SampleID, value);
      try debugStamp(obj.ID); catch, debugStamp(); end;
      if ~obj.IsRetrieving
        try obj.processPlotData(); end
      end
    end
  end
  
  %% Configurative Methods
  methods
    
    function setSource(obj, sourceID)
      
    end
    
    function resetSource(obj)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      obj.IsSettingSource = true;
      obj.clearSourceData();
      obj.retrieveSourceData();
      obj.IsSettingSource = false;
    end
    
    function clearSourceData(obj)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      obj.IsRetrieved = false;  obj.IsRetrieving = false;
      if ~obj.IsSettingSource
        obj.SourceID = [];
        return;
      end
      obj.SourceData  = [];
      obj.SetData     = [];
      obj.ExtendedParameters = [];
      obj.SampleID    = [];
    end
    
    function retrieveSourceData(obj)
      if obj.IsRetrieving || obj.IsRetrieved, return; else obj.IsRetrieving=true; end
      
      try debugStamp(obj.ID); catch, debugStamp(); end;
      
      source = obj.SourceID;
      
      if ~isValid(source, 'char')
        return;
      end
      
      obj.SourceData  = [];
      obj.SetData     = [];
      obj.ExtendedParameters = [];
      obj.SampleID    = [];
      
      args = {source};
      
      parameters = obj.DataParameters;
      
      if isClass(parameters, 'cell') && ~isempty(parameters);
        args = {args{:}, parameters{:}};
      end
      
      [sourceData setData parameters] = Plots.plotUPStats(args{:});
      
      obj.SourceData    = sourceData;
      obj.SetData       = setData;
      obj.ExtendedParameters = parameters;
      obj.SampleID      = 1;
      
      obj.IsRetrieved   = true;
      obj.IsRetrieving  = false;
      
      obj.optimizePlotLimits();
      
      obj.refreshPlotData();
    end
    
    
    function setPlotData(obj, XData, YData, ZData)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      %       obj.forceSet('XData', XData, 'YData', YData, 'ZData', ZData);
      % %       obj.set('XData', XData, 'YData', YData, 'ZData', ZData);
      obj.XData = XData;
      obj.YData = YData;
      obj.ZData = ZData;
      
      obj.refreshPlotData();
    end
    
    function sheet = setSheet (obj, sheet)
      
      try debugStamp(obj.ID); catch, debugStamp(); end;
      
      currentSheet  = obj.SampleID;
      firstSheet    = 1;
      lastSheet     = obj.Samples;
      nextSheet     = currentSheet;
      
      %Parse sheet
      if isInteger(sheet)
        nextSheet = sheet;
      else
        step = 0;
        switch lower(sheet)
          case {'summary', 'sum'}
            if isequal(obj.SampleSummary, true), nextSheet = 0; end
          case {'alpha', 'first', '#1'}
            nextSheet = firstSheet;
          case {'omega', 'last'}
            nextSheet = lastSheet;
          case {'forward',  'next', '+1', '<'}
            step = +1;
          case {'previous', 'back', '-1', '>'}
            step = -1;
          otherwise
            try
              switch(sheet(1))
                case '+'
                  step = +str2double(sheet(2:end));
                case '-'
                  step = -str2double(sheet(2:end));
              end
            end
        end
        if ~isequal(step, 0)
          nextSheet = stepSet(currentSheet, step, lastSheet, 1);
        end
      end
      
      obj.SampleID = nextSheet;
      
    end
    
    
  end
  
  %% Informative Getters
  methods
    function sourceName = get.SourceName(obj)
      sourceName = [];
      try sourceName = obj.SourceData.Name; end
    end
    
    function setName = get.SetName(obj)
      setName = [];
      try setName = obj.SetData.Name; end
    end
    
    function sampleName = get.SampleName(obj)
      sampleName = [];
      try sampleName = obj.SampleData.Name; end
    end
    
    function sets = get.Sets(obj)
      sets = 0;
      try sets = obj.SourceData.Datasets.Length; end
    end
    
    function samples = get.Samples(obj)
      samples = 0;
      try samples = obj.SourceData.length.Sheets; end
    end
    
  end
  
  %% Static Component Methods
  
  methods(Abstract, Static, Hidden)
    processPlotData(obj)
    options  = DefaultOptions()
    obj = Create()
  end
  
  
end

