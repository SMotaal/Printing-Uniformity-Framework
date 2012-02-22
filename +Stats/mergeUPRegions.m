function [ dataSource ] = mergeUPRegions( dataSource, dataSet )
  %MERGEUPREGIONS combine print uniformity regions surfaces and statistics
  %   Prepares printing uniformity statistics data for plotting by merging
  %   region statistics data generated using masks groups within processed
  %   UniformityDataModels (UDM's). UDM's contain substructures for masks
  %   and statistics generated using the mask groups, ie. sections, blocks,
  %   bands... etc. Each group has its own multidimentional structures for
  %   both components, resulting in groups of segmented uniformity data.
  %   This function merges these segements for each group to produce one
  %   contiuous surface and patch data sources. Value labels are also
  %   generated to overlay the surface and patch plots with the
  %   approporiate statistical data for each segment.
  
  surfID          = Data.generateUPID([],dataSet, 'Surfs');
    
	regionSurfsData = Data.dataSources(surfID);
    
  if (isempty(regionSurfsData))
    regionSurfsData = surfData(dataSource.statistics, dataSource.sampling.regions); %, [], dataSource.sampling.regions.zoneBands)
    Data.dataSources(surfID, regionSurfsData, true);
  end  
  
  dataSource.data = regionSurfsData;
end


function [surfs] = surfData(stats, masks, region, field, summary)
  
  default region  [];
  default field   [];
  default masks   [];
  default summary true;
  
  if (isempty(region))
    regions = fieldnames(stats);
    for r = 4:numel(regions)
      region = char(regions(r));
      surfs.(region) = surfData(stats, masks, region, field, summary);
    end
  elseif (isempty(field))
    fields = fieldnames(stats.(region));
    for f = 1:numel(fields)
      field = char(fields(f));
      surfs.(field) = surfData(stats, masks, region, field, summary);
    end
  else
    
    localStats  = stats.(region);
    localMasks  = masks.(region);
    
    if (~isVerified('summary','false') && isVerified('size(localStats,2)>1', true))
      summaryStats  = localStats(:,1);
      localStats    = localStats(:,2:end);
    end
    
    nSheets   = size(localStats,2);
    nRows     = size(localMasks,2);
    nColumns  = size(localMasks,3);
    nMasks    = size(localMasks,1);
    nValues   = numel(localStats(1,1).(field));
    
    surfs = zeros(nSheets, nMasks, nValues, nRows, nColumns);
    
    for m = 1:nMasks
      localMask = squeeze(localMasks(m,:,:))==1;
      if(all(localMask==0))
        surfs(:,m,:,:) = NaN;
      else
        for s = 1:nSheets+1
          
          if (s==1) && exists('summary')
%             sheetStats = summaryStats(m);
            fieldStats = summaryStats(m).(field);
          else
%             sheetStats = localStats(m,s-1);
            fieldStats = localStats(m,s-1).(field);
          end
          
%           fieldStats = sheetStats.(field);

          for v = 1:nValues
            surfs(s,m,v,localMask)    = fieldStats(v);
            surfs(s,m,v,localMask==0) = NaN;
          end
        end
      end
    end
%     surfs.Values = surfs;
  end
end

