%% tallyRegionStats1

cleardebug; cleardebug;

dataSourceClass     = 'PrintUniformityBeta.Data.RegionPlotDataSource';
statsClass          = 'GrasppeAlpha.Stats.TransientStats';

emptySource         = @()eval([dataSourceClass '.empty();']);
emptyStats          = @()eval([statsClass '.empty();']);

caseIDs             = {'rithp5501', 'rithp7k01', 'ritsm7402a', 'ritsm7402b', 'ritsm7402c'}; 
% {'rithp5501', 'ritsm7402a'}; %{'ritsm74001'}; {'ritsm7402a'};

setIDs              = [100 75 50 25 0];

% standardValues      = [16 NaN NaN NaN 93];  % Black Backing (12647-2)
standardValues      = [ 16  41  62  80	95];  % White Backing Informative (Photoshop Fogra39 > Absolute Colorimetric > Lab)
standardTolerances  = [ 4   4   4   4   3];   % Extrapolated from ISO 12647-2

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
tallyMetadata.CaseMetadata      = cell(1, caseCount);
tallyMetadata.SetIDs            = setIDs;
tallyMetadata.SetNames          = cell(caseCount, setCount);
tallyMetadata.SetData           = cell(caseCount, setCount);
tallyMetadata.SetStats          = cell(caseCount, setCount);
tallyMetadata.Standard          = standardValues;
tallyMetadata.Tolerance         = standardTolerances;


