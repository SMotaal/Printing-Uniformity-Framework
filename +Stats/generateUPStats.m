function [ dataSource stats ] = generateUPStats( dataSource, dataSet, regions  )
  %GENERATEUPSTATS Summary of this function goes here
  %   Detailed explanation goes here
  
  % persistent dataField;
  
  Forced                    = false;
    
  version                   = 1016;
  
  masks                     = getDataMasks(dataSource);
  
  [data filter]             = getPatchData(dataSet, masks);
  
  L2V                       = @(L)      -log10(((L+16)./116).^3);
  
  if ~isfield(dataSet.data, 'lZData')
    try
      for m = 1:numel(dataSet.data)
        dataSet.data(m).lZData  = dataSet.data(m).zData;
        dataSet.data(m).zData   = L2V(dataSet.data(m).zData);
      end
    catch err
      debugStamp;
    end
  end
  
  metrics                   = getMetrics(dataSource, size(data,1));
  
  if nargin < 3, regions = getRegionMasks(dataSource); end
  
  stats                     = struct('metadata', [], 'run', [], 'version', version, 'filter', filter); % 'data', data, 
  
  stats.metadata            = struct( ...
    'source',  dataSet.sourceName,  'set', dataSet.patchSet, ...
    'metrics', metrics, 'masks', masks, 'regions', regions, 'setData', dataSet);
  
  sourceSpace               = dataSet.sourceName;

  [stats.run stats.data]    = generateRunStats( data );
  
  regionNames               = fieldnames(regions);
  
  for r = 1:numel(regionNames)
    
    regionName      = char(regionNames{r});
    regionID        = Data.generateUPID([],dataSet, regionName);
    
    regionStatsData = Data.dataSources(regionID, sourceSpace);
    
    if Forced || ~( isstruct(regionStatsData) && ...
        isfield(regionStatsData, 'Version') && ...
        regionStatsData.Version >= version)
      regionStatsData = [];
    end

    % try
    %   if ~(isstruct(regionStatsData) && isfield(regionStatsData,'Stats')) || ...
    %       ~(sa(regionStatsData(1).Stats, 'Grasppe.Stats.TransientStats'))
    %     regionStatsData = [];
    %   end
    % catch err
    %   regionStatsData = [];
    % end
    
    if (isempty(regionStatsData))
      regionStatsData         = struct;
      regionStatsData.Version = version;
      regionStatsData.Stats   = calculateStats(stats.data, regions.(regionName), stats.run);
            
      Data.dataSources(regionID, regionStatsData, false, sourceSpace);
    end
    
    stats.(regionName)  = regionStatsData.Stats;
    
  end
  
  dataSource.statistics = stats;
  
  
end

function [ ID  ] = regionDataSetID(dataSet, regionName)
  sourceName  = dataSet.sourceName;
  
  setCode     = dataSet.patchSet;
  
  if (setCode<0 && setCode > -100)
    setCode = 200-setCode;
  end
  
  ID = genvarname([sourceName num2str(setCode, '%03.0f') regionName 'Stats']);
end


function [masks] = getDataMasks(dataSource)
  masks = dataSource.sampling.masks;
end

function [regions] = getRegionMasks(dataSource)
  regions = dataSource.sampling.regions;
end

% function [ data ] = eliminateOutliers( stats )
%   data = stats.data;
%   
%   if validCheck('stats.run.Lim', 'double')
%     
%     runLimits = stats.run.Lim;
%     
%     data(data<runLimits(1)) = NaN;
%     data(data>runLimits(2)) = NaN;
%     
%   end
%   
% end

function [run data] = generateRunStats( runData ) %stats )
  %runStats.Mean   = nanmean(stats.data(:));
  %runStats.Std    = nanstd(stats.data(:));
  %runStats.Lim    = runStats.Mean + runStats.Std*[-3  +3];
  
  % targetFilter              = stats.metadata.masks.Target~=1;
  % patchFilter               = stats.metadata.setData.filterData.dataFilter~=1;
  % dataFilter                = ~(targetFilter | patchFilter);
  
  %runData         = stats.data;
  run.Stats       = generateDataStats(runData); %stats.data(:));
  outliers        = run.Stats.Outliers;
  
  data            = runData; %stats.data;
  data(outliers)  = NaN;
  
  %filter          = dataFilter;  
  
  % runData(:, dataFilter)    = NaN;
  
