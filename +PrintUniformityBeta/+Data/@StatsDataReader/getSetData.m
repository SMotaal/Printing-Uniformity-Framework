function [ setData ] = getSetData(obj, setID, caseID, regionMode) %, parameters)
  setData                   = obj.SetData;
  
  if nargin<2, setID        = obj.SetID;      end
  if nargin<3, caseID       = obj.CaseID;     end
  if nargin<4, regionMode   = obj.RegionMode; end
  
  if (isempty(caseID) || ~ischar(caseID)) || ...
      (~isscalar(setID) && ~isnumeric(setID)) || ...
      (isempty(regionMode) || ~ischar(regionMode)), return; end
  
  settingSetData            = ...
    isempty(setData) || ( ...
    ( isfield(setData, 'CaseID') &&  strcmpi(setData.CaseID, caseID)) && ...
    ( isfield(setData, 'ID') &&  strcmpi(setData.ID, setID)) ...
    );
  
  if ~settingSetData, return; end
  
  caseData                  = obj.getCaseData(caseID);
  
  patchSets                 = obj.PatchSets;
  
  %% PatchSet Data
  setData                   = patchSets.getPatchSet(caseID, setID);
  
  %% RegionSet Data
  setKey                    = num2str(setID, 'TV%d');
  regionKey                 = [caseID ':' regionMode];
  
  regionSetData             = getRegionSetData(obj, regionKey, setKey);
  
  setData.Regions.(regionMode)  = regionSetData; % @()obj.RegionSets(regionKey); %
  
  % patchSets.setPatchSet(caseID, setID, setData);
  
  obj.Data.SetData          = setData; % if nargin<2, obj.SetData  = setData; end
  
  
  
  %% Clear Sheet Data
  obj.SheetData             = [];
  
  obj.updateSheets();
  
  % Get Sheet Data
  if nargout==0
    obj.getSheetData();
  else
    setData                 = obj.PatchSets.getPatchSet(caseID, setID);
  end
end


function regionPatchSetData = getRegionSetData(obj, regionKey, setKey)
  
  % setKey                    = num2str(setKey, 'TV%d');
  regionIDs                 = obj.RegionSets(regionKey).RegionIDs;
  
  regionSetData             = struct();
  
  try regionSetData         = obj.RegionSets(regionKey).Data; end
    
  regionPatchSetData        = struct();
  try regionPatchSetData    = regionSetData.(setKey); end
    
  for m = 1:numel(regionIDs)
    
    regionID                = regionIDs{m};
    
    if ~isfield(regionSetData, regionID)
      
      regionsFile           = obj.getCaseFile(obj.CaseData.ID, setKey(3:end), regionID); % obj.getSourceFile(
      dataStruct            = load(regionsFile, regionID);
      regionData            = dataStruct.(regionID);
      
      regionPatchSetData.(regionID)  = regionData;
      
    end
    
  end
  
  regionSetData.(setKey)    = regionPatchSetData;
  
  regionSet                 = obj.RegionSets(regionKey);
  regionSet.Data            = regionSetData;
  
  obj.RegionSets(regionKey) = regionSet;
end
