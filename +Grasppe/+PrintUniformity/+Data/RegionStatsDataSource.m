classdef RegionStatsDataSource < Grasppe.PrintUniformity.Data.UniformityDataSource
  %REGIONSTATSDATASOURCE region-based printing uniformity statistics data source
  %   Detailed explanation goes here
  
  properties
    % LocalVariabilityDataSourceProperties = {
    %   'TestProperty', 'Test Property', 'Labels', 'string', '';   ...
    %   };
    % TestProperty
    Regions
    Stats
    
    StatsMode = 'Mean';
  end
  
  methods (Hidden)
    function obj = RegionStatsDataSource(varargin)
      obj = obj@Grasppe.PrintUniformity.Data.UniformityDataSource(varargin{:});
    end
    
    function attachPlotObject(obj, plotObject)
      obj.attachPlotObject@Grasppe.PrintUniformity.Data.UniformityDataSource(plotObject);
      try plotObject.ParentAxes.setView([0 90], true); end
    end

    function [X Y Z] = processSheetData(obj, sheetID, variableID)

      [X Y Z]   = obj.processSheetData@Grasppe.PrintUniformity.Data.UniformityDataSource(sheetID, variableID);
      
      caseData      = obj.CaseData; ...
        setData   	= obj.SetData; ...
        sheetData   = obj.SheetData; ...
        stats       = obj.Stats; ...
        variableID  = obj.VariableID;
      
      dispf('Sheet ID = %s', int2str(obj.SheetID));
      targetFilter  = caseData.sampling.masks.Target~=1;
      patchFilter   = setData.filterData.dataFilter~=1;
      
      if isempty(stats)
        Z(~patchFilter) = sheetData;
        Z(targetFilter) = NaN;
        Z(patchFilter)  = NaN;
        %[Z M] = Grasppe.PrintUniformity.Data.RegionStatsDataSource.regionStatisticsFilter(Z);
      else
        regionMasks = stats.metadata.regions.(variableID);
        regionData  = stats.(variableID)(:, sheetID);
        runData     = stats.run;
        
        statsMode = regexprep(lower(obj.StatsMode), '\W', '');
        
        switch statsMode
          case {'std', 'deviation', 'standarddeviation'}
            statsMode = 'Standard Deviation'
            statsData = vertcat(regionData.Std);
          case {'deltalimits', 'deltalimit', 'sixsigma'}
            statsMode = 'Six Sigma'
            statsData = vertcat(regionData.Std) .* 6;
          case {'peaklimits', 'process limits'}
            statsMode = 'Peak Limits'
            limData   = vertcat(regionData.Lim);
            statsData = max(abs(limData - runData.Mean),[],2);
          case {'lowerlimit'}
            statsMode = 'Lower Limit'
            limData   = vertcat(regionData.Lim);
            statsData = limData(:,1);             
          case {'upperlimit'}
            statsMode = 'Upper Limit'
            limData   = vertcat(regionData.Lim);
            statsData = limData(:,2);           
          otherwise % case {'mean', 'average'}
            statsMode   = 'Mean';
            statsData = vertcat(regionData.Mean);
        end
        
        obj.StatsMode = statsMode;
        
        newData = zeros(1, size(Z,1), size(Z,2));
        
        for m = 1:size(regionMasks,1)
          maskData          = regionMasks(m, :, :)==1;
          newData(maskData) = statsData(m);
        end
        
        Z = squeeze(newData);
        
        %return;
      end
      
      % Z(targetFilter) = NaN;
      % Z(patchFilter)  = NaN;
%       
%       dataFilter  = ~isnan(Z);
%       
%       F = TriScatteredInterp(X(dataFilter), Y(dataFilter), Z(dataFilter), 'natural');
%       
%       Z = F(X, Y);
%       Z(targetFilter) = NaN;
      
      %Z(patchFilter~=1)   = NaN;      
      
    end
    
    function optimizeSetLimits(obj)
      zLim    = 'auto';
      
      obj.ZLim  = zLim;
      % obj.CLim  = zLim;
    end
    
    function setPlotData(obj, XData, YData, ZData)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      obj.XData = XData;
      obj.YData = YData;
      %obj.ZData = ZData;
      obj.CData = ZData;
      
      %ZData(~isnan(ZData)) = nanmean(ZData(:));
      
      obj.ZData = ZData;
      
      obj.updatePlots();
    end
    
  end
  
  methods
    function updateCaseData(obj, source, event)
      [dataSource regions] = Metrics.generateUPRegions(obj.CaseData);
      obj.Regions = regions;
      
      obj.LastVariableID = 'raw';
      obj.updateVariableData(source, event);      
      
      obj.updateCaseData@Grasppe.PrintUniformity.Data.UniformityDataSource(source, event);
    end
    
    function updateSetData(obj, source, event)
      obj.updateSetData@Grasppe.PrintUniformity.Data.UniformityDataSource(source, event);
    end
    
    function updateSheetData(obj, source, event)
      obj.updateSheetData@Grasppe.PrintUniformity.Data.UniformityDataSource(source, event);
    end    
    
    function updateVariableData(obj, source, event)
      variableID = regexprep(source.VariableID, '\W', '');
      validID = false;
      try 
        variableID = validatestring(variableID, fieldnames(obj.Regions));
        validID = true;
      end
      
      if ~validID
        switch lower(variableID)
%           case {'raw', 'sections', 'around', 'across', 'zones', 'zonebands'}
%             try
%               if ~stropt(lower(source.VariableID), fieldnames(obj.Regions));
%                 warning('Unknown variable ID, reverting to last variable ID.');
%                 obj.VariableID = obj.LastVariableID; return;
%               end
%             catch err
%               return;
%             end
          case {'', [], 'none'}
            obj.VariableID = 'raw'; return;
          case {'sections', 'regions', 'region'}
            obj.VariableID = 'sections'; return;
          case {'around', 'circumferential'}
            obj.VariableID = 'around'; return;
          case {'across', 'axial'}
            obj.VariableID = 'across'; return;
          case {'zones', 'zone', 'inkzones'}
            obj.VariableID = 'zones'; return;
          case {'zoneband'}
            obj.VariableID = 'zoneBands'; return;
          otherwise
            warning('Unknown variable ID, reverting to last variable ID.');
            obj.VariableID = obj.LastVariableID; return;
        end
      end
      
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

        [dataSource stats]    = Stats.generateUPStats(obj.CaseData, obj.SetData, regions);
        obj.Stats = stats;
      end
      
      dispf('Variable ID = %s', obj.VariableID);
      
      obj.updateVariableData@Grasppe.PrintUniformity.Data.UniformityDataSource(source, event);
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

