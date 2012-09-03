classdef RegionStatsDataSource < Grasppe.PrintUniformity.Data.UniformityDataSource
  %REGIONSTATSDATASOURCE region-based printing uniformity statistics data source
  %   Detailed explanation goes here
  
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
  
  methods (Hidden)
    function obj = RegionStatsDataSource(varargin)
      obj = obj@Grasppe.PrintUniformity.Data.UniformityDataSource(varargin{:});
    end
    
    function attachPlotObject(obj, plotObject)
      
      try debugStamp(obj.ID, 4); catch, debugStamp(); end;
      
      obj.attachPlotObject@Grasppe.PrintUniformity.Data.UniformityDataSource(plotObject);
      try plotObject.ParentAxes.setView([0 90], true); end
      try plotObject.ParentAxes.Box = false; end
      
      try delete(obj.PlotLabels); end %; catch err, debugStamp(err,1); end
      try
        obj.PlotLabels = Grasppe.PrintUniformity.Graphics.UniformityPlotLabels; ...
          obj.registerHandle(obj.PlotLabels);
        
        obj.PlotLabels.attachPlot(plotObject);
        obj.updatePlotLabels;
        
        if isa(obj.PlotLabels, 'Grasppe.PrintUniformity.Graphics.UniformityPlotLabels') && isvalid(obj.PlotLabels)
          obj.PlotLabels.SubPlotData = obj.SetStats;
          obj.PlotLabels.SubPlotStats = obj.Stats;
          obj.PlotLabels.updateSubPlots;
        end
      catch err
        try debugStamp(err.message, 1); catch, debugStamp(); end;
      end
      
      try obj.optimizeSetLimits; end
    end
    
    function updateSetStatistics(obj)
      
      try
        if isempty(obj.Stats)
          return;
        end;
        
        R = tic;
        
        try debugStamp(obj.ID, 3); catch, debugStamp(); end;
        
        reader   = obj.DataReader;
        
        variableID  = obj.VariableID;
        
        obj.AllDataEnabled = true;
        obj.AllData = obj.getAllData();
        obj.postprocessSheetData();
        
        %toc(R);
        
      catch err
        debugStamp(err, 1);
      end
      
    end
    
    function [id space] = getDataID(obj, prefix, suffix)
      if nargin<2 || isempty(prefix), prefix = ''; end
      if nargin<3 || isempty(suffix), suffix = ''; end

      suffix        = [obj.DataReader.VariableID obj.CurrentStatsMode suffix];
      [id space] = obj.getDataID@Grasppe.PrintUniformity.Data.UniformityDataSource(prefix, suffix);
      
    end
    
    function [sheetStats] = getSheetStatistics(obj, sheetID, variableID)
      
      sheetStats = struct('Data', [], 'Masks', [], 'Values', [], 'Strings', []);
      
      try
        rows    = obj.getRowCount;
        columns = obj.getColumnCount;
        
        [X Y Z] = meshgrid(1:columns, 1:rows, 1);
        
        stats       = obj.Stats;
        caseID      = obj.CaseID;
        setID       = obj.SetID;
        
        %% Get Stats Functions
        
        if isempty(stats) || isempty(caseID) || isempty(setID)
          return;
        end
        
        obj.updateStatsFunctions();
        
        statsMode     = obj.CurrentStatsMode;
        statsFunction = obj.CurrentStatsFunction;
        dataFunction  = obj.CurrentDataFunction;
        labelFunction = obj.CurrentLabelFunction;
        
        varID = variableID; %'Stats'; 
        switch varID
          case {'sections', 'around', 'across'}
            aroundID = 'around';
            acrossID = 'across';
          otherwise
            aroundID = [varID 'Around'];
            acrossID = [varID 'Across'];
        end
        
        %% Get Region Masks
        regionMasks     = stats.metadata.regions.(varID);
        
        %% Get Region Data
        regionData      = Grasppe.Stats.DataStats.empty;
        aroundData      = Grasppe.Stats.DataStats.empty;
        acrossData      = Grasppe.Stats.DataStats.empty;
        
        for m = 1:size(stats.(varID),1)
          regionData(m) = stats.(varID)(m, sheetID).Stats;
        end
        
        runData         = stats.run.Stats;
        sheetData       = regionData(1).Data(:);
        for k=2:numel(regionData)
          sheetData = [sheetData(:); regionData(k).Data(:)];
        end
        sheetData       = Grasppe.Stats.DataStats(sheetData, runData.Mean, runData.Sigma);
        
        try
          aroundMasks = stats.metadata.regions.(aroundID);
          aroundMasks = max(aroundMasks, [], 3);
          %aroundData  = stats.(aroundID)(:, sheetID);
          
          for m = 1:size(stats.(aroundID),1)
            aroundData(m) = stats.(aroundID)(m, sheetID).Stats;
          end
          
        catch
          aroundMasks = [];
          aroundData  = [];
        end
        
        try
          acrossMasks = stats.metadata.regions.(acrossID);
          acrossMasks = max(acrossMasks, [], 2);
          %acrossData  = stats.(acrossID)(:, sheetID);
          
          for m = 1:size(stats.(acrossID),1)
            acrossData(m) = stats.(acrossID)(m, sheetID).Stats;
          end
                    
        catch
          acrossMasks = [];
          acrossData  = [];
        end
        
        %% Stats Calcualtions

        regionStats = statsFunction{1}(regionData, runData);
        
        rows      = size(Z,2);
        columns   = size(Z,1);
        
        summaryOffset = obj.SummaryOffset;
        offsetRange   = 1:summaryOffset;
        summaryRange  = summaryOffset + 1 + [0:obj.SummaryLength];
        summaryExtent = max(summaryRange);
        
        xColumns      = columns+summaryExtent;
        xColumnRange  = columns+1:xColumns;
        xRows         = rows+summaryExtent;
        xRowRange     = rows+1:xRows;
        
        regionMasks(:, xColumnRange, xRowRange) = false;
        
        newData       = zeros(1, xColumns, xRows);
        
        for m = 1:size(regionMasks,1)
          maskData          = regionMasks(m, :, :)==1;
          newData(maskData) = regionStats(m);
        end
                
        try
          aroundStats = statsFunction{2}(aroundData, runData);
          
          for m = 1:size(aroundMasks,1)
            xMask       = zeros(1, xColumns, xRows)==1;
            
            r = rows + summaryRange;
            aroundMask  = aroundMasks(m, :, :)==1;
            xMask(1, aroundMask(:), r) = true;
            
            
            newData(xMask) = aroundStats(m);
            
            n = size(regionMasks,1)+1;
            
            regionMasks(n, :, :)  = xMask;
            regionStats(n)        = aroundStats(m);
          end
        catch err
          debugStamp(err, 1);          
        end
        
        try
          acrossStats = statsFunction{2}(acrossData, runData);
          
          for m = 1:size(acrossMasks,1)
            xMask       = zeros(1, xColumns, xRows)==1;
            
            c = columns + summaryRange;
            acrossMask  = acrossMasks(m, :, :)==1;
            xMask(1, c, acrossMask(:)) = true;
            
            newData(xMask) = acrossStats(m);
            
            n = size(regionMasks,1)+1;
            
            regionMasks(n, :, :)  = xMask;
            regionStats(n)        = acrossStats(m);
          end
        catch err
          debugStamp(err, 1);          
        end
        
        try
          sampleStats = statsFunction{3}(sheetData, runData);
          r = rows    + summaryRange;
          c = columns + summaryRange;
          newData(1, c, r) = sampleStats;
          
          xMask           = zeros(1, xColumns, xRows)==1;
          xMask(1, c, r)  = true;
          
          n = size(regionMasks,1)+1;
          
          regionMasks(n, :, :)  = xMask;
          regionStats(n)        = sampleStats;
        catch err
          debugStamp(err, 1);          
        end
        
        if size(newData, 2) > columns,  newData(1, :, rows + offsetRange)     = nan; end
        if size(newData, 3) > rows,     newData(1, columns + offsetRange, :)  = nan; end
        
        %% Generate Region Labels
        regionLabels    = {}; %cell(size(stats.(varID),1),1);
        
        labelPrefix = '';
        for m = 1:numel(regionData)
          regionLabels{end+1} = [labelPrefix labelFunction{1}(regionData(m)) ];
        end
        for m = 1:numel(aroundData)
          regionLabels{end+1} = [labelPrefix labelFunction{2}(aroundData(m)) ];
        end        
        for m = 1:numel(acrossData)
          regionLabels{end+1} = [labelPrefix labelFunction{2}(acrossData(m)) ];
        end
        regionLabels{end+1}   = [labelPrefix labelFunction{3}(sheetData)     ];
        
        
        sheetStats = struct('Data', newData, 'Masks', regionMasks, 'Values', regionStats, 'Strings', {regionLabels});
        
        try
          obj.SetStats{sheetID}   = regionStats;
        catch err
          debugStamp(err, 1);
        end
        
        try
          obj.SetStrings{sheetID} = regionLabels;
        catch err
          debugStamp(err, 1);          
        end
        
      catch err
        try debugStamp(err, 1); catch, debugStamp(); end;
        % keyboard;
      end
      
    end
    
    function [X Y Z] = processSheetData(obj, sheetID, variableID)
      
      try
        [X Y Z]   = obj.processSheetData@Grasppe.PrintUniformity.Data.UniformityDataSource(sheetID, variableID);
          
        if iscell(sheetID)
          sheetStats  = obj.getSheetStatistics([sheetID{:}], variableID);
        else
          sheetID     = obj.SheetID;
          variableID  = obj.VariableID;
          sheetStats  = obj.getSheetStatistics(sheetID, variableID);
        end
        
        newData       = sheetStats.Data; ...        
        Z             = squeeze(newData);
        [X Y]         = meshgrid(1:size(newData, 3), 1:size(newData, 2));
        
        obj.PlotRegions = sheetStats.Masks;
        obj.PlotValues  = sheetStats.Values;
        obj.PlotStrings = sheetStats.Strings;
        
        %return;
      catch err
        try debugStamp(err.message, 1); catch, debugStamp(); end;
        %keyboard;
      end
      
    end
    
    function optimizeSetLimits(obj)
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
        
        
        xLim  = [0 obj.getColumnCount + summaryExtent];  % [];
        yLim  = [0 obj.getRowCount    + summaryExtent];    % [];
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
      
    obj.optimizeSetLimits@Grasppe.PrintUniformity.Data.UniformityDataSource(xLim, yLim, zLim, cLim);
    
