%% tallyRegionStats4

function tally = tallyRegionStats
  
  cleardebug; cleardebug;
  testing                         = false;
  
  %% Cases
  
  caseIDs                         = { 'ritsm7402a', 'ritsm7402b', 'ritsm7402c', 'rithp7k01',  'rithp5501' };
  caseSymbols                     = { 'L1',         'L2',         'L3' ,        'X1',         'X2'        };
  caseFlip                        = [ false,        false,        false,        false,        false       ];
  
  setIDs                          = [100, 75, 50, 25, 0];
  
  if testing
    testIdx                       = 4; % [4    1];
    setIDs                        = [100  0];
    caseIDs                       = caseIDs(testIdx);
    caseSymbols                   = caseSymbols(testIdx);
    caseFlip                      = caseFlip(testIdx);
  end
  
  caseCount                       = numel(caseIDs);
  setCount                        = numel(setIDs);
    
  %% Units & Standards
  
  unitID                          = 'density';
  
  switch lower(unitID)
    case {'v', 'density', 'iso visual density', 'd'}
      unitID                      = 'ISO Visual Density';
      standardValues              = [ 1.6779    0.92575   0.51709   0.24656   0.057405];
      standardTolerances          = [ 0.1       0.1       0.1       0.1       0.05];
    otherwise % case {'l', 'l*', 'cie-l', 'cie-l*', 'ciel', 'ciel*'}
      unitID                      = 'CIE-L';
      % standardValues             = [ 16    NaN   NaN   NaN   93  ];  % Black Backing (12647-2)
      standardValues              = [ 16    41    62    80    95  ];  % White Backing Informative (Photoshop Fogra39 > Absolute Colorimetric > Lab)
      standardTolerances          = [  4    4     4     4     3   ];   % Extrapolated from ISO 12647-2
  end
  
  %% Class Initializations
  
  dataSourceClass                 = 'PrintUniformityBeta.Data.RegionPlotDataSource';
  statsClass                      = 'GrasppeAlpha.Stats.TransientStats';
  
  regionIDs                       = {'region', 'around', 'across'};
  
  emptySource                     = @()eval([dataSourceClass '.empty();']);
  emptyStats                      = @()eval([statsClass '.empty();']);
  
  dataSources                     = emptySource(); %feval([dataSourceClass '.empty'], 0, 5);
  tallyMasks                      = struct();
  tallyData                       = struct(); %'sheet', {}, 'around', {}, 'across', {}, 'run', {});
  tallyStats                      = struct();
  
  %% Metadata
  
  tallyMetadata.Date              = datevec(now);
  tallyMetadata.DataSourceClass 	= dataSourceClass;
  tallyMetadata.StatsClass        = statsClass;
  
  tallyMetadata.Cases.IDs         = caseIDs;
  tallyMetadata.Cases.Symbols     = caseSymbols;
  
  tallyMetadata.Cases.Names       = cell(1, caseCount); % tallyMetadata.CaseFlip          = caseFlip;
  tallyMetadata.Cases.Metadata    = cell(1, caseCount);
  tallyMetadata.Cases.Headers     = cell(1, caseCount); % indices, metrics, range, length
  
  tallyMetadata.Regions.IDs       = regionIDs;
  
  tallyMetadata.Sets.IDs          = setIDs;  
  tallyMetadata.Sets.Names        = cell(caseCount, setCount);
  
  tallyMetadata.Sheets.Index      = cell(1, caseCount);

  tallyMetadata.Standard          = standardValues;
  tallyMetadata.Tolerance         = standardTolerances;
  tallyMetadata.Unit              = unitID; %% 'ISO Visual Density'; % 'CIE-L'
  tallyMetadata.SumsMethod        = 'Reverse ANOVA';
  
  tallyMetadata.Version           = 2.1;
  tallyMetadata.Revision          = MX.stackRev;
  
  %% Prepare Output
  outputSuffix                    = datestr(now, 'yymmdd');
  outputPath                      = fullfile('Output', ['UniPrint-Stats-' outputSuffix]);
  FS.mkDir(outputPath);
  
  %% Tally Cases
  
  for m = 1:caseCount
    
    sourceID                      = caseIDs{m};
    
    caseData                      = [];
    
    for n = 1:setCount
      
      setID                       = setIDs(n);
      roiIDs                      = regionIDs; % {'region', 'around', 'across'};
      
      %% Load data
      if n == 1
        dataSources(m)            = feval(dataSourceClass, 'CaseID', sourceID, 'SetID', setID); % , 'PassiveProcessing', true);
      else
        dataSources(m).SetID      = setID;
      end
            
      dispf('\t\tChangeSet: %s\tCaseID: %s\tSetID: %d\tSheetID: %d', ...
        char(dataSources(m).Reader.State), dataSources(m).CaseID, dataSources(m).SetID, dataSources(m).SheetID);
      
      if n==1
        caseData                            = dataSources(m).CaseData.DATA;
        
        tallyMetadata.Cases.Names{m}        = caseData.metadata.title; %dataSources(m).CaseName;
        tallyMetadata.Cases.Metadata{m}     = caseData.metadata;
        tallyMetadata.Cases.Headers         = struct( ...
          'Index',    caseData.index, ...
          'Metrics',  caseData.metrics, ...
          'Range',    caseData.range, ...
          'Length',   caseData.length ...
          );
        
        tallyMetadata.Sheets.Index{m}       = caseData.index.Sheets;
      end
      
      if isempty(dataSources(m).Statistics) || ~isstruct(dataSources(m).Statistics)
        disp('Force-Processing Statistics...');
        dataSources(m).processStatistics;
      end
      stats                                 = dataSources(m).Statistics;
      
      tallyMetadata.Sets.Names{m, n}        = [dataSources(m).CaseName ' ' dataSources(m).SetName];
      
      %% Tally data filter / MASKS
      dataFilter                            = stats.filter;
      tallyData(m, n).dataFilter            = dataFilter;
      tallyMasks(m).region                  = flipdim(stats.metadata.regions.sections, 3);
      tallyMasks(m).around                  = flipdim(stats.metadata.regions.around, 3);
      tallyMasks(m).across                  = flipdim(stats.metadata.regions.across, 3);
      
      %% Tally run, sheet, patch, region counts
      
      tallyData(m, n).run                   = stats.run;
      tallyData(m, n).runData               = stats.data;
      tallyData(m, n).runCount              = 1;
      tallyData(m, n).sheetCount            = size(tallyData(m, n).runData, 1);
      tallyData(m, n).sheetSize             = [size(tallyData(m, n).runData, 2) size(tallyData(m, n).runData, 3)];
      tallyData(m, n).patchIndex            = find(~dataFilter);
      tallyData(m, n).patchCount            = numel(tallyData(m, n).patchIndex);
      tallyData(m, n).region                = stats.sections;
      tallyData(m, n).regionCount           = size(tallyData(m, n).region, 1);
      tallyData(m, n).around                = stats.around;
      tallyData(m, n).aroundCount           = size(tallyData(m, n).around, 1);
      tallyData(m, n).across                = stats.across;
      tallyData(m, n).acrossCount           = size(tallyData(m, n).across, 1);
      tallyData(m, n).zoneCount             = 0;
      
      %% Tally zone data & masks optional
      if isfield(stats.metadata.regions, 'zones')
        tallyMasks(m).zone                  = flipdim(stats.metadata.regions.zones, 3);
        tallyData(m, n).zone                = stats.zones;
        tallyData(m, n).zoneCount           = size(tallyData(m, n).zone, 1);
        roiIDs                              = [roiIDs, 'zone'];
      end
      
      %% Standard & Tolerance Values
      standardValue                         = standardValues(n);
      standardTolerance                     = standardTolerances(n);
      
      %% Run Statistics
      
      runData                               = tallyData(m, n).runData;
      patchIndex                            = tallyData(m, n).patchIndex;
      patchCount                            = tallyData(m, n).patchCount;
      sheetCount                            = tallyData(m, n).sheetCount;
      
      runMask                               = ~dataFilter;
      runSamples                            = runData(:, runMask);
      runTally                              = newTally(runData, runSamples);
      referenceValue                        = runTally.Mean;
      
      %% Run Inaccuracy & Imprecision
      runTally.Inaccuracy                   = calculateInaccuracy(runData, standardValue, standardTolerance);
      runTally.Imprecision                  = calculateImprecision(runData, standardTolerance);
      
      %% Patch Statistics
      
      patches                               = struct();
      patches.Count                         = patchCount;
      patches.Mean                          = NaN(1, patchCount);
      patches.Sigma                         = NaN(1, patchCount);
      
      for p=1:patchCount
        tallyStats(m, n).Patch(p)           = tallyPatch(runData, patchIndex(p), referenceValue, standardTolerance);
        patches.Mean(p)                     = tallyStats(m, n).Patch(p).Mean;
        patches.Sigma(p)                    = tallyStats(m, n).Patch(p).Sigma;
      end
      
      %% Sheet Statistics
      
      sheets                                = struct();
      sheets.Count                          = sheetCount;
      sheets.Mean                           = NaN(1, sheetCount);
      sheets.Sigma                          = NaN(1, sheetCount);
      
      for s=1:sheetCount
        tallyStats(m, n).Sheet(s)           = tallySheet(runData, s, ~dataFilter, referenceValue, standardTolerance);
        sheets.Mean(s)                      = tallyStats(m, n).Sheet(s).Mean;
        sheets.Sigma(s)                     = tallyStats(m, n).Sheet(s).Sigma;
      end
      
      %% Run Factors
      runTally.Factors                      = calculateFactors(patches.Sigma, sheets.Sigma);
      
      %% ROI Statistics
      tallyMetadata.Regions.IDs             = unique([tallyMetadata.Regions.IDs roiIDs], 'stable');
      
      for roiSet = roiIDs
        
        roiID                               = char(roiSet);
        roiCount                            = tallyData(m, n).([roiID 'Count']);
        roiMasks                            = tallyMasks(m).(roiID);
        roiSheets.Mean                      = NaN(roiCount, sheetCount);
        roiSheets.Sigma                     = NaN(roiCount, sheetCount);
        roiPatches.Mean                     = NaN(roiCount, patchCount);
        roiPatches.Sigma                    = NaN(roiCount, patchCount);
        roiInaccuracyValues                 = NaN(roiCount, 1);
        roiImprecisionValues                = NaN(roiCount, 1);
        roiUnevennessValues                 = NaN(roiCount, 1);
        roiUnrepeatabilityValues            = NaN(roiCount, 1);        
        roiData                             = cell(1, roiCount); %NaN(regionCount, sheetCount, regionSize
        roiTally                            = struct( ...
          'Size',[],'Samples',[],'Outliers',[], ...
          'Mean',[],'Sigma',[], ...
          'Sheet',struct(),'Patch', struct(), ...
          'Name', {}, 'Position', struct('Row',{},'Column',{}),  ...
          'Inaccuracy',struct(),'Imprecision',struct(),'Factors',struct(),'Proportions', struct() ...
          );
        
        %% Figure out ROI positions and Names
        % roiGrid(:,:)                        = roiMasks(1, :, :);
        for r = 1:roiCount
          roiMask                           = squeeze(roiMasks(r,:,:)==1);
          roiColumns                        = sum(roiMask, 1);
          roiRows                           = sum(roiMask, 2);
          columnCount                       = numel(roiColumns);
          rowCount                          = numel(roiRows);
          
          roiPosition.Row                   = [ ...
            max(1,            find(roiRows>0, 1,'first')) ...
            min(rowCount,     find(roiRows>0, 1,'last'))  ];
          
          roiPosition.Column                = [ ...          
            max(1,            find(roiColumns>0, 1,'first')) ...
            min(columnCount,  find(roiColumns>0, 1,'last'))  ];
          
          roiTally(r).Position              = roiPosition;
            
          try cell2mat(struct2cell(roiTally(r).Position)), end;

        end
        
        roiID                               = [upper(roiID(1)) roiID(2:end)];
        
        for r = 1:roiCount
          roiMask                           = roiMasks(r,:,:)==1;
          roiMask                           = squeeze(roiMask) & ~dataFilter;
          
          sampleData                        = runData(:, roiMask);
          nanSamples                        = isnan(sampleData(:));
          
          roiTally(r).Size                  = size(sampleData);
          roiTally(r).Samples               = sum(~nanSamples);
          roiTally(r).Outliers              = sum(nanSamples);
          
          for s=1:sheetCount % tally = sheetTally(data, sheet, mask, reference, tolerance)
            roiData{r}(s,:)                 = runData(s, roiMask);
            if s==1
              roiTally(r).Sheet             = tallySheet(roiData{r}, s, [], referenceValue, standardTolerance);
            else
              roiTally(r).Sheet(s)          = tallySheet(roiData{r}, s, [], referenceValue, standardTolerance);
            end
            roiSheets.Mean(r, s)            = roiTally(r).Sheet(s).Mean;
            roiSheets.Sigma(r, s)           = roiTally(r).Sheet(s).Sigma;
          end
          
          
          for p=1:size(roiData{r},2) % tally = patchTally(data, mask, reference, tolerance)
            if p==1
              roiTally(r).Patch             = tallyPatch(roiData{r}, p, referenceValue, standardTolerance);
            else
              roiTally(r).Patch(p)          = tallyPatch(roiData{r}, p, referenceValue, standardTolerance);
            end
            roiPatches.Mean(r, p)           = roiTally(r).Patch(p).Mean;
            roiPatches.Sigma(r, p)          = roiTally(r).Patch(p).Sigma;
          end
          
          roiTally(r).Mean                  = nanmean(roiData{r}(:));
          roiTally(r).Sigma                 = nanstd(roiData{r}(:));
          
          roiTally(r).Inaccuracy            = calculateInaccuracy(roiData{r}(:), referenceValue, standardTolerance);
          roiTally(r).Imprecision           = calculateImprecision(roiData{r}(:), standardTolerance);
          roiTally(r).Factors               = calculateFactors(roiPatches.Sigma(r,:), roiSheets.Sigma(r,:));
          
          roiInaccuracyValues(r)            = roiTally(r).Inaccuracy.Value;
          roiImprecisionValues(r)           = roiTally(r).Imprecision.Value;
          roiUnevennessValues(r)            = roiTally(r).Factors.Unevenness.Value;
          roiUnrepeatabilityValues(r)       = roiTally(r).Factors.Unrepeatability.Value;
          
        end
        
        inaccuracyProportions               = @(x) (abs(x)) ./  sumabs(x(:));
        imprecisionProportions              = @(x) (x.^2)   ./  sumsqr(x(:));
        
        roiInaccuracyProportions            = inaccuracyProportions(roiInaccuracyValues(:)); %(roiInaccuracyValues(:)     ) ./  sum(roiInaccuracyValues(:));
        roiImprecisionProportions           = imprecisionProportions(roiImprecisionValues(:)); % (roiImprecisionValues(:).^2 ) ./  sumsqr(roiImprecisionValues(:));
        
        [V, I]                              = sort(abs(roiInaccuracyValues));
        roiInaccuracyRanks                  = I;
        [V, I]                              = sort(roiImprecisionValues);
        roiImprecisionRanks                 = I;        
        [V, I]                              = sort(roiUnevennessValues);
        roiUnevennessRanks                  = I;        
        [V, I]                              = sort(roiUnrepeatabilityValues);
        roiUnrepeatabilityRanks             = I;                
        
        
        [V, I]                              = sort(roiInaccuracyValues);
        roiInaccuracySequences              = I;
        
        %% ROI Proportions
        for r = 1:roiCount
          roiTally(r).Proportions.Inaccuracy  = roiInaccuracyProportions(r);
          roiTally(r).Proportions.Imprecision = roiImprecisionProportions(r);
          
          roiTally(r).Ranks.Inaccuracy      = find(roiInaccuracyRanks==r,1,'first');
          roiTally(r).Ranks.Imprecision     = find(roiImprecisionRanks==r,1,'first');
          roiTally(r).Ranks.Unevenness      = find(roiUnevennessRanks==r,1,'first');
          roiTally(r).Ranks.Unrepeatability = find(roiUnrepeatabilityRanks==r,1,'first');
          
          roiTally(r).Sequences.Inaccuracy  = find(roiInaccuracySequences==r,1,'first');
        end
        
        roiIndex                            = struct();
        roiIndex.Ranks.Inaccuracy           = roiInaccuracyRanks;
        roiIndex.Ranks.Imprecision          = roiImprecisionRanks;
        roiIndex.Ranks.Unevenness           = roiUnevennessRanks;
        roiIndex.Ranks.Unrepeatability      = roiUnrepeatabilityRanks;
        roiIndex.Sequences.Inaccuracy       = roiInaccuracySequences;
        roiIndex.Sequences.Imprecision      = roiImprecisionRanks;
        roiIndex.Sequences.Unevenness       = roiUnevennessRanks;
        roiIndex.Sequences.Unrepeatability  = roiUnrepeatabilityRanks;        
        runTally.Index.(roiID)              = roiIndex;
        
        switch lower(roiID)
          case 'region'
            regionInaccuracyValues          = roiInaccuracyValues(:);
            % regionImprecisionValues       = roiImprecisionValues(:);
          case 'around'
            aroundInaccuracyValues          = roiInaccuracyValues(:);
            aroundImprecisionValues         = roiImprecisionValues(:);
          case 'across'
            acrossInaccuracyValues          = roiInaccuracyValues(:);
            acrossImprecisionValues         = roiImprecisionValues(:);
        end
        
        tallyStats(m, n).(roiID)            = roiTally;
        % tallyStats(m, n).(roiID)            = rmfield(roiTally, {'Sheet', 'Patch'});
      end
      
      %% Run Directionality
      inaccuracyDirectionality              = @(x,r) (max(x)-min(x))  / (max(r)-min(r));
      imprecisionDirectionality             = @(x,y) (meansqr(x)      / (meansqr(x)+meansqr(y)));
      
      runTally.Directionality.Inaccuracy.Around   = inaccuracyDirectionality(aroundInaccuracyValues,    regionInaccuracyValues);
      runTally.Directionality.Inaccuracy.Across   = inaccuracyDirectionality(acrossInaccuracyValues,    regionInaccuracyValues);
      
      runTally.Directionality.Imprecision.Around  = imprecisionDirectionality(aroundImprecisionValues,  acrossImprecisionValues);
      runTally.Directionality.Imprecision.Across  = imprecisionDirectionality(acrossImprecisionValues,  aroundImprecisionValues);
      
      tallyStats(m, n).Run                = runTally;
      
      % setTally                          = struct();
      % setTally.Data                     = tallyData(m, n);
      % setTally.Masks                    = tallyMasks(m, n);
      % setTally.Stats                    = tallyStats(m, n);
      
      % save(fullfile(outputPath, ['Case-' sourceID '-TV' int2str(setID) '-Data.mat']),  '-struct', 'setTally', 'Data');
      % save(fullfile(outputPath, ['Case-' sourceID '-TV' int2str(setID) '-Masks.mat']), '-struct', 'setTally', 'Masks');
      % save(fullfile(outputPath, ['Case-' sourceID '-TV' int2str(setID) '-Stats.mat']), '-struct', 'setTally', 'Stats');
      
      setStats                            = tallyStats(m, n);
      statFields                          = fieldnames(setStats);
      for p = 1:numel(statFields)
        save(fullfile(outputPath, [sourceID '-' int2str(setID) '-' statFields{p}  '.mat']), '-struct', 'setStats', statFields{p});
      end  
      
      for roiSet = roiIDs
        roiID                             = char(roiSet);
        roiID                             = [upper(roiID(1)) roiID(2:end)];
        tallyStats(m, n).(roiID)          = rmfield(tallyStats(m, n).(roiID), {'Sheet', 'Patch'});
      end
      
      
    end
    
    caseTally                         = struct();
    caseTally.Masks                   = tallyMasks(m);
    save(fullfile(outputPath, [sourceID '-Masks.mat']), '-struct', 'caseTally', 'Masks');
    
    % if ~testing || all(ismember(setIDs,[100, 75, 50, 25, 0]));
    %   caseTally.Data                    = tallyData(m, :);
    %   caseTally.Masks                   = tallyMasks(m, :);
    %   caseTally.Stats                   = tallyStats(m, :);
    %
    %   save(fullfile(outputPath, ['Case-' sourceID '-Data.mat']),  '-struct', 'caseTally', 'Data');
    %   save(fullfile(outputPath, ['Case-' sourceID '-Masks.mat']), '-struct', 'caseTally', 'Masks');
    %   save(fullfile(outputPath, ['Case-' sourceID '-Stats.mat']), '-struct', 'caseTally', 'Stats');
    % end
    
      
  end
  
  for m = 1:numel(tallyMetadata.Regions.IDs)
    roiID                               = char(tallyMetadata.Regions.IDs{m});
    roiID                               = [upper(roiID(1)) roiID(2:end)];
    tallyMetadata.Regions.IDs{m}        = roiID;
  end
  
  tally.Metadata                        = tallyMetadata;
  tally.Data                            = tallyData;
  tally.Stats                           = tallyStats;
  tally.Masks                           = tallyMasks;
  
  if ~testing
    save(fullfile(outputPath, 'Metadata.mat'), '-struct', 'tally', 'Metadata');
  end
  
  save(fullfile('Output', ['tallyStats-'  outputSuffix  '.mat']), '-struct', 'tally', 'Metadata', 'Stats', 'Masks'); %, 'tallyStats', 'tallyData', 'tallyMasks');
  save(fullfile('Output', ['tallyData-'   outputSuffix  '.mat']), '-struct', 'tally', 'Data'); %, 'tallyStats', 'tallyData', 'tallyMasks');
  
