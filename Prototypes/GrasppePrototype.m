classdef GrasppePrototype < handle
  %GRASPPEPROTOTYPE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    MetaProperties
  end
  
  methods
    function obj = GrasppePrototype()
      GrasppePrototype.InitializeGrasppePrototypes;
      obj.processMetaData;
    end
    
    function dup = CreateDuplicate(obj)
      dup = [];
    end
    
    function processMetaData(obj)
      try
        definedProperties = obj.MetaProperties;
        if iscell(definedProperties) && size(definedProperties, 2)==5
          metaProperties   = struct;
          for i = 1:size(definedProperties, 1)
            property    = definedProperties{i,1};
            metaData    = definedProperties(i,2:end);
            
            metaProperties.(property) = GrasppeMetaProperty.Declare( ...
              property, class(obj), metaData{:});
          end
          obj.MetaProperties = metaProperties;
        end
      catch err
        % disp(err);
      end
    end
    
    function metaProperties = get.MetaProperties(obj)
      if ~isempty(obj.MetaProperties)
        metaProperties =  obj.MetaProperties;
      else
        metaProperties = {};
        tree = vertcat(obj.ClassName, superclasses(obj));
        
        for i = 1:numel(tree)
          className     = tree{i};
          propertyMeta  = metaProperty(className, 'metaProperties');
          
          if length(propertyMeta) > 0
            try
              if isempty(metaProperties)
                metaProperties = propertyMeta.DefaultValue;
              else
                metaProperties = vertcat(metaProperties, propertyMeta.DefaultValue);
              end
            end
          end
        end
        
        obj.MetaProperties = metaProperties;
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

