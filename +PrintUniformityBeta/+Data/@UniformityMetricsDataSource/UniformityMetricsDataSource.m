classdef UniformityMetricsDataSource < PrintUniformityBeta.Data.DataSource
  %UNIFORMITYMETRICSDATASOURCE Print Uniformity Plot Data Source
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    %     HandleProperties = {};
    %     HandleEvents = {};
    %     ComponentType = 'PrintingUniformityUniformityMetricsDataSource';
    %     ComponentProperties = '';
    %
    %     DataProperties = {'CaseID', 'SetID', 'XData', 'YData', 'ZData', 'SheetID'};
    
    %     UniformityMetricsDataSourceProperties = {
    %       'PlotType',   'Plot Type',          'Plot'      'string',     '';   ...
    %       'ALim',       'Alpha Map Limits',   'Plot',     'limits',     '';   ...
    %       'CLim',       'Color Map Limits',   'Plot',     'limits',     '';   ...
    %       'XLim',       'X Axes Limits',      'Plot',     'limits',     '';   ...
    %       'YLim',       'Y Axes Limits',      'Plot',     'limits',     '';   ...
    %       'ZLim',       'Z Axes Limits',      'Plot',     'limits',     '';   ...
    %       };
    
  end
  
  properties (AbortSet, SetObservable, GetObservable)
    
    %     AspectRatio
    %     XData, YData, ZData, CData
    %     CLim,       ALim                      %CLimMode   ALimMode
    %     XLim,       XTick,      XTickLabel    %XLimMode   XTickMode,  XTickLabelMode
    %     YLim,       YTick,      YTickLabel    %YLimMode   YTickMode,  YTickLabelMode
    %     ZLim,       ZTick,      ZTickLabel    %ZLimMode   ZTickMode,  ZTickLabelMode
    
    % ColorMap
    
    % NextSheetID
    
    RegionMasks;
    RegionMetrics;
    RegionData                  = {};
    RegionLabels                = {};
    StatisticsMode
    Statistics
    PassiveProcessing           = false;
  end
  
  properties (SetAccess=protected, GetAccess=protected)
    summaryOffset               = 1;
    summaryLength               = 12;
    
    currentStatsMode
    currentStatsFunction
    currentDataFunction
    currentLabelFunction
    
    sheetStatistics
  end
  
  methods
    function obj = UniformityMetricsDataSource(varargin)
      obj                       = obj@PrintUniformityBeta.Data.DataSource(varargin{:});      
    end
  end
  
  % methods (Access=protected)
  %   function createComponent(obj)
  %     obj.createComponent@PrintUniformityBeta.Data.DataSource;
  %   end
  % end
  
  methods
  end
  
  methods
        
  end
  
  methods (Access=protected)
        
  end
  
  methods
    
    function processCaseData(obj, recursive)
      if ~isequal(obj.caseID, obj.Reader.CaseID) || isempty(obj.CaseData) || isempty(obj.CaseName)
        obj.processCaseData@PrintUniformityBeta.Data.DataSource(false);     % non-recursive
        obj.processRegionMetrics();
      end
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processSetData(); end
    end
    
    function OnCaseIDChange(obj, varargin)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      if obj.DebuggingDataEvents, disp('CaseID Change'); end
      obj.OnCaseIDChange@PrintUniformityBeta.Data.DataSource(varargin{:});
    end
    
    function OnSetIDChange(obj, varargin)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      if obj.DebuggingDataEvents, disp('SetID Change'); end
      
      obj.resetStatistics();
      obj.OnSetIDChange@PrintUniformityBeta.Data.DataSource(varargin{:});
    end
    
    function OnVariableIDChange(obj, varargin)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      if obj.DebuggingDataEvents, disp('VariableID Change'); end
      obj.sheetStatistics       = {};
      obj.OnVariableIDChange@PrintUniformityBeta.Data.DataSource(varargin{:});
    end
    
    function resetStatistics(obj)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      
      resetting                 = true;
      try resetting             = ~(isequal(obj.caseID, obj.Statistics.metadata.source) && isequal(obj.setID, obj.Statistics.metadata.set)); end
      
      if resetting
        obj.Statistics          = [];
        obj.sheetStatistics     = {};
      else
        if obj.DebuggingDataEvents, disp('Not Resetting!'); end
      end
    end
    
    function processStatistics(obj)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      if ~(isempty(obj.sheetStatistics) || isempty(obj.Statistics)), return; end  % Must resetStatistics first!      
      
      variableID                = obj.VariableID;

      regions                   = struct;
      
      stepString                = @(m, n)       sprintf('%d of %d', m, n);  
      progressString            = @(s)          [obj.CaseName ' ' obj.SetName ': ' s];
      progressValue             = @(x, y, z)    min(1, (max(0,x-1)+y)/z);
      
      progressUpdate            = @(x, y, z, s) GrasppeKit.Utilities.ProgressUpdate(progressValue(x, y, z), ['Processing ' progressString(s)]);
      
      switch lower(variableID)
        case {'raw'}
          obj.Stats = [];
          regions = [];
        case {'sections', 'around', 'across', 'zones', 'zoneBands'}
          try regions.sections  = obj.RegionMasks.sections;   end
          try regions.around    = obj.RegionMasks.around;     end
          try regions.across    = obj.RegionMasks.across;     end
          try regions.zones     = obj.RegionMasks.zones;      end
          try regions.zoneBands = obj.RegionMasks.zoneBands;  end
        otherwise
          regions.(obj.VariableID)  = obj.Regions.(obj.VariableID);
          try regions.([obj.VariableID 'Around']) = obj.RegionMasks.([variableID 'Around']); end
          try regions.([obj.VariableID 'Across']) = obj.RegionMasks.([variableID 'Across']); end
      end
        
      try % if ~isempty(regions)       
        
        subProgressUpdate       = @(x, y, z, s) progressUpdate(1, 0.0 + progressValue(x, y, z)/2, 1, s);
        
        if isempty(obj.Statistics)         
          obj.Statistics        = PrintUniformityBeta.Data.UniformityMetricsDataSource.ProcessSetStatistics(obj.CaseData, obj.SetData, regions, subProgressUpdate);
        end
        
        subProgressUpdate       = @(x, y, z, s) progressUpdate(1, 0.5 + progressValue(x, y, z)/2, 1, s); % try subProgressUpdate(1, 0, 1, stepString(0, obj.SheetCount)); end
        
        for m = 0:obj.SheetCount  % if numel(obj.sheetStatistics) < m || ~iscell(obj.sheetStatistics) isempty(obj.sheetStatistics(m));
          
          sheetID               = m;
          if m==0, sheetID      = obj.SheetCount+1; end
          
          sheetStatistics       = [];
          try sheetStatistics   = obj.sheetStatistics{sheetID}; end
          
          if isempty(sheetStatistics)
            try subProgressUpdate(m, 0.5, obj.SheetCount, stepString(m, obj.SheetCount)); end
            obj.sheetStatistics{sheetID}  = obj.processRegionStatistics(m, variableID);
            try subProgressUpdate(m, 1, obj.SheetCount, stepString(m, obj.SheetCount)); end
          end
        end
        
      catch err
        debugStamp(err, 1);
        rethrow(err);
      end
      
      try GrasppeKit.Utilities.ProgressUpdate(); end
      
    end
    
    
    function processSetData(obj, recursive)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      if ~isequal(obj.setID, obj.Reader.SetID) || isempty(obj.SetData) || isempty(obj.SetName)
        obj.processSetData@PrintUniformityBeta.Data.DataSource(false);      % non-recursive
        
        if isequal(obj.PassiveProcessing, false)
          % obj.Statistics          = [];
          obj.processStatistics;
          drawnow expose update;
        end
      end
      
