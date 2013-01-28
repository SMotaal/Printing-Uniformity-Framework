classdef RegionPlotDataSource < PrintUniformityBeta.Data.PlotDataSource
  
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
    SummaryLength = 12;
    SummaryOffset = 1;
    
    PlotOverlay   = PrintUniformityBeta.Graphics.UniformityPlotOverlay.empty();
    
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
    IsLoading     = 0;
  end
  
  
  methods
    metrics       = GetRegionMetrics(obj);
    masks         = GetRegionMasks(obj);
    stats         = GetStatistics(obj, sheetID, variableID);
  end
  
  methods
    function obj = RegionPlotDataSource(varargin)
      obj = obj@PrintUniformityBeta.Data.PlotDataSource(varargin{:});
    end
  end
  
  methods (Access=protected)
    function createComponent(obj)
      % obj.GetCaseDataFunction       = @obj.GetCaseData;
      % obj.GetSetDataFunction        = @obj.GetSetData;
      % obj.GetVariableDataFunction   = @obj.GetVariableData;
      % obj.GetSheetDataFunction      = @obj.GetSheetData;
      obj.GetPlotDataFunction         = @obj.GetPlotData;
      
      obj.createComponent@PrintUniformityBeta.Data.PlotDataSource;
    end
  end
  
  methods
    function attachPlotObject(obj, plotObject)
      
      try debugStamp(obj.ID, 4); catch, debugStamp(5); end;
      
      obj.attachPlotObject@PrintUniformityBeta.Data.PlotDataSource(plotObject);
      try plotObject.ParentAxes.setView([0 90], true); end
      try plotObject.ParentAxes.Box       = false; end
      try plotObject.ParentAxes.handleSet('Clipping', 'off'); end
      %try plotObject.ParentAxes.ZDir  = 'reverse'; end
      
      try delete(obj.PlotOverlay); end %; catch err, debugStamp(err,1); end
      try
        obj.PlotOverlay = PrintUniformityBeta.Graphics.UniformityPlotOverlay; ...
          obj.registerHandle(obj.PlotOverlay);
        
        obj.PlotOverlay.attachPlot(plotObject);
        obj.UpdatePlotLabels;
        %
        % if isa(obj.PlotOverlay, 'PrintUniformityBeta.Graphics.UniformityPlotLabels') && isvalid(obj.PlotOverlay)
        %   obj.PlotOverlay.SubPlotData = obj.SetStats;
        %   obj.PlotOverlay.SubPlotStats = obj.Stats;
        %   obj.PlotOverlay.updateSubPlots;
        % end
      catch err
        try debugStamp(err.message, 1); catch, debugStamp(5); end;
      end
      
      % try obj.optimizeSetLimits; end
    end
    
%     function createPlotOverlay(obj)
%     end
    
    function UpdatePlotLabels(obj)
      
      try debugStamp(obj.ID, 4); catch, debugStamp(); end;
      
      try
        if ~isscalar(obj.PlotOverlay) || ~isa(obj.PlotOverlay, 'PrintUniformityBeta.Graphics.UniformityPlotOverlay') ...
            || ~isvalid(obj.PlotOverlay)
          return;
        end
        try
          if ~isempty(obj.RegionData{obj.SheetID})
            obj.PlotValues  = obj.RegionData{obj.SheetID};
          end
          if ~isempty(obj.RegionLabels{obj.SheetID})
            obj.PlotStrings = obj.RegionLabels{obj.SheetID};
          end
        end
        obj.PlotOverlay.MarkerIndex = obj.SheetID;
        obj.PlotOverlay.defineLabels(obj.PlotRegions, obj.PlotValues, obj.PlotStrings);
        obj.PlotOverlay.SubPlotData = obj.RegionData;
        obj.PlotOverlay.SubPlotStats = obj.Stats;
        obj.PlotOverlay.createLabels;
        %try obj.optimizeSetLimits; end
      catch err
        try debugStamp(err, 1); catch, debugStamp(); end;
      end
      
