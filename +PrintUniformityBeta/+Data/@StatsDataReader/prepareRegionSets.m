function prepareRegionSets(obj)
  %PREPAREREGIONSETS Summary of this function goes here
  %   Detailed explanation goes here
  
  if isempty(obj.cases), obj.prepareCases; end
  
  processModes                    = isequal(obj.ProcessRegionModes, true);
  
  if processModes
    regionModeRules               = obj.regionModeRules;
    regionModeIDs                 = regionModeRules(:,1);
    regionModeConstraints         = regionModeRules(:,2);
    regionModeNames               = regionModeRules(:,3);
    regionModeCount               = numel(regionModeIDs);
  end
  
  cases                           = obj.cases;
  caseIDs                         = cases.keys;
  caseCount                       = cases.length;
  
  %regionEntries             = cell(1, regionModeCount);
  
  regionStruct                    = struct();
  regionNames                     = {}; % cell(1, regionModeCount*caseCount);
  regionEntries                   = {}; % cell(1, regionModeCount*caseCount);
  
  for m = 1:caseCount
    caseID                        = caseIDs{m};
    caseData                      = cases(caseID);
    caseFiles                     = caseData.Files;
    caseMasksFile                 = caseFiles.Masks;
    caseStatsFiles                = caseFiles.Stats;
    caseRegionFields              = fieldnames(caseStatsFiles);
    
    caseRegionIDs                 = caseData.Index.Regions;
    
    if processModes
      caseRegionModes             = {};
      caseRegionModeRegionIDs     = {};
      caseRegionModeNames         = {};
      
      for n = 1:regionModeCount
        if stropt(regionModeRules{n,2}, caseRegionIDs)
          caseRegionModes         = [caseRegionModes regionModeRules{n,1}];
          caseRegionModeRegionIDs = [caseRegionModeRegionIDs {regionModeRules{n,2}}];
          caseRegionModeNames     = [caseRegionModeNames regionModeRules{n,3}];
        end
      end
    else
      caseRegionModes             = {'Full'};
      caseRegionModeRegionIDs     = {{'Run', 'Sheet', 'Around', 'Across', 'Region'}};         % 'Zone', 'Patch'
      caseRegionModeNames         = {'Full-Grid'};
    end
    
    for n = 1:numel(caseRegionModes)
      regionMode                  = caseRegionModes{n};
      regionIDs                   = caseRegionModeRegionIDs{n};
      regionModeName              = caseRegionModeNames{n};
      
      entry                       = struct();
      entry.RegionMode            = regionMode;
      entry.RegionName            = regionModeName;
      entry.CaseID                = caseID;
      entry.Key                   = caseID;
      entry.RegionIDs             = regionIDs;
      
      entry.Key                   = [caseID ':' regionMode];
      
      entry.Files                 = struct(...
        'CaseID',   caseID,           'RegionMode',  regionMode, ...
        'Path',     caseFiles.Path,   'Masks',  caseMasksFile, ...
        'Stats',    rmfield(caseStatsFiles, setdiff(caseRegionFields, regionIDs)));
      
      regionStruct.(regionMode).(caseID) = entry;
      regionNames                 = [regionNames, entry.Key];
      regionEntries               = [regionEntries, entry];
      
    end
    
  end
  
  regionSets                      = PrintUniformityBeta.Models.RegionSetModel(regionStruct); % regionNames, regionEntries);
  
  obj.regionSets                  = regionSets;
    
end
