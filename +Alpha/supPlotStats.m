function [ plotStats ] = supPlotStats( plotData, supData, plotStats )
%SUPSTATS returns stats struct for sup plot data (SRCV)
%   Returns statistics structure for interpolated plot data matrix. Plot
%   data matrix must 4-D in SRCV order (sheet, row, column, value).

%regionROI(11,22,6,6)
%return;

% if ~exist('plotSet','var')
  plotSets = fieldnames(plotData);
  plotSet = plotSets{1};
% end

% if ~exist('rowPitch', 'var')
  rowPitch = supData.rowPitch;
% end

% if ~exist('columnPitch', 'var')
  columnPitch = supData.columnPitch;
% end

sheets = numel(plotData);
sheetSize = size(plotData(1).(plotSet));
rows = sheetSize(2);
columns = sheetSize(1);

plotMatrix = zeros(sheets, rows, columns);
for i = 1:numel(plotData)
  plotMatrix(i,:,:) = plotData(i).(plotSet)';%getfield(plotData,[], plotSet);
end

% if ~exist('plotStats','var')
plotStats = struct('sheets', sheets, 'rows', rows, 'columns', columns);
% end

% if ~exist('plotStats.metrics','var')
metrics = plotMetrics(rows, columns, rowPitch, columnPitch, sheets);
% end

%% Sample Statistics
runMean = nanmean(plotMatrix(:));
runStd  = nanstd(plotMatrix(:));
runLimits = runMean + [-runStd*3  +runStd*3];

plotStats.rawData = plotMatrix;
plotStats.rawStats.Mean = runMean;
plotStats.rawStats.Std  = runStd;
plotStats.rawStats.Limits = runLimits;


%% Statistical Outlier Elimintation

sampleData = plotMatrix;
sampleData(sampleData<runLimits(1)) = NaN;
sampleData(sampleData>runLimits(2)) = NaN;

sampleMean = nanmean(sampleData(:));
sampleStd  = nanstd(sampleData(:));
sampleLimits = sampleMean + [-sampleStd*3 +sampleStd*3];

plotStats.sampleData = sampleData;
plotStats.sampleStats.Mean = sampleMean;
plotStats.sampleStats.Std  = sampleStd;
plotStats.sampleStats.Limits = sampleLimits;



%% Patch Stats
% Stats for each patch across all sheets. Patches are the set of all
% patches for a given measurable characteristic, for instance, the L*
% values for each solid patch across all prints, or, the L* values for each
% 50% patch across all prints.

%% Sheet Stats
% Stats for all patches in every sheet across all sheets. Sheets are the
% set of all sheets, and each sheet is a summary of all the patches in the
% sheet.

plotStats.sheetMasks(1,:,:) = [ones(rows, columns)];
[stats summary] = localStats(plotStats.sampleData, plotStats.sheetMasks, plotStats.sampleStats);
plotStats.sheetStats = stats;
plotStats.sheetSummary = summary;

% surfData(stats, field, masks, metrics, summary)
plotStats.sheetSurfs = surfData(stats, [], plotStats.sheetMasks, metrics, summary);

%% Localized Stats
% Stats for arbitrary group of patches across all sheets. Locations are
% defined as all the patches that are within specific ROIs across all
% prints. Specific ROIs may be arbitrarily predefined. Systemic ROIs may be
% determined based on some patterns idenfied through other stats, like
% patch, sheet, region... etc. All subdivions are generally localized
% areas which are determined by specific rules.

[roiMasks metrics] = regionROI(metrics);

regionMasks = roiMasks.regionMasks;
bandMasks = roiMasks.bandMasks;
circumferentialMasks = roiMasks.circumferentialMasks;
axialMasks = roiMasks.axialMasks;

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
% plotStats.regionStats = localStats(plotStats.sampleData, plotStats.regionMasks, plotStats.sampleStats);
[stats summary] = localStats(plotStats.sampleData, plotStats.regionMasks, plotStats.sampleStats);
plotStats.regionStats = stats;
plotStats.regionSummary = summary;