%       try obj.PlotOverlay.updateLabels; catch err 
%         try debugStamp(err, 1); catch, debugStamp(); end; end
      
    end
    
    
  end
  
  methods (Access=protected)
    function setPlotData(obj, XData, YData, ZData)
      try debugStamp(obj.ID, 5); catch, debugStamp(); end;
      
      obj.XData               = XData;
      obj.YData               = YData;
      
      zLim                    = obj.ZLim;
      zData                   = ZData;      
      zData(zData<min(zLim))  = min(zLim);
      zData(zData>max(zLim))  = max(zLim);      
      obj.ZData               = zData; %zeros(size(ZData));
      
      cLim                    = obj.CLim;
      cData                   = ZData;      
      cData(cData<min(cLim))  = min(cLim);
      cData(cData>max(cLim))  = max(cLim);
      obj.CData               = cData;
      
      obj.updatePlots();
    end
  end
  
  methods
    function ProcessCaseData(obj, eventData)
      debugStamp(5);
      
      obj.Stats               = [];
      obj.SheetStats          = {};
      obj.RegionData          = {};
      obj.RegionLabels        = {};      
      obj.Regions             = [];
      obj.RegionMasks         = [];
      
      
      if nargin>1, obj.ProcessCaseData@PrintUniformityBeta.Data.PlotDataSource(eventData);
      else try obj.ProcessCaseData@PrintUniformityBeta.Data.PlotDataSource(); end; end
            
      try obj.PlotOverlay.updateSubPlots(); end
    end
    
    function ProcessSetData(obj, eventData)
      debugStamp(5);
      
      obj.Stats               = [];
      obj.SheetStats          = {};
      obj.RegionData          = {};
      obj.RegionLabels        = {};
      obj.Regions             = [];
      obj.RegionMasks         = [];      
      try obj.Regions         = obj.GetRegionMetrics(); end
      try obj.RegionMasks     = obj.GetRegionMasks(); end     
      
      try obj.GetStatistics('reset update'); end
      
      
      if nargin>1, obj.ProcessSetData@PrintUniformityBeta.Data.PlotDataSource(eventData);
      else try obj.ProcessSetData@PrintUniformityBeta.Data.PlotDataSource(); end; end
      
      try obj.PlotOverlay.deleteLabels(); end
      try obj.PlotOverlay.updateSubPlots(); end
      try obj.UpdatePlotLabels(); end      
      %try obj.PlotOverlay.updateSubPlots(); end
    end
    
    function ProcessVariableData(obj, eventData)
      
      debugStamp(1);
      
      variableID = obj.VariableID;
      try
        variableID = eventData.NewValue;
      end
      
      %       updateVariable = false; newVariable=false;
      %       try updateVariable  = isequal(eventData.Parameter, 'VariableID'); end
      %       try newVariable     = updateVariable && ...
      %           (isempty(eventData.PreviousValue) || ~isempty(eventData.NewValue)) && ...
      %           ~isequal(eventData.NewValue, eventData.PreviousValue), end
      %
      %       if ~newVariable && ...
      %           (~isempty(obj.Stats) && isequal(obj.VariableID, variableID) && ...
      %           ~(isempty(obj.Regions) || ~isstruct(obj.Regions)))
      %         return;
      %       end
      
      if ~isempty(obj.Stats) && isequal(obj.VariableID, variableID) && ...
          ~(isempty(obj.Regions) || ~isstruct(obj.Regions))
        return;
      end
      
      debugStamp(1);
      
      %obj.GetStatistics('reset update');
      %       obj.Stats               = [];
      %       obj.SheetStats          = {};
      %       obj.RegionData          = {};
      %       obj.RegionLabels        = {};

      
      if ~isempty(variableID)
        % try obj.Regions             = obj.GetRegionMetrics(); end
        % try obj.RegionMasks     = obj.GetRegionMasks(); end
        
        regions                   = struct;
        
        switch lower(variableID)
          case {'raw'}
            obj.Stats = [];
            regions = [];
          case {'sections', 'around', 'across', 'zones', 'zoneBands'}
            try regions.sections  = obj.Regions.sections;   end
            try regions.around    = obj.Regions.around;     end
            try regions.across    = obj.Regions.across;     end
            try regions.zones     = obj.Regions.zones;      end
            try regions.zoneBands = obj.Regions.zoneBands;  end
          otherwise
            regions.(obj.VariableID)  = obj.Regions.(obj.VariableID);
            try regions.([obj.VariableID 'Around']) = obj.Regions.([variableID 'Around']); end
            try regions.([obj.VariableID 'Across']) = obj.Regions.([variableID 'Across']); end
        end
        
        try if ~isempty(regions)
            %[dataSource stats]    = Stats.generateUPStats(obj.CaseData, obj.SetData.DATA, regions);
            [dataSource stats]    = PrintUniformityBeta.Data.DataReader.ProcessStatistics(obj.CaseData, obj.SetData.DATA, regions);
            obj.Stats = stats;
            
            obj.ProcessStatistics(variableID);
            
          end
        catch err
          debugStamp(err, 1);
          rethrow(err);
        end
      end
      
      if nargin>1, obj.ProcessVariableData@PrintUniformityBeta.Data.PlotDataSource(eventData);
      else try obj.ProcessVariableData@PrintUniformityBeta.Data.PlotDataSource(); end; end

      %       try obj.PlotOverlay.deleteLabels(); end
      %       try obj.PlotOverlay.updateSubPlots(); end
      %       try obj.UpdatePlotLabels(); end
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
      
      if nargin>1, obj.ProcessSheetData@PrintUniformityBeta.Data.PlotDataSource(eventData);
      else obj.ProcessSheetData@PrintUniformityBeta.Data.PlotDataSource(); end
    end
    
    function OnDataLoad(obj, eventData)
      obj.IsLoading = true;
      if nargin>1, obj.OnDataLoad@PrintUniformityBeta.Data.PlotDataSource(eventData); end
    end
    
    function OnDataSuccess(obj, eventData)
      if nargin>1, obj.OnDataSuccess@PrintUniformityBeta.Data.PlotDataSource(eventData); end
      obj.UpdatePlotLabels;
      
      if isequal(eventData.Parameter, 'VariableID') || isequal(eventData.Parameter, 'SetID') % || isequal(eventData.Parameter, 'SetID')
        try obj.PlotOverlay.updateSubPlots(); end
      end
      
      obj.IsLoading = false;
    end
    
    function OnDataFailure(obj, eventData)
      if nargin>1, obj.OnDataFailure@PrintUniformityBeta.Data.PlotDataSource(eventData); end
      
      obj.IsLoading = false;
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
        zLength = 0.2; % 6;
        
        summaryOffset = obj.SummaryOffset;
        offsetRange   = 1:summaryOffset;
        summaryRange  = summaryOffset + 1 + [0:obj.SummaryLength];
        summaryExtent = max(summaryRange);
        
        
        xLim  = [0 obj.ColumnCount + summaryExtent];  % [];
        yLim  = [0 obj.RowCount    + summaryExtent];    % [];
        zLim  = [];
        cLim  = [];
        
        % zLim  = [0 2];  % [];
        % cLim  = [0 2];  % [];
        
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
      
      obj.optimizeSetLimits@PrintUniformityBeta.Data.PlotDataSource(xLim, yLim, zLim, cLim);
    end
    
  end

  methods
    
    function Wait(obj)
      % waitfor(obj, 'IsLoading', false);
      while ~isequal(obj.IsLoading, false)
        pause(1);
      end
    end
    
    function set.StatsMode(obj, value)
      obj.StatsMode         = value;
      obj.ProcessSetData;
      %GrasppeKit.Utilities.DelayedCall(@(s,e)obj.ProcessSetData(obj), 1, 'start');
    end
    
    function set.Stats(obj, stats)
      obj.Stats = stats;
    end
    
    function value = get.StatsMode(obj)
      value = obj.StatsMode;
      %if ~isempty(obj.Stats), obj.ProcessSetData(); end      
    end
    
    
  end
  
  methods (Static, Hidden)
    
    function OPTIONS  = DefaultOptions()
      VariableID = 'sections';
      
      GrasppeAlpha.Utilities.DeclareOptions;
    end
  end
  
  
  
end