for m = 1:caseCount
  
  sourceID                        = caseIDs{m};
  
  for n = 1:setCount
    
    setID                         = setIDs(n);
    
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
      tallyMetadata.CaseMetadata{m}     = dataSources(m).CaseData.metadata;
    end
    
    stats                               = dataSources(m).Stats;
    
    tallyMetadata.SetNames{m, n}        = [dataSources(m).CaseName ' ' dataSources(m).SetName];
    tallyMetadata.SetData{m, n}         = dataSources(m).SetData;
    tallyMetadata.SetStats{m, n}        = stats;
    
    
    %% Tally run data
    tallyData(m, n).run                 = stats.run;
    tallyData(m, n).runData             = stats.data;
    tallyData(m, n).runCount            = 1;
    tallyData(m, n).runStats            = tallyData(m, n).run.Stats; % .Sample!
    
    %% Tally sheet data
    tallyData(m, n).sheetCount          = size(tallyData(m, n).runData, 1);
    tallyData(m, n).sheetSize           = [size(tallyData(m, n).runData, 2) size(tallyData(m, n).runData, 3)];
    
    % targetFilter              = stats.metadata.masks.Target~=1;
    % patchFilter               = stats.metadata.setData.filterData.dataFilter~=1;
    %
    % runData                   = stats.data;
    % runData(:, targetFilter)  = NaN;
    % runData(:, patchFilter)   = NaN;
    
    dataFilter                          = stats.filter;
    
    tallyData(m, n).dataFilter          = dataFilter;
    
    for s = 1:tallyData(m, n).sheetCount
      
      sheetData                         = tallyData(m, n).runData(s, ~dataFilter);
      tallyData(m, n).sheetStats(1, s)  = feval(statsClass, sheetData);

      % tallyData(m, n).sheetStats(1, s)  = feval(statsClass, tallyData(m, n).runData(s, :, :));
    end
    
    %% Tally region data
    
    tallyMasks(m).regions               = stats.metadata.regions.sections;
    
    tallyData(m, n).regions             = stats.sections;
    tallyData(m, n).regionCount         = size(tallyData(m, n).regions, 1);
    tallyData(m, n).regionStats         = emptyStats();
    
    for s = 1:tallyData(m, n).regionCount
      tallyData(m, n).regionStats(s, :) = tallyData(m, n).regions(s, :).Stats;
      tallyData(m, n).regionSize        = size(tallyMasks(m).regions(s));
    end
    
    %% Tally around data
    tallyMasks(m).around                = stats.metadata.regions.around;
    
    tallyData(m, n).around              = stats.around;
    tallyData(m, n).aroundCount         = size(tallyData(m, n).around, 1);
    tallyData(m, n).aroundStats         = emptyStats();
    
    for s = 1:tallyData(m, n).aroundCount
      tallyData(m, n).aroundStats(s, :) = tallyData(m, n).around(s, :).Stats;
      tallyData(m, n).aroundSize        = size(tallyMasks(m).around(s));
    end
    
    %% Tally across data
    tallyMasks(m).across                = stats.metadata.regions.across;
    
    tallyData(m, n).across              = stats.across;
    tallyData(m, n).acrossCount         = size(tallyData(m, n).across, 1);
    tallyData(m, n).acrossStats         = emptyStats();
    
    for s = 1:size(tallyData(m, n).across, 1)
      tallyData(m, n).acrossStats(s, :) = tallyData(m, n).across(s, :).Stats;
      tallyData(m, n).acrossSize        = size(tallyMasks(m).across(s));
    end
    
    %% Standard & Tolerance
    standardValue                           = standardValues(n);
    standardTolerance                       = standardTolerances(n);
    
    runData                                 = tallyData(m, n).runData;
    sheetCount                              = tallyData(m, n).sheetCount;
    regionCount                             = tallyData(m, n).regionCount;
    
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
    
    % Run Uniformity
    % Spread between upper and lower bounds for all patches across all sheets.
    
    tallyStats(m, n).Run.Uniformity         = tallyStats(m, n).Run.Sigma*6;
    
    % Patch Mean (Patch Accuracy ve. Run Mean)
    % Mean of one patch across sheets. Patch is a spatial unit with
    % a mean value taken from samples across the sheet (temporal) domain.
    
    % Patch Repeatability (Patch Uniformity)
    % Spread between upper and lower bounds for one patch across sheets.
    
    sheetMean                               = NaN(1, sheetCount);
    sheetAccuracy                           = NaN(1, sheetCount);
    sheetEvenness                           = NaN(1, sheetCount);
    
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
      
      %% Sheet Evenness (Sheet Uniformity)
      % Spread between upper and lower bounds for one sheet across patches.
      
      tallyStats(m, n).Sheet(s).Evenness    = tallyData(m, n).sheetStats(1, s).Sigma*6;
      
      sheetMean(s)                          = tallyStats(m, n).Sheet(s).Mean;
      sheetAccuracy(s)                      = tallyStats(m, n).Sheet(s).Accuracy;
      sheetEvenness(s)                      = tallyStats(m, n).Sheet(s).Evenness;
      
    end
    
    % Run Evenness
    % Mean across all sheets of the spread between the upper and lower
    % bounds of all the patches within each sheet. Run evenness is the mean
    % of the sheet evenness across all sheets.
    
    tallyStats(m, n).Run.Evenness               = nanmean(sheetEvenness(:));
    
    % Run Repeatability
    % Spread between the upper and lower bounds of the sheet mean
    % across all sheets.
    
    tallyStats(m, n).Run.Repeatability          = nanstd(sheetMean(:))*6;
    
    
    %% Region Statistics
    
    regionMean                                  = NaN(regionCount, sheetCount);
    regionSigma                                 = NaN(regionCount, sheetCount);
    regionAccuracy                              = NaN(regionCount, sheetCount);
    
    regionData                                  = cell(1, regionCount); %NaN(regionCount, sheetCount, regionSize
    
    for p = 1:regionCount
      
      regionMask                                      = tallyMasks(m).regions(p,:,:)==1;
      
      regionMask                                      = squeeze(regionMask) & ~dataFilter;
      
      sampleData                                      = runData(:, regionMask);
      nanSample                                       = isnan(sampleData(:));
      
      tallyStats(m, n).Region(p).Size                 = size(sampleData);
      tallyStats(m, n).Region(p).Samples              = sum(~nanSample);
      tallyStats(m, n).Region(p).Outliers             = sum(nanSample);
      
      tallyStats(m, n).Region(p).Mean                 = [];
      tallyStats(m, n).Region(p).Sigma                = [];
      
      for s=1:sheetCount
        
        regionData{p}(s,:)                            = runData(s, regionMask);
        
        % Region Mean
        % Mean of all patches in one region in one sheet. Each region is a
        % spatial unit with a mean value take from samples across the patch
        % (spatial) domain.
        
        sampleData                                    = regionData{p}(s,:);
        nanSamples                                    = isnan(sampleData(:));
        
        tallyStats(m, n).Region(p).Sheet(s).Size      = size(sampleData);
        tallyStats(m, n).Region(p).Sheet(s).Samples   = sum(~nanSamples);
        tallyStats(m, n).Region(p).Sheet(s).Outliers  = sum(nanSamples);
        
        
        tallyStats(m, n).Region(p).Sheet(s).Mean      = nanmean(regionData{p}(s,:));% tallyData(m, n).regionStats(p, s).Mean;
        tallyStats(m, n).Region(p).Sheet(s).Sigma     = nanstd(regionData{p}(s,:));% tallyData(m, n).regionStats(p, s).Sigma;
        
        tallyStats(m, n).Region(p).Sheet(s).Accuracy  = tallyStats(m, n).Region(p).Sheet(s).Mean  - referenceValue;
        
        regionMean(p, s)                              = tallyStats(m, n).Region(p).Sheet(s).Mean;
        regionSigma(p, s)                             = tallyStats(m, n).Region(p).Sheet(s).Sigma;
        regionAccuracy(p, s)                          = tallyStats(m, n).Region(p).Sheet(s).Accuracy;
      end
      
      tallyStats(m, n).Region(p).Mean           = nanmean(regionData{p}(:));
      tallyStats(m, n).Region(p).Sigma          = nanstd(regionData{p}(:));
      
      % Region Norm (Region Accuracy)
      % Mean of all the patches in one region across all sheets. Each region
      % is a spatial unit with a norm value take from samples across both the
      % patch (spatial) and sheet (temporal) domains. Norm is also the mean
      % of all region means for one region across all sheets.
      
      tallyStats(m, n).Region(p).Norm           = tallyStats(m, n).Region(p).Mean;
      tallyStats(m, n).Region(p).Accuracy       = tallyStats(m, n).Region(p).Norm  - referenceValue;
      
      % Region Uniformity
      % Spread between upper and lower bounds for all patches in one region
      % across all sheets.
      
      tallyStats(m, n).Region(p).Uniformity   	= tallyStats(m, n).Region(p).Sigma*6;
      
      % Region Evenness
      % Mean across all sheets of the spread between the upper and lower
      % bounds of all the patches in one region within each sheet.
      
      tallyStats(m, n).Region(p).Evenness       = nanmean(regionSigma(p,:)*6);
      
      % Region Repeatability
      % Spread between upper and lower bounds of region mean across all sheets.
      
      tallyStats(m, n).Region(p).Repeatability  = nanstd(regionMean(p,:))*6;
      
    end
    
    %% Band Statistics
    
    for bandSet = {'around', 'across'}
      
      band                                      = char(bandSet);
      bandCount                                 = tallyData(m, n).([band 'Count']);
      bandStats                                 = tallyData(m, n).([band 'Stats']);
      bandMasks                                 = tallyMasks(m).(band);
      
      bandMean                                  = NaN(bandCount, sheetCount);
      bandSigma                                 = NaN(bandCount, sheetCount);
      bandAccuracy                              = NaN(bandCount, sheetCount);
      
      bandData                                  = cell(1, bandCount); %NaN(regionCount, sheetCount, regionSize
      
      bandTally                                 = struct();
      
      for p = 1:bandCount
        bandMask                                = bandMasks(p,:,:)==1;
        bandMask                                = squeeze(bandMask) & ~dataFilter;
        
        sampleData                              = runData(:, bandMask);
        nanSamples                              = isnan(sampleData(:));
        
        bandTally(p).Size         = size(sampleData);
        bandTally(p).Samples      = sum(~nanSample);
        bandTally(p).Outliers     = sum(nanSample);
        
        bandTally(p).Mean         = [];
        bandTally(p).Sigma        = [];
        
        
        for s=1:sheetCount
          
          bandData{p}(s,:)                      = runData(s, bandMask);
          
          sampleData                            = bandData{p}(s,:);
          nanSamples                            = isnan(sampleData(:));
          
          bandTally(p).Sheet(s).Size            = size(sampleData);
          bandTally(p).Sheet(s).Samples         = sum(~nanSamples);
          bandTally(p).Sheet(s).Outliers        = sum(nanSamples);
          
          
          % Band Mean
          % Mean of region means in a set of regions in one sheet.
          
          bandTally(p).Sheet(s).Mean            = nanmean(bandData{p}(s,:)); % bandStats(p, s).Mean;
          bandTally(p).Sheet(s).Sigma           = nanstd(bandData{p}(s,:)); % bandStats(p, s).Sigma;
          
          bandTally(p).Sheet(s).Accuracy        = bandTally(p).Sheet(s).Mean - referenceValue;
          
          bandMean(p, s)                        = bandTally(p).Sheet(s).Mean;
          bandSigma(p, s)                       = bandTally(p).Sheet(s).Sigma;
          bandAccuracy(p, s)                    = bandTally(p).Sheet(s).Accuracy;
        end
        
        bandTally(p).Mean                       = nanmean(bandData{p}(:));
        bandTally(p).Sigma                      = nanstd(bandData{p}(:));
        
        % Band Norm (Band Accuracy)
        % Mean of region means in a set of regions across all sheets.
        
        bandTally(p).Norm                         = bandTally(p).Mean;
        bandTally(p).Accuracy                     = bandTally(p).Norm  - referenceValue;
        
        
        % Band Uniformity
        % Spread between upper and lower bounds for all the patches in a set of
        % regions across all sheets.
        
        bandTally(p).Uniformity                   = bandTally(p).Sigma*6;
        
        % Band Evenness
        % Mean across all sheets of the spread between the upper and lower
        % bounds of all the patches in a set of regions within each sheet.
        
        bandTally(p).Evenness                     = nanmean(bandSigma(p,:)*6);
        
        % Band Repeatability
        % Spread between upper and lower bounds for band mean for a set of
        % regions across all sheets.
        
        bandTally(p).Repeatability                = nanstd(bandMean(p,:))*6;
        
      end
      
      band = [upper(band(1)) band(2:end)];
      
      tallyStats(m, n).(band)                     = bandTally;
    end
    
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