% plotStats.regionSurfs = surfData(plotStats.regionStats, [], plotStats.regionMasks, metrics);
plotStats.regionSurfs = surfData(stats, [], plotStats.regionMasks, metrics, summary);

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
% plotStats.bandStats = localStats(plotStats.sampleData, plotStats.bandMasks, plotStats.sampleStats);
[stats summary] = localStats(plotStats.sampleData, plotStats.bandMasks, plotStats.sampleStats);
plotStats.bandStats = stats;
plotStats.bandSummary = summary;
% plotStats.bandSurfs = surfData(plotStats.bandStats, [], plotStats.bandMasks, metrics);
plotStats.bandSurfs = surfData(stats, [], plotStats.bandMasks, metrics, summary);

plotStats.circumferentialMasks = circumferentialMasks;
% plotStats.circumferentialStats = localStats(plotStats.sampleData, plotStats.circumferentialMasks, plotStats.sampleStats);
[stats summary] = localStats(plotStats.sampleData, plotStats.circumferentialMasks, plotStats.sampleStats);
plotStats.circumferentialStats = stats;
plotStats.circumferentialSummary = summary;
% plotStats.circumferentialSurfs = surfData(plotStats.circumferentialStats, [], plotStats.circumferentialMasks, metrics);
plotStats.circumferentialSurfs = surfData(stats, [], plotStats.circumferentialMasks, metrics, summary);

plotStats.axialMasks = axialMasks;
% plotStats.axialStats = localStats(plotStats.sampleData, plotStats.axialMasks, plotStats.sampleStats);
[stats summary] = localStats(plotStats.sampleData, plotStats.axialMasks, plotStats.sampleStats);
plotStats.axialStats = stats;
plotStats.axialSummary = summary;
% plotStats.axialSurfs = surfData(plotStats.axialStats, [], plotStats.axialMasks, metrics);
plotStats.axialSurfs = surfData(stats, [], plotStats.axialMasks, metrics, summary);

%% Zone Stats
% Stats for all patches in every sheet across all sheets. Zones are the set
% of all zones across the print area, and each zone is all the patches in a
% distinctly controllable area denoted the zone identifier. Zones are
% commonly found in lithography, where ink keys are used to control the
% ink within axial bands. Zones are predetermined and are optimized for in
% the design of the test form. Zone alignemnt validity is assumed.
% try
try
  metrics.inkZones = supData.inkZones;
  
  plotStats.zoneMasks = zoneROI(metrics);
  %   plotStats.zoneStats = localStats(plotStats.sampleData, plotStats.zoneMasks, plotStats.sampleStats);
  [stats summary] = localStats(plotStats.sampleData, plotStats.zoneMasks, plotStats.sampleStats);
  plotStats.zoneStats = stats;
  plotStats.zoneSummary = summary;
  %   plotStats.zoneSurfs = surfData(plotStats.zoneStats, [], plotStats.zoneMasks, metrics);
  plotStats.zoneSurfs = surfData(stats, [], plotStats.zoneMasks, metrics, summary);
  
  plotStats.zoneBandMasks = zoneROI(metrics, 3);
  %   plotStats.zoneBandStats = localStats(plotStats.sampleData, plotStats.zoneBandMasks, plotStats.sampleStats);
  [stats summary] = localStats(plotStats.sampleData, plotStats.zoneBandMasks, plotStats.sampleStats);
  plotStats.zoneBandStats = stats;
  plotStats.zoneBandSummary = summary;
  %   plotStats.zoneBandSurfs = surfData(plotStats.zoneBandStats, [], plotStats.zoneBandMasks, metrics);
  plotStats.zoneBandSurfs = surfData(stats, [], plotStats.zoneBandMasks, metrics, summary);
catch err
  %     disp(err);
end
% end

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

function [surfs] = surfData(stats, field, masks, metrics, summary)

if (isempty(field))
  fields = fieldnames(stats);
  for f = 5:numel(fields)
    field = char(fields(f));
    surfs.(field) = surfData(stats, field, masks, metrics, summary);
  end
  
