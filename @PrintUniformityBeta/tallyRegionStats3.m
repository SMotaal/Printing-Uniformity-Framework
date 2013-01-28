cleardebug; cleardebug;

dataSourceClass     = 'PrintUniformityBeta.Data.RegionPlotDataSource';
statsClass          = 'GrasppeAlpha.Stats.TransientStats';

emptySource         = @()eval([dataSourceClass '.empty();']);
emptyStats          = @()eval([statsClass '.empty();']);

caseIDs             = { 'ritsm7402a', 'ritsm7402b', 'ritsm7402c', 'rithp7k01',  'rithp5501' };
caseSymbols         = { 'L1',         'L2',         'L3' ,        'X1',         'X2'        };
caseFlip            = [ false,        false,        false,        true,         true        ];

setIDs              = [100 75 50 25 0];

unitID              = 'density';

switch lower(unitID)
  case {'v', 'density', 'iso visual density', 'd'}
    unitID              = 'ISO Visual Density';
    standardValues      = [ 1.6779    0.92575   0.51709   0.24656   0.057405];
    standardTolerances  = [ 0.1       0.1       0.1       0.1       0.05];
  otherwise % case {'l', 'l*', 'cie-l', 'cie-l*', 'ciel', 'ciel*'}
    unitID              = 'CIE-L';
    % standardValues      = [ 16    NaN   NaN   NaN   93  ];  % Black Backing (12647-2)
    standardValues      = [ 16    41    62    80    95  ];  % White Backing Informative (Photoshop Fogra39 > Absolute Colorimetric > Lab)
    standardTolerances  = [  4    4     4     4     3   ];   % Extrapolated from ISO 12647-2
end

caseCount           = numel(caseIDs);
setCount            = numel(setIDs);

dataSources         = emptySource(); %feval([dataSourceClass '.empty'], 0, 5);

tallyMasks          = struct();
tallyData           = struct(); %'sheet', {}, 'around', {}, 'across', {}, 'run', {});
tallyStats          = struct();

tallyMetadata.Date              = datevec(now);
tallyMetadata.DataSourceClass   = dataSourceClass;
tallyMetadata.StatsClass        = statsClass;
tallyMetadata.CaseIDs           = caseIDs;
tallyMetadata.CaseSymbols       = caseSymbols;
tallyMetadata.CaseFlip          = caseFlip;
tallyMetadata.CaseMetadata      = cell(1, caseCount);
tallyMetadata.SetIDs            = setIDs;
tallyMetadata.SetNames          = cell(caseCount, setCount);
tallyMetadata.SetData           = cell(caseCount, setCount);
tallyMetadata.SetStats          = cell(caseCount, setCount);
tallyMetadata.Standard          = standardValues;
tallyMetadata.Tolerance         = standardTolerances;
tallyMetadata.Unit              = unitID; %% 'ISO Visual Density'; % 'CIE-L'