%   runData                   = runData(~isnan(runData));
%   run.Stats                 = generateDataStats(runData);
%   
%   outliers                  = run.Stats.Outliers;
%   
%   %samples                   = setdiff(1:numel(stats.data(:)), outliers);
%   data                      = runData;
%   data(outliers)            = NaN;
%   
%   run.Stats  	= generateDataStats(runData); %stats.data(:));
%   
%   outliers                  = run.Stats.Outliers;
%   
%   data            = runData; %stats.data;
%   data(outliers)  = NaN;
%   filter          = dataFilter;
  
end

function stats = generateDataStats(data, varargin)
  stats = Grasppe.Stats.TransientStats(data, varargin{:}); %opt{:});
end

function [regionStats] = calculateStats( data,  masks, population )
  
  %import(eval(NS.CLASS));

  regionStats = struct;
  
  % IN PLOTUPSTATS: Data.filterUPDataSet produces Column-First data!
  % IN PLOTUPSTATS: Metrics.generateUPRegions produces Row-First masks!
  
  % data is Row-First
    
  if ~isa(population.Stats, 'Grasppe.Stats.TransientStats')
    error('Grasppe:Stats:PopulationInvalid', 'Stats can only be computed with TransientStats population reference.');
  end
    
  %% Masks
  if ~exists('masks') || isempty(masks)
    sData                       = size(data);
    masks                       = ones(sData([1 2:end]));
  end
  
  nMasks                        = size(masks,1);
  nSheets                       =  size(data,1);
  
  %% Sample Statistics
  for s = 0:nSheets % si = s+1;
    
    if (s>0)
      sheetData                 = data(s, :);
    else
      sheetData                 = data;
    end
    
    for m = 1:nMasks
      localMask                 = masks(m,:,:)==1;
      regionData                = sheetData(localMask);
      regionStats(m,s+1).Stats  = generateDataStats(regionData, population.Stats.Sample);
    end
  end
  
end

function [data filter] = getPatchData( dataSet, masks )
  
  try
    if ~exists('masks') || isempty(masks)
      masks                   = ones(sData([1 2:end]));
    end
    
    dataField                 = 'zData';
    
    nSheets                   = numel(dataSet.data);
    
    [setData{1:nSheets}]      = deal(dataSet.data(:).(dataField));
    
    targetFilter              = masks.Target~=1;
    patchFilter               = dataSet.filterData.dataFilter~=1;
    filter                    = (targetFilter | patchFilter);
    
    sheetSize                 = size(patchFilter);
    nRows                     = sheetSize(1);
    nColumns                  = sheetSize(2);
    
    data                      = NaN(nSheets, nRows, nColumns);   
    
    for m = 1:nSheets
      data(m,~patchFilter)    = setData{m}';
    end
    
    data(:, targetFilter)     = NaN;
  catch err
    debugStamp();
  end
  
end

%function [sampleStats] = sampleStats(data,

function [dataMatrix] = getData( dataSet, dataField )
  
  nSheets     = numel(dataSet.data);
  
  [setData{1:nSheets}] = deal(dataSet.data(:).(dataField));
  
  sheetSize   = size(setData{1});
  nRows       = sheetSize(2);
  nColumns    = sheetSize(1);
  
  dataMatrix  = nan(nSheets, nRows, nColumns);
  
  for i = 1:nSheets
    dataMatrix(i,:,:) = setData{i}';
  end
  
end

function [metrics] = getMetrics( dataSource, sheets ) %rows, columns, rowPitch, columnPitch, sheets)
  
  if (exist('sheets','var'))
    metrics.sheets = sheets;
  end
  
  metrics.rows        = dataSource.metrics.sampleSize(1);
  metrics.columns     = dataSource.metrics.sampleSize(2);
  metrics.length      = dataSource.metrics.sampleLength; %(metrics.rows-1)*metrics.patchLength;
  metrics.width       = dataSource.metrics.sampleWidth; %(metrics.columns-1)*metrics.patchWidth;
  metrics.size        = dataSource.metrics.sampleArea;
  
  metrics.patchLength = dataSource.metrics.patchLength;
  metrics.patchWidth  = dataSource.metrics.patchWidth;
  metrics.patchSize   = [dataSource.metrics.patchLength dataSource.metrics.patchWidth];
  
  
end
