function metrics = getRegionMetrics(obj, metricsTable, roiData, roiRows, roiColumns)
  
  if ~exist('roiRows', 'var')     || ~isscalar(roiRows),    roiRows     = 1; end
  if ~exist('roiColumns', 'var')  || ~isscalar(roiColumns), roiColumns  = 1; end
    
  metricsCount                  = size(metricsTable, 1);
  
  roiCount                      = roiRows*roiColumns;
  
  isRegionData                  = isfield(roiData, 'Sheet'); %  && roiCount>1;  

  if isRegionData
    sheetCount                  = 1;
    try sheetCount              = numel(roiData(1).Sheet);  end
  else
    sheetCount                  = numel(roiData);
  end
  
  tableSize                     = [roiRows roiColumns sheetCount];
  metrics                       = containers.Map();
  
  for m = 1:metricsCount
    
    metricID                    = metricsTable{m, 2};
    metricField                 = metricsTable{m, 1};
    metricModel                 = metricsTable{m, 3};
    
    if iscell(metricField)
      metricComponents          = numel(metricField);      
    else
      metricField               = {metricField};
      metricComponents          = 1;
    end
    
    sheetValues                 = cell(tableSize); %NaN([tableSize metricComponents]);
    regionValues                = cell(tableSize(1:2));
    
    allSheetNaN                 = true;
    
    for n = 1:roiCount
      r                         = 1;
      try r                     = roiData(n).Position.Around; end
      
      c                         = 1;
      try c                     = roiData(n).Position.Across; end
      
      s                         = 0;
      
      if isRegionData
        sheets                  = roiData(n).Sheet(:);
      else
        sheets                  = roiData;
      end
      
      for s = 1:numel(sheets)
        sheetValues{r, c, s}    = NaN(1, metricComponents);
        for v = 1:metricComponents
          try sheetValues{r, c, s}(v)  = eval(['sheets(s).' metricField{v}]); end
          allSheetNaN           = allSheetNaN && any(isnan(sheetValues{r, c, s}));
        end
      end
            
      if isRegionData
        regionValues{r, c, 1}   = NaN(1, metricComponents);
        for v = 1:metricComponents
          try regionValues{r, c, 1}(v)  = eval(['roiData(n).' metricField{v}]); end
        end
      end
    end
    
    metricValues                = {};
    
    %% Ignoring Sheets
    if ~allSheetNaN, metricValues = cat(3,metricValues, sheetValues);   end
    if isRegionData, metricValues = cat(3,metricValues, regionValues);  end
    
    if ~isempty(metricModel)
      metrics(metricID)         = feval(['PrintUniformityBeta.Models.Metrics.' metricModel],  metricValues);
    else
      metricModel               = feval('PrintUniformityBeta.Models.Metrics.MetricModel',     metricValues);
      metricModel.ID            = regexprep(metricID, '\s', '');
      metricModel.Name          = metricID;      
      metrics(metricID)         = metricModel;
      
      % shortFormat               = {};
      % try shortFormat           = reshape(cellfun(@num2str, metricValues, 'UniformOutput', false), size(metricValues)); end
      %
      % longFormat                = shortFormat;
      %
      % metrics(metricID)         = struct( ...
      %   'ID',           regexprep(metricID, '\s', ''), ...
      %   'Values',       {metricValues}, ...
      %   'ShortFormat',  {shortFormat}, ...
      %   'LongFormat',   {longFormat});
    end
    
  end

end
