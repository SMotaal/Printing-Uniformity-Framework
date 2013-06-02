function stats = processRegionStatistics( obj, sheetID, variableID)
  %GETSTATISTICS Summary of this function goes here
  %   Detailed explanation goes here
  
  stats                         = [];
  
  if ~exist('sheetID',    'var'), sheetID     = obj.SheetID; end
  if ~exist('variableID', 'var'), variableID  = obj.VariableID; end
  
  if nargin>1 && ischar(sheetID)
    options                     = sheetID;
    while ~isempty(strtok(options))
      [token options]           = strtok(options);
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
  if ~isempty(sheetID),   stats   = getSheetStatistics(obj, sheetID, variableID); end % updateSheetStats
end

function stats = newStatistics(varargin)
  if nargin==0
    stats                       = GrasppeAlpha.Stats.TransientStats.empty();
  else
    stats                       = GrasppeAlpha.Stats.TransientStats(varargin{:});
  end
end

function [sheetStats] = getSheetStatistics(obj, sheetID, variableID)
  
  sheetStats                    = struct('Data', [], 'Masks', [], 'Values', [], 'Strings', []);
  
  try
    rows                        = obj.RowCount;
    columns                     = obj.ColumnCount;
    
    [X Y Z]                     = meshgrid(1:columns, 1:rows, 1);
    
    caseID                      = obj.CaseID;
    setID                       = obj.SetID;
    
    caseData                    = obj.CaseData;
    setData                     = obj.SetData;
    
    stats                       = obj.Statistics;
    
    debugStamp(5);
    
    %% Get Stats Functions
    
    if isempty(stats) || isempty(caseID) || isempty(setID), return; end
    
    updateStatsFunctions(obj);
    
    statsMode                   = obj.currentStatsMode;
    statsFunction               = obj.currentStatsFunction;
    dataFunction                = obj.currentDataFunction;
    labelFunction               = obj.currentLabelFunction;
    
    varID                       = variableID; %'Stats';
    switch varID
      case {'sections', 'around', 'across'}
        aroundID                = 'around';
        acrossID                = 'across';
      otherwise
        aroundID                = [varID 'Around'];
        acrossID                = [varID 'Across'];
    end
    
    runStats                    = stats.run.Stats.Sample;
    
    %% Get Region Masks
    regionMasks                 = obj.RegionMasks.(varID); % stats.metadata.regions.(varID);
    
    %% Get Sheet Data
    regionData                  = newStatistics(); % GrasppeAlpha.Stats.TransientStats.empty;
    
    if sheetID == 0, sheetID    = obj.SheetCount + 1; end
    
    for m = 1:size(stats.(varID),1)
      regionData(m)             = stats.(varID)(m, sheetID).Stats; % .Sample;
    end
    
    if sheetID > obj.SheetCount,
      sheetData                 = runStats;                     % stats.data
    else
      dataFilter                = stats.filter;
      
      sheetData                 = stats.data(sheetID, :, :);    % regionData(1).Data(:);
      sheetData                 = sheetData(~dataFilter);
      sheetData                 = newStatistics(sheetData, runStats);
    end
    
    
    %% Get Circumferential Data
    aroundData                  = newStatistics();
    
    try
      aroundMasks               = stats.metadata.regions.(aroundID);
      aroundMasks               = max(aroundMasks, [], 3);
      
      for m = 1:size(stats.(aroundID),1)
        aroundData(m)           = stats.(aroundID)(m, sheetID).Stats; % .Sample;
      end
      
    catch
      aroundMasks               = [];
      aroundData                = [];
    end
    
    %% Get Axial Data
    acrossData                  = newStatistics();
    
    try
      acrossMasks               = stats.metadata.regions.(acrossID);
      acrossMasks               = max(acrossMasks, [], 2);
      
      for m = 1:size(stats.(acrossID),1)
        acrossData(m)           = stats.(acrossID)(m, sheetID).Stats; % .Sample;
      end
      
    catch
      acrossMasks               = [];
      acrossData                = [];
    end
    
    %% Prepare Plot Data
    rows                        = size(Z,2);
    columns                     = size(Z,1);
    
    summaryOffset               = obj.summaryOffset;
    summaryLength               = obj.summaryLength;
    
    offsetRange                 = 1:summaryOffset;
    summaryRange                = summaryOffset + 1 + [0:summaryLength];
    summaryExtent               = max(summaryRange);
    
    xColumns                    = columns+summaryExtent;
    xColumnRange                = columns+1:xColumns;
    xRows                       = rows+summaryExtent;
    xRowRange                   = rows+1:xRows;
    
    regionMasks(:, xColumnRange, xRowRange) = false;
    
    newData                     = zeros(1, xColumns, xRows);
    
    %% Region Stats
    try
      regionCount               = size(regionMasks,1);
      regionStats               = NaN(1, regionCount);
      
      for m = 1:regionCount
        regionStats(m)          = statsFunction{1}(regionData(m), runStats);
        maskData                = regionMasks(m, :, :)==1;
        newData(maskData)       = regionStats(m);
      end
      
    catch err
      try if ~isequal(size(newData), size(maskData)), return; end; end % obj.Regions = []; % obj.ProcessVariableData();
      debugStamp(1);
    end
    
    %% Circumferential Stats
    try
      
      aroundCount               = size(aroundMasks,1);
      aroundStats               = NaN(1, aroundCount);
      
      for m = 1:aroundCount
        aroundStats(m)          = statsFunction{2}(aroundData(m), runStats);
        xMask                   = zeros(1, xColumns, xRows)==1;
        r                       = rows + summaryRange;
        aroundMask              = aroundMasks(m, :, :)==1;
        xMask(1, aroundMask(:), r) = true;
        newData(xMask)          = aroundStats(m);
        n                       = size(regionMasks,1)+1;
        regionMasks(n, :, :)    = xMask;
        regionStats(n)          = aroundStats(m);
        
      end
    catch err
      debugStamp(err, 1, obj);
    end
    
    %% Axial Stats
    try
      
      acrossCount               = size(acrossMasks,1);
      acrossStats               = NaN(1, acrossCount);
      
      for m = 1:acrossCount
        acrossStats(m)          = statsFunction{2}(acrossData(m), runStats);
        xMask                   = zeros(1, xColumns, xRows)==1;
        c                       = columns + summaryRange;
        acrossMask              = acrossMasks(m, :, :)==1;
        xMask(1, c, acrossMask(:)) = true;
        newData(xMask)          = acrossStats(m);
        n                       = size(regionMasks,1)+1;
        regionMasks(n, :, :)    = xMask;
        regionStats(n)          = acrossStats(m);
      end
    catch err
      debugStamp(err, 1, obj);
    end
    
    %% Summary Stats
    try
      sampleStats               = statsFunction{3}(sheetData, runStats);
      r                         = rows    + summaryRange;
      c                         = columns + summaryRange;
      newData(1, c, r)          = sampleStats;
      xMask                     = zeros(1, xColumns, xRows)==1;
      xMask(1, c, r)            = true;
      n                         = size(regionMasks,1)+1;
      regionMasks(n, :, :)      = xMask;
      regionStats(n)            = sampleStats;
      
    catch err
      debugStamp(err, 1, obj);
    end
    
    if size(newData, 2) > columns,  newData(1, :, rows + offsetRange)     = nan; end
    if size(newData, 3) > rows,     newData(1, columns + offsetRange, :)  = nan; end
    
    %% Generate Region Labels
    regionLabels                = {}; %cell(size(stats.(varID),1),1);
    
    labelPrefix                 = '';
    for m = 1:numel(regionData)
      regionLabels{end+1}       = [labelPrefix labelFunction{1}(regionData(m)) ];
    end
    for m = 1:numel(aroundData)
      regionLabels{end+1}       = [labelPrefix labelFunction{2}(aroundData(m)) ];
    end
    for m = 1:numel(acrossData)
      regionLabels{end+1}       = [labelPrefix labelFunction{2}(acrossData(m)) ];
    end
    regionLabels{end+1}         = [labelPrefix labelFunction{3}(sheetData)     ];
    
    newData                     = squeeze(newData);
    
    sheetStats                  = struct('Data', newData, 'Masks', regionMasks, 'Values', regionStats, 'Strings', {regionLabels});
    
    obj.RegionData{sheetID}     = regionStats;
    obj.RegionLabels{sheetID}   = regionLabels;
    obj.sheetStatistics{sheetID}   = sheetStats;
    
  catch err
    debugStamp(err, 1, obj);
  end
  
