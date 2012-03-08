classdef UniformityDataSource < GrasppeComponent
  %UNIFORMITYDATASOURCE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    HandleProperties = {};
    HandleEvents = {};
    ComponentType = 'UniformityDataSource';
    ComponentProperties = '';
  end
  
  
  properties (Hidden)
    IsRetrieving = false;
  end
  
  properties (SetObservable)
    DataParameters
    ExtendedParameters
    DataSource
    SourceData
    SetData
    SampleData
    
    XData
    YData
    ZData
    
    SourceID
    SetID
    SampleID;
    
    SampleIndex
    SampleSummary = false;
  end
  
  properties (Dependent)
    SourceName
    
    SetName
    Sets
    
    SampleName
    Samples
    
    Rows
    Columns
    Regions
    Zones
  end
  
  
  methods (Hidden)
    function obj = UniformityDataSource(varargin)
      
      args = varargin;
      plotObject = [];
      try
        if UniformityDataSource.checkInheritence(varargin{1}, 'SurfaceObject')
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
      objSetObserve = {'XData', 'YData', 'ZData', 'SampleID', 'SourceID', 'SetID'}; %objProperties([obj.MetaClass.PropertyList.SetObservable]);
      
      if ~isempty(objSetObserve)
        addlistener(obj, objSetObserve, 'PostSet', @plotObject.refreshPlotData);
      end
    end
  end
  
  %% Configurative Setters
  methods
    function set.SourceID(obj, value)
      obj.SourceID = changeSet(obj.SourceID, value);
      obj.retrieveSourceData();
    end
    
    function set.SetID(obj, value)
      obj.SetID = changeSet(obj.SetID, value);
    end
    
    function set.SampleID(obj, value)
      obj.SampleID = changeSet(obj.SampleID, value);
      try obj.processPlotData(); end
    end
  end
  
  %% Configurative Methods
  methods
    
    function setSource(obj, sourceID)
      
    end
    
    function retrieveSourceData(obj)
      
      if obj.IsRetrieving
        return;
      end
      
      source = obj.SourceID;
      
      if ~isValid(source, 'char')
        obj.SourceData  = [];
        obj.SetData     = [];
        obj.ExtendedParameters = [];
        obj.SampleID    = [];
%         obj.Samples     = [];
        return;
      end
      
      obj.IsRetrieving = true;
      
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
%       obj.Samples       = obj.SourceData.length.Sheets;
      
      obj.IsRetrieving = false;
    end
    
    
    function setPlotData(obj, XData, YData, ZData)
      obj.XData = XData;
      obj.YData = YData;
      obj.ZData = ZData;
    end
    
    function sheet = setSheet (obj, sheet)
      
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
    obj = createDataSource()
  end
  
  
end

