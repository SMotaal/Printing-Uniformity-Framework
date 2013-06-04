classdef StatsPlotDataSource < PrintUniformityBeta.Data.PlotDataSource & GrasppeAlpha.Occam.Process %& PrintUniformityBeta.Data.PlotDataSource
  %UNIFORMITYPLOTDATASOURCE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    % PlotRegions                 = [];
    % PlotValues                  = [];
    % PlotStrings                 = {};
    % PlotRegions                   = PrintUniformityBeta.Models.PlotRegionModel.empty;
    PlotData                      = PrintUniformityBeta.Models.Visualizer.StatsPlotDataModel.empty();
    PlotDataMap
    Tasks                         = struct;
  end
  
  events
    % ObjectBeingDestroyed
    % PropertyAdded
    % PropertyRemoved
    
    % DataChange
    % DataSourceChange
    
    % PlotChange
    % PlotDataChange
    % PlotTitleChange
    % PlotStateChange
    % PlotAxesChange
    % PlotMapChange
    % PlotViewChange
    
    % OverlayChange
    % OverlayDataChange
    % OverlayStyleChange
    % OverlayPlotsDataChange
    % OverlayPlotsStyleChange
    % OverlayLabelsDataChange
    % OverlayLabelsStyleChange
    
    % ExecutionComplete
    % ExecutionFailed
    % ExecutionStarted
    % StatusChanged
    % ProcessParametersChanged
    % ProgrssChanged
    
  end
  
  methods
    
    %preparePlotRegions(obj);
    setMetrics                  = getSetMetrics(obj, setData);
    metrics                     = getRegionMetrics(obj, metricsTable, roiData, roiRows, roiColumns)
    plotData                    = getPlotData(obj, setData);
    
    function obj = StatsPlotDataSource(varargin)
      % initializer = true; try initializer = ~isequal(evalin('caller', 'initializer'), true); end
      % disp([mfilename ' initializer: ' num2str(nargout) '<' num2str(initializer)]);
      obj                       = obj@PrintUniformityBeta.Data.PlotDataSource(varargin{:});
      %obj                       = obj@PrintUniformityBeta.Data.PlotDataSource(varargin{:});
      
      obj.processCaseData;
    end
    
    function setSheet(obj, varargin)
      try obj.setSheet@PrintUniformityBeta.Data.PlotDataSource(varargin{:}); end
      % try obj.ParentFigure.StatusText = obj.GetSheetName(obj.NextSheetID); end % int2str(obj.DataSource.NextSheetID)
      % obj.notify('PlotTitleChange');
      %obj.updatePlotTitle([], [], obj.DataSource.GetSheetName(obj.DataSource.NextSheetID));
      % drawnow expose update;      
    end    
    
    
    function processCaseData(obj, recursive)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      % disp('Processing Case Data');
      
      try
        animate                 = obj.PlotObjects{1}.ParentFigure.Animate;
        obj.PlotObjects{1}.ParentFigure.Animate = 'off';
      end
      
      caseData                  = obj.caseData;
      
      if ~isequal(obj.caseID, obj.Reader.CaseID) || isempty(obj.CaseData) || isempty(obj.CaseName)
        
        try cellfun(@(p)cla(p.ParentAxes.Handle), obj.PlotObjects); drawnow update expose; end
        
        obj.caseID              = obj.Reader.CaseID;          % skip ID change event
        obj.CaseData            = obj.Reader.getCaseData();   % fire Data change event
        obj.CaseName            = obj.Reader.GetCaseTag();    % fire Name change event %obj.Reader.CaseName;
        
      else
        if ~isequal(obj.caseData, obj.Reader.CaseData), obj.CaseData = obj.Reader.CaseData; end
      end
      
      if ~isequal(caseData, obj.caseData)
        % notify
        if obj.DebuggingDataProcessing, disp('processCaseData:caseDataChanged'); end
      end
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processSetData(); end
      
      % try obj.PlotObjects{1}.ParentAxes.IsVisible = true; end      
      
      try
        obj.PlotObjects{1}.ParentFigure.Animate = animate;
      end
      % disp('Processed Case Data');
    end
    
    function processSetData(obj, recursive)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      % disp('Processing Set Data');
      
      setData                   = obj.setData;
      try if  ~isfield(setData, 'ID') || ~isequal(setData.ID, obj.setID), obj.setData = []; end; end
      try if  ~isequal(setData.obj.setID, obj.Reader.SetID),              obj.setData = []; end; end
      
      try
        if ~isequal(obj.setID, obj.Reader.SetID) || isempty(obj.setData) || isempty(obj.setName)
          
          try cellfun(@(p)cla(p.ParentAxes.Handle), obj.PlotObjects); drawnow update expose; end
          
          obj.setID               = obj.Reader.SetID;           % skip ID change event
          newData                 = obj.Reader.getSetData();
          newData.Metrics         = obj.getSetMetrics(newData);        % if ~isfield(newData, 'Metrics')
          
          obj.setData             = newData;
          obj.SetName             = obj.Reader.SetName;         % fire Name change event
          
          obj.PlotData            = obj.getPlotData(obj);
        end
      catch err
        debugStamp(err, 1, obj);
        rethrow(err);
      end
      
      if ~isequal(setData, obj.setData)
        if obj.DebuggingDataProcessing, disp('processSetData:setDataChanged'); end
        obj.resetAxesLimits();
        obj.resetColorMap();
        obj.notify('OverlayPlotsDataChange'); % obj.preparePlotRegions();        
      end
      
      try obj.Tasks.GetMetrics.SEAL; end
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processSheetData(); end
      
      try obj.resetTasks(); end
      
      % disp('Processed Set Data');
    end
    
    function processSheetData(obj, recursive)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      % disp('Processing Sheet Data');
      
      sheetData                   = obj.sheetData;
      
      if ~isequal(obj.sheetID, obj.Reader.SheetID) || isempty(obj.SheetData) || isempty(obj.SheetName)
        obj.sheetID               = obj.Reader.SheetID;         % skip ID change event
        obj.SheetData             = obj.Reader.getSheetData();  % fire Data change event
        obj.SheetName             = obj.Reader.SheetName;       % fire Name change event
      else
        if ~isequal(obj.sheetData, obj.Reader.SheetData), obj.SheetData = obj.Reader.SheetData; end
      end
      
      if ~isequal(sheetData, obj.sheetData)
        if obj.DebuggingDataProcessing, disp('processSheetData:sheetDataChanged'); end
        obj.notify('PlotDataChange');
      end
      
      % if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processVariableData(); end
      % disp('Processed Sheet Data');
    end
    
    function processVariableData(obj, recursive)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      % disp('Processing Variable Data');
      % obj.VariableData          = obj.SheetData;              % fire Data change event
      % obj.VariableName          = '';                         % fire Name change event
      
      % obj.updatePlotData();
      
      % obj.notify('OverlayLabelsDataChange');
      
      plotData                    = obj.PlotData;
      try obj.PlotData            = obj.getPlotData(); end
      
      if ~isequal(plotData, obj.PlotData)
        if obj.DebuggingDataProcessing, disp('processSetData:variableDataChanged'); end
        obj.notify('OverlayPlotsDataChange'); % obj.preparePlotRegions();
      end
      
      % disp('Processed Variable Data');
    end
    
    %     function resetAxesLimits(obj, x, y, z, c)
    %       rows                        = obj.RowCount;
    %       columns                     = obj.ColumnCount;
    %
    %       summaryOffset               = obj.summaryOffset;
    %       summaryLength               = obj.summaryLength;
    %
    %       % offsetRange                 = 1:summaryOffset;
    %       % summaryRange                = summaryOffset + 1 + [0:summaryLength];
    %       summaryExtent               = summaryOffset+1+summaryLength;%max(summaryRange);
    %
    %       % xColumns                    = columns+summaryExtent;
    %       % xColumnRange                = columns+1:xColumns;
    %       % xRows                       = rows+summaryExtent;
    %       % xRowRange                   = rows+1:xRows;
    %
    %       obj.resetAxesLimits@PrintUniformityBeta.Data.PlotDataSource(obj, 0:columns+summaryExtent, 0:rows+summaryExtent);
    %
    %     end
    
  end
  
  methods (Access=protected)
    function createComponent(obj)
      obj.dataReaderClass       = 'PrintUniformityBeta.Data.StatsDataReader';
      obj.indexField            = 'Length';
      obj.createComponent@GrasppeAlpha.Data.Source;
    end
    
    function resetTasks(obj)
      try delete(obj.Tasks.GetMetrics); end
      try obj.ProcessProgress.Tasks = obj.ProcessProgress.Tasks(isvalid(obj.ProcessProgress.Tasks)); end
    end
  end
  
  
  methods (Access=protected)
    function [X Y Z] = updatePlotData(obj)
      
      rows                      = obj.RowCount;
      columns                   = obj.ColumnCount;
      
      [X Y Z]                   = meshgrid(1:columns, 1:rows, NaN);   % % X = []; Y = []; Z = [];
      
      sheetID                   = obj.SheetID;
      variableID                = obj.VariableID;
      
      %       if sheetID == 0, sheetID  = obj.SheetCount+1; end
      %
      %       sheetStatistics           = [];
      %       try sheetStatistics       = obj.sheetStatistics{sheetID}; end
      %
      %       if isempty(sheetStatistics), sheetStatistics = obj.processRegionStatistics(sheetID, variableID); end
      %
      %       if ~isempty(sheetStatistics) %else  [X Y Z]         = meshgrid(1:obj.RowCount, 1:obj.ColumnCount, NaN);
      %         tries                   = 0;
      %
      %         while tries < 2
      %           try
      %             newData             = sheetStatistics.Data; ...
      %               Z                 = squeeze(newData);
      %             [X Y]               = meshgrid(1:size(newData, 2), 1:size(newData, 1));
      %
      %             obj.PlotRegions     = sheetStatistics.Masks;
      %             obj.PlotValues      = sheetStatistics.Values;
      %             obj.PlotStrings     = sheetStatistics.Strings;
      %             tries               = tries + 1;
      %           catch err
      %             try sheetStatistics      = obj.processRegionStatistics(sheetID, variableID); end
      %           end
      %         end
      %       end
      %
      %       obj.setPlotData(X, Y, Z);
      %
      %
    end
    
  end
  
  methods(Access=protected)
    function validCaseID = validateCaseID(obj, caseID)
      validCaseID               = true;
      try validCaseID           = any(strcmp(caseID, obj.Reader.Cases.keys)); end
    end
    
    function validSetID = validateSetID(obj, setID)
      validSetID                = true;
    end
    
    function validSheetID = validateSheetID(obj, sheetID)
      validSheetID              = true;
    end
    
    function validVariableID = validateVariableID(obj, variableID)
      validVariableID           = true;
      try validVariableID       = strcmpi(); end
    end
    
  end
  
  methods(Hidden)
    results = testPerformance(obj);
  end
  
  
  methods (Static, Hidden)
    function OPTIONS  = DefaultOptions()
      VariableID = 'Imprecision';
      
      GrasppeAlpha.Utilities.DeclareOptions;
    end
  end
  
end

