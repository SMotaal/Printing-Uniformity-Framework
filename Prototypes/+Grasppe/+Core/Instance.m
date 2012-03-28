classdef Instance < GrasppePrototype
  %GRASPPEINSTANCE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  properties (SetAccess=immutable)
    InstanceID
  end
  
  properties (Dependent)
    ID
  end
  
  methods
    function id = get.ID(obj)
      id = obj.InstanceID;
    end
  end
  
  methods (Hidden)
    
    function obj = GrasppeInstance()
      obj = obj@GrasppePrototype();
      if (isempty(obj.InstanceID))
        obj.InstanceID = obj.generateInstanceID;
      end
    end
    
    function instanceID = generateInstanceID(obj)
      instanceID = [];

      try
        instanceID = obj.InstanceID;
        if (isempty(instanceID) || ~ischar(instanceID))
          instanceID = GrasppeInstance.InstanceRecord(obj);
          if (isempty(instanceID) || ~ischar(instanceID))
            instanceID = genvarname([obj.ClassName '_' int2str(rand*10^12)]);
          end
        end
      end
    end
  end
  
  methods (Static, Hidden)
    
    function [ID instance] = InstanceRecord(object)
      persistent instances hashmap
      
      if (~exist('object','var')), return; end
      
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

