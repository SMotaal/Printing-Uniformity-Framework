function [ sheetData ] = getSheetData(obj, sheetID) %, newData, parameters, variableData)
  %GetSheetData Load and Get Sheet Data
  %   Detailed explanation goes here
  
  sheetData                     = [];
  
  if nargin<2, sheetID          = obj.SheetID; end
  
  if isempty(sheetID), return; end
  
  sheetData                     = obj.SheetData;
  if ~isempty(sheetData), return; end
  
  setData                       = obj.getSetData();
  
  if isempty(obj.Sheets)
    obj.updateSheets();
  end
  
  dataMap                       = obj.Sheets;
  
  sheetKey                      = num2str(sheetID, '#%d');
  
  if dataMap.isKey(sheetKey)
    sheetData                   = dataMap(sheetKey);
  end
  
  if nargin<2, obj.SheetData    = sheetData; end
  
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
