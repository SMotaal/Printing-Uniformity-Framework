function stats = ProcessSetStatistics( dataSource, dataSet, regions, progressUpdate)
  %GENERATEUPSTATS Summary of this function goes here
  %   Detailed explanation goes here
  
  % persistent dataField;
  
  % import PrintUniformityBeta.Data.DataReader;
  
  %% SimpleDataModel Compatibility
  try dataSource            = dataSource.DATA;  end
  try dataSet               = dataSet.DATA;     end
  
  localProgress             = ~exist('progressUpdate', 'var');
  
	stepString                = @(m, n)       sprintf('%d of %d', m, n);
  progressString            = @(s)          ['Statistics: ' s];  
  progressValue             = @(x, y, z)    min(1, (max(0,x-1)+y)/z);
  
  progressSteps             = 4;

  if localProgress
    progressUpdate          = @(x, y, z, s) GrasppeKit.Utilities.ProgressUpdate(progressValue(x, y, z), ['Processing ' progressString(s)]);
  end
  
  
  Forced                    = false;
    
  version                   = 1017;

  try progressUpdate(1,0,progressSteps, 'Data'); end
  masks                     = getDataMasks(dataSource);
  [data filter]             = getPatchData(dataSet, masks);
  
  L2V                       = @(L)      -log10(((L+16)./116).^3);
  
  if ~isfield(dataSet.data, 'lZData')
    
    dataCount               = numel(dataSet.data);
    
    try
      for m = 1:dataCount
        dataSet.data(m).lZData  = dataSet.data(m).zData;
        dataSet.data(m).zData   = L2V(dataSet.data(m).zData);
        
        try progressUpdate(1, m/dataCount, progressSteps, ['Data ' stepString(m, dataCount)]); end
        % try progressUpdate(m,1,dataCount, 'Data'); end
      end
    catch err
      debugStamp;
    end
  end
  
  try progressUpdate(2, 0, progressSteps, 'Metrics'); end
  metrics                   = getMetrics(dataSource, size(data,1));
  
  try progressUpdate(3, 0, progressSteps, 'Masks'); end
  if nargin < 3, regions    = getRegionMasks(dataSource); end
  
  stats                     = struct('metadata', [], 'run', [], 'version', version, 'filter', filter); % 'data', data, 
  
  stats.metadata            = struct( ...
    'source',  dataSet.sourceName,  'set', dataSet.patchSet, ...
    'metrics', metrics, 'masks', masks, 'regions', regions, 'setData', dataSet);
  
  sourceSpace               = dataSet.sourceName;

  try progressUpdate(0,0,1, 'Run'); end
  
  [stats.run stats.data]    = generateRunStats( data );
  
  regionNames               = fieldnames(regions);
  
  regionCount               = numel(regionNames);
    
  for r = 1:regionCount
    
    regionName              = char(regionNames{r});
    regionID                = generateCacheID([],dataSet, regionName);
    
    try progressUpdate(4, progressValue(r, 0, regionCount), progressSteps, regionName); end
    
    regionStatsData         = DS.dataSources(regionID, sourceSpace);
    
    if Forced || ~( isstruct(regionStatsData) && ...
        isfield(regionStatsData, 'Version') && ...
        regionStatsData.Version >= version && ...
        isfield(regionStatsData, 'Stats') && ...
        isfield(regionStatsData.Stats(1), 'Stats') && ...
        ~isempty(regionStatsData.Stats(1).Stats))
      regionStatsData = [];
    end

    % try progressUpdate(r, 0.25, regionCount, regionName); end
    
    if (isempty(regionStatsData))
      regionStatsData         = struct;
      regionStatsData.Version = version;
      
      subProgressUpdate       = @(x, y, z, s) progressUpdate(4, progressValue(r, progressValue(x,y,z)-0.05, regionCount), progressSteps, [regionName ' ' s]);
      %progressUpdate(r, progressValue(x,y,z)-0.05, regionCount, [regionName ' ' s]);
      
      regionStatsData.Stats   = calculateStats(stats.data, regions.(regionName), stats.run, subProgressUpdate);
      
            
      DS.dataSources(regionID, regionStatsData, false, sourceSpace);
      
      %try progressUpdate(r, 1.0, regionCount, regionName); end
    end
    
    stats.(regionName)  = regionStatsData.Stats;
    
    try progressUpdate(4, r/regionCount, progressSteps, regionName); end
    
  end
  
  try if localProgress, GrasppeKit.Utilities.ProgressUpdate(); end; end
  
  
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
  stats = GrasppeAlpha.Stats.TransientStats(data, varargin{:}); %opt{:});
end

function [regionStats] = calculateStats( data,  masks, population, progressUpdate )
  
  %import(eval(NS.CLASS));
  stepString                = @(m, n)       sprintf('%d of %d', m, n);

  regionStats = struct;
  
  % IN PLOTUPSTATS: Data.filterUPDataSet produces Column-First data!
  % IN PLOTUPSTATS: Metrics.generateUPRegions produces Row-First masks!
  
  % data is Row-First
    
  if ~isa(population.Stats, 'GrasppeAlpha.Stats.TransientStats')
    error('Grasppe:Stats:PopulationInvalid', 'Stats can only be computed with TransientStats population reference.');
  end
    
  %% Masks
  if ~exists('masks') || isempty(masks)
    sData                       = size(data);
    masks                       = ones(sData([1 2:end]));
  end
  
  nMasks                        = size(masks,1);
  nSheets                       = size(data,1);
  
  %% Sample Statistics
  for s = 0:nSheets % si = s+1;
    
    if (s>0)
      sheetData                 = data(s, :);
    else
      sheetData                 = data;
    end
    
    try progressUpdate(s, 0, nSheets, stepString(s, nSheets)); end
    
    for m = 1:nMasks
      localMask                 = masks(m,:,:)==1;
      regionData                = sheetData(localMask);
      regionStats(m,s+1).Stats  = generateDataStats(regionData, population.Stats.Sample);
    end
  end
  
end

function [data filter] = getPatchData( dataSet, masks )
  
  try
    % if ~exists('masks') || isempty(masks)
    %   masks                   = ones(sData([1 2:end]));
    % end
    
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



function [ strID ] = generateCacheID( dataSource, dataSet, dataClass )
  if ~exists('dataSource'), dataSource = ''; end
  
  if isstruct(dataSource)
    try
      dataSource = dataSource.name;
    catch
      dataSource = '';
    end
  end
  
  if ~exists('dataSet')
    dataSet='';
  else
    if isstruct(dataSet)
      try
        dataSource  = dataSet.sourceName;
      end      
      try
        dataSet     = dataSet.patchSet;
      catch
        dataSet = '';
      end
    end
  end
  
  if ~exists('dataClass')
    dataClass = '';
  end
  
  try
    dataSource = strtrim(dataSource);
    dataSource = lower(dataSource);
  end
  
  
  strID = [toString(dataSource) toString(dataSet) toString(dataClass)];
  
end

