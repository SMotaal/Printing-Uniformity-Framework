function prepareSource(obj, sourcePath)
  %PREPARESOURCE Populate Cases, PatchSets, RegionSet... etc.
  %   Detailed explanation goes here
  
  % if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end
  
  try
    obj.Tasks.GetSource    = obj.ProcessProgress.addAllocatedTask('Processing Source', 100, 5);
    TASK                   = obj.Tasks.GetSource;
    obj.ProcessProgress.activateTask(TASK);
  end  
  
  if ~exist('sourcePath', 'var'), sourcePath = obj.sourcePath; end
  if obj.loadSource(sourcePath)
    try delete(obj.cases); end
    try delete(obj.patchSets);  end
    try delete(obj.regionSets); end
    % try delete(obj.sheets);     end
    
    obj.cases               = [];
    obj.patchSets           = [];
    obj.regionSets          = [];
    obj.sheets              = [];
    
    try TASK.CHECK(); end                             % CHECK GetSource 1
    
    try
      obj.prepareCases();         % Populate obj.Cases with CaseSetModel
      try TASK.CHECK(); end                             % CHECK GetSource 2
      
      obj.preparePatchSets();     % Populate obj.PatchSets with PatchSetModel
      try TASK.CHECK(); end                             % CHECK GetSource 3
      
      obj.prepareRegionSets();    % Populate obj.RegionSets with RegionSetModel
      try TASK.CHECK(); end                             % CHECK GetSource 4
    catch err
      debugStamp(err, 1, obj);
      throw(addCause( ...
        MException('Grasppe:StatsDataReader:PrepareSourceFailed', ...
        'Failed to prepare source due to %s in line %d in %s@%s.', ...
        err.identifier, err.stack(1).line, err.stack(1).file, err.stack(1).name), err));
    end
    % obj.updateRegionSets();
  end
  try TASK.SEAL(); end                                % SEAL GetSource
  try obj.resetTasks(); end
end
