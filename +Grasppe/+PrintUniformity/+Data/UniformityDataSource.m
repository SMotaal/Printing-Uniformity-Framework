classdef UniformityDataSource < Grasppe.Core.Component % & GrasppeComponent
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
      'SetID',      'Set ID',           'Data Source',      'string',   '';   ...
      'SheetID',    'Sheet ID',         'Data Source',      'int',      '';   ...
      'ALim',       'Alpha Map Limits', 'Data Limits',      'limits',   '';   ...
      'CLim',       'Color Map Limits', 'Data Limits',      'limits',   '';   ...
      'XLim',       'X Axes Limits',    'Data Limits',      'limits',   '';   ...
      'YLim',       'Y Axes Limits',    'Data Limits',      'limits',   '';   ...
      'ZLim',       'Z Axes Limits',    'Data Limits',      'limits',   '';   ...
      };%     HANDLEPROPERTIES  = {};
        
  end
  
  properties (Hidden)
    LinkedPlotObjects = [];
    LinkedPlotHandles = [];
    PlotObjects       = [];
  end
  
  properties (SetObservable, GetObservable)
    
    ExtendedParameters,
    DataParameters, SourceData, SetData, SampleData
    XData, YData, ZData
    CaseID, SetID, SheetID
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
  
  properties (GetAccess=public, SetAccess=protected)
    currentParameters = [];
  end
  
  properties (Dependent)
    CaseName, SetName, SheetName,
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
      
      % obj = obj@GrasppeComponent(args{:});
      
      obj.attachPlotObject(plotObject);
      
    end
    
    function attachPlotObject(obj, plotObject)
      
      if isempty(plotObject) || ~Grasppe.Graphics.PlotComponent.checkInheritence(plotObject)
       return;
      end
      
      try debugStamp(obj.ID); catch, debugStamp(); end;
      plotObjects = obj.PlotObjects;
      if ~any(plotObjects==plotObject)
        try
          obj.PlotObjects(end+1) = plotObject;
        catch
          obj.PlotObjects = plotObject;
        end
      end
      
      obj.linkPlot(plotObject);
      
    end
    
    function linkPlot(obj, plotObject)
      try
        if Grasppe.Graphics.PlotComponent.checkInheritence(plotObject)
          plotObject.XData    = 'xData'; ...
            plotObject.YData  = 'yData'; ...
            plotObject.ZData  = 'zData';
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
      