for m = 1:caseCount
  
  sourceID                        = caseIDs{m};
  
  for n = 1:setCount
    
    setID                         = setIDs(n);
    roiIDs                        = {'region', 'around', 'across'};
    
    %% Load data
    if n ==1
      dataSources(m)              = feval(dataSourceClass, 'CaseID', sourceID, 'SetID', setID);
    else
      dataSources(m).SetID        = setID;
    end
    
    pause(5);
    
    dataSources(m).Wait;
    
    dispf('\t\tChangeSet: %s\tCaseID: %s\tSetID: %d\tSheetID: %d', ...
      char(dataSources(m).Reader.State), dataSources(m).CaseID, dataSources(m).SetID, dataSources(m).SheetID);
    
    if n==1
      tallyMetadata.CaseMetadata{m}         = dataSources(m).CaseData.metadata;
    end
    
    stats                                   = dataSources(m).Stats;
    
    tallyMetadata.SetNames{m, n}            = [dataSources(m).CaseName ' ' dataSources(m).SetName];
    tallyMetadata.SetData{m, n}             = dataSources(m).SetData;
    tallyMetadata.SetStats{m, n}            = stats;
    
    
    %% Tally run data
    tallyData(m, n).run                     = stats.run;
    tallyData(m, n).runData                 = stats.data;
    tallyData(m, n).runCount                = 1;
    tallyData(m, n).runStats                = tallyData(m, n).run.Stats; % .Sample!
    
    %% Tally sheet data
    tallyData(m, n).sheetCount              = size(tallyData(m, n).runData, 1);
    tallyData(m, n).sheetSize               = [size(tallyData(m, n).runData, 2) size(tallyData(m, n).runData, 3)];
    
    dataFilter                              = stats.filter;
    
    tallyData(m, n).dataFilter              = dataFilter;
    
    for s = 1:tallyData(m, n).sheetCount
      sheetData                             = tallyData(m, n).runData(s, ~dataFilter);
      tallyData(m, n).sheetStats(1, s)      = feval(statsClass, sheetData);
    end
    
    tallyData(m, n).patchIndex              = find(~dataFilter);
    tallyData(m, n).patchCount              = numel(tallyData(m, n).patchIndex);
    
    for p = 1:tallyData(m, n).patchCount
      patchIdx                              = tallyData(m, n).patchIndex(p);
      patchData                             = tallyData(m, n).runData(:,patchIdx);
      tallyData(m, n).patchStats(1,p)       = feval(statsClass, patchData(:));
    end
    
    %% Tally region data
    
    tallyMasks(m).region                    = stats.metadata.regions.sections;
    
    tallyData(m, n).region                  = stats.sections;
    tallyData(m, n).regionCount             = size(tallyData(m, n).region, 1);
    tallyData(m, n).regionStats             = emptyStats();
    
    for s = 1:tallyData(m, n).regionCount
      tallyData(m, n).regionStats(s, :)     = tallyData(m, n).region(s, :).Stats;
      tallyData(m, n).regionSize            = size(tallyMasks(m).region(s));
    end
    
    %% Tally around data
    tallyMasks(m).around                    = stats.metadata.regions.around;
    
    tallyData(m, n).around                  = stats.around;
    tallyData(m, n).aroundCount             = size(tallyData(m, n).around, 1);
    tallyData(m, n).aroundStats             = emptyStats();
    
    for s = 1:tallyData(m, n).aroundCount
      tallyData(m, n).aroundStats(s, :)     = tallyData(m, n).around(s, :).Stats;
      tallyData(m, n).aroundSize            = size(tallyMasks(m).around(s));
    end
    
    %% Tally across data
    tallyMasks(m).across                    = stats.metadata.regions.across;
    
    tallyData(m, n).across                  = stats.across;
    tallyData(m, n).acrossCount             = size(tallyData(m, n).across, 1);
    tallyData(m, n).acrossStats             = emptyStats();
    
    for s = 1:size(tallyData(m, n).across, 1)
      tallyData(m, n).acrossStats(s, :)     = tallyData(m, n).across(s, :).Stats;
      tallyData(m, n).acrossSize            = size(tallyMasks(m).across(s));
    end
    
    %% Tally Zone Data
    if isfield(stats.metadata.regions, 'zones')
      tallyMasks(m).zone                    = stats.metadata.regions.zones;
      tallyData(m, n).zone                  = stats.zones;
      tallyData(m, n).zoneCount             = size(tallyData(m, n).zone, 1);
      tallyData(m, n).zoneStats             = emptyStats();
      
      for s = 1:size(tallyData(m, n).zone, 1)
        tallyData(m, n).zoneStats(s, :)     = tallyData(m, n).zone(s, :).Stats;
        tallyData(m, n).zoneSize            = size(tallyMasks(m).zone(s));
      end
      
      roiIDs                                = [roiIDs, 'zone'];
    else
      tallyData(m, n).zoneCount             = 0;
    end
    
    %% Standard & Tolerance
    standardValue                           = standardValues(n);
    standardTolerance                       = standardTolerances(n);
    
    runData                                 = tallyData(m, n).runData;
    patchIndex                              = tallyData(m, n).patchIndex;
    
    patchCount                              = tallyData(m, n).patchCount;
    sheetCount                              = tallyData(m, n).sheetCount;
    regionCount                             = tallyData(m, n).regionCount;
    aroundCount                             = tallyData(m, n).aroundCount;
    acrossCount                             = tallyData(m, n).acrossCount;
    zoneCount                               = tallyData(m, n).zoneCount;
    
    %% Run Statistics
    
    % Run Mean (Run Accuracy vs. Standard)
    % Mean of all patches across all sheets. Run accuracy has spatial and
    % temporal components with a mean value takeb from samples across the
    % patch (spatial) domain and the sheet (temporal) domain.
    
    % outlierIdx                             = tallyData(m, n).run.Outliers;
    samples                                 = runData(:, ~dataFilter);
    
    nanSamples                              = isnan(samples(:));
    
    tallyStats(m, n).Run.Size               = size(runData);
    tallyStats(m, n).Run.Samples            = sum(~nanSamples);
    tallyStats(m, n).Run.Outliers           = sum(nanSamples);
    
    tallyStats(m, n).Run.Mean               = nanmean(samples(:));
    tallyStats(m, n).Run.Sigma              = nanstd(samples(:));
    
    tallyStats(m, n).Run.Accuracy           = tallyStats(m, n).Run.Mean - standardValue;
    
    referenceValue                          = tallyStats(m, n).Run.Mean;
    
    % Run Precision
    % Spread between upper and lower bounds for all patches across all sheets.
    
    tallyStats(m, n).Run.Precision          = tallyStats(m, n).Run.Sigma*6;
    
    %% Patch Statistics
    
    % Patch Mean (Patch Accuracy ve. Run Mean)
    % Mean of one patch across sheets. Patch is a spatial unit with
    % a mean value taken from samples across the sheet (temporal) domain.
    
    % Patch Repeatability (Patch Precision)
    % Spread between upper and lower bounds for one patch across sheets.
    
    patchMean                               = NaN(1, patchCount);
    patchAccuracy                           = NaN(1, patchCount);
    patchSigma                              = NaN(1, patchCount);
    
    for p=1:patchCount
      
      patchIdx                              = tallyData(m, n).patchIndex(p);
      patchData                             = tallyData(m, n).runData(:,patchIdx);
      
      nanSamples                            = isnan(patchData(:));
      
      tallyStats(m, n).Patch(p).Size        = size(patchData);
      tallyStats(m, n).Patch(p).Samples     = sum(~nanSamples);
      tallyStats(m, n).Patch(p).Outliers    = sum(nanSamples);
      
      tallyStats(m, n).Patch(p).Mean        = tallyData(m, n).patchStats(1, p).Mean;
      tallyStats(m, n).Patch(p).Sigma       = tallyData(m, n).patchStats(1, p).Sigma;
      
      %% Patch Mean (Sheet Accuracy vs. Run Mean)
      % Mean of one patches in all sheets. Each patch is a spatial unit
      % with a mean value taken from samples across the sheets (temporal) domain.
      
      tallyStats(m, n).Patch(p).Accuracy    = tallyStats(m, n).Patch(p).Mean - referenceValue;
      
      %% Patch Repeatability (Patch Precision)
      % Spread between upper and lower bounds for one patch across sheets.
      
      tallyStats(m, n).Patch(p).Precision   = []; % tallyData(m, n).patchStats(1, p).Sigma*6;
      
      tallyStats(m, n).Patch(p).Repeatability = tallyData(m, n).patchStats(1, p).Sigma*6;
      
      tallyStats(m, n).Patch(p).Precision   = tallyStats(m, n).Patch(p).Repeatability;
      
      
      patchMean(p)                          = tallyStats(m, n).Patch(p).Mean;
      patchAccuracy(p)                      = tallyStats(m, n).Patch(p).Accuracy;
      patchSigma(p)                         = tallyStats(m, n).Patch(p).Sigma;
      
    end
    
    
    %% Sheet Statistics
    
    sheetMean                               = NaN(1, sheetCount);
    sheetAccuracy                           = NaN(1, sheetCount);
    sheetSigma                              = NaN(1, sheetCount);
    
    for s=1:sheetCount
      
      sheetData                             = runData(s, ~dataFilter);
      nanSamples                            = isnan(sheetData(:));
      
      tallyStats(m, n).Sheet(s).Size        = size(sheetData);
      tallyStats(m, n).Sheet(s).Samples     = sum(~nanSamples);
      tallyStats(m, n).Sheet(s).Outliers    = sum(nanSamples);
      
      tallyStats(m, n).Sheet(s).Mean        = tallyData(m, n).sheetStats(1, s).Mean;
      tallyStats(m, n).Sheet(s).Sigma       = tallyData(m, n).sheetStats(1, s).Sigma;
      
      %% Sheet Mean (Sheet Accuracy vs. Run Mean)
      % Mean of all patches in one sheet. Each sheet is a temporal unit
      % with a mean value taken from samples across the patch (spatial) domain.
      
      tallyStats(m, n).Sheet(s).Accuracy    = tallyStats(m, n).Sheet(s).Mean - referenceValue;
      
      %% Sheet Evenness (Sheet Precision)
      % Spread between upper and lower bounds for one sheet across patches.
      
      tallyStats(m, n).Sheet(s).Precision   = [];
      tallyStats(m, n).Sheet(s).Evenness    = tallyData(m, n).sheetStats(1, s).Sigma*6;
      
      tallyStats(m, n).Sheet(s).Precision   = tallyStats(m, n).Sheet(s).Evenness;
      
      sheetMean(s)                          = tallyStats(m, n).Sheet(s).Mean;
      sheetAccuracy(s)                      = tallyStats(m, n).Sheet(s).Accuracy;
      sheetSigma(s)                         = tallyStats(m, n).Sheet(s).Sigma;
      
    end
    
    %% Run Statistics (Precision)
    
    % Run Evenness
    % Mean across all sheets of the spread between the upper and lower
    % bounds of all the patches within each sheet. Run evenness is the mean
    % of the sheet evenness across all sheets.
    
    tallyStats(m, n).Run.Evenness                     = nanmean(sheetSigma(:).*6);
    
    % Run Repeatability
    % Spread between the upper and lower bounds of the sheet mean
    % across all sheets.
    
    tallyStats(m, n).Run.Repeatability                = nanmean(patchSigma(:).*6);
    
    
    
    
    %% ROI Statistics
    
    for roiSet = roiIDs
      
      roiID                                 = char(roiSet);
      roiCount                              = tallyData(m, n).([roiID 'Count']);
      roiStats                              = tallyData(m, n).([roiID 'Stats']);
      roiMasks                              = tallyMasks(m).(roiID);
      
      roiSheetMean                          = NaN(roiCount, sheetCount);
      roiSheetSigma                         = NaN(roiCount, sheetCount);
      roiSheetAccuracy                      = NaN(roiCount, sheetCount);
      
      roiData                               = cell(1, roiCount); %NaN(regionCount, sheetCount, regionSize
      
      roiTally                              = struct();
      
      for r = 1:roiCount
        roiMask                             = roiMasks(r,:,:)==1;
        roiMask                             = squeeze(roiMask) & ~dataFilter;
        
        sampleData                          = runData(:, roiMask);
        nanSamples                          = isnan(sampleData(:));
        
        roiTally(r).Size                    = size(sampleData);
        roiTally(r).Samples                 = sum(~nanSamples);
        roiTally(r).Outliers                = sum(nanSamples);
        
        roiTally(r).Mean                    = [];
        roiTally(r).Sigma                   = [];
        
        
        for s=1:sheetCount
          
          roiData{r}(s,:)                   = runData(s, roiMask);
          
          sampleData                        = roiData{r}(s,:);
          nanSamples                        = isnan(sampleData(:));
          
          roiTally(r).Sheet(s).Size         = size(sampleData);
          roiTally(r).Sheet(s).Samples      = sum(~nanSamples);
          roiTally(r).Sheet(s).Outliers     = sum(nanSamples);
          
          
          % ROI Mean
          % Mean of region means in a set of regions in one sheet.
          
          roiTally(r).Sheet(s).Mean         = nanmean(roiData{r}(s,:)); % roiStats(p, s).Mean;
          roiTally(r).Sheet(s).Sigma        = nanstd(roiData{r}(s,:)); % roiStats(p, s).Sigma;
          
          roiTally(r).Sheet(s).Accuracy     = roiTally(r).Sheet(s).Mean - referenceValue;
          
          roiSheetMean(r, s)                = roiTally(r).Sheet(s).Mean;
          roiSheetSigma(r, s)               = roiTally(r).Sheet(s).Sigma;
          roiSheetAccuracy(r, s)            = roiTally(r).Sheet(s).Accuracy;
        end
        
        
        for p=1:size(roiData{r},2) % tallyStats(m, n).Region(r).Count
          patchData                         = roiData{r}(:,p);
          
          nanSamples                        = isnan(patchData(:));
          
          roiTally(r).Patch(p).Size         = size(patchData);
          roiTally(r).Patch(p).Samples      = sum(~nanSamples);
          roiTally(r).Patch(p).Outliers     = sum(nanSamples);
          
          
          roiTally(r).Patch(p).Mean         = nanmean(patchData(:));% tallyData(m, n).regionStats(p, s).Mean;
          roiTally(r).Patch(p).Sigma        = nanstd(patchData(:));% tallyData(m, n).regionStats(p, s).Sigma;
          
          roiTally(r).Patch(p).Accuracy     = roiTally(r).Patch(p).Mean  - referenceValue;
          
          roiPatchMean(r, p)                = roiTally(r).Patch(p).Mean;
          roiPatchSigma(r, p)               = roiTally(r).Patch(p).Sigma;
          roiPatchAccuracy(r, p)            = roiTally(r).Patch(p).Accuracy;
          
        end
        
        
        roiTally(r).Mean                    = nanmean(roiData{r}(:));
        roiTally(r).Sigma                   = nanstd(roiData{r}(:));
        
        % ROI Norm (Band Accuracy)
        % Mean of region means in a set of regions across all sheets.
        
        roiTally(r).Norm                    = roiTally(r).Mean;
        roiTally(r).Accuracy                = roiTally(r).Norm  - referenceValue;
        
        
        % ROI Precision
        % Spread between upper and lower bounds for all the patches in a set of
        % regions across all sheets.
        
        roiTally(r).Precision               = roiTally(r).Sigma*6;
        
        % ROI Evenness
        % Mean across all sheets of the spread between the upper and lower
        % bounds of all the patches in a set of regions within each sheet.
        
        roiTally(r).Evenness                = nanmean(roiSheetSigma(r,:).*6);
        
        % ROI Repeatability
        
        roiTally(r).Repeatability           = nanmean(roiPatchSigma(r,:).*6); % nanstd(roiSheetMean(r,:))*6;
        
      end
      
      roiID = [upper(roiID(1)) roiID(2:end)];
      
      tallyStats(m, n).(roiID)              = roiTally;
    end
    
    
    %     %% Region Statistics
    %
    %     regionSheetMean                                   = NaN(regionCount, sheetCount);
    %     regionSheetSigma                                  = NaN(regionCount, sheetCount);
    %     regionSheetAccuracy                               = NaN(regionCount, sheetCount);
    %
    %     regionData                                        = cell(1, regionCount); %NaN(regionCount, sheetCount, regionSize
    %
    %     for r = 1:regionCount
    %
    %       regionMask                                      = tallyMasks(m).regions(r,:,:)==1;
    %
    %       regionMask                                      = squeeze(regionMask) & ~dataFilter;
    %
    %       sampleData                                      = runData(:, regionMask);
    %       nanSample                                       = isnan(sampleData(:));
    %
    %       tallyStats(m, n).Region(r).Size                 = size(sampleData);
    %       tallyStats(m, n).Region(r).Samples              = sum(~nanSample);
    %       tallyStats(m, n).Region(r).Outliers             = sum(nanSample);
    %
    %       tallyStats(m, n).Region(r).Mean                 = [];
    %       tallyStats(m, n).Region(r).Sigma                = [];
    %
    %       for s=1:sheetCount
    %
    %         regionData{r}(s,:)                            = runData(s, regionMask);
    %
    %         % Region Mean
    %         % Mean of all patches in one region in one sheet. Each region is a
    %         % spatial unit with a mean value take from samples across the patch
    %         % (spatial) domain.
    %
    %         sampleData                                    = regionData{r}(s,:);
    %         nanSamples                                    = isnan(sampleData(:));
    %
    %         tallyStats(m, n).Region(r).Sheet(s).Size      = size(sampleData);
    %         tallyStats(m, n).Region(r).Sheet(s).Samples   = sum(~nanSamples);
    %         tallyStats(m, n).Region(r).Sheet(s).Outliers  = sum(nanSamples);
    %
    %
    %         tallyStats(m, n).Region(r).Sheet(s).Mean      = nanmean(regionData{r}(s,:));% tallyData(m, n).regionStats(p, s).Mean;
    %         tallyStats(m, n).Region(r).Sheet(s).Sigma     = nanstd(regionData{r}(s,:));% tallyData(m, n).regionStats(p, s).Sigma;
    %
    %         tallyStats(m, n).Region(r).Sheet(s).Accuracy  = tallyStats(m, n).Region(r).Sheet(s).Mean  - referenceValue;
    %
    %         regionSheetMean(r, s)                         = tallyStats(m, n).Region(r).Sheet(s).Mean;
    %         regionSheetSigma(r, s)                        = tallyStats(m, n).Region(r).Sheet(s).Sigma;
    %         regionSheetAccuracy(r, s)                     = tallyStats(m, n).Region(r).Sheet(s).Accuracy;
    %       end
    %
    %       for p=1:size(regionData{r},2) % tallyStats(m, n).Region(r).Count
    %         patchData                                     = regionData{r}(:,p);
    %
    %         nanSamples                                    = isnan(patchData(:));
    %
    %         tallyStats(m, n).Region(r).Patch(p).Size      = size(patchData);
    %         tallyStats(m, n).Region(r).Patch(p).Samples   = sum(~nanSamples);
    %         tallyStats(m, n).Region(r).Patch(p).Outliers  = sum(nanSamples);
    %
    %
    %         tallyStats(m, n).Region(r).Patch(p).Mean      = nanmean(patchData(:));% tallyData(m, n).regionStats(p, s).Mean;
    %         tallyStats(m, n).Region(r).Patch(p).Sigma     = nanstd(patchData(:));% tallyData(m, n).regionStats(p, s).Sigma;
    %
    %         tallyStats(m, n).Region(r).Patch(p).Accuracy  = tallyStats(m, n).Region(r).Patch(p).Mean  - referenceValue;
    %
    %         regionPatchMean(r, p)                         = tallyStats(m, n).Region(r).Patch(p).Mean;
    %         regionPatchSigma(r, p)                        = tallyStats(m, n).Region(r).Patch(p).Sigma;
    %         regionPatchAccuracy(r, p)                     = tallyStats(m, n).Region(r).Patch(p).Accuracy;
    %
    %       end
    %
    %
    %       tallyStats(m, n).Region(r).Mean                 = nanmean(regionData{r}(:));
    %       tallyStats(m, n).Region(r).Sigma                = nanstd(regionData{r}(:));
    %
    %       % Region Norm (Region Accuracy)
    %       % Mean of all the patches in one region across all sheets. Each region
    %       % is a spatial unit with a norm value take from samples across both the
    %       % patch (spatial) and sheet (temporal) domains. Norm is also the mean
    %       % of all region means for one region across all sheets.
    %
    %       tallyStats(m, n).Region(r).Norm                 = tallyStats(m, n).Region(r).Mean;
    %       tallyStats(m, n).Region(r).Accuracy             = tallyStats(m, n).Region(r).Norm  - referenceValue;
    %
    %       % Region Precision
    %       % Spread between upper and lower bounds for all patches in one region
    %       % across all sheets.
    %
    %       tallyStats(m, n).Region(r).Precision            = tallyStats(m, n).Region(r).Sigma*6;
    %
    %       % Region Evenness
    %       % Mean across all sheets of the spread between the upper and lower
    %       % bounds of all the patches in one region within each sheet.
    %
    %       tallyStats(m, n).Region(r).Evenness             = nanmean(regionSheetSigma(r,:)*6);
    %
    %       % Region Repeatability
    %       % Spread between upper and lower bounds of region mean across all sheets.
    %
    %       tallyStats(m, n).Region(r).Repeatability        = nanmean(regionPatchSigma(r,:)*6); %nanstd(regionSheetMean(r,:))*6;
    %
    %     end
    %
    %     %% Band Statistics
    %
    %     for bandSet = {'around', 'across'}
    %
    %       band                                              = char(bandSet);
    %       bandCount                                         = tallyData(m, n).([band 'Count']);
    %       bandStats                                         = tallyData(m, n).([band 'Stats']);
    %       bandMasks                                         = tallyMasks(m).(band);
    %
    %       bandSheetMean                                     = NaN(bandCount, sheetCount);
    %       bandSheetSigma                                    = NaN(bandCount, sheetCount);
    %       bandSheetAccuracy                                 = NaN(bandCount, sheetCount);
    %
    %       bandData                                          = cell(1, bandCount); %NaN(regionCount, sheetCount, regionSize
    %
    %       bandTally                                         = struct();
    %
    %       for r = 1:bandCount
    %         bandMask                                        = bandMasks(r,:,:)==1;
    %         bandMask                                        = squeeze(bandMask) & ~dataFilter;
    %
    %         sampleData                                      = runData(:, bandMask);
    %         nanSamples                                      = isnan(sampleData(:));
    %
    %         bandTally(r).Size                               = size(sampleData);
    %         bandTally(r).Samples                            = sum(~nanSample);
    %         bandTally(r).Outliers                           = sum(nanSample);
    %
    %         bandTally(r).Mean                               = [];
    %         bandTally(r).Sigma                              = [];
    %
    %
    %         for s=1:sheetCount
    %
    %           bandData{r}(s,:)                              = runData(s, bandMask);
    %
    %           sampleData                                    = bandData{r}(s,:);
    %           nanSamples                                    = isnan(sampleData(:));
    %
    %           bandTally(r).Sheet(s).Size                    = size(sampleData);
    %           bandTally(r).Sheet(s).Samples                 = sum(~nanSamples);
    %           bandTally(r).Sheet(s).Outliers                = sum(nanSamples);
    %
    %
    %           % Band Mean
    %           % Mean of region means in a set of regions in one sheet.
    %
    %           bandTally(r).Sheet(s).Mean                    = nanmean(bandData{r}(s,:)); % bandStats(p, s).Mean;
    %           bandTally(r).Sheet(s).Sigma                   = nanstd(bandData{r}(s,:)); % bandStats(p, s).Sigma;
    %
    %           bandTally(r).Sheet(s).Accuracy                = bandTally(r).Sheet(s).Mean - referenceValue;
    %
    %           bandSheetMean(r, s)                           = bandTally(r).Sheet(s).Mean;
    %           bandSheetSigma(r, s)                          = bandTally(r).Sheet(s).Sigma;
    %           bandSheetAccuracy(r, s)                       = bandTally(r).Sheet(s).Accuracy;
    %         end
    %
    %
    %         for p=1:size(bandData{r},2) % tallyStats(m, n).Region(r).Count
    %           patchData                                     = bandData{r}(:,p);
    %
    %           nanSamples                                    = isnan(patchData(:));
    %
    %           bandTally(r).Patch(p).Size                    = size(patchData);
    %           bandTally(r).Patch(p).Samples                 = sum(~nanSamples);
    %           bandTally(r).Patch(p).Outliers                = sum(nanSamples);
    %
    %
    %           bandTally(r).Patch(p).Mean                    = nanmean(patchData(:));% tallyData(m, n).regionStats(p, s).Mean;
    %           bandTally(r).Patch(p).Sigma                   = nanstd(patchData(:));% tallyData(m, n).regionStats(p, s).Sigma;
    %
    %           bandTally(r).Patch(p).Accuracy                = bandTally(r).Patch(p).Mean  - referenceValue;
    %
    %           bandPatchMean(r, p)                           = bandTally(r).Patch(p).Mean;
    %           bandPatchSigma(r, p)                          = bandTally(r).Patch(p).Sigma;
    %           bandPatchAccuracy(r, p)                       = bandTally(r).Patch(p).Accuracy;
    %
    %         end
    %
    %
    %         bandTally(r).Mean                               = nanmean(bandData{r}(:));
    %         bandTally(r).Sigma                              = nanstd(bandData{r}(:));
    %
    %         % Band Norm (Band Accuracy)
    %         % Mean of region means in a set of regions across all sheets.
    %
    %         bandTally(r).Norm                               = bandTally(r).Mean;
    %         bandTally(r).Accuracy                           = bandTally(r).Norm  - referenceValue;
    %
    %
    %         % Band Precision
    %         % Spread between upper and lower bounds for all the patches in a set of
    %         % regions across all sheets.
    %
    %         bandTally(r).Precision                          = bandTally(r).Sigma*6;
    %
    %         % Band Evenness
    %         % Mean across all sheets of the spread between the upper and lower
    %         % bounds of all the patches in a set of regions within each sheet.
    %
    %         bandTally(r).Evenness                           = nanmean(bandSheetSigma(r,:).*6);
    %
    %         % Band Repeatability
    %
    %         bandTally(r).Repeatability                      = nanmean(bandPatchSigma(r,:).*6); % nanstd(bandSheetMean(r,:))*6;
    %
    %       end
    %
    %       band = [upper(band(1)) band(2:end)];
    %
    %       tallyStats(m, n).(band)                     = bandTally;
    %     end
    
  end
  
end

tally.Metadata  = tallyMetadata;
tally.Data      = tallyData;
tally.Stats     = tallyStats;
tally.Masks     = tallyMasks;

save(fullfile('Output', 'tallyStats.mat'), '-struct', 'tally'); %, 'tallyStats', 'tallyData', 'tallyMasks');



%
%     %% Sheet Evenness
%     % Sheet evenness is calculated from the varaibility between the summary of
%     % the patches across all sheets. Spatial accuracy is the spread of the
%     % cross-sheet means across all patches. Spatial precision is the spread
%     % of the cross-sheet spread across all patches. The mean and spread is
%     % first detemined for every single patch by taking the values across
%     % all sheets for each patch.
%     tallyStats(m, n).sheet.spatial.Mean    = feval(statsClass, tallyStats(m, n).spatial.Mean);
%     tallyStats(m, n).sheet.spatial.Sigma   = feval(statsClass, tallyStats(m, n).spatial.Sigma);
%
%     %% Sheet Repeatability
%     % Sheet repeatability is calculated from the variability between the
%     % summary of the sheets across all patches. Temporal accruacy is the
%     % spread of the cross-patch means across all sheets. Temporal precision
%     % is the spread of the cross-patch spread across all sheets.. The mean and
%     % spread is first determined for every single sheet by taking the
%     % values across all the patches for each sheet.
%     tallyStats(m, n).sheet.temporal.Mean    = feval(statsClass, tallyStats(m, n).temporal.Mean);
%     tallyStats(m, n).sheet.temporal.Sigma   = feval(statsClass, tallyStats(m, n).temporal.Sigma);
%
%     %% Region Evenness
%     % Region evenness is calculated from the varaibility between the summary of
%     % the patches within a given region across all sheets. Spatial region
%     % accuracy is the spread of the cross-sheet means across all patches
%     % within the region. Spatial region precision is the spread of the
%     % cross-sheet spread across all patches within the region. The mean and
%     % spread is first detemined for every single patch within the region by
%     % taking the values across all sheets for each patch.
%
%
%     %     for p = 1:tallyData(m, n).aroundCount
%     %       %tallyStats(m, n).around(p).spatial.Data  = tallyData(m, n).acrossStats(p, :);
%     %       tallyStats(m, n).around(p).spatial.Mean  = feval(statsClass, tallyStats(m, n).spatial.Mean);
%     %       tallyStats(m, n).around(p).spatial.Sigma = feval(statsClass, tallyStats(m, n).spatial.Sigma);
%     %     end
%
%
%     %% Region Repeatability
%     % Region repeatability is calculated from the variability between the
%     % summary of the sheets across all patches within a given region.
%     % Temporal region accruacy is the spread of the cross-patch means
%     % across all sheets for the patches in the region. Temporal precision
%     % is the spread of the cross-patch spread across all sheets for the
%     % patches in the region. The mean and spread is first determined for
%     % every single sheet by taking the values across all the patches within
%     % the reagion for each sheet.
%
%     %% Directional Evenness
%     % Directional evenness is the variability between the band evenness values
%     % of the all the bands in a given direction (axial or circumferential).
%     % Spatial directional accruacy is the spread of the means across bands.
%     % Spatial directional precision is the spread of the spread across bands.
%
%     %     tallyStats(m, n).axial.spatial.Mean    = feval(statsClass, tallyData(m, n).aroundStats);
%     %     tallyStats(m, n).axial.spatial.Sigma   = feval(statsClass, tallyStats(m, n).spatial.Sigma);
%
%     %% Directional Repeatability
%     % Directional repeatability is the variability between the band
%     % repeatability values of the all the bands in a given direction (axial
%     % or circumferential). Temporal direction accruacy is the spread of the
%     % means across bands. Temporal precision is the spread of the spread
%     % across the bands.
