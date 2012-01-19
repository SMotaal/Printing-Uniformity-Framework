function [ plotStats ] = supPlotStats( plotData, plotSet, rowPitch, columnPitch )
%SUPSTATS returns stats struct for sup plot data (SRCV)
%   Returns statistics structure for interpolated plot data matrix. Plot
%   data matrix must 4-D in SRCV order (sheet, row, column, value).

%regionROI(11,22,6,6)
%return;

if ~exist('plotSet','var')
  plotSets = fieldnames(plotData);
  plotSet = plotSets{1};
end

if ~exist('rowPitch', 'var')
  rowPitch = 6;
end

if ~exist('columnPitch', 'var')
  columnPitch = rowPitch;
end

sheets = numel(plotData);
sheetSize = size(plotData(1).(plotSet));
rows = sheetSize(2);
columns = sheetSize(1);

plotMatrix = zeros(sheets, rows, columns);
for i = 1:numel(plotData)
  plotMatrix(i,:,:) = plotData(i).(plotSet)';%getfield(plotData,[], plotSet);
end


plotStats = struct('sheets', sheets, 'rows', rows, 'columns', columns);

metrics = plotMetrics(rows, columns, rowPitch, columnPitch, sheets);

%% Patch Stats
% Stats for each patch across all sheets. Patches are the set of all
% patches for a given measurable characteristic, for instance, the L*
% values for each solid patch across all prints, or, the L* values for each
% 50% patch across all prints.

%% Sheet Stats
% Stats for all patches in every sheet across all sheets. Sheets are the
% set of all sheets, and each sheet is a summary of all the patches in the
% sheet.

% plotStats.sheetMasks(1,:,:) = [ones(rows, columns)];
% plotStats.sheetStats = localStats(plotMatrix, plotStats.sheetMasks);

%% Localized Stats
% Stats for arbitrary group of patches across all sheets. Locations are
% defined as all the patches that are within specific ROIs across all
% prints. Specific ROIs may be arbitrarily predefined. Systemic ROIs may be
% determined based on some patterns idenfied through other stats, like
% patch, sheet, region... etc. All subdivions are generally localized
% areas which are determined by specific rules.

[regionMasks bandMasks metrics] = regionROI(metrics);
plotStats.metrics = metrics;

%% Region Stats
% Stats for all patches in every sheet across all sheets. Regions are the
% set of all regions, and each region all the patches within a grid-cell of
% the print area. Cells are equally divided subsections of predefined
% grid. To accomodate various print areas, the principal cell side length
% is determined based on 1/3 of the length of the shorter dimension of the
% print area. There are three equal subdivisions on the principal
% direction, for instance, 3 divisions in the circumferential direction of
% a wide-web press. The alternative dimension is divided equally based on
% the principal lenth. The alternative length is thus the length of the
% longer dimension of the print area divided by the optimal number of cells
% and the optimal number of cells is the rounded number obtained by
% dividing the longer dimension by the principal length.

plotStats.regionMasks = regionMasks;
plotStats.regionStats = localStats(plotMatrix, plotStats.regionMasks);

plotStats.regionSurfs = surfData(plotStats.regionStats, [], plotStats.regionMasks, metrics);

% regionMeans = zeros(size(regionMasks,1),sheets);
% regionMeansPlot = zeros(sheets, rows, columns);
% 
% for s = 1:sheets
%   for m = 1:size(regionMasks,1)
%     regionMask = squeeze(regionMasks(m,:,:))==1;
%     
%     regionMean = plotStats.regionStats(1,m).Mean(s,1)
%     %     sheetValues = regionMask.*regionMean;
%     regionValues = squeeze(regionMeansPlot(s,:,:));
%     %     regionValues = regionValues + regionMask.*regionMean;
%     %     regionIndex = ==1;
%     regionValues(regionMask) = regionMean; %sheetValues(regionMask)+m;
%     regionMeansPlot(s,:,:) = regionValues(:,:); %(regionValues>0);
%   end
% end
% plotStats.regionMeanPlot = squeeze(mean(regionMeansPlot,1));
% plotStats.regionMeansPlot = regionMeansPlot;


%% Band Stats
% Stats for all patches in every sheet across all sheets. Bands are
% subdivisons along the circumferential or axial dimensions at equal
% intervals. Regional Bands are bands in either direction that summarize
% the stats within all the regions for each band. It's a bit
% tricky to remain consistent defining specific bands, but the rule is that
% a band is the summary of it's subdisions, and bands in one direction are
% subdivided in the perpendicular direction. For example,
% circumferential region band stats are the summary of each of the axial
% regions in each of the circumferential regions over all prints.