%       try
%         zNaN        = isnan(zData);
%         
%         xData(zNaN) = NaN;
%         yData(zNaN) = NaN;
%       end
      
      try
        linkedPlots = unqiue(linkedPlots);
        if Grasppe.Graphics.PlotComponent.checkInheritence(plotObject), linkedPlots = linkedPlots.Handle; end
      catch err
        obj.validatePlots;
        linkedPlots = obj.LinkedPlotHandles;
      end
      
      linkedPlots = linkedPlots(ishandle(obj.LinkedPlotHandles));
      try
        refreshdata(linkedPlots, 'caller');
        % disp(['Refreshing Data for ' toString(linkedPlots(:))]);
      catch err
        disp(['Refreshing Data FAILED for ' toString(linkedPlots(:))]);
        halt(err, 'obj.ID');
        try debugStamp(obj.ID, 4); end
      end
      
      for h = linkedPlots
        plotObject = get(h, 'UserData');
        try plotObject.refreshPlot(obj); end     
        try plotObject.updatePlotTitle; end
      end
    end
    
  end
  
  %% Data Source Getters & Setters
  methods
    
    %% currentParameters
    
    function parameters = get.currentParameters(obj)
      parameters = [];
      try
        if isempty(obj.currentParameters)
          obj.currentParameters = Grasppe.PrintUniformity.Models.DataParameters;
        end
      end
      try parameters = obj.currentParameters; end
    end
    
    %% CaseID & SourceName
    
    function set.CaseID(obj, value)
      [obj.CaseID changed] = changeSet(obj.CaseID, value);
      changed = changed && ~isequal(value, obj.currentParameters.CaseID);
      if changed, obj.updateSourceParameters; end
      obj.CaseID = obj.currentParameters.CaseID;
      try debugStamp(obj.ID); catch, debugStamp(); end
    end
    
    function caseName = get.CaseName(obj)
      caseName = []; pressName = []; runCode = [];
      
      try pressName = obj.SourceData.metadata.testrun.press.name; end

      try runCode   = obj.SourceData.name; end
      try runCode   = sprintf('#%s', char(regexpi(runCode, '[0-9]{2}[a-z]?$', 'match'))); end

      try caseName  = strtrim([pressName ' ' runCode]); end
    end
    
    %% SetID & SetName
    
    function set.SetID(obj, value)
      [obj.SetID changed] = changeSet(obj.SetID, value);
      changed = changed && ~isequal(value, obj.currentParameters.SetID);
      if changed, obj.updateSourceParameters; end
      obj.SetID = obj.currentParameters.SetID;
      try debugStamp(obj.ID); catch, debugStamp(); end
    end
    
    function setName = get.SetName(obj)
      setName = [];
      %try setName = obj.SetData.setLabel; end
      try
        setName = [int2str(obj.SetData.patchSet) '%'];
      end
      if isnumeric(setName), setName = int2str(setName); end
    end
    
    %% SheetID & SheetName
    
    function set.SheetID(obj, value)
      [obj.SheetID changed] = changeSet(obj.SheetID, value);
      changed = changed && ~isequal(value, obj.currentParameters.SheetID);
      if changed, obj.updateSourceParameters; end
      obj.SheetID = obj.currentParameters.SheetID;
      try debugStamp(obj.ID); catch, debugStamp(); end;
    end
    
    function sampleName = get.SheetName(obj)
      sampleName = [];
      try sampleName = obj.SourceData.index.Sheets(obj.currentParameters.SheetID); end
      if isnumeric(sampleName), sampleName = int2str(sampleName); end
    end
    
    %% SetCount, SheetCount, Rows, Columns, RegionCount, ZoneCount
    
    function sets = getSetCount(obj)
      sets = [];
      try sets = obj.SourceData.Datasets.Length; end
    end
    
    function samples = getSheetCount(obj)
      samples = [];
      try samples = obj.SourceData.length.Sheets; end
    end    
    
    function rows = getRowCount(obj)
      rows = [];
      try rows    = obj.SourceData.metrics.sampleSize(1); end
    end
    
    function columns = getColumnCount(obj)
      columns = [];
      try columns = obj.SourceData.metrics.sampleSize(2); end
    end
    
    function regions = getRegionCount(obj)
      regions = [];
      % try regions    = obj.SourceData.metrics.sampleSize(1); end
    end
    
    function zones = getZoneCount(obj)
      zones = [];
      % try zones    = obj.SourceData.metrics.sampleSize(1); end
    end
    
  end
  
  %% Data Source Update Routines
  methods
    
    function updateSourceParameters(obj)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      parameters = obj.currentParameters;
      
      [parameters.CaseID  updateSource] = changeSet(parameters.CaseID,  obj.CaseID);
      [parameters.SetID   updateSet   ] = changeSet(parameters.SetID,   obj.SetID);
      [parameters.SheetID updateSheet ] = changeSet(parameters.SheetID, obj.SheetID);
      
      if updateSource || updateSet
        obj.updateSourceData();
      end
      
      if updateSheet || updateSet || updateSource
        obj.updateSheetData();
      end
      
      [obj.CaseID  updateSource] = changeSet(obj.CaseID,  parameters.CaseID);
      [obj.SetID   updateSet   ] = changeSet(obj.SetID,   parameters.SetID);
      [obj.SheetID updateSheet ] = changeSet(obj.SheetID, parameters.SheetID);
    end
    
    function updateSourceData(obj)
      parameters  = obj.currentParameters;
      
      sourceID    = parameters.CaseID; ...
        setID     = parameters.SetID; ...
        sheetID   = parameters.SheetID;
      
      if ~isnumeric(setID)
        setID = [];
      end
      
      args = {sourceID, setID};
      
      dataParameters  = obj.DataParameters;
      
      if isempty(dataParameters)
        dataParameters = {};
      end
      
      if ~iscell(dataParameters)
        dataParameters = {dataParameters};
      end
      
      args = {args{:}, dataParameters{:}};
      
      [sourceData setData extendedParameters] = Plots.plotUPStats(args{:});
      
      obj.SourceData            = sourceData; ...
        obj.SetData             = setData; ...
        obj.ExtendedParameters  = extendedParameters;
      
      parameters.SetID          = obj.SetData.patchSet;     
      parameters.SheetID        = limit(sheetID, 1, obj.getSheetCount);
              
      obj.optimizeSetLimits;
      
    end
    
    function updateSheetData(obj)
      parameters  = obj.currentParameters;
      
      sourceID  = parameters.CaseID; ...
        setID   = parameters.SetID; ...
        sheetID = parameters.SheetID;
      
      rows      = obj.getRowCount;
      columns   = obj.getColumnCount;
      
      [X Y Z]   = obj.processSheetData(sheetID);
      
      obj.setPlotData(X, Y, Z);
      
    end
    
    function [X Y Z] = processSheetData(obj, sheetID)
      rows    = obj.getRowCount;
      columns = obj.getColumnCount;
      
      [X Y Z] = meshgrid(1:columns, 1:rows, 1);
    end
    
    function setPlotData(obj, XData, YData, ZData)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      obj.XData = XData;
      obj.YData = YData;
      obj.ZData = ZData;
      
      obj.updatePlots();
    end
    
    
    function optimizeSetLimits(obj)
      zLim = 'auto';
      cLim = 'auto';
      
      try
        setData   = obj.SetData;

        zData     = [setData.data(:).zData];
        zMean     = nanmean(zData);
        zStd      = nanstd(zData,1);
        zSigma    = [-3 +3] * zStd;


        zMedian   = round(zMean*2)/2;
        zRange    = [-3 +3];
        zLim      = zMedian + zRange;

        cLim      = zLim;
      end
      
      obj.ZLim  = zLim;
      obj.CLim  = cLim;
    end

    
    function sheet = setSheet (obj, sheet)
      
      try debugStamp(obj.ID); catch, debugStamp(); end;
      
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
      
      % dispf('Sheet #%d >> %s', round(nextSheet), obj.ID);
      obj.SheetID = nextSheet;
      
    end
    
  end
  
  %% Static Component Methods
  
  methods(Abstract, Static, Hidden)
    % processPlotData(obj)
    options  = DefaultOptions()
    obj = Create()
  end
  
  
end

