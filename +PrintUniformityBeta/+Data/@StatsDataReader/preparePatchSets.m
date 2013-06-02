function preparePatchSets(obj)
  %PREPAREPATCHSETS Populate obj.PatchSets with PatchSetModel
  %   Detailed explanation goes here
  
  % if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end
  
  if isempty(obj.cases), obj.prepareCases; end
  
  setIDs                    = obj.sourceMetadata.Sets.IDs;
  setNames                  = obj.sourceMetadata.Sets.Names;
  
  setEntries                = cell(size(setNames));
  
  caseIDs                   = obj.cases.keys;
  
  for m = 1:numel(caseIDs)
    caseID                  = caseIDs{m};
    caseData                = obj.cases(caseID);
    caseFiles               = caseData.Files;
    caseMasksFile           = caseFiles.Masks;
    caseStatsFiles          = caseFiles.Stats;
    caseRegionFields        = fieldnames(caseStatsFiles);
    
    for n = 1:numel(setIDs)
      setID                 = setIDs(n);
      
      setEntry              = struct();
      setEntry.ID           = setID;
      setEntry.CaseID       = caseID;
      setEntry.Name         = setNames{m, n};
      
      setEntry.Files        = struct(...
        'CaseID',   caseID,           'SetID',  setID, ...
        'Path',     caseFiles.Path,   'Masks',  caseMasksFile, ...
        'Stats', struct());
      
      setEntry.Regions      = struct();
      setEntry.Sheets       = struct();
      
      setStatsField         = ['TV' int2str(setID)];
      
      for p = 1:numel(caseRegionFields)
        regionStatsField    = caseRegionFields{p};
        setEntry.Files.Stats.(regionStatsField) = caseStatsFiles.(regionStatsField).(setStatsField);
      end
      
      setEntries{m, n}      = setEntry;
    end
  end
  
  patchSets                 = PrintUniformityBeta.Models.PatchSetModel(caseIDs, setIDs, setEntries);
  
  obj.patchSets             = patchSets;
  
end
