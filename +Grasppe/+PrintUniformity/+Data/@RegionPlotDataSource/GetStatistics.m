function stats = GetStatistics( obj, sheetID, variableID)
  %GETSTATISTICS Summary of this function goes here
  %   Detailed explanation goes here
  
  stats = [];
  
  if ~exist('sheetID',    'var'), sheetID     = []; end
  if ~exist('variableID', 'var'), variableID  = []; end
  
  if nargin>1 && ischar(sheetID)
    options = sheetID;
    while ~isempty(strtok(options))
      [token options] = strtok(options);
      switch lower(token)
        case 'reset'
          resetStatsOptions(obj);
        case 'update'
          updateStatsFunctions(obj);
      end
    end
    return;
  end
  
  if ~isnumeric(sheetID), sheetID = []; end
  
  %   updateVariableStats           = ~isempty(variableID);
  updateSheetStats              = ~isempty(sheetID); % updateVariableStats
  %
  %   if updateVariableStats
  %     resetStatsOptions(obj);
  %
  %   end
  
  if updateSheetStats
    stats = getSheetStatistics(obj, sheetID, variableID);
  end
end

function [sheetStats] = getSheetStatistics(obj, sheetID, variableID)
  
  sheetStats = struct('Data', [], 'Masks', [], 'Values', [], 'Strings', []);
  
  try
    rows    = obj.RowCount;
    columns = obj.ColumnCount;
    
    [X Y Z] = meshgrid(1:columns, 1:rows, 1);
    
    stats       = obj.Stats;
    caseID      = obj.CaseID;
    setID       = obj.SetID;
    
    %% Get Stats Functions
    
    if isempty(stats) || isempty(caseID) || isempty(setID)
      return;
    end
    
    updateStatsFunctions(obj);
    
    statsMode     = obj.CurrentStatsMode;
    statsFunction = obj.CurrentStatsFunction;
    dataFunction  = obj.CurrentDataFunction;
    labelFunction = obj.CurrentLabelFunction;
    
    varID = variableID; %'Stats';
    switch varID
      case {'sections', 'around', 'across'}
        aroundID = 'around';
        acrossID = 'across';
      otherwise
        aroundID = [varID 'Around'];
        acrossID = [varID 'Across'];
    end
    
    %% Get Region Masks
    regionMasks     = stats.metadata.regions.(varID);
    
    %% Get Region Data
    regionData      = Grasppe.Stats.DataStats.empty;
    aroundData      = Grasppe.Stats.DataStats.empty;
    acrossData      = Grasppe.Stats.DataStats.empty;
    
    for m = 1:size(stats.(varID),1)
      regionData(m) = stats.(varID)(m, sheetID).Stats;
    end
    
    runData         = stats.run.Stats;
    sheetData       = regionData(1).Data(:);
    for k=2:numel(regionData)
      sheetData = [sheetData(:); regionData(k).Data(:)];
    end
    sheetData       = Grasppe.Stats.DataStats(sheetData, runData.Mean, runData.Sigma);
    
    try
      aroundMasks = stats.metadata.regions.(aroundID);
      aroundMasks = max(aroundMasks, [], 3);
      %aroundData  = stats.(aroundID)(:, sheetID);
      
      for m = 1:size(stats.(aroundID),1)
        aroundData(m) = stats.(aroundID)(m, sheetID).Stats;
      end
      
    catch
      aroundMasks = [];
      aroundData  = [];
    end
    
    try
      acrossMasks = stats.metadata.regions.(acrossID);
      acrossMasks = max(acrossMasks, [], 2);
      %acrossData  = stats.(acrossID)(:, sheetID);
      
      for m = 1:size(stats.(acrossID),1)
        acrossData(m) = stats.(acrossID)(m, sheetID).Stats;
      end
      
    catch
      acrossMasks = [];
      acrossData  = [];
    end
    
    %% Stats Calcualtions
    
    regionStats = statsFunction{1}(regionData, runData);
    
    rows      = size(Z,2);
    columns   = size(Z,1);
    
    summaryOffset = obj.SummaryOffset;
    offsetRange   = 1:summaryOffset;
    summaryRange  = summaryOffset + 1 + [0:obj.SummaryLength];
    summaryExtent = max(summaryRange);
    
    xColumns      = columns+summaryExtent;
    xColumnRange  = columns+1:xColumns;
    xRows         = rows+summaryExtent;
    xRowRange     = rows+1:xRows;
    
    regionMasks(:, xColumnRange, xRowRange) = false;
    
    newData       = zeros(1, xColumns, xRows);
    
    for m = 1:size(regionMasks,1)
      maskData          = regionMasks(m, :, :)==1;
      newData(maskData) = regionStats(m);
    end
    
    try
      aroundStats = statsFunction{2}(aroundData, runData);
      
      for m = 1:size(aroundMasks,1)
        xMask       = zeros(1, xColumns, xRows)==1;
        
        r = rows + summaryRange;
        aroundMask  = aroundMasks(m, :, :)==1;
        xMask(1, aroundMask(:), r) = true;
        
        
        newData(xMask) = aroundStats(m);
        
        n = size(regionMasks,1)+1;
        
        regionMasks(n, :, :)  = xMask;
        regionStats(n)        = aroundStats(m);
      end
    catch err
      debugStamp(err, 1);
    end
    
    try
      acrossStats = statsFunction{2}(acrossData, runData);
      
      for m = 1:size(acrossMasks,1)
        xMask       = zeros(1, xColumns, xRows)==1;
        
        c = columns + summaryRange;
        acrossMask  = acrossMasks(m, :, :)==1;
        xMask(1, c, acrossMask(:)) = true;
        
        newData(xMask) = acrossStats(m);
        
        n = size(regionMasks,1)+1;
        
        regionMasks(n, :, :)  = xMask;
        regionStats(n)        = acrossStats(m);
      end
    catch err
      debugStamp(err, 1);
    end
    
    try
      sampleStats = statsFunction{3}(sheetData, runData);
      r = rows    + summaryRange;
      c = columns + summaryRange;
      newData(1, c, r) = sampleStats;
      
      xMask           = zeros(1, xColumns, xRows)==1;
      xMask(1, c, r)  = true;
      
      n = size(regionMasks,1)+1;
      
      regionMasks(n, :, :)  = xMask;
      regionStats(n)        = sampleStats;
    catch err
      debugStamp(err, 1);
    end
    
    if size(newData, 2) > columns,  newData(1, :, rows + offsetRange)     = nan; end
    if size(newData, 3) > rows,     newData(1, columns + offsetRange, :)  = nan; end
    
    %% Generate Region Labels
    regionLabels    = {}; %cell(size(stats.(varID),1),1);
    
    labelPrefix = '';
    for m = 1:numel(regionData)
      regionLabels{end+1} = [labelPrefix labelFunction{1}(regionData(m)) ];
    end
    for m = 1:numel(aroundData)
      regionLabels{end+1} = [labelPrefix labelFunction{2}(aroundData(m)) ];
    end
    for m = 1:numel(acrossData)
      regionLabels{end+1} = [labelPrefix labelFunction{2}(acrossData(m)) ];
    end
    regionLabels{end+1}   = [labelPrefix labelFunction{3}(sheetData)     ];
    
    
    sheetStats = struct('Data', newData, 'Masks', regionMasks, 'Values', regionStats, 'Strings', {regionLabels});
    
    try
      obj.SetStats{sheetID}   = regionStats;
    catch err
      debugStamp(err, 1);
    end
    
    try
      obj.SetStrings{sheetID} = regionLabels;
    catch err
      debugStamp(err, 1);
    end
    
  catch err
    debugStamp(err, 1);
  end
  