plotStats.bandMasks = bandMasks;
plotStats.bandStats = localStats(plotMatrix, plotStats.bandMasks);

plotStats.bandSurfs = surfData(plotStats.bandStats, [], plotStats.bandMasks, metrics);

%% Zone Stats
% Stats for all patches in every sheet across all sheets. Zones are the set
% of all zones across the print area, and each zone is all the patches in a
% distinctly controllable area denoted the zone identifier. Zones are
% commonly found in lithography, where ink keys are used to control the
% ink within axial bands. Zones are predetermined and are optimized for in
% the design of the test form. Zone alignemnt validity is assumed.


%% Page Stats
% Stats for patches within a page area across all sheets. Pages are the set
% of all pages across the print area, and each page is all the patches in
% an 8.5x11 section denoted it's location and orientation. Orientation is
% relative to the printing direction. Locations are logical positions over
% the print area, for instance, 2-up portrait pages at the center of the
% print area, or, 1-up portrait page at the leading-left corner. Print
% areas are specific to each press and as such, a one size fits all does
% not apply. Locations are defined relative to optimal imopsition for the
% print area.

end

% function [data] = UpperLimit(data, multiplier)
% if (~exist('multiplier','var')
%   multiplier=3;
% end
% 
% mean
% 
% end

function [surfs] = surfData(stats, field, masks, metrics)

if (isempty(field))
  fields = fieldnames(stats);
  for f = 4:numel(fields)
    field = char(fields(f));
    surfs.(field) = surfData(stats, field, masks, metrics);
  end
  
else
sheets = metrics.sheets; % numel(fieldStats(:,1));
rows = size(masks,2);
columns = size(masks,3);
frames = size(masks,1);
nanMask = zeros(rows,columns);

plotValues = zeros(sheets, frames, rows, columns);
  
%   size(plotValues)
for m = 1:frames
  fieldStats = stats(m).(field);
  for s = 1:sheets
    
    if (m==1 && s==1)
      nanMask = ~squeeze(stats(m).DataMask(s,:,:));
    end
    
    mask = squeeze(masks(m,:,:))==1;
    
    statValues = fieldStats(s,1);
    
    setValues = squeeze(plotValues(s,m,:,:));
    
    setValues(mask) = statValues;
    setValues(mask==0) = NaN;
    
    setValues(nanMask) = NaN;
    plotValues(s,m,:,:) = setValues(:,:);
  end
end
surfs.Summary = squeeze(mean(plotValues,1));
surfs.Values = plotValues;
end
end

function [data] = roiData (plotData, roiMask)

index = roiMask==1;
data = zeros(size(plotData,1), numel(index(index==1)));

if (isempty(index))
  return;
end

for sheet = 1:size(plotData,1)
  %data(sheet,:,:) = plotData(sheet,:,:) .* roiMask;
  sheetData = squeeze(plotData(sheet,:,:));
  regionData = sheetData(index);
  if(any(isnan(regionData)))
    1;
  end
  data(sheet, :) = regionData(:);
  if(any(isnan(data(sheet, :))))
    1;
  end  
end

end

function [index] = length2index(length, pitch)
  index = round(length./pitch);
end

function [length] = index2length(index, pitch)
  mm = round(index.*pitch);
end

function [mm] = in2mm(in)
  mm = in.*25.4;
end

function [in] = mm2in(mm)
  in = mm./25.4;
end

function [metrics] = plotMetrics(rows, columns, rowPitch, columnPitch, sheets)

if (exist('sheets','var'))
  metrics.sheets = sheets;
end

  metrics.rows = rows;
  metrics.columns = columns;
  metrics.rowPitch = rowPitch;
  metrics.columnPitch = columnPitch;

  metrics.length = (metrics.rows-1)*metrics.rowPitch;
  metrics.width = (metrics.columns-1)*metrics.columnPitch;

  metrics.printArea = [metrics.length metrics.width];
  metrics.pitch = [metrics.rowPitch, metrics.columnPitch];
end

function [band] = bandMetrics(Length, Bands, Pitch)
band.FullLength = Length;
band.Bands  = Bands; %round(Length / Bands);
band.BandLength = Length / Bands;
band.Pitch = Pitch;
band.Steps = 1+[length2index([0:band.Bands].*band.BandLength, band.Pitch)];
end

function [regionMasks, bandMasks, metrics] = regionROI (metrics) %rows, columns, rowPitch, columnPitch)

