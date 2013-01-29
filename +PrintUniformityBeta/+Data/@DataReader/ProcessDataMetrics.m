function [ dataSource ] = ProcessDataMetrics( dataSource )
  %GENERATEUPMETRICS generate metrics for printing uniformity plots
  %   Using metrics extracted from the dataSource metrics cartesian metrics
  %   are constructed defining the metric boundaries of the sampled target
  %   area, press sheet, press (printing) plane, and, sometimes, ink zones.
  %   Metrics are separate from sparse index and other dataSource positioning
  %   attributes. They only describe the physical positioning aspects as
  %   length values, target steps, or impression number.
  %
  %   *PRESS METRICS*
  %   The press plane is defined as the maximum printing area of a press in
  %   millimeters. The press plane origin is at the bottom-right, which is
  %   the operator-side lead-edge and extends to the top-left corner, which
  %   is the driver-side tail-edge of the press. Press metrics include:
  %
  %   * Width & Length (Maximum sheet size)
  %   * Offset (Physical Gripper Gap)
  %   * Image Repeate Length **Optional**
  %   * Plate Cylinder Gap  **Optional**
  %
  %
  %   *SAMPLE METRICS*
  %   The sampled target area is defined as the region encompasing all
  %   patches on a print, from the bottom-right operator-side lead-edge to
  %   the top-left driver-side tail-edge in press plane cartesian space.
  %   The target area may reflect one physical target or several imposed
  %   targets, depedning on the available sampling area and the measuring
  %   device target size constraints. Target metrics include:
  %
  %   * Sheets (sheet index)
  %   * Rows & Columns (Across all targets)
  %   * Patch Width & Height (Pitch)
  %   * Offset (lead-edge to first patch)
  %   * Shift (Axially off-center from -ve operator to +ve driver)
  %
  %  
  %   Sample metrics include:
  %
  %   * Sample index (from okay sheet)
  %   * Sample length (first-to-last sample index)
  %   * Runlength (from start to finish)
  %   * Makeready length
  %   NOTE: Sampling masks are defined relative to target area  
  %
  %
  %   *PRINT METRICS*
  %   The press sheet area reflects the metric sheet dimensions. The offset
  %   defines the designated gripper gap from an imposition standpoint and
  %   shift defines the axial off-center shift from operator to driver.
  %   Sheet metrics include:
  %
  %   * Width & Length (Actual Sheet Size)
  %   * Offset (Imposition Gripper Gap)
  %   * Shift (Axially off-center from -ve operator to +ve driver)
  %   * Basic Type & Size **Optional**
  %   * Basis Weight / Grammage **Optional**
  %
  %
  %   *ZONE METRICS* **Optional**
  %   In presses where ink zones are used, zones reflect the homogeneity of
  %   each ink zone band. Band boundaries are at the mid-point between the
  %   vertices of two adjacent zone keys. Typically, the printing width is
  %   divided by several equally spaced zones. This can be specified using
  %   the single number of zones. Zone metrics include:
  %
  %   * Zones (number)
  %   * Zone width (metric band width)
  %   * Zone range **Optional**
  %   * Zone vertices (metric center of zone band) **Optional**
  %
  %
  
  if isVerified('dataSource.metrics.SourceMetrics');
    metrics = dataSource.metrics;
  else
    metrics = pressMetrics  (dataSource);
    metrics = printMetrics  (dataSource, metrics);  
    metrics = sampleMetrics (dataSource, metrics);  
    try
      metrics = zoneMetrics (dataSource, metrics);
    catch err
%       warning('Grasppe:UniPrint:Metrics:ZoneUndefined', ...
%         'Zone metrics are not defined in dataSource and will not be generated');
    end

    metrics.SourceMetrics = dataSource.metrics;
    dataSource.metrics = metrics;
  end
  
  
end

function [metrics] = pressMetrics(dataSource, metrics)
  
  %% Width & Length (Maximum sheet size)
  metrics.pressWidth    = dataSource.metrics.pressWidth;
  metrics.pressLength   = dataSource.metrics.pressLength;
  
  %% Offset (Physical Gripper Gap)
  
  %% Image Repeate Length **Optional**
  
  %% Plate Cylinder Gap  **Optional**
  
end


