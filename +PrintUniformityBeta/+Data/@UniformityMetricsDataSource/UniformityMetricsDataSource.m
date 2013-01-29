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
      obj.processCaseData@PrintUniformityBeta.Data.DataSource(false);     % non-recursive
      
      obj.processRegionMetrics();
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processSetData(); end
    end
    
    function OnCaseIDChange(obj, varargin)
      disp('CaseID Change');
      obj.resetStatistics();
      obj.OnCaseIDChange@PrintUniformityBeta.Data.DataSource(varargin{:});
    end
    
    function OnSetIDChange(obj, varargin)
      disp('SetID Change');
      obj.resetStatistics();
      obj.OnSetIDChange@PrintUniformityBeta.Data.DataSource(varargin{:});
    end
    
    function OnVariableIDChange(obj, varargin)
      disp('VariableID Change');
      obj.sheetStatistics       = {};
      obj.OnVariableIDChange@PrintUniformityBeta.Data.DataSource(varargin{:});
    end
    
    function resetStatistics(obj)
      obj.Statistics            = [];
      obj.sheetStatistics       = {};      
    end
    
    function processStatistics(obj)
      variableID                = obj.VariableID;
      % try obj.Regions             = obj.GetRegionMetrics(); end
      % try obj.RegionMasks     = obj.GetRegionMasks(); end
      
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
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processSheetData(); end
      
    end
    
    
    function processSetData(obj, recursive)
      obj.processSetData@PrintUniformityBeta.Data.DataSource(false);      % non-recursive
      
      obj.processStatistics;
%       variableID                = obj.VariableID;
%       % try obj.Regions             = obj.GetRegionMetrics(); end
%       % try obj.RegionMasks     = obj.GetRegionMasks(); end
%       
%       regions                   = struct;
%       
%       stepString                = @(m, n)       sprintf('%d of %d', m, n);  
%       progressString            = @(s)          [obj.CaseName ' ' obj.SetName ': ' s];
%       progressValue             = @(x, y, z)    min(1, (max(0,x-1)+y)/z);
%       
%       progressUpdate            = @(x, y, z, s) GrasppeKit.Utilities.ProgressUpdate(progressValue(x, y, z), ['Processing ' progressString(s)]);
%       
%       switch lower(variableID)
%         case {'raw'}
%           obj.Stats = [];
%           regions = [];
%         case {'sections', 'around', 'across', 'zones', 'zoneBands'}
%           try regions.sections  = obj.RegionMasks.sections;   end
%           try regions.around    = obj.RegionMasks.around;     end
%           try regions.across    = obj.RegionMasks.across;     end
%           try regions.zones     = obj.RegionMasks.zones;      end
%           try regions.zoneBands = obj.RegionMasks.zoneBands;  end
%         otherwise
%           regions.(obj.VariableID)  = obj.Regions.(obj.VariableID);
%           try regions.([obj.VariableID 'Around']) = obj.RegionMasks.([variableID 'Around']); end
%           try regions.([obj.VariableID 'Across']) = obj.RegionMasks.([variableID 'Across']); end
%       end
%         
%       try % if ~isempty(regions)       
%         
%         if isempty(obj.Statistics)
%           
%           subProgressUpdate     = @(x, y, z, s) progressUpdate(1, 0.0 + progressValue(x, y, z)/2, 1, s);
%           
%           obj.Statistics        = PrintUniformityBeta.Data.UniformityMetricsDataSource.ProcessSetStatistics(obj.CaseData, obj.SetData, regions, subProgressUpdate);
%           
%           subProgressUpdate     = @(x, y, z, s) progressUpdate(1, 0.5 + progressValue(x, y, z)/2, 1, s);
%           
%           try subProgressUpdate(1, 0, 1, stepString(0, obj.SheetCount)); end
%           
%           for m = 0:obj.SheetCount
%             try subProgressUpdate(m, 0.5, obj.SheetCount, stepString(m, obj.SheetCount)); end
%             obj.processRegionStatistics(m, variableID);
%             try subProgressUpdate(m, 1, obj.SheetCount, stepString(m, obj.SheetCount)); end
%           end
%         end
%       catch err
%         debugStamp(err, 1);
%         rethrow(err);
%       end
%       
%       try GrasppeKit.Utilities.ProgressUpdate(); end
%       
%       if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processSheetData(); end
    end
    
    function processSheetData(obj, recursive)
      obj.processSheetData@PrintUniformityBeta.Data.DataSource(false);    % non-recursive
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processVariableData(); end
    end    
    
    function processVariableData(obj, recursive)
      obj.processVariableData@PrintUniformityBeta.Data.DataSource(false); % non-recursive
      
      % obj.processStatistics;
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.updatePlotData(); end
    end
    
    function rois = processRegionMetrics(obj)
      
      rois                      = [];
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