%       %% Update to LinkedPlots
%       try
%         plotObject = obj.LinkedPlotObjects;
%         
%         for m = 1:numel(plotObject)
%           try 
%             plotObject(m).ParentAxes.XLim = obj.XLim; 
%             %plotObject(m).ParentAxes.handleSet('xlim', obj.XLim);
%           end
    
      
    try
      
      cmap          = ones(64,3);
      cmap(:,2)     = linspace(0.95, 0, size(cmap,1));
      cmap(:,3)     = cmap(:,2);
      
      cmap = [flipud(cmap); cmap(2:end,:)];
      
      plotObject = obj.LinkedPlotObjects;
      
      for m = 1:numel(plotObject)
        hax         = plotObject(m).ParentAxes.Handle;
        % try plotObject(m).ParentAxes.handleSet('XTick', []); end
        % try plotObject(m).ParentAxes.handleSet('YTick', []); end
        % try plotObject(m).ParentAxes.handleSet('ZTick', []); end
        try colormap(hax, cmap); end
        try set(hax, 'XTick', [], 'YTick', [], 'ZTick', []); end
      end
      
    end
    
    end
    
  end
  
  methods
    function updatePlotLabels(obj)
      
      try debugStamp(obj.ID, 4); catch, debugStamp(); end;
      
      try
        if ~isa(obj.PlotLabels, 'Grasppe.PrintUniformity.Graphics.UniformityPlotLabels') ...
            || ~isvalid(obj.PlotLabels)
          % if ~isobject(obj.PlotLabels)
          return;
        end
        try
          if ~isempty(obj.SetStats{obj.SheetID})
            obj.PlotValues  = obj.SetStats{obj.SheetID};
          end
          if ~isempty(obj.SetStrings{obj.SheetID})
            obj.PlotStrings = obj.SetStrings{obj.SheetID};
          end
        end
        obj.PlotLabels.MarkerIndex = obj.SheetID;
        obj.PlotLabels.defineLabels(obj.PlotRegions, obj.PlotValues, obj.PlotStrings);
        obj.PlotLabels.SubPlotData = obj.SetStats;
        obj.PlotLabels.SubPlotStats = obj.Stats;
        obj.PlotLabels.createLabels;
        %try obj.optimizeSetLimits; end
      catch err
        try debugStamp(err.message, 1); catch, debugStamp(); end;
      end
      