else
  sheets = metrics.sheets;
  rows = size(masks,2);
  columns = size(masks,3);
  frames = size(masks,1);
  nanMask = zeros(rows,columns);
  
  plotValues = zeros(sheets, frames, rows, columns);
  
  
  
  
  for m = 1:frames
    for s = 1:sheets+1
      
      if (s==sheets+1)
        if exists('summary')
          mStats = summary(m);
          fieldStats = mStats.(field);
        else
          continue;
        end
      else
        mStats = stats(m);
        fieldStats = mStats.(field);
        fieldStats = fieldStats(s,1);        
      end
            
      if (m==1 && s==1)
        nanMask = ~squeeze(mStats(m).DataMask(s,:,:));
      end
      
      mask = squeeze(masks(m,:,:))==1;
      
      if(all(mask==0))
        plotValues(s,m,:,:) = NaN;
      else
        try
          statValues = fieldStats;
        catch err
          try debugStamp(err, 1); catch, debugStamp(); end;
          continue;
        end
        plotValues(s,m,mask) = statValues;
        plotValues(s,m,mask==0) = NaN;
        %         plotValues(s,m,nanMask) = NaN;
      end
    end
  end
  %   surfs.Summary = squeeze(mean(plotValues,1));
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
  sheetData = squeeze(plotData(sheet,:,:));
  regionData = sheetData(index);
  try
    data(sheet, :) = regionData(:);
  catch err
    try debugStamp(err, 1); catch, debugStamp(); end;
    continue;
  end
end

end

function [index] = length2index(length, pitch)
index = round(length./pitch);
end

function [length] = index2length(index, pitch)
length = round(index.*pitch);
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

function [zoneMasks] = zoneROI (metrics, bands) %, inkZones)

rows = metrics.rows;
columns = metrics.columns;

if ~exist('bands', 'var')
  bands = 1;
elseif (bands>1)
  length = metrics.length;
  pitch = metrics.rowPitch;
  zoneBands = bandMetrics(length, bands, pitch);
end

inkZones = metrics.inkZones;

