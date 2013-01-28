function resetAxesLimits(obj, x, y, z, c)
  %RESETAXESLIMITS Summary of this function goes here
  %   Detailed explanation goes here
  
  try debugStamp(obj.ID, 3); catch, debugStamp(); end;
  
  threshold                     = 0.3;
  
  try
    
    %% Optimize XLim & YLim
    xLim                          = 'auto';
    yLim                          = 'auto';
    
    try
      if nargin > 1 && ~isempty(x), xLim  = x;
      else                          xLim  = [0 obj.ColumnCount]; end
    end
    
    try
      if nargin > 2 && ~isempty(y), yLim  = y;
      else                          yLim  = [0 obj.RowCount]; end
    end
    
    obj.XLim                      = xLim;
    obj.YLim                      = yLim;
    
    
    %% Optimize ZLim & CLim
    zLim                          = 'auto';
    cLim                          = 'auto';
    
    try
      if nargin > 3 && ~isempty(z)
        zLim = z;
      else
        setData                   = obj.SetData;
        
        zData                     = [setData.data(:).zData];
        zMean                     = nanmean(zData);
        zStd                      = nanstd(zData,1);
        zSigma                    = [-threshold +threshold] * zStd;
        
        
        zMedian                   = round(zMean*2)/2;
        zRange                    = [-threshold +threshold];
        zLim                      = zMedian + zRange;
      end
    end
    
    try
      if nargin > 4 && ~isempty(c)
        cLim                      = c;
      else
        cLim                      = zLim;
      end
    end
    
    obj.ZLim                      = zLim;
    obj.CLim                      = [min(cLim) max(cLim)];
    
  catch err
    debugStamp(err, 1, obj);
  end
  
  obj.AspectRatio                 = [10 10 threshold/2];
  
  obj.notify('PlotAxesChange');
  
end