end

function tally = newTally(data, samples)
  nanSamples                            = isnan(samples(:));
  tally.Size                            = size(data);
  tally.Samples                         = sum(~nanSamples);
  tally.Outliers                        = sum(nanSamples);
  tally.Mean                            = nanmean(samples(:));
  tally.Sigma                           = nanstd(samples(:));
end

function tally = tallyPatch(data, mask, reference, tolerance)
  if ~isempty(mask)
    samples                             = data(:, mask);
  else
    samples                             = data(:);
  end
  tally                                 = newTally(data, samples);
  tally.Inaccuracy                      = calculateInaccuracy(samples, reference, tolerance);
  tally.Imprecision                     = calculateImprecision(samples, tolerance);
  tally.Factors.Unrepeatability.Samples = tally.Samples;
  tally.Factors.Unrepeatability.Value   = factorValue(tally.Sigma(:), tally.Samples);
  tally.Factors.Unrepeatability.Factor  = 1.0;
end

function tally = tallySheet(data, sheet, mask, reference, tolerance)
  if ~isempty(mask)
    samples                             = data(sheet, mask);
  else
    samples                             = data(sheet, :);
  end
  tally                                 = newTally(data, samples);
  tally.Inaccuracy                      = calculateInaccuracy(samples, reference, tolerance);
  tally.Imprecision                     = calculateImprecision(samples, tolerance);
  tally.Factors.Unevenness.Samples      = tally.Samples;
  tally.Factors.Unevenness.Value        = factorValue(tally.Sigma(:), tally.Samples);
  tally.Factors.Unevenness.Factor       = 1.0;