%       try obj.PlotLabels.updateLabels; catch err 
%         try debugStamp(err, 1); catch, debugStamp(); end; end
      
    end
    
    function updateCaseData(obj, source, event)
      try debugStamp(obj.ID, 3); catch, debugStamp(); end;
      
      [dataSource regions] = Metrics.generateUPRegions(obj.CaseData);
      obj.Regions = regions;
      
      obj.updateCaseData@Grasppe.PrintUniformity.Data.UniformityDataSource(source, event);
    end
    
    function updateSetData(obj, source, event)
      try debugStamp(obj.ID, 3); catch, debugStamp(); end;
      try
        % obj.Stats                 = [];
        % obj.SetStats              = [];
        % obj.CurrentStatsMode      = 'Mean';
        % obj.CurrentStatsFunction  = [];
        % obj.CurrentDataFunction   = [];
        % obj.CurrentLabelFunction  = [];
        obj.resetStats;
        
        try obj.PlotLabels.deleteLabels; end
        
        %obj.DataReader.preloadSheetData();
        %obj.DataReader.preloadSheetData();
        
        obj.updateSetData@Grasppe.PrintUniformity.Data.UniformityDataSource(source, event);
        
        obj.updateVariableData(source, event);
      catch err
        try debugStamp(err.message, 1); catch, debugStamp(); end;
      end
      
      obj.updatePlotLabels;
      try
        if isa(obj.PlotLabels, 'Grasppe.PrintUniformity.Graphics.UniformityPlotLabels') && isvalid(obj.PlotLabels)
          obj.PlotLabels.SubPlotData  = obj.SetStats;
          obj.PlotLabels.SubPlotStats = obj.Stats;
          obj.PlotLabels.updateSubPlots;
        end
      catch err
        try debugStamp(err, 1); catch, debugStamp(); end;
      end
      
      %try obj.optimizeSetLimits; end
    end
    
    function updateSheetData(obj, source, event)
      try debugStamp(obj.ID, 4); catch, debugStamp(); end;
      
      obj.updateSheetData@Grasppe.PrintUniformity.Data.UniformityDataSource(source, event);
      
      obj.updatePlotLabels;
    end
    
    function updateVariableData(obj, source, event)
      
      if nargin==1
        source = obj;
      end
      
      variableID = regexprep(source.VariableID, '\W', '');
      validID = false;
      if isstruct(obj.Regions)
        variableID = validatestring(variableID, fieldnames(obj.Regions));
        validID = true;
      else
        return;
      end
      
      if ~validID
        switch lower(variableID)
          case {'', [], 'none'}
            obj.VariableID = 'raw'; %return;
          case {'sections', 'regions', 'region'}
            obj.VariableID = 'sections'; % return;
          case {'around', 'circumferential'}
            obj.VariableID = 'around'; %return;
          case {'across', 'axial'}
            obj.VariableID = 'across'; %return;
          case {'zones', 'zone', 'inkzones'}
            obj.VariableID = 'zones'; %return;
          case {'zoneband'}
            obj.VariableID = 'zoneBands'; %return;
          otherwise
            try
              if ~isequal(obj.VariableID, obj.LastVariableID) && ~isempty(obj.LastVariableID)
                warning('Unknown variable ID, reverting to last variable ID.');
                obj.VariableID = obj.LastVariableID;
                %return;
              else
                obj.VariableID = 'sections';
              end
            end
        end
      end
      
      try debugStamp(obj.ID, 3); catch, debugStamp(); end;

      obj.resetStats;
      
      if ~isequal(obj.VariableID, variableID)
        obj.VariableID = variableID;
      end
      
      if isequal(obj.VariableID, 'raw')
        obj.Stats = [];
      else
        switch obj.VariableID
          case {'sections', 'around', 'across'}
            regions.sections  = obj.Regions.sections;
            regions.around    = obj.Regions.around;
            regions.across    = obj.Regions.across;
          otherwise
            regions.(obj.VariableID)  = obj.Regions.(obj.VariableID);
            try regions.([obj.VariableID 'Around']) = obj.Regions.([obj.VariableID 'Around']); end
            try regions.([obj.VariableID 'Across']) = obj.Regions.([obj.VariableID 'Across']); end
        end
        
        try obj.PlotLabels.clearLabels; end
        [dataSource stats]    = Stats.generateUPStats(obj.CaseData, obj.SetData.DATA, regions);
        obj.Stats = stats;
      end
      
      obj.updateVariableData@Grasppe.PrintUniformity.Data.UniformityDataSource(source, event);
      
    end
    
    function postprocessSheetData(obj)
      
      try debugStamp(obj.ID, 6); catch, debugStamp(); end;

      
      obj.postprocessSheetData@Grasppe.PrintUniformity.Data.UniformityDataSource;
      
    end
    
    function set.StatsMode(obj, value)
      %if isequal(lower(obj.StatsMode), lower(value)), return; end
      obj.StatsMode         = value;
      GrasppeKit.DelayedCall(@(s,e)obj.updateVariableData(obj,e), 1, 'start');
    end
    
    function set.Stats(obj, stats)
      obj.Stats = stats;
      obj.updateSetStatistics;
    end
    
    function resetStats(obj)
      obj.Stats                 = [];
      obj.SetStats              = [];
      obj.SetStrings            = {};
      obj.CurrentStatsMode      = 'Limits';
      obj.CurrentStatsFunction  = [];
      obj.CurrentDataFunction   = [];
      obj.CurrentLabelFunction  = [];
    end
    
    function updateStatsFunctions(obj)
      
      if ~isempty(obj.CurrentStatsMode) && ...
          ~isempty(obj.CurrentStatsFunction) && ...
          ~isempty(obj.CurrentDataFunction) && ...
          ~isempty(obj.CurrentLabelFunction)
        return;
      end
      
      try debugStamp(obj.ID, 4); catch, debugStamp(); end;
      
      if isempty(obj.StatsMode)
        obj.StatsMode = 'Mean';
      end
      
      statsMode = regexprep(lower(obj.StatsMode), '\W', '');
      
      statsFunction = {};
      dataFunction  = {};
      labelFunction = {};
      
      switch statsMode
          %         case {'std', 'deviation', 'standarddeviation'}
          %           statsMode     = 'Standard Deviation';
          %           statsFunction = @(d, r) vertcat(d.Std);
          %           dataFunction  = @(s)    nanstd(s(:));
          %         case {'deltalimits', 'deltalimit', 'sixsigma'}
          %           statsMode     = 'Six Sigma';
          %           statsFunction = @(d, r) vertcat(d.Std) .* 6;
          %           dataFunction  = @(s)    nanstd(s(:)) .* 6;
          %         case {'peaklimits', 'process limits'}
          %           statsMode     = 'Peak Limits';
          %           statsFunction = @(d, r) max(abs(vertcat(d.Lim) - r.Mean),[],2);
          %           dataFunction  = @(s)    nanmax(s(:));
          %         case {'lowerlimit'}
          %           statsMode     = 'Lower Limit';
          %           statsFunction = @(d, r) eval('vertcat(d.Lim); ans(:,1)');
          %           dataFunction  = @(s)    nanmin(s(:));
          %         case {'upperlimit'}
          %           statsMode     = 'Upper Limit';
          %           statsFunction = @(d, r) eval('vertcat(d.Lim); ans(:,2)');
          %           dataFunction  = @(s)    nanmax(s(:));
        case {'limits'}
          statsMode     = 'Limits';
          statsFunction{1}  = @(d, r) vertcat(d.Mean);
          dataFunction{1}   = @(s)    nanmean(s(:));
          labelFunction{1}  = @(d)    sprintf('%1.1f-%1.1f-%1.1f', min(d.Limits), mean(d.Mean), max(d.Limits));
          labelFunction{2}  = @(d)    sprintf('%1.1f±%1.1f', mean(d.Mean), (d.Sigma.*3));
        case {'peaklimits'}
          statsMode         = 'PeakLimits';
          statsFunction{1}  = @(d, r) vertcat(d.Mean);
          dataFunction{1}   = @(s)    nanmean(s(:));
          labelFunction{1}  = @(d)    sprintf('{\\fontsize{n}{\\bf %1.1f}{\\fontsize{s}%+1.1f }}\n{\\fontsize{t}({\\itpeak_{r}} = {\\it\\mu_{R}}%+1.1f)}', d.PeakLimit(1), 2*(d.Mean-d.PeakLimit(1)), d.PeakLimit(1)-d.ReferenceMean); %d.Sigma*3);
          labelFunction{2}  = @(d)    sprintf('{\\fontsize{n}{\\bf %1.1f}{\\fontsize{s}±%1.1f  } }\n{\\fontsize{t}({\\it\\mu_{b}} = {\\it\\mu_{R}}%+1.1f)  }', [d.Mean   d.Sigma*3 d.Mean-d.ReferenceMean]);
          labelFunction{3}  = @(d)    sprintf('{\\fontsize{n}{\\bf %1.1f}{\\fontsize{s}±%1.1f  } }\n{\\fontsize{t}({\\it\\mu_{s}} = {\\it\\mu_{R}}%+1.1f)  }', [d.Mean   d.Sigma*3 d.Mean-d.ReferenceMean]);
          %labelFunction{1}  = @(d)    sprintf('{\\bf %1.1f}\n{\\fontsize{4}({\\it\\mu_{R}}%+1.1f)}\n{\\fontsize{4.5}{\\it\\mu_{r}}=%1.1f±%1.1f}', d.PeakLimit(1), d.PeakLimit(1)-d.ReferenceMean, d.Mean, d.Sigma*3);          
          %labelFunction{2}  = @(d)    sprintf('{\\bf %1.1f}{\\fontsize{4}±%1.1f}   ', [d.Mean   d.Sigma*3]);
        otherwise % case {'mean', 'average'}
          statsMode         = 'Mean';
          statsFunction{1}  = @(d, r) vertcat(d.Mean);
          dataFunction{1}   = @(s)    nanmean(s(:));
          labelFunction{1}  = @(d)    sprintf('%1.1f', d.Mean);
      end
      
      try while numel(statsFunction) < 3, statsFunction(end+1)  = statsFunction(end); end; end
      try while numel(dataFunction)  < 3, dataFunction(end+1)   = dataFunction(end);  end; end
      try while numel(labelFunction) < 3, labelFunction(end+1)  = labelFunction(end); end; end
      
      obj.CurrentStatsMode      = statsMode;
      obj.CurrentStatsFunction  = statsFunction;
      obj.CurrentDataFunction   = dataFunction;
      obj.CurrentLabelFunction  = labelFunction;
      
    end
    
    function value = get.StatsMode(obj)
      value = obj.StatsMode; %CurrentStatsMode;
    end
    
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      obj.AllDataEnabled = true;
      obj.createComponent@Grasppe.PrintUniformity.Data.UniformityDataSource;
      %obj.DataReader.preloadSheetData();
      %obj.DataReader.preloadSheetData();
    end
    
  end
  
  methods (Static, Hidden)
    function stats = regionStatistics(caseData, setData)
      
    end
    
    function masks = regionMasks(caseData)
      %% Axial Masks
      
      %% Circumferential Masks
      
      %% Region Masks
      
    end
    
    function masks = zoneMasks(caseData)
      
    end
    
    function [newData metrics]  = regionStatisticsFilter(zData)
      %newData = zData;
      
      rows    = size(zData, 1);
      columns = size(zData, 2);
      
      if rows > columns
        across = 3;
        around = round(((rows/columns*3)-1)/2)*2+1;
      else % rows <= columns
        around = 3;
        across = round(((columns/rows*3)-1)/2)*2+1;
      end
      
      rowSteps          = reshape(([(rows)/around] * ceil(0:0.5:around-0.5)),2,[]);
      rowSteps          = round(rowSteps);
      rowSteps(1,:)     = rowSteps(1,:) + 1;
      
      columnSteps       = reshape(([(columns)/across] * ceil(0:0.5:across-0.5)),2,[]);
      columnSteps       = round(columnSteps);
      columnSteps(1,:)  = columnSteps(1,:) + 1;
      
      % try
      newData = zeros(size(zData));
      
      values  = zeros(around, across);
      
      for r = 1:around
        row = round(rowSteps(1,r):rowSteps(2,r));
        for c = 1:across
          column  = round(columnSteps(1,c):columnSteps(2,c));
          cellData              = zData(row, column);
          values(r,c)           = nanmean(cellData(:)); % ([(r-1)*across]+c)/(around*across)
          newData(row, column)  = values(r,c); % 1/(around*across)*(r*(c-1)+1);
        end
      end
      
      metrics.rowBands    = around;
      metrics.columnBands = across;
      metrics.rowSteps    = rowSteps;
      metrics.columnSteps = columnSteps;
      metrics.values      = values;
      % end
    end
    
    function OPTIONS  = DefaultOptions()
      VariableID = 'sections';
      
      Grasppe.Utilities.DeclareOptions;
    end
  end
  
  methods (Static)
    function obj = Create(varargin)
      obj = Grasppe.PrintUniformity.Data.LocalVariabilityDataSource(varargin{:});
    end
  end
  
  
end

