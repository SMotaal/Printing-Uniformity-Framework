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
    RegionData    = {};
    SheetStats    = {};
    RegionLabels  = {};
    
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
    StatsMode = 'PeakLimits';
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
      
      try debugStamp(obj.ID, 4); catch, debugStamp(5); end;
      
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
        try debugStamp(err.message, 1); catch, debugStamp(5); end;
      end
      
      % try obj.optimizeSetLimits; end
    end
    
  end
  
  methods
    function ProcessCaseData(obj, eventData)
      debugStamp(5);
      
      obj.Stats               = [];
      obj.Regions             = [];
      obj.RegionMasks         = [];
      
      if nargin>1, obj.ProcessCaseData@Grasppe.PrintUniformity.Data.PlotDataSource(eventData);
      else obj.ProcessCaseData@Grasppe.PrintUniformity.Data.PlotDataSource(); end
            
    end
    
    function ProcessSetData(obj, eventData)
      debugStamp(5);
      
      obj.Stats               = [];
      obj.SheetStats          = {};
      obj.RegionData          = {};
      obj.RegionLabels        = {};      
      try obj.Regions         = obj.GetRegionMetrics(); end
      try obj.RegionMasks     = obj.GetRegionMasks(); end      
      
      
      if nargin>1, obj.ProcessSetData@Grasppe.PrintUniformity.Data.PlotDataSource(eventData);
      else obj.ProcessSetData@Grasppe.PrintUniformity.Data.PlotDataSource(); end
      
    end
    
    function ProcessVariableData(obj, eventData)
      
      debugStamp(5);
      
      variableID = obj.VariableID;
      try
        variableID = eventData.NewValue;
      end
      
      if ~isempty(obj.Stats) && isequal(obj.VariableID, variableID) && ...
          ~(isempty(obj.Regions) || ~isstruct(obj.Regions))
        return;
      end
      
      if ~isempty(variableID)
        obj.GetStatistics('reset update');
        
        obj.Regions             = obj.GetRegionMetrics();
        try obj.RegionMasks     = obj.GetRegionMasks(); end
        
        switch lower(variableID)
          case {'raw'}
            obj.Stats = [];
            regions = [];
          case {'sections', 'around', 'across'}
            regions.sections  = obj.Regions.sections;
            regions.around    = obj.Regions.around;
            regions.across    = obj.Regions.across;
          otherwise
            regions.(obj.VariableID)  = obj.Regions.(obj.VariableID);
            try regions.([obj.VariableID 'Around']) = obj.Regions.([variableID 'Around']); end
            try regions.([obj.VariableID 'Across']) = obj.Regions.([variableID 'Across']); end
        end
        
        try if ~isempty(regions)
            [dataSource stats]    = Stats.generateUPStats(obj.CaseData, obj.SetData.DATA, regions);
            obj.Stats = stats;
            
            obj.ProcessStatistics(variableID);
            
          end
        catch err
          debugStamp(err, 1);
        end
      end
      
      if nargin>1, obj.ProcessVariableData@Grasppe.PrintUniformity.Data.PlotDataSource(eventData);
      else obj.ProcessVariableData@Grasppe.PrintUniformity.Data.PlotDataSource(); end

    end
    
    function ProcessStatistics(obj, variableID)
      if ~exist('variableID', 'var')
        variableID = obj.VariableID;
      end
      
      if isempty(variableID), return; end
      
      for m = 0:obj.SheetCount
        obj.GetStatistics(m, variableID);
      end
      
    end
    
    function ProcessSheetData(obj, eventData)
      debugStamp(5);
      
      if nargin>1, obj.ProcessSheetData@Grasppe.PrintUniformity.Data.PlotDataSource(eventData);
      else obj.ProcessSheetData@Grasppe.PrintUniformity.Data.PlotDataSource(); end
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
            
      sheetID           = obj.SheetID;
      variableID        = obj.VariableID;
      
      if sheetID == 0, sheetID = obj.SheetCount+1; end
      
      sheetStats        = [];
      try sheetStats    = obj.SheetStats{sheetID}; end
      if isempty(sheetStats), sheetStats = obj.GetStatistics(sheetID, variableID); end
      
      if isempty(sheetStats)
        [X Y Z]         = meshgrid(1:obj.RowCount, 1:obj.ColumnCount, NaN);
        
      else
        tries           = 0;
        
        while tries < 2
          try
            newData           = sheetStats.Data; ...
              Z               = squeeze(newData);
            [X Y]             = meshgrid(1:size(newData, 2), 1:size(newData, 1));
            
            obj.PlotRegions   = sheetStats.Masks;
            obj.PlotValues    = sheetStats.Values;
            obj.PlotStrings   = sheetStats.Strings;
            tries             = tries + 1;
          catch err
            try sheetStats    = obj.GetStatistics(sheetID, variableID); end
          end
        end
      end
      
      skip                = true;
      
    end
    
    
    function optimizeSetLimits(obj, x, y, z, c)
      try debugStamp(obj.ID, 4); catch, debugStamp(5); end;
      
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

  methods
    
    function set.StatsMode(obj, value)
      obj.StatsMode         = value;
      GrasppeKit.DelayedCall(@(s,e)obj.updateVariableData(obj,e), 1, 'start');
    end
    
    function set.Stats(obj, stats)
      obj.Stats = stats;
      if ~isempty(obj.Stats), obj.ProcessVariableData(); end
    end
    
    function value = get.StatsMode(obj)
      value = obj.StatsMode;
    end
    
    
  end
  
  methods (Static, Hidden)
    
    function OPTIONS  = DefaultOptions()
      VariableID = 'sections';
      
      Grasppe.Utilities.DeclareOptions;
    end
  end
  
  
  
end
