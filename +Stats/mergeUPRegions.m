function [ dataSet ] = mergeUPRegions( dataSource, dataSet, params, options )
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
  
  [regions fields]  = surfParams(params); %, options);
  
  
  regionSurfsData   = surfData(dataSource, dataSet, regions, fields);
  
  for region = fieldnames(regionSurfsData)
    regionName = char(region);
    
    if ~stropt(regionName, fieldnames(regionSurfsData))
      continue;
    end    
    
    if isVerified('dataSet.surfs.(regionName)')
      
      dataFields = fieldnames(regionSurfsData.(regionName));
      for field = dataFields
        fieldName = char(field);
        dataSet.surfs.(regionName).(fieldName) = regionSurfsData.(regionName).(fieldName);
      end
      
      
    else
      dataSet.surfs.(regionName) = regionSurfsData.(char(region));
    end
  end
  
end

function [regions fields] = surfParams(params)
  % statMode    = {'sheet', 'axial', 'across', 'circumferential', 'around',
  %       'region', 'regions', 'section', 'sections', 'zone', 'zones',
  %       'zoneband', 'zonebands', 'band', 'bands'};
  
  statModes     = regexp(params.statMode,'\w+', 'match');
  regions       = {};
  
  if stropt('complete', statModes)
    statModes = {'axial', 'circumferential', 'region', 'zone', 'zonebands'};
  end
  
  for statMode  = statModes
    switch lower(char(statMode{1}))
      case {'axial', 'across'}
        region  = 'across';
      case {'circumferential', 'around'}
        region  = 'around';
      case {'region', 'regions', 'section', 'sections'}
        region  = 'sections';
      case {'zone', 'zones'}
        region  = 'across';
      case {'zoneband', 'zonebands', 'band', 'bands'}
        region  = 'zoneBands';
      otherwise
        region  = '';
    end
    if ~isempty(region)
      regions{numel(regions)+1} = region;
    end
  end
  
  
  statFields    = regexp(params.statField,'\w+', 'match');
  fields        = {};
  for statField = statFields
    switch lower(char(statField{1}))
      case {'all'}
        fields  = {};
        break;
      case {'mean'}
        field   = 'Mean';
      case {'std'}
        field   = 'Std';
      case {'lim'}
        field   = 'Lim';
        %       case {'mean'}
        %         field = 'Mean';
      otherwise
        field   = '';
    end
    if ~isempty(field)
      fields{numel(fields)+1} = field;
    end
  end
  
end


function [surfs] = surfData(dataSource, dataSet, regions, fields, summary)
  
  default summary true;
  
  stats = dataSource.statistics;
  masks = dataSource.sampling.regions;
  
  if (~exists('regions') || isempty(regions))
    regions = fieldnames(stats);
    regions = regions(4:end);
  end
    
  for r = 1:numel(regions)
    region = char(regions(r));
    
    if ~stropt(region, fieldnames(stats))
      continue;
    end
    
    if (~exists('fields') || isempty(fields))
      fields = fieldnames(stats.(region));
    end
    
    for f = 1:numel(fields)
      field = char(fields(f));
      
      if ~stropt(field, fieldnames(stats.(region)))
        continue;
      end
      
      surfID          = Data.generateUPID([],dataSet, [region ' ' field 'Surfs']);
      regionSurfsData = []; Data.dataSources(surfID);
      
      if (isempty(regionSurfsData))
        
        
        localStats  = stats.(region);
        localMasks  = masks.(region);
        
        if (~isVerified('summary','false') && isVerified('size(localStats,2)>1', true))
          summaryStats  = localStats(:,1);
          localStats    = localStats(:,2:end);
        end
        
        nSheets     = size(localStats,2);
        nRows       = size(localMasks,2);
        nColumns    = size(localMasks,3);
        nMasks      = size(localMasks,1);
        nValues     = numel(localStats(1,1).(field));
        
        localSubs   = zeros(nSheets, nMasks, nValues, nRows, nColumns);
        localSurfs  = zeros(nSheets,nValues,nRows,nColumns);
        localSurfs  = NaN;
        
        for m = 1:nMasks
          localMask = squeeze(localMasks(m,:,:))==1;
          if(all(localMask==0))
            localSubs(:,m,:,:) = NaN;
          else
            for s = 1:nSheets+1
              if (s==1) && exists('summary')
                fieldStats = summaryStats(m).(field);
              else
                fieldStats = localStats(m,s-1).(field);
              end
              for v = 1:nValues
                localSubs(s,m,v,localMask)    = fieldStats(v);
                localSubs(s,m,v,localMask==0) = NaN;
                localSurfs(s,v,localMask) = fieldStats(v);
              end
            end
          end
        end
        
        regionSurfsData = localSurfs;
      end
      subsurf.(region).(field)  = regionSurfsData;
      surfs.(region).(field)    = localSurfs;
      Data.dataSources(surfID, regionSurfsData, true);
    end
    
  end
end
