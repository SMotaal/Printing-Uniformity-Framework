classdef GrasppePrototype < handle
  %GRASPPEPROTOTYPE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    function obj = GrasppePrototype()
      GrasppePrototype.InitializeGrasppePrototypes;
      obj.processMetaData;
    end
    
    function processMetaData(obj)
      try
        if iscell(obj.MetaProperties) && size(obj.MetaProperties, 2)==5
          metaProperties   = struct;
          for i = 1:size(obj.MetaProperties, 1)
            property    = obj.MetaProperties{i,1};
            metaData    = obj.MetaProperties(i,2:end);
            
            metaProperties.(property) = GrasppeMetaProperty.Declare( ...
              property, class(obj), metaData{:});
          end
          obj.MetaProperties = metaProperties;
        end
      catch err
%         disp(err);
      end
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

