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

