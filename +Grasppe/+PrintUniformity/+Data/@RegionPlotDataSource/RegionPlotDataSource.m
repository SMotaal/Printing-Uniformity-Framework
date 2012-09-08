classdef RegionPlotDataSource < Grasppe.PrintUniformity.Data.PlotDataSource
  
  %REGIONPLOTDATASOURCE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    RegionMetrics
    RegionMasks
  end
  
  properties (AbortSet)
    Regions
    Stats
    SetStats      = {};
    SetStrings    = {};
    
    StatsFunction = [];
    DataFunction  = [];
    LabelFunction = [];
    SummaryLength = 5;
    SummaryOffset = 1;
    
    PlotLabels    = [];
    PlotRegions   = [];
    PlotValues    = [];
    PlotStrings   = [];
  end
  
  properties
    StatsMode = 'Mean';
  end
  
  properties (SetAccess=private, GetAccess=private)
    CurrentStatsMode
    CurrentStatsFunction
    CurrentDataFunction
    CurrentLabelFunction
  end
  
  
  methods
    metrics       = GetRegionMetrics(obj);
    masks         = GetRegionMasks(obj);
    stats         = GetStatistics(obj, sheetID, variableID);
  end
  
  methods
    function obj = RegionPlotDataSource(varargin)
      obj = obj@Grasppe.PrintUniformity.Data.PlotDataSource(varargin{:});
    end
  end
  
  methods (Access=protected)
    function createComponent(obj)
      % obj.GetCaseDataFunction       = @obj.GetCaseData;
      % obj.GetSetDataFunction        = @obj.GetSetData;
      % obj.GetVariableDataFunction   = @obj.GetVariableData;
      % obj.GetSheetDataFunction      = @obj.GetSheetData;
      obj.GetPlotDataFunction         = @obj.GetPlotData;
      
      obj.createComponent@Grasppe.PrintUniformity.Data.PlotDataSource;
    end
  end
  
  methods
    function attachPlotObject(obj, plotObject)
      
      try debugStamp(obj.ID, 4); catch, debugStamp(); end;
      
      obj.attachPlotObject@Grasppe.PrintUniformity.Data.PlotDataSource(plotObject);
      try plotObject.ParentAxes.setView([0 90], true);  end
      try plotObject.ParentAxes.Box = false;            end
      
      try delete(obj.PlotLabels); end %; catch err, debugStamp(err,1); end
      try
        % obj.PlotLabels = Grasppe.PrintUniformity.Graphics.UniformityPlotLabels; ...
        %   obj.registerHandle(obj.PlotLabels);
        %
        % obj.PlotLabels.attachPlot(plotObject);
        % obj.updatePlotLabels;
        %
        % if isa(obj.PlotLabels, 'Grasppe.PrintUniformity.Graphics.UniformityPlotLabels') && isvalid(obj.PlotLabels)
        %   obj.PlotLabels.SubPlotData = obj.SetStats;
        %   obj.PlotLabels.SubPlotStats = obj.Stats;
        %   obj.PlotLabels.updateSubPlots;
        % end
      catch err
        try debugStamp(err.message, 1); catch, debugStamp(); end;
      end
      
      % try obj.optimizeSetLimits; end
    end
    
  end
  
  methods
    function ProcessCaseData(obj, eventData)
      if nargin>1, obj.ProcessCaseData@Grasppe.PrintUniformity.Data.PlotDataSource(eventData); end
      
      obj.Regions         = obj.GetRegionMetrics();
      try obj.RegionMasks     = obj.GetRegionMasks(); end
      
      if nargin==1, obj.ProcessSetData; end
    end
    
    function ProcessSetData(obj, eventData)
      if nargin>1, obj.ProcessSetData@Grasppe.PrintUniformity.Data.PlotDataSource(eventData); 
      else obj.ProcessVariableData; end
    end
    
    function ProcessVariableData(obj, eventData)
      
      variableID = [];
      try
        variableID = eventData.NewValue;
      end
      
      if ~isequal(obj.VariableID, variableID)
        obj.VariableID = variableID;
      end
      
      obj.GetStatistics('reset update');   
      
      if ~isempty(obj.VariableID)
        
        if isempty(obj.Regions) || ~isstruct(obj.Regions)
          obj.Regions         = obj.GetRegionMetrics();
          try obj.RegionMasks     = obj.GetRegionMasks(); end
        end
        
        switch lower(obj.VariableID)
          case {'raw'}
            obj.Stats = [];
            regions = [];
          case {'sections', 'around', 'across'}
            regions.sections  = obj.Regions.sections;
            regions.around    = obj.Regions.around;
            regions.across    = obj.Regions.across;
          otherwise
            regions.(obj.VariableID)  = obj.Regions.(obj.VariableID);
            try regions.([obj.VariableID 'Around']) = obj.Regions.([obj.VariableID 'Around']); end
            try regions.([obj.VariableID 'Across']) = obj.Regions.([obj.VariableID 'Across']); end
        end
        
        try if ~isempty(regions)
            [dataSource stats]    = Stats.generateUPStats(obj.CaseData, obj.SetData.DATA, regions);
            obj.Stats = stats;
          end
        end
      end
      
      if nargin>1, obj.ProcessVariableData@Grasppe.PrintUniformity.Data.PlotDataSource(eventData); 
      else obj.ProcessSheetData; end
    end
    
    function ProcessSheetData(obj, eventData)
      if nargin>1, obj.ProcessSheetData@Grasppe.PrintUniformity.Data.PlotDataSource(eventData); end
    end
    
    function OnDataLoad(obj, eventData)
      if nargin>1, obj.OnDataLoad@Grasppe.PrintUniformity.Data.PlotDataSource(eventData); end
    end
    
    function OnDataSuccess(obj, eventData)
      if nargin>1, obj.OnDataSuccess@Grasppe.PrintUniformity.Data.PlotDataSource(eventData); end
    end
    
    function OnDataFailure(obj, eventData)
      if nargin>1, obj.OnDataFailure@Grasppe.PrintUniformity.Data.PlotDataSource(eventData); end
    end
    
    function [X Y Z skip]         = GetPlotData(obj, data)
      X = []; Y = []; Z = [];
      skip          = false;
      
      %       if iscell(sheetID)
      %         sheetStats  = obj.getSheetStatistics([sheetID{:}], variableID);
      %       else
      %         sheetID     = obj.SheetID;
      %         variableID  = obj.VariableID;
      %         sheetStats  = obj.getSheetStatistics(sheetID, variableID);
      %       end
      
      sheetID           = obj.SheetID;
      variableID        = obj.VariableID;
      sheetStats        = obj.GetStatistics(sheetID, variableID);
      
      
      newData           = sheetStats.Data; ...
        Z               = squeeze(newData);
      [X Y]             = meshgrid(1:size(newData, 3), 1:size(newData, 2));
      
      obj.PlotRegions   = sheetStats.Masks;
      obj.PlotValues    = sheetStats.Values;
      obj.PlotStrings   = sheetStats.Strings;
      
      skip              = true;
      
    end
    
    
    function optimizeSetLimits(obj, x, y, z, c)
      try debugStamp(obj.ID, 4); catch, debugStamp(); end;
      
      xLim  = [];
      yLim  = [];
      zLim  = [];
      cLim  = [];
      
      try
        zLength = 6;
        
        summaryOffset = obj.SummaryOffset;
        offsetRange   = 1:summaryOffset;
        summaryRange  = summaryOffset + 1 + [0:obj.SummaryLength];
        summaryExtent = max(summaryRange);
        
        
        xLim  = [0 obj.ColumnCount + summaryExtent];  % [];
        yLim  = [0 obj.RowCount    + summaryExtent];    % [];
        zLim  = [];
        cLim  = [];
        
        
        switch regexprep(lower(obj.StatsMode), '\W', '')
          case {'mean', 'average', 'limits', 'peaklimits'}
            setData   = obj.SetData;
            zData     = [setData.data(:).zData];
            zMean     = nanmean(zData);
            
            zLim      = zMean + [+zLength/2 -zLength/2];
            %cLim      = zLim;
          case {'lowerlimit', 'upperlimit'}
            setData   = obj.SetData;
            zData     = [setData.data(:).zData];
            zMean     = nanmean(zData);
            zStd      = nanstd(zData,1);
            zLim      = zMean + [+zLength/2 -zLength/2];
          case {'std', 'deviation', 'standarddeviation'}
            zLim      = [0 10];
          case {'deltalimits', 'deltalimit', 'sixsigma'}
            zLim      = [0 10];
          case {'process limits'}
            zLim      = [0 10];
          otherwise
        end
      end
      
      obj.optimizeSetLimits@Grasppe.PrintUniformity.Data.PlotDataSource(xLim, yLim, zLim, cLim);
    end
    
  end
  
  %     function [caseData skip]      = GetCaseData(obj, newData)
  %       caseData            = [];     % Replaced with sourceData if not skipping
  %       skip                = false;
  %
  %       obj.GetRegionMaetrics();
  %       obj.GetRegionMasks();
  %     end
  %
  %     function [setData skip]       = GetSetData(obj, newData)
  %       setData       = [];     % Replaced with setData when skipped
  %       skip          = false;
  %     end
  %
  %     function [variableData skip]  = GetVariableData(obj, newData)
  %       variableData  = [];     % Amended with raw data field when skipped
  %       skip          = false;
  %     end
  %
  %     function [sheetData skip]     = GetSheetData(obj, newData, variableData)
  %       sheetData     = [];     % Replaced with raw sheetData when skipped
  %       skip          = false;
  %     end
  
  
  methods
    
    function set.StatsMode(obj, value)
      %if isequal(lower(obj.StatsMode), lower(value)), return; end
      obj.StatsMode         = value;
      GrasppeKit.DelayedCall(@(s,e)obj.updateVariableData(obj,e), 1, 'start');
    end
    
    function set.Stats(obj, stats)
      obj.Stats = stats;
      obj.ProcessSetData();   %obj.updateSetStatistics;
    end
    
    function value = get.StatsMode(obj)
      value = obj.StatsMode; %CurrentStatsMode;
    end
    
    
  end
  
  methods (Static, Hidden)
    
    function OPTIONS  = DefaultOptions()
      VariableID = 'sections';
      
      Grasppe.Utilities.DeclareOptions;
    end
  end
  
  
  
end
