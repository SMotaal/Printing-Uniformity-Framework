function [ surfs ] = supMergeSurfs( statPlots, statMasks, field )
%SUPMERGESURFS Merges stats surfs creating data / label timeseries array

%% Extract field data & masks
data      = statPlots.(field).Values;           % SMRC Order

%% Sort data
data      = permute(data, [2 1 3 4]);           % SMRC>MSRC Order

%% Determine data volumes
nSheets   = size(data,2);
nMasks    = size(data,1);
nRows     = size(data,3);
nColumns  = size(data,4);

%% Prepare output arrays
% (SRCM Order: Sheet, Row, Column, Mask)

zData         = zeros(nSheets, nRows, nColumns);  % Sheet/Surf data

regionMean    = zeros(nMasks, nSheets);           % Sheet/Mask mean data
regionStDev   = zeros(nMasks, nSheets);           % Sheet/Mask stdev data

regionCentres = zeros(nMasks,2);                  % Mask X/Y coordinates
regionAreas   = zeros(nMasks,2);                  % Mask W/H dimensions

% summaryData   = zeros(nRows, nColumns, nMasks);   % Summary/Mask data
% patchData     = zeros(nSheets, nRows, nColumns);  % Sheet/Patch data


dataMean      = nanmean(data(:));
dataStDev     = nanstd(data(:));
dataLimit     = dataStDev.*3;
dataRange     = [dataMean-dataLimit dataMean+dataLimit];

zData(:)      = NaN;

for m = 1:nMasks
  maskedData          = squeeze(data(m, :, :, :));         % MSRC Order
  dataIndex           = ~isnan(maskedData);
  zData(dataIndex)    = maskedData(dataIndex);        
  
  for s = 1:nSheets
    if (size(maskedData,1)==1)    
      regionData        = maskedData(s);
    else
      regionData        = maskedData(s,:,:);
    end
    regionMean(m,s)   = nanmean(regionData(:));
    regionStDev(m,s)  = nanstd(regionData(:));
  end
  
%   summaryData(:,:,m)  = nanmean(maskedData,1);
  
  regionMask          = squeeze(statMasks(m,:,:));
  [mY1 mX1]           = ind2sub(size(regionMask),find(regionMask==1, 1, 'first'));
  [mY2 mX2]           = ind2sub(size(regionMask),find(regionMask==1, 1, 'last'));
  try
    regionAreas(m,1)    = abs(mX1-mX2);
    regionAreas(m,2)    = abs(mY1-mY2);
    regionCentres(m,1)  = min(mX1,mX2) + round(regionAreas(m,1)/2.0);
    regionCentres(m,2)  = min(mY1,mY2) + round(regionAreas(m,2)/2.0);
  end
  
end

surfs.fieldName     = field;

surfs.sheets        = nSheets;
surfs.masks         = nMasks;
surfs.rows          = nRows;
surfs.columns       = nColumns;

surfs.data          = permute(zData,[2 3 1]);     % RCS
surfs.dataMean      = dataMean;                   % double
surfs.dataStDev     = dataStDev;                  % double
surfs.dataLimit     = dataLimit;                  % double
surfs.dataRange     = dataRange;                  % double

surfs.regionMean    = regionMean;                 % MS
surfs.regionStDev   = regionStDev;                % MS
surfs.regionCentres = regionCentres;              % MX/Y
surfs.regionAreas   = regionAreas;                % MW/H
surfs.regionMasks   = permute(statMasks, [2 3 1]);% RCM

% surfs.summaryData   = summaryData;
% surfs.patchData     = patchData;


end