pressZones = inkZones.range;
patchZones = inkZones.targetrange;
zoneRange = [ setdiff(pressZones(:),patchZones(:))' ...
  intersect(pressZones(:),patchZones(:))'];

zoneRange = reshape(patchZones',1,[]);

zoneWidth = inkZones.patches;
zoneShift = -min(inkZones.targetrange(:));

masks = numel(zoneRange.*bands);
zoneMasks = zeros(masks,rows, columns);

for z = 1:numel(zoneRange)
  zone = zoneRange(z);
  zoneLeft  = zoneWidth * (zone+zoneShift);
  c1 = zoneLeft + 1;
  c2 = zoneLeft + zoneWidth;
  
  if (bands==1)
    zoneMask = rectROI(rows, columns, [], [], c1, c2);
    zoneMasks(z,:,:) = zoneMask;
  elseif (bands > 1)
    for band = 1:bands
      r1 = zoneBands.Steps(band);
      r2 = zoneBands.Steps(band+1);
      zoneMask = rectROI(rows, columns, r1, r2, c1,c2);
      bandZone = ((band-1)*numel(zoneRange))+z;
      zoneMasks(bandZone,:,:) = zoneMask;
    end
  end
end

end

function [masks, metrics] = regionROI (metrics)

rows = metrics.rows;
columns = metrics.columns;
rowPitch = metrics.rowPitch;
columnPitch = metrics.columnPitch;
length = metrics.length;
width = metrics.width;
printArea = metrics.printArea;
pitch = metrics.pitch;
division = 3;

[principal, shortSide] = min(printArea);

longSide = 2-(shortSide~=1);

minor = bandMetrics(principal, division, pitch(shortSide));
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

circumferentialMasks = zeros(long.Bands, rows, columns);
axialMasks = zeros(wide.Bands, rows, columns);

for longStep = 1:long.Bands
  r1 = long.Steps(longStep);
  r2 = long.Steps(longStep+1);
  bandMask = rectROI(rows, columns, r1, r2, [], []);
  bandMasks(longStep,:,:) = bandMask;
  
  circumferentialMasks(longStep, :, :) = bandMask;
end

for wideStep = 1:wide.Bands
  c1 = wide.Steps(wideStep);
  c2 = wide.Steps(wideStep+1);
  bandMask = rectROI(rows, columns, [], [], c1, c2);
  bandMasks(long.Bands + wideStep,:,:) = bandMask;
  
  axialMasks (wideStep,:,:) = bandMask;
end

long.Bands = long.Bands-1;

masks.regionMasks = regionMasks;
masks.bandMasks = bandMasks;
masks.circumferentialMasks = circumferentialMasks;
masks.axialMasks = axialMasks;

end

function [mask] = rectROI (rows, columns, startRow, endRow, startColumn, endColumn)

if (~exist('rows','var') || isempty(rows) || ~exist('columns','var') || isempty(columns))
  mask = [];
  return
end

if (~exist('startRow','var') || isempty(startRow))
  startRow = 1;
end

if (~exist('startColumn','var') || isempty(startColumn))
  startColumn = 1;
end

if (~exist('endRow','var') || isempty(endRow))
  endRow = rows;
end

if (~exist('endColumn','var')  || isempty(endColumn))
  endColumn = columns;
end

mask = zeros(rows, columns);

try
  
  mask(startRow:endRow, startColumn:endColumn) = 1;
catch err
  try debugStamp(err, 1); catch, debugStamp(); end;
  return;
end

end

function [Stats Summary] = localStats(plotData, localMasks, sampleStats)

numMasks = size(localMasks,1);
nanMask = isnan(plotData(1,:));

Stats(1:numMasks) = struct;
Summary(1:numMasks) = struct;

if exists('sampleStats')
  runMean = sampleStats.Mean;
  runStd = sampleStats.Std;
  runLimits =  sampleStats.Limits;
else
  runMean = nanmean(plotData(:));
  runStd  = nanstd(plotData(:));
  runLimits = runMean + [-runStd*3 runStd*3];
end

for i = 1:numMasks
  
  localMask = squeeze(localMasks(i,:,:));
  localData = roiData(plotData, localMask);
  
  Stats(i).Mask = localMask;
  Stats(i).Data = localData;
  Stats(i).DataMask = ~nanMask;
  Stats(i).NaN = [];
  
  Stats(i).Mean = nanmean(localData,2);
  Stats(i).Std  = nanstd(localData,0,2);
  
  Stats(i).UpperLimit = Stats(i).Mean + Stats(i).Std.*3;
  Stats(i).LowerLimit = Stats(i).Mean - Stats(i).Std.*3;
  Stats(i).DeltaLimit = Stats(i).UpperLimit - Stats(i).LowerLimit;
  
  Stats(i).RelativeMean = nanmean(localData,2)-runMean;
  Stats(i).RelativeUpperLimit = Stats(i).UpperLimit-runMean;
  Stats(i).RelativeLowerLimit = Stats(i).LowerLimit-runMean;
  
  peakMask = abs(Stats(i).RelativeUpperLimit)<abs(Stats(i).RelativeLowerLimit);
  Stats(i).RelativePeakLimit = Stats(i).RelativeUpperLimit;
  Stats(i).RelativePeakLimit(peakMask) = Stats(i).RelativeLowerLimit(peakMask);
  
  Stats(i).NaN  = isnan(Stats(i).Mean);
  
  
  
  Summary(i).Mask     = Stats(i).Mask ;
  Summary(i).Data     = Stats(i).Data;
  Summary(i).DataMask = Stats(i).DataMask;
  Summary(i).NaN = Stats(i).NaN;
  
  Summary(i).Mean = nanmean(localData(:));
  Summary(i).Std = nanstd(localData(:));
  
  Summary(i).UpperLimit = Summary(i).Mean + Summary(i).Std.*3;
  Summary(i).LowerLimit = Summary(i).Mean - Summary(i).Std.*3;
  Summary(i).DeltaLimit = Summary(i).UpperLimit - Summary(i).LowerLimit;
  
  Summary(i).RelativeMean = nanmean(localData(:))-runMean;
  Summary(i).RelativeUpperLimit = Summary(i).UpperLimit-runMean;
  Summary(i).RelativeLowerLimit = Summary(i).LowerLimit-runMean;
  
  peakMask = (abs(Summary(i).RelativeUpperLimit)<abs(Summary(i).RelativeLowerLimit));
  Summary(i).RelativePeakLimit = Summary(i).RelativeUpperLimit;
  Summary(i).RelativePeakLimit(peakMask) = Summary(i).RelativeLowerLimit(peakMask);
  
end

end
