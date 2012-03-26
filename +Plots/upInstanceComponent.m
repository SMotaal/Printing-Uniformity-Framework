classdef upInstanceComponent < handle
  %UPINSTANCECOMPONENT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (SetAccess = protected, GetAccess = protected)
    InstanceID
    InstanceLimit = 20;
  end
  
  properties (Dependent = true)
    ID, Type, ClassName, 	ClassPath
  end
  
  methods
    function id = get.ID(obj)
      instanceID = obj.InstanceID;
      if (isempty(instanceID) || ~ischar(instanceID))
        instanceID = Plots.upViewComponent.InstanceRecord(obj);
        if (isempty(instanceID) || ~ischar(instanceID))
          obj.InstanceID = genvarname([obj.ClassName '_' int2str(rand*10^12)]);
        else
          obj.InstanceID = instanceID;
        end
      end
      id = obj.InstanceID;
    end
    
    function type = get.Type(obj)
      type = obj.ClassName;
    end
    
    function type = getComponentType(obj, type)
      if validCheck('type','char')
        return;
      end
      try
        type = obj.ComponentType;
      catch err
        error('Grasppe:Component:MissingType', ...
          'Attempt to create component without specifying type.');
      end      
    end
    
    function className = get.ClassName(obj)
      superName = eval(CLASS);
      className = class(obj);
      if (strcmpi(superName, className))
        warning('Grasppe:Component:ClassName:Unexpected', ...
          ['Attempting to access a component''s super class (%s) instead of the ' ...
          'actual component. Make sure this is the intended behaviour.'], superName);
      end
    end
    
    function classPath = get.ClassPath(obj)
      classPath = fullfile(which(obj.ClassName));
    end
    
  end
  
  
    methods (Static)
    
    function [ID instance] = InstanceRecord(object)
      persistent instances hashmap
           
      if (~exist('object','var'))
        return;
      end
      
      instance = struct( 'class', class(object), 'created', now(), 'object', object );
      
      if (isempty(hashmap) || ~iscell(hashmap))
        hashmap = {};
      end
      
      row = [];
      
      GetInstance = @(r)  instances.(hashmap(r, 2))(hashmap(r, 3));
      
      SafeName    = @(t)  genvarname(regexprep(t,'[^\w]+','_'));
      
      if (~isempty(object.InstanceID) && ischar(object.ID) && size(hashmap,1)>0) % Rows
        row = find(strcmpi(hashmap(:, 1),object.ID));
      end
      
      if (numel(row)>1)
        warning('Grasppe:Componenet:InvalidInstanceRecords', ...
          ['Instance records are out of sync and showing duplicates ' ...
          'for the instance %s. A new ID will be created for this object.'], object.ID);
      end
      
      if (numel(row)==1)
        try
          stored  = GetInstance(row);
          
          if (~strcmpi(stored.class, instance.class) || stored.object ~= instance.object)
            row = [];
          else
            instance = stored;
          end
        catch err
          row   = [];
        end
      end
      
      group 	= SafeName(instance.class);                                 %genvarname(strrep(instance.class,',','_'));

      if (numel(row)~=1)
        try
          groupInstances  = instances.(group);
          index   = numel(groupInstances) + 1;
        catch err
          index   = 1;
        end
        
        id = SafeName([instance.class '.' int2str(index)]);
        
        instances.(group)(index) = instance;
        hashmap(end+1,:) = {id, group, index};
        
      end
      
      ID  = id;
      
    end
  end

  
end

