classdef GrasppePrototype < handle
  %GRASPPEPROTOTYPE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    function obj = GrasppePrototype()
      GrasppePrototype.InitializeGrasppePrototypes;
    end
  end
  
  methods (Static, Hidden)
    function InitializeGrasppePrototypes(forced)
      persistent initialized;
      try  if forced, initialized = false; end, end
      
      if ~isequal(initialized, true)
        [currentPath] = fileparts(mfilename('fullpath'));
        
        folders     = dir(currentPath);
        folderNames = {folders([folders.isdir]).name};
        subNames    = folderNames(~cellfun('isempty', ...
          regexp(folderNames,'^[A-Z].*')));
        
        subPaths    = strcat(currentPath,filesep,subNames);
        
        addpath(subPaths{:});
        initialized = true;
      end
    end
  end
  
end

