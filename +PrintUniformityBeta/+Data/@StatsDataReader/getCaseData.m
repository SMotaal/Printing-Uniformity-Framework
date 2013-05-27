function [ caseData ] = getCaseData(obj, caseID) %, parameters)
  caseData                  = obj.Data.CaseData;
  
  if nargin<2, caseID       = obj.CaseID; end
  if (isempty(caseID) || ~ischar(caseID)), return; end
  
  settingCaseData           = ...
    isempty(caseData) || ~isfield(caseData, 'Symbol') || ~strcmpi(caseData.Symbol, caseID);
  % % ( isfield(caseData, 'ID') &&  strcmpi(caseData.ID, caseID)) || ...
  
  if ~settingCaseData, return; end
  
  caseData                  = obj.cases(caseID);
  
  obj.Data.CaseData         = caseData; % if nargin<2, obj.CaseData = caseData; end
  
  %% Update IDs
  longID                    = caseData.ID;
  regionIDs                 = obj.Data.CaseData.Index.Regions;
  setIDs                    = obj.Data.CaseData.Index.PatchSets;
  
  try obj.regionIDs         = setdiff(unique(['Sheet'; regionIDs], 'Stable'), 'Run', 'Stable'); end
  try obj.setIDs            = sort(setIDs); end
  
  dispf('\t%s:\t%s\n\t\tSetIDs: [%s]\n\t\tRegionIDs: {%s}', caseID, upper(longID),  toString(obj.setIDs), toString(obj.regionIDs{:}));
  
  %% Clear Set & Sheet Data
  obj.Data.SheetData        = [];
  obj.Data.SetData          = [];
  
  % Get Set Data
  if nargout==0, obj.getSetData(); end
end