%       if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processSheetData(); end
    end
    
    function processSheetData(obj, recursive)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      % if ~isequal(obj.sheetID, obj.Reader.SheetID) || isempty(obj.SheetData) || isempty(obj.SheetName)
      obj.processSheetData@PrintUniformityBeta.Data.DataSource(false);    % non-recursive
      % end
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processVariableData(); end
    end    
    
    function processVariableData(obj, recursive)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      obj.processVariableData@PrintUniformityBeta.Data.DataSource(false); % non-recursive
      
      % obj.processStatistics;
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.updatePlotData(); end
    end
    
    function rois = processRegionMetrics(obj)
      
      rois                      = struct('Masks',[],'Metrics',[]);
      try rois                  = PrintUniformityBeta.Data.UniformityMetricsDataSource.ProcessRegionOfInterest(obj.CaseData); end
      
      obj.RegionMasks           = rois.Masks;
      obj.RegionMetrics         = rois.Metrics;
      
    end
            
  end

  methods (Static)
    [rois                     ] = ProcessRegionOfInterest(dataSource);
    [stats                    ] = ProcessSetStatistics(dataSource, dataSet, regions, progressUpdate);
  end
  
  methods (Static, Hidden)
    function OPTIONS  = DefaultOptions()
      VariableID = 'sections';
      
      GrasppeAlpha.Utilities.DeclareOptions;
    end
  end
  
  
  
end
