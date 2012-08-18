classdef UniformityDataSource < Grasppe.Core.Component & Grasppe.Occam.Process % & GrasppeComponent
  %UNIFORMITYDATASOURCE Superclass for surface uniformity data sources
  %   Detailed explanation goes here
  
  %   properties (Access=private)
  %     COMPONENTTYPE     = 'PrintingUniformityDataSource';
  %     HANDLEEVENTS      = {};
  %     DATAPROPERTIES    = {'CaseID', 'SetID', 'XData', 'YData', 'ZData', 'SheetID'};
  %     TESTPROPERTY      = 'test';
  %   end
  
  properties (Transient, Hidden)
    HandleProperties = {};
    HandleEvents = {};
    ComponentType = 'PrintingUniformityDataSource';
    ComponentProperties = '';
    
    DataProperties = {'CaseID', 'SetID', 'XData', 'YData', 'ZData', 'SheetID'};
    
    UniformityDataSourceProperties = {
      'CaseID',     'Case ID',          'Data Source',      'string',   '';   ...
      'SetID',      'Set ID',           'Data Source',      'int',      '';   ...
      'SheetID',    'Sheet ID',         'Data Source',      'int',      '';   ...
      'VariableID', 'Variable ID',      'Data Source',      'string',   '';   ...
      'PlotType',   'Plot Type',        'Data Processing'   'string',   '';   ...
      'ALim',       'Alpha Map Limits', 'Data Limits',      'limits',   '';   ...
      'CLim',       'Color Map Limits', 'Data Limits',      'limits',   '';   ...
      'XLim',       'X Axes Limits',    'Data Limits',      'limits',   '';   ...
      'YLim',       'Y Axes Limits',    'Data Limits',      'limits',   '';   ...
      'ZLim',       'Z Axes Limits',    'Data Limits',      'limits',   '';   ...
      };
    
  end
  
  properties (Hidden)
    LinkedPlotObjects = [];
    LinkedPlotHandles = [];
    PlotObjects       = [];
  end
  
  properties (SetObservable, GetObservable)
    
    AspectRatio
    XData, YData, ZData, CData
    CLim,       ALim                      %CLimMode   ALimMode
    XLim,       XTick,      XTickLabel    %XLimMode   XTickMode,  XTickLabelMode
    YLim,       YTick,      YTickLabel    %YLimMode   YTickMode,  YTickLabelMode
    ZLim,       ZTick,      ZTickLabel    %ZLimMode   ZTickMode,  ZTickLabelMode
    
    PlotType = 'Surface';
  end
  
  properties (GetAccess=public, SetAccess=protected)
    DataReader;
    PreprocessTimer = [];
    AllData         = {};
    AllDataEnabled  = false;
  end
  
  properties (SetObservable, GetObservable, AbortSet)
    %Parameters, % Data
    CaseID,     SetID,    SheetID,    VariableID='raw'
    CaseName,   SetName,  SheetName
    SampleSummary = false
  end
  
  properties (Hidden)
    LastCaseID,   LastSetID,  LastSheetID,  LastVariableID
  end
  
  properties (Dependent, Hidden=true)
    CaseData,   SetData,  SheetData
  end
  
  events
    CaseChange
    SetChange
    SheetChange
    VariableChange
    PlotChange
    ProcessorChange
  end
  
  methods (Hidden)
    function obj = UniformityDataSource(varargin)
      obj = obj@Grasppe.Core.Component(varargin{:});
            
      args = varargin;
      plotObject = [];
      try
        if Grasppe.Graphics.PlotComponent.checkInheritence(varargin{1})
          plotObject = varargin{1};
          args = varargin(2:end);
        end
      end      
      
      %obj.attachPlotObject(plotObject);
      
    end
    
    function preprocessSheetData(obj) %, variableID)
      isRunning   = @(x) isequal(x.Running, 'on');
      
      if isempty(obj.PreprocessTimer) || ~isa(obj.PreprocessTimer, 'timer')
        obj.PreprocessTimer = timer('Tag',['PreprocessTimer' obj.ID], ...
          'StartDelay', 0.5, ...
          'TimerFcn', @(s,e)obj.preprocessSheetData() ...
          );
      end

        
      
      preprocessing  = false;
      try preprocessing  = isRunning(obj.PreprocessTimer); end
      
      if preprocessing
        stop(obj.PreprocessTimer);
        
        obj.AllData = obj.getAllData();
        obj.postprocessSheetData();
      else
        if isempty(obj.AllData) && isequal(obj.AllDataEnabled, true)
          try start(obj.PreprocessTimer); end
        end
      end
      
    end
    
    function postprocessSheetData(obj)
    end
    
    function [id space] = getDataID(obj, prefix, suffix)
      
      if nargin<2 || isempty(prefix), prefix = 'SourceData'; end
      if nargin<3 || isempty(suffix), suffix = ''; end
      
      prefix = regexprep([upper(prefix(1)) prefix(2:end)], '\W', '');
      suffix = regexprep([upper(suffix(1)) suffix(2:end)], '\W', '');

        reader     = obj.DataReader;
        caseID        = reader.CaseID;
        setID       = reader.SetID;
        sheetID     = reader.SheetID;
        variableID  = reader.VariableID;
        
        space         = [caseID prefix];
        id            = Data.generateUPID(caseID, setID, [variableID suffix]);
    end
    
    function data = getAllData(obj)
      
      bufferAllData = true; %Grasppe.PrintUniformity.Options.Defaults.BufferSurfData';
      
      data = obj.AllData;
      if ~isempty(obj.AllData) || ~isequal(obj.AllDataEnabled, true), return; end;
      
      try debugStamp(obj.ID, 3); catch, debugStamp(); end;
                  
      try

        reader     = obj.DataReader; ...
          ...
          caseID      = reader.CaseID; ...
          setID       = reader.SetID; ...
          sheetID     = reader.SheetID; ...
          variableID  = reader.VariableID;
        
        %% Data Buffering
        
        t             = tic;
        
        [id space]    = obj.getDataID;
        bufferedData  = {};
        
        if bufferAllData, bufferedData = Data.dataSources(id, space); end
        
        if isempty(bufferedData)
        
          sheetRange    = reader.Data.CaseData.range.Sheets;

          data          = cell(numel(sheetRange),1);

          obj.AllData   = data;

          for s = sheetRange
            [X Y Z]     = obj.processSheetData({s}, variableID);
            data{s,1}  = X;
            data{s,2}  = Y;
            data{s,3}  = Z;
            %data{s,:}  = {X, Y, Z};
          end
          
          Data.dataSources(id, data, true, space);
        else
          data = bufferedData;
        end
        
        obj.AllData   = data;
      
      catch err
        disp(err);
      end
      
    end
    
    
    function attachPlotObject(obj, plotObject)
      
      if isempty(plotObject) || ~Grasppe.Graphics.PlotComponent.checkInheritence(plotObject)
        return;
      end
      
      try debugStamp(obj.ID, 3); catch, debugStamp(); end;

      plotObjects = obj.PlotObjects;
      if ~any(plotObjects==plotObject)
        try
          obj.PlotObjects(end+1) = plotObject;
        catch
          obj.PlotObjects = plotObject;
        end
      end
      
      obj.linkPlot(plotObject);
      
      obj.optimizeSetLimits;
      
    end
    
    function linkPlot(obj, plotObject)
      try
        if Grasppe.Graphics.PlotComponent.checkInheritence(plotObject)
          plotObject.XData    = 'xData'; ...
            plotObject.YData  = 'yData'; ...
            plotObject.ZData  = 'zData'; % ...
          % plotObject.CData  = 'cData';
          
          try
            obj.LinkedPlotObjects(end+1) = plotObject;
          catch
            obj.LinkedPlotObjects = plotObject;
          end
        end
      end
      obj.validatePlots();
      obj.updatePlots(plotObject.Handle);
    end
    
    function validatePlots(obj)
      try obj.LinkedPlotObjects = unique(obj.LinkedPlotObjects); end
      try obj.LinkedPlotHandles = unique([obj.LinkedPlotObjects.Handle]); end
    end
    
    function updatePlots(obj, linkedPlots)
      xData = obj.XData; yData = obj.YData; zData = obj.ZData;
      
      % cData = obj.CData;
      
      linkedPlots = [];
      
      try
        linkedPlots = unique(linkedPlots);
        if exist('plotObject', 'var') && ...
            Grasppe.Graphics.PlotComponent.checkInheritence(plotObject)
          linkedPlots = linkedPlots.Handle;
        end
      catch err
      end
      
      if isempty(linkedPlots)
        obj.validatePlots;
        linkedPlots = obj.LinkedPlotHandles;
      end
      
      linkedPlots = linkedPlots(ishandle(obj.LinkedPlotHandles));
      try
        refreshdata(linkedPlots, 'caller');
        % disp(['Refreshing Data for ' toString(linkedPlots(:))]);
      catch err
        disp(['Refreshing Data FAILED for ' toString(linkedPlots(:))]);
        % halt(err, 'obj.ID');
        try debugStamp(obj.ID, 2); end
      end
      
      for h = linkedPlots
        plotObject = get(h, 'UserData');
        try plotObject.refreshPlot(obj); end
        % try plotObject.updatePlotTitle; end
      end
    end
    
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      obj.initializeDataReader;
      obj.createComponent@Grasppe.Core.Component;
    end
    
    function initializeDataReader(obj)
      if ~isa(obj.DataReader, 'Grasppe.PrintUniformity.Data.UniformityDataReader') ...
          || ~isvalid(obj.DataReader)
        obj.DataReader = Grasppe.PrintUniformity.Data.UniformityDataReader;
        obj.DataReader.addlistener('CaseChange',   @obj.updateCaseData);
        obj.DataReader.addlistener('SetChange',    @obj.updateSetData);
        obj.DataReader.addlistener('SheetChange',  @obj.updateSheetData);
        obj.DataReader.addlistener('VariableChange',  @obj.updateVariableData);
      end
    end
  end
  
  %% Data Source Getters & Setters
  methods
        
    %% CaseID / CaseName / CaseData
    function caseID = get.CaseID(obj)
      caseID = [];
      try caseID = obj.DataReader.CaseID; end
    end
    
    function set.CaseID(obj, caseID)
      reader = obj.DataReader;
      
      lastValue       = obj.LastCaseID;
      obj.LastCaseID  = obj.CaseID;
      
      [reader.CaseID changed] = changeSet(reader.CaseID, caseID);
      
      if changed
        obj.CaseID      = reader.CaseID;
      else
        obj.LastCaseID  = lastValue;
      end
      
    end
    
    function caseName = get.CaseName(obj)
      caseName = []; pressName = []; runCode = [];
      
      try pressName = obj.CaseData.metadata.testrun.press.name; end
      
      try runCode   = obj.CaseData.name; end
      try runCode   = sprintf('#%s', char(regexpi(runCode, '[0-9]{2}[a-z]?$', 'match'))); end
      
      try caseName  = strtrim([pressName ' ' runCode]); end
    end
    
    function caseData = get.CaseData(obj)
      caseData = [];
      try caseData = obj.DataReader.CaseData; end
    end
    
    %% SetID & SetName
    function setID = get.SetID(obj)
      setID = [];
      try setID = obj.DataReader.SetID; end
    end
    
    function set.SetID(obj, setID)
      reader = obj.DataReader;
      
      lastValue     = obj.LastSetID;
      obj.LastSetID = obj.SetID;
      
      [reader.SetID changed] = changeSet(reader.SetID, setID);
      
      if changed
        obj.SetID     = reader.SetID;
      else
        obj.LastSetID = lastValue;
      end
      
    end
    
    function setName = get.SetName(obj)
      setName = [];
      %try setName = obj.SetData.setLabel; end
      try
        setName = [int2str(obj.SetData.patchSet) '%'];
      end
      if isnumeric(setName), setName = int2str(setName); end
    end
    
    function setData = get.SetData(obj)
      setData = [];
      try setData = obj.DataReader.SetData; end
    end
    
    %% SheetID & SheetName
    function sheetID = get.SheetID(obj)
      sheetID = [];
      try sheetID = obj.DataReader.SheetID; end
    end
    
    function set.SheetID(obj, sheetID)
      reader = obj.DataReader;
      
      lastValue       = obj.LastSheetID;
      obj.LastSheetID = obj.SheetID;
      
      [reader.SheetID changed] = changeSet(reader.SheetID, sheetID);
      
      if changed
        obj.SheetID     = reader.SheetID;
      else
        obj.LastSheetID = lastValue;
      end
    end
    
    function sampleName = get.SheetName(obj)
      sampleName = [];
      try sampleName = obj.CaseData.index.Sheets(obj.SheetID); end
      if isnumeric(sampleName), sampleName = int2str(sampleName); end
    end
    
    function sheetData = get.SheetData(obj)
      sheetData = [];
      try sheetData = obj.DataReader.SheetData; end
    end
    
    %% VariableID
    function variableID = get.VariableID(obj)
      variableID = [];
      try variableID = obj.DataReader.VariableID; end
    end
    
    function set.VariableID(obj, variableID)
      reader = obj.DataReader;
      
      lastValue           = obj.LastVariableID; %obj.VariableID;
      obj.LastVariableID  = obj.VariableID;
      
      [reader.VariableID changed] = changeSet(reader.VariableID, variableID);
      
      if changed
        obj.VariableID      = reader.VariableID;
      else
        obj.LastVariableID  = lastValue;
      end
    end
    
    
    %% SetCount, SheetCount, Rows, Columns, RegionCount, ZoneCount
    
    function sets = getSetCount(obj)
      sets = [];
      try sets = obj.CaseData.Datasets.Length; end
    end
    
    function samples = getSheetCount(obj)
      samples = [];
      try samples = obj.CaseData.length.Sheets; end
    end
    
    function rows = getRowCount(obj)
      rows = [];
      try rows = obj.CaseData.metrics.sampleSize(1); end
    end
    
    function columns = getColumnCount(obj)
      columns = [];
      try columns = obj.CaseData.metrics.sampleSize(2); end
    end
    
  end
  
  %% Data Source Update Routines
  methods
    
    function updateCaseData(obj, source, event)    
      
      try stop(obj.PreprocessTimer); end
      obj.AllData = {};      
      
      try debugStamp(obj.ID, 3); catch, debugStamp(); end;
      
      try
        obj.notify('CaseChange', event.EventData);
      catch err
        obj.notify('CaseChange');
      end
      
      obj.updateSetData(source, event);
      
    end
    
    function updateSetData(obj, source, event) 

      try stop(obj.PreprocessTimer); end
      obj.AllData = {};
      
      try debugStamp(obj.ID, 3); catch, debugStamp(); end;
      
      try
        obj.notify('SetChange', event.EventData);
      catch err
        obj.notify('SetChange');
      end
      
      obj.optimizeSetLimits;

      obj.updateSheetData(source, event);
      
    end
    
    function updateSheetData(obj, source, event)
      
      obj.preprocessSheetData;
      
      allData = obj.AllData;
      
      reader     = obj.DataReader; ...
        ...
        sourceID    = reader.CaseID; ...
        setID       = reader.SetID; ...
        sheetID     = reader.SheetID; ...
        variableID  = reader.VariableID;
      
      if isempty(sheetID) || ~isnumeric(sheetID), return; end
      
      try debugStamp(obj.ID, 4); catch, debugStamp(); end;
      
      try
        obj.notify('SheetChange', event.EventData);
      catch err
        obj.notify('SheetChange');
      end
      
      if ~isempty(allData) && sheetID>0 %&& sheetID<obj.getSheetCount
        if size(allData,1) >= sheetID && ~isempty(allData{sheetID,1}) % || isempty(sheetID)
          %[X Y Z]
          X         = allData{sheetID,1};
          Y         = allData{sheetID,2};
          Z         = allData{sheetID,3};
          
          if isempty(Y) && isempty(Z) && ~isempty(X)
            X = allData{1,1};
            Y = allData{1,2};
            Z = allData{sheetID,1};
          end
        else
          [X Y Z]   = obj.processSheetData(sheetID, variableID);
          
          try
            obj.AllData{sheetID,1} = X;
            obj.AllData{sheetID,1} = Y;
            obj.AllData{sheetID,1} = Z;
          end
        end
      else        
        [X Y Z]   = obj.processSheetData(sheetID, variableID);         %rows      = obj.getRowCount; %columns   = obj.getColumnCount;
      end
      
      obj.setPlotData(X, Y, Z);
      
    end
    
    function updateVariableData(obj, source, event)
            
      try stop(obj.PreprocessTimer); end
      obj.AllData = {};
      
      try debugStamp(obj.ID, 3); catch, debugStamp(); end;
      
      obj.updateSheetData(source, event);
    end
    
    function [X Y Z] = processSheetData(obj, sheetID, variableID)
      rows    = obj.getRowCount;
      columns = obj.getColumnCount;
      
      [X Y Z] = meshgrid(1:columns, 1:rows, 1);
    end
    
    function setPlotData(obj, XData, YData, ZData)
      try debugStamp(obj.ID, 5); catch, debugStamp(); end;
      
      obj.XData = XData;
      obj.YData = YData;
      obj.ZData = ZData;
      obj.CData = ZData;
      
      obj.updatePlots();
    end
    
    
    function optimizeSetLimits(obj, x, y, z, c)
      
      try debugStamp(obj.ID, 3); catch, debugStamp(); end;
      
      %% Optimize XLim & YLim
      xLim = 'auto';
      yLim = 'auto';
      
      try
        if nargin > 1 && ~isempty(x) % isnumeric(x) && size(x)==[1 2];
          xLim = x;
        else
          xLim = [1 obj.getColumnCount];
        end
      end
      
      try
        if nargin > 2 && ~isempty(y) % isnumeric(y) && size(y)==[1 2];
          yLim = y;
        else
          yLim = [1 obj.getRowCount];
        end
      end
      
      obj.XLim  = xLim;
      obj.YLim  = yLim;
      
      
      %% Optimize ZLim & CLim
      zLim = 'auto';
      cLim = 'auto';
      
      try
        if nargin > 3 && ~isempty(z) % isnumeric(z) && size(z)==[1 2];
          zLim = z;
        else
          setData   = obj.SetData;
          
          zData     = [setData.data(:).zData];
          zMean     = nanmean(zData);
          zStd      = nanstd(zData,1);
          zSigma    = [-3 +3] * zStd;
          
          
          zMedian   = round(zMean*2)/2;
          zRange    = [-3 +3];
          zLim      = zMedian + zRange;
        end
      end
      
      try
        if nargin > 4 && ~isempty(c) % isnumeric(c) && size(c)==[1 2];
          cLim      = c;
        else
          cLim      = zLim;
        end
      end
      
      obj.ZLim  = zLim;
      obj.CLim  = cLim;
      
      %% Update to LinkedPlots
      try
        plotObject = obj.LinkedPlotObjects;
        
        for m = 1:numel(plotObject)
          try plotObject(m).ParentAxes.XLim = obj.XLim; end
          try plotObject(m).ParentAxes.YLim = obj.YLim; end
          try plotObject(m).ParentAxes.ZLim = obj.ZLim; end
          try plotObject(m).ParentAxes.CLim = obj.CLim; end
        end
      end
      
    end
    
    
    function sheet = setSheet (obj, sheet)
      
      try debugStamp(obj.ID, 5); catch, debugStamp(); end;
      
      currentSheet  = obj.SheetID;
      firstSheet    = 1;
      lastSheet     = obj.getSheetCount;
      nextSheet     = currentSheet;
            
      %Parse sheet
      if isInteger(sheet)
        nextSheet = sheet;
      else
        step = 0;
        switch lower(sheet)
          case {'summary', 'sum'}
            nextSheet = lastSheet+1; %if isequal(obj.SampleSummary, true), nextSheet = 0; end
          case {'alpha', 'first', '#1'}
            nextSheet = firstSheet;
          case {'omega', 'last'}
            nextSheet = lastSheet;
          case {'forward',  'next', '+1', '<'}
            if currentSheet>lastSheet, currentSheet=0;
            end
            step = +1;
          case {'previous', 'back', '-1', '>'}
            if currentSheet>lastSheet, currentSheet=1;
            end
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
      
      % dispf('Sheet #%d >> %s', round(nextSheet), obj.ID);
      obj.SheetID = nextSheet;
      
    end
    
  end
  
  %% Static Component Methods
  
  methods(Static, Hidden)
    function OPTIONS  = DefaultOptions()
      Grasppe.Utilities.DeclareOptions;
    end
  end
  
  
end
