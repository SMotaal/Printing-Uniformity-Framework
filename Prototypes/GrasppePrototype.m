classdef GrasppePrototype < handle
  %GRASPPEPROTOTYPE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    MetaProperties
    ClassName
    ClassPath
    MetaClass
  end
  
  methods
    function obj = GrasppePrototype()
      GrasppePrototype.InitializeGrasppePrototypes;
      % obj.processMetaData;
    end
    
    function dup = CreateDuplicate(obj)
      dup = [];
    end
    
    
    function className = get.ClassName(obj)
      % superName = eval(CLASS);
      className = class(obj);
      % if (strcmpi(superName, className))
      %   warning('Grasppe:Component:ClassName:Unexpected', ...
      %     ['Attempting to access a component''s super class (%s) instead of the ' ...
      %     'actual component. Make sure this is the intended behaviour.'], superName);
      % end
    end
    
    function classPath = get.ClassPath(obj)
      classPath = fullfile(which(obj.ClassName));
    end
    
    function metaClass = get.MetaClass(obj)
      metaClass = metaclass(obj);
    end    
    
    
    function metaProperties = get.MetaProperties(obj)
      if ~isempty(obj.MetaProperties)
        metaProperties =  obj.MetaProperties;
      else
        metaProperties = {};
        try
          tree = vertcat(obj.ClassName, superclasses(obj));

          for i = 1:numel(tree)
            className     = tree{i};
                        
            try
              classProperties = obj.([className 'Properties']);
              if isempty(metaProperties)
                metaProperties = classProperties;
              else
                metaProperties = vertcat(metaProperties, classProperties);
              end
            end
              
          end

          obj.MetaProperties = metaProperties;
        end
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
    
    function checks = checkInheritence(obj, classname)     
      checks = false;
      try
        checks = isa(obj, classname);
      catch
        try checks = isa(obj, eval(CLASS)); end
      end
    end
    
  end
  
end