end

%% Spatial-Temporal Factors

function factors = calculateFactors(temporalSigmas, spatialSigmas)
  temporalSigmas                        = temporalSigmas(~isnan(temporalSigmas(:)));
  temporalCount                         = numel(temporalSigmas);
  
  spatialSigmas                         = spatialSigmas(~isnan(spatialSigmas(:)));
  spatialCount                          = numel(spatialSigmas);
      
  unrepeatabilityValue                  = factorValue(temporalSigmas, temporalCount);
  unevennessValue                       = factorValue(spatialSigmas,  spatialCount);
  
  squaredFactor                         = @(x, y) (x^2)/sumsqr([x y]);
  
  % totalValue                            = sum(unrepeatabilityValue^2, unevennessValue^2);
  unrepeatabilityFactor                 = squaredFactor(unevennessValue,      unrepeatabilityValue); % sqrt(unrepeatabilityValue^2 / totalValue);
  unevennessFactor                      = squaredFactor(unrepeatabilityValue, unevennessValue);      % sqrt(unevennessValue^2      / totalValue);
  
  factors.Unrepeatability.Samples       = temporalCount;
  factors.Unrepeatability.Value         = unrepeatabilityValue;
  factors.Unrepeatability.Factor        = unrepeatabilityFactor;
  
  factors.Unevenness.Samples            = spatialCount;
  factors.Unevenness.Value              = unevennessValue;
  factors.Unevenness.Factor             = unevennessFactor;
end

function value = factorValue(sigmas, count)
  value                                 = sqrt(sumsqr(sigmas(:)) / (count-1));
end

%% Inaccuracy & Imprecision Metrics
function result = calculateInaccuracy(data, reference, tolerance)
  result.Reference                      = reference;
  result.Tolerance                      = tolerance;
  result.Value                          = nanmean(data(:))-reference;
  result.Score                          = result.Value/(tolerance/2);
end

function result = calculateImprecision(data, tolerance)
  result.Tolerance                      = tolerance;
  result.Value                          = nanstd(data(:))*6;
  result.Score                          = result.Value/(tolerance);
end
