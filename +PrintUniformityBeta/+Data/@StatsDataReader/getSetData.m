function [ setData ] = getSetData(obj, setID, caseID, regionMode) %, parameters)
  
  persistent RegionSetData SourcePath;
  
  setData                         = obj.SetData;
  
  processModes                    = isequal(obj.ProcessRegionModes, true);
  
  if nargin<2, setID              = obj.SetID;      end
  if nargin<3, caseID             = obj.CaseID;     end
  if nargin<4, regionMode         = obj.RegionMode; end
  
  if (isempty(caseID) || ~ischar(caseID)) || ...
      (~isscalar(setID) && ~isnumeric(setID)) || ...
      (processModes && (isempty(regionMode) || ~ischar(regionMode)))
    return
    % ProcessRegionModes default false: 0 && (* || *) = false => proceed...
  end
  
  settingSetData                  = true;
  
  try
    differentCase                 = ~isfield(setData, 'CaseID') || strcmpi(setData.CaseID, caseID );
    differentSet                  = ~isfield(setData, 'ID'    ) || strcmpi(setData.ID, setID      );
    
    settingSetData                = isempty(setData) || differentCase || differentSet;
  end
  
  if ~settingSetData, return; end
  
  sourcePath                      = obj.SourcePath;
  caseData                        = obj.getCaseData(caseID);
  
  %% PatchSet Data
  patchSets                       = obj.PatchSets;
  setData                         = patchSets.getPatchSet(caseID, setID);
  setKey                          = num2str(setID, 'TV%d');
  
  %% RegionSetData Cache
  if isempty(RegionSetData), RegionSetData = containers.Map(); end
  
  %% RegionSet Data
  if ~processModes, regionMode    = 'Full'; end
  
  % regionKey                       = [caseID               ];
  regionKey                       = [caseID ':' regionMode];
  
  regionSetKey                    = [regionKey ':' setKey];
  
  if isequal(sourcePath, SourcePath) && RegionSetData.isKey(regionSetKey)
    regionSetData                 = RegionSetData(regionSetKey);
  else
    regionSetData                 = getRegionSetData(obj, regionKey, setKey);
    RegionSetData(regionSetKey)   = regionSetData;
    SourcePath                    = sourcePath;
  end
  
  % setData.Regions.(regionMode)    = regionSetData; % @()obj.RegionSets(regionKey); %
  
  if processModes
    regionModes                   = {regionMode};
    try regionModes               = unique([regionMode, setData.Regions.Modes]); end
    setData.Regions.Modes         = regionModes;
    setData.Regions.(regionMode)  = regionSetData; % @()obj.RegionSets(regionKey); %
  else
    setData.Regions               = struct;
    setData.Regions               = regionSetData;
  end
  
  % patchSets.setPatchSet(caseID, setID, setData);
  
  obj.Data.SetData                = setData; % if nargin<2, obj.SetData  = setData; end
  
  %% Clear Sheet Data
  obj.SheetData                   = [];
  
  obj.updateSheets();
  
  % Get Sheet Data
  if nargout==0
    obj.getSheetData();
  else
    setData                       = obj.PatchSets.getPatchSet(caseID, setID);
  end
end


function regionSetData = getRegionSetData(obj, regionKey, setKey)
  
  % setKey                    = num2str(setKey, 'TV%d');
  regionIDs                 = ['Run', 'Sheet', obj.RegionSets(regionKey).RegionIDs];
  
  regionSets                = struct();
  
  try regionSets            = obj.RegionSets(regionKey).Data; end
  
  regionSetData             = struct();
  try regionSetData         = regionSets.(setKey); end
  
  for m = 1:numel(regionIDs)
    
    regionID                = regionIDs{m};
    
    if ~isfield(regionSets, regionID)
      
      regionsFile           = obj.getCaseFile(obj.CaseData.ID, setKey(3:end), regionID); % obj.getSourceFile(
      dataStruct            = load(regionsFile, regionID);
      regionData            = dataStruct.(regionID);
      
      if isfield(regionData, 'Position')
        
        regionPositions       = {regionData.Position};
        regionRows            = cell2mat(cellfun(@(x)x.Row, regionPositions, 'UniformOutput', false)');
        regionColumns         = cell2mat(cellfun(@(x)x.Column, regionPositions, 'UniformOutput', false)');
        
        aroundRange           = unique(regionRows(:,1));
        acrossRange           = unique(regionColumns(:,1));
        
        for n = 1:numel(regionData)
          regionData(n).Position.Around   = find(regionRows(n,1)    == aroundRange, 1, 'first');
          regionData(n).Position.Across   = find(regionColumns(n,1) == acrossRange, 1, 'first');
        end
      end
      
      regionSetData.(regionID)  = regionData;
      
    end
    
  end
  
  try regionSetData.Run.Sheet  = regionSetData.Sheet; end
  
  regionSets.(setKey)    = regionSetData;
  
  regionSet                 = obj.RegionSets(regionKey);
  regionSet.Data            = regionSets;
  
  obj.RegionSets(regionKey) = regionSet;
end
