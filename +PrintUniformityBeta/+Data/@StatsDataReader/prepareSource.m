function prepareSource(obj, sourcePath)
  %PREPARESOURCE Populate Cases, PatchSets, RegionSet... etc.
  %   Detailed explanation goes here
  
  if ~exist('sourcePath', 'var'), sourcePath = obj.sourcePath; end
  if obj.loadSource(sourcePath)
    try delete(obj.cases); end
    try delete(obj.patchSets);  end
    try delete(obj.regionSets); end
    try delete(obj.sheets);     end
    
    obj.cases               = [];
    obj.patchSets           = [];
    obj.regionSets          = [];
    obj.sheets              = [];
    
    try
      obj.prepareCases();         % Populate obj.Cases with CaseSetModel
      obj.preparePatchSets();     % Populate obj.PatchSets with PatchSetModel
      obj.prepareRegionSets();    % Populate obj.RegionSets with RegionSetModel
    catch err
      debugStamp(err, 1);
      throw(addCause( ...
        MException('Grasppe:StatsDataReader:PrepareSourceFailed', ...
        'Failed to prepare source due to %s in line %d in %s@%s.', ...
        err.identifier, err.stack(1).line, err.stack(1).file, err.stack(1).name), err));
    end
    % obj.updateRegionSets();
  end
end