rows = metrics.rows;
columns = metrics.columns;
rowPitch = metrics.rowPitch;
columnPitch = metrics.columnPitch;
length = metrics.length;
width = metrics.width;
printArea = metrics.printArea;
pitch = metrics.pitch;

[principal, shortSide] = min(printArea);

longSide = 2-(shortSide~=1);

minor = bandMetrics(principal, 3, pitch(shortSide));
majorBands = round(printArea(longSide) / minor.BandLength);
majorBands = majorBands + (1 - rem(majorBands,2));  % Ensure odd bands
major = bandMetrics(printArea(longSide), majorBands, pitch(longSide));

if (shortSide==1) % Portrait
  long = minor; wide = major;
elseif (shortSide==2) % Landscape
  long = major; wide = minor;
end

metrics.longSide = longSide;
metrics.shortSide = shortSide;
metrics.orientation = (width>length);
metrics.long = long;
metrics.wide = wide;

regionMasks = zeros(long.Bands * wide.Bands, rows, columns);

for longStep = 1:long.Bands
  r1 = long.Steps(longStep);
  r2 = long.Steps(longStep+1);  
  for wideStep = 1:wide.Bands
    mi = ((wideStep-1)*long.Bands) + longStep;
    c1 = wide.Steps(wideStep);
    c2 = wide.Steps(wideStep+1);
    regionMask = rectROI(rows, columns, r1, r2, c1, c2);
    regionMasks(mi, :, : ) = regionMask;
  end
end

bandMasks = zeros(long.Bands + wide.Bands, rows, columns);

for longStep = 1:long.Bands
  r1 = long.Steps(longStep);
  r2 = long.Steps(longStep+1);    
  bandMask = rectROI(rows, columns, r1, r2, min(wide.Steps), max(wide.Steps));
  bandMasks(longStep,:,:) = bandMask;
end

for wideStep = 1:wide.Bands
  c1 = wide.Steps(wideStep);
  c2 = wide.Steps(wideStep+1);
  bandMask = rectROI(rows, columns, min(long.Steps), max(long.Steps), c1, c2);
  bandMasks(long.Bands + wideStep,:,:) = bandMask;
end

long.Bands = long.Bands-1;

return;

end

function [mask] = rectROI (rows, columns, startRow, endRow, startColumn, endColumn)

mask = zeros(rows, columns);

mask(startRow:endRow, startColumn:endColumn) = 1;
  
end

function [Stats] = localStats(plotData, localMasks)

% numMasks = numel(localMasks);
numMasks = size(localMasks,1);

Stats(1:numMasks) = struct;

for i = 1:numMasks
  
  localMask = squeeze(localMasks(i,:,:));
  localData = roiData(plotData, localMask);
  
  Stats(i).Mask = localMask;
  Stats(i).Data = localData;
  Stats(i).DataMask = ~isnan(plotData);
  
  Stats(i).Min  = nanmin(localData,[],2);
  Stats(i).Max  = nanmax(localData,[],2);
  Stats(i).Mean = nanmean(localData,2);
  Stats(i).Std  = nanstd(localData,0,2);
  Stats(i).UpperLimit = Stats(i).Mean + Stats(i).Std.*3; %nanmean(localData,2)+(nanstd(localData,0,2).*3);
  Stats(i).LowerLimit = Stats(i).Mean - Stats(i).Std.*3;%nanmean(localData,2)-(std(localData,0,2).*3);
  Stats(i).DeltaLimit = Stats(i).UpperLimit - Stats(i).LowerLimit;
  
  
%   nanMask = ~Stats(i).DataMask(:);
% %   nanSum = sum(nanMask(:));
%  
%   
%   Stats(i).Min(nanMask) = NaN;
%   Stats(i).Max(nanMask) = NaN;
%   Stats(i).Mean(nanMask) = NaN;
%   Stats(i).Std(nanMask) = NaN;
%   Stats(i).UpperLimit(nanMask) = NaN;
%   Stats(i).LowerLimit(nanMask) = NaN;
%   Stats(i).DeltaLimit(nanMask) = NaN;
  
  
  
end

end
