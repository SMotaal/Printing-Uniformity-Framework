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
      'SetID',      'Set ID',           'Data Source',      'int',      '';   ...
      'SheetID',    'Sheet ID',         'Data Source',      'int',      '';   ...
      'VariableID', 'Variable ID',      'Data Source',      'string',   '';   ...
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
    
    % ExtendedParameters,
    % DataParameters, CaseData, SetData, SampleData
    XData, YData, ZData, CData
    % CaseID, SetID, SheetID, VariableID
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
    % currentParameters = [];
    
    DataProcessor;
  end
  
  properties (SetObservable, GetObservable, AbortSet)
    Parameters, Data;
    CaseID,     SetID,    SheetID,    VariableID
    CaseName,   SetName,  SheetName
  end
  
  properties (Dependent, Hidden=true)
    CaseData,   SetData,  SheetData
  end
  
  events
    CaseChange
    SetChange
    SheetChange
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
      
      % obj.currentParameters = Grasppe.PrintUniformity.Models.DataParameters;
      
      % obj.updateSourceParameters();
      
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
            plotObject.ZData  = 'zData'; ...
            plotObject.CData  = 'cData';
            
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

      cData = obj.CData;
      
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
        % halt(err, 'obj.ID');
        try debugStamp(obj.ID, 4); end
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
      obj.initializeDataProcessor;
      obj.createComponent@Grasppe.Core.Component;
    end
    
    function initializeDataProcessor(obj)
      if ~isa(obj.DataProcessor, 'Grasppe.PrintUniformity.Data.UniformityProcessor') ...
          || ~isvalid(obj.DataProcessor)
        obj.DataProcessor = Grasppe.PrintUniformity.Data.UniformityProcessor;
        obj.DataProcessor.addlistener('CaseChange',   @obj.updateCaseData);
        obj.DataProcessor.addlistener('SetChange',    @obj.updateSetData);
        obj.DataProcessor.addlistener('SheetChange',  @obj.updateSheetData);
        
        % dispf('%s.%s', obj.ID, 'initializeDataProcessor');
      end
    end
  end
  
  %% Data Source Getters & Setters
  methods
    
    %% currentParameters
    
    %     function parameters = get.currentParameters(obj)
    %       parameters = [];
    %       try
    % %         if isempty(obj.currentParameters)
    % %           obj.currentParameters = Grasppe.PrintUniformity.Models.DataParameters;
    % %         end
    %       end
    %       try parameters = obj.currentParameters; end
    %     end
    
    %% CaseID / CaseName / CaseData
    function caseID = get.CaseID(obj)
      caseID = [];
      try caseID = obj.DataProcessor.CaseID; end
    end
    
    function set.CaseID(obj, caseID)
      processor = obj.DataProcessor;
      [processor.CaseID changed] = changeSet(processor.CaseID, caseID);
      
      if changed, obj.CaseID = processor.CaseID; end
      % [obj.CaseID changed] = changeSet(obj.CaseID, value);
      % try
      %   changed = changed && ~isequal(value, obj.currentParameters.CaseID);
      %   if changed, obj.updateSourceParameters; end
      %   obj.CaseID = obj.currentParameters.CaseID;
      % end
      % try debugStamp(obj.ID); catch, debugStamp(); end
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
      try caseData = obj.DataProcessor.CaseData; end
    end
    
    %% SetID & SetName
    function setID = get.SetID(obj)
      setID = [];
      try setID = obj.DataProcessor.SetID; end
    end
    
    function set.SetID(obj, setID)
      processor = obj.DataProcessor;
      [processor.SetID changed] = changeSet(processor.SetID, setID);
      
      
      if changed, obj.SetID = processor.SetID; end
      % [obj.SetID changed] = changeSet(obj.SetID, value);
      % try
      %   changed = changed && ~isequal(value, obj.currentParameters.SetID);
      %   if changed, obj.updateSourceParameters; end
      %   obj.SetID = obj.currentParameters.SetID;
      % end
      % try debugStamp(obj.ID); catch, debugStamp(); end
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
      try setData = obj.DataProcessor.SetData; end
    end    
    
    %% SheetID & SheetName
    function sheetID = get.SheetID(obj)
      sheetID = [];
      try sheetID = obj.DataProcessor.SheetID; end
    end
    
    function set.SheetID(obj, sheetID)
      processor = obj.DataProcessor;
      [processor.SheetID changed] = changeSet(processor.SheetID, sheetID);
      
      if changed, obj.SheetID = processor.SheetID; end
    end
    
    function sampleName = get.SheetName(obj)
      sampleName = [];
      try sampleName = obj.CaseData.index.Sheets(obj.SheetID); end
      if isnumeric(sampleName), sampleName = int2str(sampleName); end
    end
    
    function sheetData = get.SheetData(obj)
      sheetData = [];
      try sheetData = obj.DataProcessor.SheetData; end
    end    
    
    %% VariableID
    function variableID = get.VariableID(obj)
      variableID = [];
      try variableID = obj.DataProcessor.VariableID; end
    end
    
    function set.VariableID(obj, variableID)
      processor = obj.DataProcessor;
      [processor.VariableID changed] = changeSet(processor.VariableID, variableID);
      
      
      obj.VariableID = processor.VariableID;
      % [obj.VariableID changed] = changeSet(obj.VariableID, value);
      % try
      %   changed = changed && ~isequal(value, obj.currentParameters.VariableID);
      %   if changed, obj.updateSourceParameters; end
      %   obj.VariableID = obj.currentParameters.VariableID;
      % end
      % try debugStamp(obj.ID); catch, debugStamp(); end
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
    