function [metrics] = sampleMetrics(dataSource, metrics)
  
  %% Sample Sheets (from okay sheet)
  metrics.sampleSheets  = dataSource.index.Sheets;
    
  %% Rows & Columns (Across all targets)
  metrics.targetRows    = unique(dataSource.index.Rows);
  metrics.targetColumns = unique(dataSource.index.Columns);
   
  %% Patch Width & Height (Pitch)
  metrics.patchWidth    = dataSource.metrics.patchWidth;
  metrics.patchLength   = dataSource.metrics.patchLength;
  
  %% Sampled Area
  metrics.sampleSize    = [nanmax(metrics.targetRows(:)) nanmax(metrics.targetColumns(:))];
    
  metrics.sampleLength  = metrics.sampleSize(1).* metrics.patchLength;
  metrics.sampleWidth   = metrics.sampleSize(2).* metrics.patchWidth;
  metrics.sampleArea    = [metrics.sampleLength metrics.sampleWidth];
  
  %% Offset (lead-edge to first patch)
  metrics.targetOffset  = dataSource.metrics.targetOffset;
  
  %% Shift (Axially off-center from -ve operator to +ve driver)
  metrics.targetShift   = dataSource.metrics.targetShift;
  
%   %% Sample size (sheets)
%   metrics.sampleSize    = numel(metrics.sampleSheets); 
%   
%   %% Sample range (first-to-last sample index)
%   metrics.sampleRange   = dataSource.range.Sheets;  
  
end


function [metrics] = printMetrics(dataSource, metrics)
  %% Width & Length (Actual Sheet Size)
  metrics.printWidth    = dataSource.metrics.paperWidth;
  metrics.printLength   = dataSource.metrics.paperLength;
  
  %% Offset (Imposition Gripper Gap)
  metrics.printOffset   = dataSource.metrics.printOffset;
  
  %% Shift (Axially off-center from -ve operator to +ve driver)
  %% Basic Type & Size **Optional**
  %% Basis Weight / Grammage **Optional**
  
end

function [metrics] = zoneMetrics(dataSource, metrics)
  try
    %       inkZones                = ticket.testform.press.inkzones;
    %       dataSource.metrics.zoneRange  = inkZones.range;
    %       dataSource.metrics.zoneWidth  = inkZones.width;
    %       dataSource.metrics.zoneSteps  = inkZones.patches;
    
    %% Zones (number)
    metrics.zoneBands  = dataSource.length.PressZones;
    
    %% Zone width (metric band width)
    metrics.zoneWidth   = dataSource.metrics.zoneWidth;
    
    %% Zone Samples
    metrics.zonePatches = round(metrics.zoneWidth / metrics.patchWidth);
    
    %% Zone range **Optional**
    metrics.zoneRange   = dataSource.metrics.zoneRange;
    
    %% Zone metrics (centres / vertices) **Optional**
    if isVerified('metrics.pressWidth')
      metrics.sampleZones      = dataSource.index.SampleZones;
      metrics.zoneBandMetrics = bandMetrics(metrics.pressWidth, metrics.zoneBands, metrics.patchWidth);
      metrics.zoneCentres     = metrics.zoneBandMetrics.Centres;
      metrics.zoneVertices    = metrics.zoneBandMetrics.Vertices;
%       metrics.zoneSteps       = metrics.zoneBandMetrics.Steps;
    end
    
  catch err
    error('Grasppe:UniPrint:Metrics:ZoneUndefined', ...
      'Failed to obtain zone metrics from the dataSource source.');
  end
  
end


function [ metrics ] = bandMetrics( Length, Bands, Pitch)
  %BANDMETRICS equally dividing vertices, centers and steps
  metrics.Span      = Length;
  metrics.Bands     = Bands;
  metrics.BandWidth = (metrics.Span-1) / Bands;
  
  default Pitch NaN;
  
  if isnan(Pitch)
    metrics.Pitch   = metrics.BandWidth+1/Bands;
  else
    metrics.Pitch   = Pitch;
  end
  
  metrics.Vertices  = (0:metrics.BandWidth:metrics.Span-1)+0.5; %(0:Bands).*metrics.BandWidth;
  metrics.Centres   = midPoints(metrics.Vertices);
%   metrics.Zones     = 1+floor(metrics.Centres/metrics.Pitch);
  metrics.Steps     = round(metrics.Vertices/metrics.Pitch); %1+floor(metrics.Vertices/metrics.Pitch); % metrics.Vertices/metrics.Span*Length/Pitch%1+length2index(metrics.Vertices, metrics.Pitch);
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

function [points] = midPoints(vertices)
  % Image Analyst answered on 7 Jan 2012
  % http://www.mathworks.com/matlabcentral/answers/25536-selecting-mid-points
  points = conv(vertices, [0.5 0.5], 'valid');
end

