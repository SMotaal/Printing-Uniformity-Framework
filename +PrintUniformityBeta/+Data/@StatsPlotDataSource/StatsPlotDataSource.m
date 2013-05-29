classdef StatsPlotDataSource < PrintUniformityBeta.Data.PlotDataSource & GrasppeAlpha.Occam.Process %& PrintUniformityBeta.Data.PlotDataSource
  %UNIFORMITYPLOTDATASOURCE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    % PlotRegions                 = [];
    % PlotValues                  = [];
    % PlotStrings                 = {};
    PlotRegions                   = PrintUniformityBeta.Models.PlotRegionModel.empty;
    Tasks                         = struct;
  end
  
  methods
    
    %preparePlotRegions(obj);
    setMetrics                  = getSetMetrics(obj, setData);
    metrics                     = getRegionMetrics(obj, metricsTable, roiData, roiRows, roiColumns)
    
    function obj = StatsPlotDataSource(varargin)
      % initializer = true; try initializer = ~isequal(evalin('caller', 'initializer'), true); end
      % disp([mfilename ' initializer: ' num2str(nargout) '<' num2str(initializer)]);
      obj                       = obj@PrintUniformityBeta.Data.PlotDataSource(varargin{:});
      %obj                       = obj@PrintUniformityBeta.Data.PlotDataSource(varargin{:});
      
      obj.processCaseData;
    end
        
    
    function processCaseData(obj, recursive)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      
      caseData                  = obj.caseData;
      
      if ~isequal(obj.caseID, obj.Reader.CaseID) || isempty(obj.CaseData) || isempty(obj.CaseName)
        
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
    end
    
    function processSetData(obj, recursive)  
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      
      setData                   = obj.setData;
      
      if isfield(setData, 'ID') && ~isequal(setData.ID, obj.setID), obj.setData = []; end
      
      if ~isequal(obj.setID, obj.Reader.SetID) || isempty(obj.setData) || isempty(obj.setName)
                
        obj.setID               = obj.Reader.SetID;           % skip ID change event
        newData                 = obj.Reader.getSetData();
        
        try
          try delete(obj.Tasks.ProcessMetrics); end
          try obj.ProcessProgress.Tasks = obj.ProcessProgress.Tasks(isvalid(obj.ProcessProgress.Tasks)); end
          
          obj.Tasks.ProcessMetrics = obj.ProcessProgress.addAllocatedTask('Processing Metrics', 100, 14);
          obj.ProcessProgress.activeTask(obj.Tasks.ProcessMetrics);
        end
        
        newData.Metrics         = obj.getSetMetrics(newData);        % if ~isfield(newData, 'Metrics'),
        
        try obj.Tasks.ProcessMetrics.SEAL; end
        
        obj.setData             = newData;
        
        obj.SetName             = obj.Reader.SetName;         % fire Name change event
        
      else
        
        if ~isequal(obj.setData, obj.Reader.SetData), obj.SetData = obj.Reader.SetData; end
        
      end
      
      if ~isequal(setData, obj.setData)
        if obj.DebuggingDataProcessing, disp('processSetData:setDataChanged'); end
        % obj.preparePlotRegions();
        obj.notify('OverlayPlotsDataChange');
      end
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processSheetData(); end
    end
    
    function processSheetData(obj, recursive)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      
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
        % notify
      end      
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processVariableData(); end
    end
    
    function processVariableData(obj, recursive)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      % obj.VariableData          = obj.SheetData;              % fire Data change event
      % obj.VariableName          = '';                         % fire Name change event      
      
      % obj.updatePlotData();
      
      % obj.notify('OverlayLabelsDataChange');
    end
    
    function processStatistics(obj)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      if ~(isempty(obj.sheetStatistics) || isempty(obj.Statistics)), return; end  % Must resetStatistics first!      
      
      % variableID                = obj.VariableID;
      %
      % regions                   = struct;
      %
      % stepString                = @(m, n)       sprintf('%d of %d', m, n);
      % progressString            = @(s)          [obj.CaseName ' ' obj.SetName ': ' s];
      % progressValue             = @(x, y, z)    min(1, (max(0,x-1)+y)/z);
      %
      % progressUpdate            = @(x, y, z, s) GrasppeKit.Utilities.ProgressUpdate(progressValue(x, y, z), ['Processing ' progressString(s)]);
      %
      % switch lower(variableID)
      %   case {'raw'}
      %     obj.Stats = [];
      %     regions = [];
      %   case {'sections', 'around', 'across', 'zones', 'zoneBands'}
      %     try regions.sections  = obj.RegionMasks.sections;   end
      %     try regions.around    = obj.RegionMasks.around;     end
      %     try regions.across    = obj.RegionMasks.across;     end
      %     try regions.zones     = obj.RegionMasks.zones;      end
      %     try regions.zoneBands = obj.RegionMasks.zoneBands;  end
      %   otherwise
      %     regions.(obj.VariableID)  = obj.Regions.(obj.VariableID);
      %     try regions.([obj.VariableID 'Around']) = obj.RegionMasks.([variableID 'Around']); end
      %     try regions.([obj.VariableID 'Across']) = obj.RegionMasks.([variableID 'Across']); end
      % end
      %
      % try % if ~isempty(regions)
      %
      %   subProgressUpdate       = @(x, y, z, s) progressUpdate(1, 0.0 + progressValue(x, y, z)/2, 1, s);
      %
      %   if isempty(obj.Statistics)
      %     obj.Statistics        = PrintUniformityBeta.Data.PlotDataSource.ProcessSetStatistics(obj.CaseData, obj.SetData, regions, subProgressUpdate);
      %   end
      %
      %   subProgressUpdate       = @(x, y, z, s) progressUpdate(1, 0.5 + progressValue(x, y, z)/2, 1, s); % try subProgressUpdate(1, 0, 1, stepString(0, obj.SheetCount)); end
      %
      %   for m = 0:obj.SheetCount  % if numel(obj.sheetStatistics) < m || ~iscell(obj.sheetStatistics) isempty(obj.sheetStatistics(m));
      %
      %     sheetID               = m;
      %     if m==0, sheetID      = obj.SheetCount+1; end
      %
      %     sheetStatistics       = [];
      %     try sheetStatistics   = obj.sheetStatistics{sheetID}; end
      %
      %     if isempty(sheetStatistics)
      %       try subProgressUpdate(m, 0.5, obj.SheetCount, stepString(m, obj.SheetCount)); end
      %       obj.sheetStatistics{sheetID}  = obj.processRegionStatistics(m, variableID);
      %       try subProgressUpdate(m, 1, obj.SheetCount, stepString(m, obj.SheetCount)); end
      %     end
      %   end
      %
      % catch err
      %   debugStamp(err, 1);
      %   rethrow(err);
      % end
      
      try GrasppeKit.Utilities.ProgressUpdate(); end
      
    end    
    
    function resetAxesLimits(obj, x, y, z, c)
      rows                        = obj.RowCount;
      columns                     = obj.ColumnCount;
      
      summaryOffset               = obj.summaryOffset;
      summaryLength               = obj.summaryLength;
      
      % offsetRange                 = 1:summaryOffset;
      % summaryRange                = summaryOffset + 1 + [0:summaryLength];
      summaryExtent               = summaryOffset+1+summaryLength;%max(summaryRange);
      
      % xColumns                    = columns+summaryExtent;
      % xColumnRange                = columns+1:xColumns;
      % xRows                       = rows+summaryExtent;
      % xRowRange                   = rows+1:xRows;
      
      obj.resetAxesLimits@PrintUniformityBeta.Data.PlotDataSource(obj, 0:columns+summaryExtent, 0:rows+summaryExtent);
      
    end
    
  end
  
  methods (Access=protected)
    function createComponent(obj)
      obj.dataReaderClass       = 'PrintUniformityBeta.Data.StatsDataReader';
      obj.indexField            = 'Length';
      obj.createComponent@GrasppeAlpha.Data.Source;
    end
  end    
  
  
  methods (Access=protected)
    function [X Y Z] = updatePlotData(obj)
      
      rows                      = obj.RowCount;
      columns                   = obj.ColumnCount;
      
      [X Y Z]                   = meshgrid(1:columns, 1:rows, NaN);   % % X = []; Y = []; Z = [];      
      
      sheetID                   = obj.SheetID;
      variableID                = obj.VariableID;
      
      if sheetID == 0, sheetID  = obj.SheetCount+1; end
      
      sheetStatistics           = [];
      try sheetStatistics       = obj.sheetStatistics{sheetID}; end
      
      if isempty(sheetStatistics), sheetStatistics = obj.processRegionStatistics(sheetID, variableID); end
      
      if ~isempty(sheetStatistics) %else  [X Y Z]         = meshgrid(1:obj.RowCount, 1:obj.ColumnCount, NaN);
        tries                   = 0;
        
        while tries < 2
          try
            newData             = sheetStatistics.Data; ...
              Z                 = squeeze(newData);
            [X Y]               = meshgrid(1:size(newData, 2), 1:size(newData, 1));
            
            obj.PlotRegions     = sheetStatistics.Masks;
            obj.PlotValues      = sheetStatistics.Values;
            obj.PlotStrings     = sheetStatistics.Strings;
            tries               = tries + 1;
          catch err
            try sheetStatistics      = obj.processRegionStatistics(sheetID, variableID); end
          end
        end
      end
      
      obj.setPlotData(X, Y, Z);
      
      %       rows                      = obj.RowCount;
      %       columns                   = obj.ColumnCount;
      %
      %       [X Y Z]                   = meshgrid(1:columns, 1:rows, 1);   % % X = []; Y = []; Z = [];
      %
      %       caseData                  = obj.CaseData;
      %       setData                   = obj.SetData;
      %       sheetData                 = obj.SheetData;
      %       variableData              = obj.VariableData;
      %
      %       targetFilter              = caseData.sampling.masks.Target~=1;
      %       patchFilter               = setData.filterData.dataFilter~=1;
      %
      %       if ~isempty(variableData)
      %         try
      %           Z(~patchFilter)       = variableData;
      %           Z(targetFilter)       = NaN;
      %           Z(patchFilter)        = NaN;
      %
      %           dataFilter            = ~isnan(Z);
      %
      %           if isnumeric(obj.ZLim)
      %             Z(Z>max(obj.ZLim) | Z<min(obj.ZLim)) = NaN;
      %           end
      %
      %           rawSurfaceData        = TriScatteredInterp(X(dataFilter), Y(dataFilter), Z(dataFilter), 'natural');
      %
      %           Z                     = rawSurfaceData(X, Y);
      %
      %           Z(targetFilter)       = NaN;
      %
      %         catch err
      %           debugStamp(err, 1, obj);
      %           % rethrow(err);
      %         end
      %       end
      % obj.setPlotData(X, Y, Z);
      
      
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