end


function updateStatsFunctions(obj)
  
  if ~isempty(obj.CurrentStatsMode) && ...
      ~isempty(obj.CurrentStatsFunction) && ...
      ~isempty(obj.CurrentDataFunction) && ...
      ~isempty(obj.CurrentLabelFunction)
    return;
  end
  
  debugStamp(obj.ID, 4);
  
  if isempty(obj.StatsMode)
    obj.StatsMode = 'Mean';
  end
  
  statsMode = regexprep(lower(obj.StatsMode), '\W', '');
  
  statsFunction = {};
  dataFunction  = {};
  labelFunction = {};
  
  switch statsMode
    case {'limits'}
      statsMode     = 'Limits';
      statsFunction{1}  = @(d, r) vertcat(d.Mean);
      dataFunction{1}   = @(s)    nanmean(s(:));
      labelFunction{1}  = @(d)    sprintf('%1.1f-%1.1f-%1.1f', min(d.Limits), mean(d.Mean), max(d.Limits));
      labelFunction{2}  = @(d)    sprintf('%1.1f±%1.1f', mean(d.Mean), (d.Sigma.*3));
    case {'peaklimits'}
      statsMode         = 'PeakLimits';
      statsFunction{1}  = @(d, r) vertcat(d.Mean);
      dataFunction{1}   = @(s)    nanmean(s(:));
      labelFunction{1}  = @(d)    sprintf('{\\fontsize{n}{\\bf %1.1f}{\\fontsize{s}%+1.1f }}\n{\\fontsize{t}({\\itpeak_{r}} = {\\it\\mu_{R}}%+1.1f)}', d.PeakLimit(1), 2*(d.Mean-d.PeakLimit(1)), d.PeakLimit(1)-d.ReferenceMean); %d.Sigma*3);
      labelFunction{2}  = @(d)    sprintf('{\\fontsize{n}{\\bf %1.1f}{\\fontsize{s}±%1.1f  } }\n{\\fontsize{t}({\\it\\mu_{b}} = {\\it\\mu_{R}}%+1.1f)  }', [d.Mean   d.Sigma*3 d.Mean-d.ReferenceMean]);
      labelFunction{3}  = @(d)    sprintf('{\\fontsize{n}{\\bf %1.1f}{\\fontsize{s}±%1.1f  } }\n{\\fontsize{t}({\\it\\mu_{s}} = {\\it\\mu_{R}}%+1.1f)  }', [d.Mean   d.Sigma*3 d.Mean-d.ReferenceMean]);
    otherwise
      statsMode         = 'Mean';
      statsFunction{1}  = @(d, r) vertcat(d.Mean);
      dataFunction{1}   = @(s)    nanmean(s(:));
      labelFunction{1}  = @(d)    sprintf('%1.1f', d.Mean);
  end
  
  try while numel(statsFunction) < 3, statsFunction(end+1)  = statsFunction(end); end; end
  try while numel(dataFunction)  < 3, dataFunction(end+1)   = dataFunction(end);  end; end
  try while numel(labelFunction) < 3, labelFunction(end+1)  = labelFunction(end); end; end
  
  obj.CurrentStatsMode      = statsMode;
  obj.CurrentStatsFunction  = statsFunction;
  obj.CurrentDataFunction   = dataFunction;
  obj.CurrentLabelFunction  = labelFunction;
  
end

function resetStatsOptions(obj)
  obj.Stats                 = [];
  obj.SetStats              = [];
  obj.SetStrings            = {};
  obj.CurrentStatsMode      = 'Limits';
  obj.CurrentStatsFunction  = [];
  obj.CurrentDataFunction   = [];
  obj.CurrentLabelFunction  = [];
end

