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
    
    PlotObjects   = {};
  end
  
  properties (SetObservable, GetObservable)
    
    ExtendedParameters,
    DataParameters, DataSource, SourceData, SetData, SampleData
    XData, YData, ZData
    SourceID, SetID, SampleID
    SetIndex, SampleIndex,
    SampleSummary = false
    
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
      
      if ~isempty(plotObject)
        obj.attachPlotObject(plotObject);
      end
    end
    
    function attachPlotObject(obj, plotObject)
      debugStamp(obj.ID);
      plotObjects = obj.PlotObjects;
      if ~any(plotObjects==plotObject)
        obj.PlotObjects = {plotObjects{:}, plotObject};
      end
      
      obj.refreshPlot(plotObject);
    end
    
    function refreshPlot(obj, plotObject)
      plotObject.refreshPlot(obj);
    end
    
    function refreshPlotData(obj, varargin)
      plotObjects = {};
      if isempty(varargin)
        plotObjects = obj.PlotObjects;
      else
        plotObjects = varargin;
      end
      
      if ~isempty(plotObjects), debugStamp(obj.ID); end
      
      for i = 1:numel(plotObjects)
        
        try
          plotObjects{i}.refreshPlot();
        end
      end
    end
  end
  
  %% Configurative Setters
  methods
    function set.SourceID(obj, value)
      obj.SourceID = changeSet(obj.SourceID, value);
      debugStamp(obj.ID);
      obj.resetSource;
    end
    
    function set.SetID(obj, value)
      obj.SetID = changeSet(obj.SetID, value);
      debugStamp(obj.ID);
    end
    
    function set.SampleID(obj, value)
      obj.SampleID = changeSet(obj.SampleID, value);
      debugStamp(obj.ID);
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
      debugStamp(obj.ID);
      obj.IsSettingSource = true;
      obj.clearSourceData();
      obj.retrieveSourceData();
      obj.IsSettingSource = false;
    end
    
    function clearSourceData(obj)
      debugStamp(obj.ID);
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
      
      debugStamp(obj.ID);
      
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
      
      obj.refreshPlotData();
    end
    
    
    function setPlotData(obj, XData, YData, ZData)
      debugStamp(obj.ID);
      %       obj.forceSet('XData', XData, 'YData', YData, 'ZData', ZData);
      % %       obj.set('XData', XData, 'YData', YData, 'ZData', ZData);
      obj.XData = XData;
      obj.YData = YData;
      obj.ZData = ZData;
      obj.refreshPlotData;
    end
    
    function sheet = setSheet (obj, sheet)
      
      debugStamp(obj.ID);
      
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

