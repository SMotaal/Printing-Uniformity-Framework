function [ output_args ] = BestFitImposition( input_args )
  %BESTFITIMPOSITION Summary of this function goes here
  %   Detailed explanation goes here
  
  cells           = 7;
  
  imposed         = 0;
  positions       = zeros(cells,4);
  
  width             = 1400
  height            = 1400
  
  cellWidthRatrio   = [1.25 1.75]
  
  height            = round(max(width./cellWidthRatrio))
  
  boxWidthRatio     = width/height
  fittingRatio      = max(boxWidthRatio./cellWidthRatrio)
  
  optimalCellRatio  = boxWidthRatio./floor(fittingRatio)
  optimalCellRatio  = optimalCellRatio (optimalCellRatio>min(cellWidthRatio))
  optimalCellRatio  = optimalCellRatio (optimalCellRatio<max(cellWidthRatio))
  optimalCellRatio  = max(optimalCellRatio)
  
  %% Best Case
  long  = max([width, height])
  short = min([width, height])
  
  % Optimal Cells
  perms = [1:cells]
  major = ceil(cells./perms)
  minor = ceil(cells./major)
  ratio = major./minor
  
  % Optimal Ratio
  
  %%
  if width > height
    ratio   = cellWidthRatio;
  else
    ratio   = 1.0/cellWidthRatio;
  end
  
  for i = 1:cells
    
  end
  
end

function imposition = impose(width, height, cells, widthRatio)
  
  %% Post Condition Constraints
  % * Total cells >= cells
  % * 
end
