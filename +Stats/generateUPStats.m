function [ dataSource stats ] = generateUPStats( dataSource, dataSet  )
  %GENERATEUPSTATS Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent dataField;
  
  default dataField surfData;
  
  data    = getData(dataSet, dataField);
  metrics = getMetrics(dataSource, size(data,1));
  masks   = getDataMasks(dataSource);
  regions = getRegionMasks(dataSource);
  
  stats = struct('metadata', [], 'data', data, 'run', []);
  
  stats.metadata  = struct( ...
    'source',  dataSet.sourceName,  'set', dataSet.patchSet, ...
    'metrics', metrics, 'masks', masks, 'regions', regions);
  
  stats.run   = generateRunStats  ( stats );
  
  stats.data  = eliminateOutliers ( stats );
  
  regionNames = fieldnames(regions);
  
  for r = 1:numel(regionNames)
    
    regionName      = char(regionNames{r});
    regionID        = Data.generateUPID([],dataSet, regionName);
    
    regionStatsData = Data.dataSources(regionID);
    
    if (isempty(regionStatsData))
      regionStatsData = calculateStats(data, regions.(regionName), stats.run);
      Data.dataSources(regionID, regionStatsData, true);
    end
    
    stats.(regionName)  = regionStatsData;

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

function [ data ] = eliminateOutliers( stats )
  data = stats.data;
  
  if isValid('stats.run.Lim', 'double')
    
    runLimits = stats.run.Lim;
    
    data(data<runLimits(1)) = NaN;
    data(data>runLimits(2)) = NaN;
    
  end
  
end

function [runStats] = generateRunStats( stats )
  runStats.Mean   = nanmean(stats.data(:));
  runStats.Std    = nanstd(stats.data(:));
  runStats.Lim    = runStats.Mean + runStats.Std*[-3  +3];
end

function [localStats] = calculateStats( data,  masks, population )
   
  tMean   = 'Mean';
  tStd    = 'Std' ;
  tLim    = 'Lim' ;
  
  tRMean  = 'RelativeMean';
  tRLim   = 'RelativeLim';
  tPLim   = 'PeakLim';
  
  localStats = struct;
  
  % IN PLOTUPSTATS: Data.filterUPDataSet produces Column-First data!
  % IN PLOTUPSTATS: Metrics.generateUPRegions produces Row-First masks!
  
  % data is Row-First
  
  %% Run Statistics
  if isValid('population', 'struct')
    iMean = firstMatch(fieldnames(population), '^Mean$' );
    iStd  = firstMatch(fieldnames(population), '^Std$'  );
    iLim  = firstMatch(fieldnames(population), '^Lim$'  );
    
    opt(['rMean=population.'  iMean ]);
    opt(['rStd=population.'   iStd  ]);
    opt(['rLim=population.'   iLim  ]);
    
  end
  
  %% Masks
  if ~exists('masks') || isempty(masks)
    sData = size(data);
    masks = ones(sData([1 2:end]));
  end
  
  nMasks  = size(masks,1);
  nSheets =  size(data,1);
  
  %% Sample Statistics
  for s = 0:nSheets
    if (s>0)
      sheetData = data(s, :);
    else
      sheetData = data;
    end
    
    si = s+1;
            
    for m = 1:nMasks
      
      localMask   = masks(m,:,:)==1;
      regionData  = sheetData(localMask); % regionData  = zeros(size(localMask)) * NaN; % regionData(localMask)  = sheetData(localMask);

      localStats(m,si).(tMean) = nanmean(regionData);
      localStats(m,si).(tStd ) = nanstd(regionData);
      localStats(m,si).(tLim ) = localStats(m,si).(tMean) + [-3 +3].*localStats(m,si).(tStd);

      if isValid('rMean', 'double')
        localStats(m,si).(tRMean) = localStats(m,si).(tMean) - rMean;
      end

      if isValid('rLim',  'double')
        localStats(m,si).(tRLim) = localStats(m,si).(tLim)-rLim;
        localStats(m,si).(tPLim) = nanmax(localStats(m,si).(tRLim),[],2);
      end
    end
  end
  
end

%function [sampleStats] = sampleStats(data, 

function [dataMatrix] = getData( dataSet, dataField )
  
  nSheets     = numel(dataSet.data);
  
  [setData{1:nSheets}] = deal(dataSet.data(:).(dataField));
  
  sheetSize   = size(setData{1});
  nRows       = sheetSize(2);
  nColumns    = sheetSize(1);
  
  dataMatrix = zeros(nSheets, nRows, nColumns);
  
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