%     function regions = getRegionCount(obj)
%       regions = [];
%       try regions = obj.CaseData.metrics.sampleSize(1); end
%     end
%     
%     function zones = getZoneCount(obj)
%       zones = [];
%       try zones = obj.CaseData.metrics.sampleSize(1); end
%     end
    
  end
  
  %% Data Source Update Routines
  methods
    
    % function updateSourceParameters(obj)
    %   try debugStamp(obj.ID); catch, debugStamp(); end;
    %
    %   if ~isa(obj.currentParameters, 'Grasppe.PrintUniformity.Models.DataParameters')
    %     return;
    %   end
    %
    %   parameters = obj.currentParameters;
    %
    %   [parameters.CaseID      updateSource    ] = changeSet(parameters.CaseID,      obj.CaseID      );
    %   [parameters.SetID       updateSet       ] = changeSet(parameters.SetID,       obj.SetID       );
    %   [parameters.SheetID     updateSheet     ] = changeSet(parameters.SheetID,     obj.SheetID     );
    %   [parameters.VariableID  updateVariable  ] = changeSet(parameters.VariableID,  obj.VariableID  );
    %
    %   if updateSource || updateSet || updateVariable
    %     obj.updateCaseData();
    %   end
    %
    %   if updateSheet || updateSet || updateSource || updateVariable
    %     obj.updateSheetData();
    %   end
    %
    %   [obj.CaseID     updateSource    ] = changeSet(obj.CaseID,     parameters.CaseID     );
    %   [obj.SetID      updateSet       ] = changeSet(obj.SetID,      parameters.SetID      );
    %   [obj.SheetID    updateSheet     ] = changeSet(obj.SheetID,    parameters.SheetID    );
    %   [obj.VariableID updateVariable  ] = changeSet(obj.VariableID, parameters.VariableID );
    % end
    
    function updateCaseData(obj, source, event)
      % dispf('%s.%s', obj.ID, 'updateCaseData');
      
      obj.updateSetData(source, event);
      
      try obj.notify('CaseChange', event.EventData); return; end
      obj.notify('CaseChange');
    end
    
    function updateSetData(obj, source, event)
      % dispf('%s.%s', obj.ID, 'updateSetData');
      
      % obj.updateSheetData;
      
      obj.updateSheetData(source, event);
      
      obj.optimizeSetLimits;
      
      try obj.notify('SetChange', event.EventData); return; end
      obj.notify('SetChange');
    end
    
    function updateSheetData(obj, source, event)
      % dispf('%s.%s', obj.ID, 'updateSheetData');
      processor     = obj.DataProcessor; ...
        ...
        sourceID    = processor.CaseID; ...
        setID       = processor.SetID; ...
        sheetID     = processor.SheetID; ...
        variableID  = processor.VariableID;
      
      if isempty(sheetID) || ~isnumeric(sheetID), return; end
      
      rows      = obj.getRowCount;
      columns   = obj.getColumnCount;
      
      [X Y Z]   = obj.processSheetData(sheetID, variableID);
      
      obj.setPlotData(X, Y, Z);     
      
      try obj.notify('SheetChange', event.EventData); return; end
      obj.notify('SheetChange');
    end
    
    function [X Y Z] = processSheetData(obj, sheetID, variableID)
      rows    = obj.getRowCount;
      columns = obj.getColumnCount;
      
      [X Y Z] = meshgrid(1:columns, 1:rows, 1);
    end
    
    function setPlotData(obj, XData, YData, ZData)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      obj.XData = XData;
      obj.YData = YData;
      obj.ZData = ZData;
      obj.CData = ZData;
      
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
  
  methods(Static, Hidden)
    function OPTIONS  = DefaultOptions()
      Grasppe.Utilities.DeclareOptions;
    end
  end
  
  
end