end


function updateStatsFunctions(obj)
  
  debugStamp(5);
  
  if ~isempty(obj.currentStatsMode) && ...
      ~isempty(obj.currentStatsFunction) && ...
      ~isempty(obj.currentDataFunction) && ...
      ~isempty(obj.currentLabelFunction)
    return;
  end
  
  debugStamp(obj.ID, 4);
  
  if isempty(obj.StatisticsMode) || ~ischar(obj.StatisticsMode)
    obj.StatisticsMode  = 'Mean';
  end
  
  statsMode                     = regexprep(lower(obj.StatisticsMode), '\W', '');
  
  statsFunction                 = {};
  dataFunction                  = {};
  labelFunction                 = {};
  
  medium                        = @(x) ['{\\fontsize{n}' x '}' ];
  small                         = @(x) ['{\\fontsize{s}' x '}' ];
  tiny                          = @(x) ['{\\fontsize{t}' x '}' ];
  bold                          = @(x) ['{\\bf ' x '}' ];
  
  singlePrecision               = ['%1.2f'];
  singleSigned                  = ['%+1.2f'];
  
  try
    
    switch statsMode
      case {'limits'}
        
        statsMode               = 'Limits';
        statsFunction{1}        = @(d, r) vertcat(d.Mean);
        dataFunction{1}         = @(s)    nanmean(s(:));
        labelFunction{1}        = @(d)    sprintf('%1.1f-%1.1f-%1.1f', min(d.Limits), mean(d.Mean), max(d.Limits));
        labelFunction{2}        = @(d)    sprintf('%1.1f±%1.1f', mean(d.Mean), (d.Sigma.*3));
        
      case {'peaklimits'}
        
        statsMode               = 'PeakLimits';
        statsFunction{1}        = @(d, r) d.Peak; %vertcat(d.detailed);
        dataFunction{1}         = @(s)    nanmean(s(:));
        
        
        labelFormat             = [ ... %labelFormatTiny
          small([ bold('\\mu: ')    singlePrecision   ' (±' singlePrecision               ')' ])  '\n'...
          tiny([ bold('\\Delta: ')  singlePrecision   ' ('  singlePrecision singleSigned  ')' ])  '\n' ...
          tiny([ bold('\\sigma: ')  singlePrecision   ' - ' singlePrecision]     )                '\n'...
          ];
        
        labelFunction{1}        = @(d)    sprintf(labelFormat, ...
          d.Mean, d.Sigma*3, ...
          fliplr(d.GetPeakMeasure), ...
          d.LowerBound, d.UpperBound ...
          );
        
      case {'peakmean', 'peakmeans', 'meanpeak', 'meanpeaks'}
        
        statsMode               = 'PeakMean';
        statsFunction{1}        = @(d, r) d.Peak; %vertcat(d.detailed);
        dataFunction{1}         = @(s)    nanmean(s(:));
        
        labelFormat             = [ ... %labelFormatTiny
          medium( [ bold('\\mu: '    ) singlePrecision ' (±' singlePrecision   ')' ])  '\n'...
          small(  [ bold('\\sigma: ' ) singlePrecision ' - ' singlePrecision       ]) 	'\n'...
          ];
        
        labelFunction{1}          = @(d) sprintf(labelFormat, ...
          d.Mean, d.Sigma*3, ...
          d.LowerBound, d.UpperBound ...
          );
        
        
      otherwise
        
        statsMode               = 'Mean';
        statsFunction{1}        = @(d, r) d.Mean; %vertcat(d.detailed);
        dataFunction{1}         = @(s)    nanmean(s(:));
        
        labelFormat             = [ ... %labelFormatTiny
          medium( [ bold('\\mu: '    ) singlePrecision ' (±' singlePrecision   ')' ])  '\n'...
          small(  [ bold('\\sigma: ' ) singlePrecision ' - ' singlePrecision       ]) 	'\n'...
          ];
        
        labelFunction{1}        = @(d) sprintf(labelFormat, ...
          d.Mean, d.Sigma*3, ...
          d.LowerBound, d.UpperBound ...
          );
        
    end
    
  catch err
    debugStamp;
    rethrow(err);
  end
  
  try while numel(statsFunction) < 3, statsFunction(end+1)  = statsFunction(end); end; end
  try while numel(dataFunction)  < 3, dataFunction(end+1)   = dataFunction(end);  end; end
  try while numel(labelFunction) < 3, labelFunction(end+1)  = labelFunction(end); end; end
  
  obj.currentStatsMode          = statsMode;
  obj.currentStatsFunction      = statsFunction;
  obj.currentDataFunction       = dataFunction;
  obj.currentLabelFunction      = labelFunction;
  
end

function resetStatsOptions(obj)
  
  debugStamp(1);
  
  obj.Statistics                = [];
  obj.RegionData                = {};
  obj.RegionLabels              = {};
  
  obj.currentStatsMode          = 'Limits';
  obj.currentStatsFunction      = [];
  obj.currentDataFunction       = [];
  obj.currentLabelFunction      = [];
  obj.sheetStatistics           = {};
end


% targetFilter    = caseData.sampling.masks.Target~=1;
% patchFilter     = setData.filterData.dataFilter~=1;
% sheetFilter     = targetFilter~=1 & patchFilter~=1;
