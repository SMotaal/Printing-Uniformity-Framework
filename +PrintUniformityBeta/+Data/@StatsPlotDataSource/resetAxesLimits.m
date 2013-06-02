function resetAxesLimits(obj, x, y, z, c)
  %RESETAXESLIMITS Summary of this function goes here
  %   Detailed explanation goes here
  
  try debugStamp(obj.ID, 3); catch, debugStamp(); end;
  
  means                           = obj.Reader.getSheetData(0);
  threshold                       = 0.15;
  stdThreshold                    = 0;
  
  caseData                        = obj.CaseData;
  setData                         = obj.SetData;
  
  try
    
    %% Optimize XLim & YLim
    xLim                          = 'auto';
    yLim                          = 'auto';
    
    try
      if nargin > 1 && ~isempty(x), xLim  = x;
      else                          xLim  = [0 size(caseData.Masks.Region, 3)]; end
    end
    
    try
      if nargin > 2 && ~isempty(y), yLim  = y;
      else                          yLim  = [0 size(caseData.Masks.Region, 2)]; end
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
        % zLim = [-1 1];
        % setData                   = obj.SetData;
        %
        % zData                     = means; %[setData.data(:).zData];
        % zMean                     = nanmean(zData(:));
        % zStd                      = nanstd(zData,1);
        % zSigma                    = [-threshold +threshold] * zStd;
        %
        %
        % zMedian                   = round(zMean*20)/20;
        % zRange                    = [-threshold +threshold];
        % zLim                      = zMedian + zRange;
      end
    end
    
    try
      if nargin > 4 && ~isempty(c)
        cLim                      = c;
      else
        % cLim                      = zLim;
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
