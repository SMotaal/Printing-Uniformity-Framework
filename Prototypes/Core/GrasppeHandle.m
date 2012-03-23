classdef GrasppeHandle < GrasppePrototype & dynamicprops & hgsetget
  %GRASPPEHANDLE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Hidden=false)
    IsUpdating  = false;
    Debugging   = false;
    
  end
  
  properties (SetAccess=immutable)
    InstanceID
  end
  
  properties (Dependent)
    ID
  end
  
  properties (Dependent, Hidden=false)
    Handle
    IsHandled
    ClassName
    ClassPath
    MetaClass
  end
  
  properties (SetAccess=private, GetAccess=public, Hidden)
    Primitive
  end
  
  methods
    function obj = GrasppeHandle()
      %GrasppeHandle.InitializeGrasppePrototypes();
      obj = obj@GrasppePrototype;
      obj = obj@dynamicprops;
      obj = obj@hgsetget;
      
      if (isempty(obj.InstanceID))
        obj.InstanceID = obj.generateInstanceID;
      end

    end
    
    function instanceID = generateInstanceID(obj)
      instanceID = [];
      % t = tic;
      try
        instanceID = obj.InstanceID;
        if (isempty(instanceID) || ~ischar(instanceID))
          instanceID = GrasppeHandle.InstanceRecord(obj);
          if (isempty(instanceID) || ~ischar(instanceID))
            instanceID = genvarname([obj.ClassName '_' int2str(rand*10^12)]);
          end
        end
      end
      % toc(t);      
    end
    
    function state = get.IsHandled(obj)
      handle = obj.Primitive;
      state = ~isempty(handle);
    end
    
    function handle = get.Handle(obj)
      handle = obj.Primitive;
      if ~isValidHandle('handle')
        handle = [];
      end
    end
    
    function set.Handle(obj, handle)
      if ~isValidHandle('handle')
        handle = [];
      end
      obj.Primitive = changeSet(obj.Primitive, handle);
      
      try obj.pullHandleOptions; end
    end
    
    function id = get.ID(obj)
      id = obj.InstanceID;
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
    
    function metaClass = get.MetaClass(obj)
      metaClass = metaclass(obj);
    end
    
  end
  
  methods (Hidden)
    
    function handleSet(obj, varargin)
      try
        if isobject(obj) && isOn(obj.IsDestructing)
          return;
        end
      catch err
        if ~any(strcmp(err.identifier, {'MATLAB:nonStrucReference', 'MATLAB:noSuchMethodOrField'}))
          try debugStamp(obj.ID, 4); end;
          disp(err);
        end
        return;
      end
      
      try
        if nargin>1 && isValidHandle('varargin{1}')
          handle = varargin{1};
          args = varargin(2:end);
        else
          handle = obj.Handle;
          args = varargin;
        end
        if ~isempty(handle)
          try
            set(handle, args{:});
          catch err
            GrasppeHandle.VerboseSet(handle, args{:});
          end
        else
          % disp(varargin);
        end
      catch err
        dealwith(err);
      end
    end
    
    function values = handleGet(obj, varargin)
      values = {};
      
      if nargin>1 && isValidHandle('varargin{1}')
        handle = varargin{1};
        args = varargin(2:end);
      else
        handle = obj.Handle;
        args = varargin;
      end
      if ~isempty(handle)
        try
          values = get(handle, args{:});
        catch
          try
            values = get(handle, args);
          catch err
            try debugStamp(obj.ID); end
            disp(err);
            try
              disp(sprintf('%s:HandleGet: %s', obj.ID, toString(args)));
            end
          end
        end
      end
      
    end
    
    function autoSet(obj, property, value)
      if isnumeric(value)
        obj.handleSet(property, value);
      elseif isequal(lower(value), 'auto')
        obj.handleSet([property 'Mode'], 'auto');
      end
    end
    
    function value = autoGet(obj, property)
      value = obj.handleGet([property 'Mode']);
      if ~isequal(lower(value), 'auto')
        value = obj.handleGet(property);
      end
    end
    
    
  end
  
  methods (Access=protected, Hidden)
    
    function pushHandleOptions(obj, names, emptyValues)
      
      try debugStamp(obj.ID, 5); catch, debugStamp('', 5); end;
      try
        
        default emptyValues true;
        
        if ~isempty(names)
          if ischar(names)
            names = {names};
          end
        end
        
        try
          [options] = obj.getHandleOptions(names, false);
        catch err
          halt(err, 'obj.ID');
          try debugStamp(obj.ID, 4); catch, debugStamp('', 4); end;
          
          for i = 1:numel(names)
            if ischar(names{i})
              [name alias]  = obj.lookupOptionName(names{i}, 'all');
              names{i} = {alias, name};
            end
          end
          [options] = obj.getHandleOptions(names, false);
        end
        
        if ~emptyValues
          options = obj.removeEmptyOptions(options);
        end
        
        obj.handleSet(options{:});
        
      catch err
        halt(err, 'obj.ID');
        
        try debugStamp(obj.ID, 4); catch, debugStamp('', 4); end;
      end
    end
    
    function [options handleOptions] = getHandleOptions(obj, names, readonly)
      
      default readonly true;
      
      options={}; handleOptions={};
      
      [names aliases] = obj.getOptionNames(names, readonly);
      
      options           = obj.getOptions(aliases);
      options(1:2:end)  = names(:);
      
      if nargout==2 && obj.IsHandled
        try
          handleOptions = cell(1,2*numel(names));
          handleValues = get(obj.Handle, names);
          handleOptions(1:2:end) = aliases;
          handleOptions(2:2:end) = handleValues;
        end
      end
    end
    
    function handleOptions = pullHandleOptions (obj, names, updateLocal)
      
      default updateLocal true;
      
      options = cell(1,2*numel(names));
      
      [names aliases] = obj.getOptionNames(names);
      
      handleOptions = obj.handleGet(names);
      
      options(1:2:end) = aliases;
      options(2:2:end) = handleOptions;
      
      if updateLocal
        obj.setOptions(options{:});
      end
    end
    
    function [options handleOptions] = getOptions(obj, names)
      
      options = cell(1, numel(names).*2);
      for i = 1:numel(names)
        name  = names{i};
        value = obj.getOptionValue(name);
        idx = 1+(i-1)*2;
        options{idx}        = name;
        options{idx+1}      = value;
      end
    end
    
    function [options] = removeEmptyOptions(obj, options)
      
      finalOptions = cell(size(options));
      p = 0;
      for i = 1:numel(options)/2
        name  = options{i*2-1};
        value = options{i*2};
        if ~isempty(name) && ~isempty(value)
          p = p + 1;
          finalOptions{p*2-1} = name;
          finalOptions{p*2}   = value;
        end
      end
      options = finalOptions(1:p*2);
    end
    
    function setOptions(obj, varargin)
      try
        if obj.IsUpdating, return; else obj.IsUpdating = true; end
        
        [args values paired pairs] = obj.parseOptions(varargin{:});
        if (paired)
          for i=1:numel(args)
            try
              if ~isequal(obj.(args{i}), values{i})
                obj.(args{i}) = values{i};
              end
            catch err
              if ~strcontains(err.identifier, 'noSetMethod')
                try debugStamp(obj.ID, 5); end
                disp(['Could not set ' args{i} ' for ' class(obj)]);
              end
            end
          end
          
        end
        
        obj.IsUpdating = false;
      catch err
        halt(err, 'obj.ID');
      end
    end
    
    function [args values paired pairs] = parseOptions(obj, varargin)
      
      args        = varargin;
      extraArgs   = {};
      
      %% Parse Lead Structures
      while (~isempty(args) && isstruct(args{1}))
        stArgs    = structArgs(args{1});
        extraArgs = [extraArgs stArgs]; %#ok<*AGROW>
        
        if length(args)>1
          args = args(2:end);
        else
          args = {};
        end
        
      end
      
      args = [extraArgs, args];
      
      [pairs paired args values ] = pairedArgs(args{:});
      
    end
    
    
    function [names aliases] = getOptionNames(obj, list, readonly)
      default readonly true;
      
      names   = {}; aliases = {}; n = 1;
      
      if ischar(list)
        list = {list};
      end
      
      for i = 1:numel(list)
        try
          item = list{i};
          ilength  = length(item);
          if ischar(item) % object property name is same as alias!
            aliases{n}  = item;
            names{n}    = item;
          elseif ilength==1
            aliases{n}  = char(item);
            names{n}    = char(item);
          elseif ilength==2
            aliases{n}  = item{1};
            names{n}    = item{2};
          elseif ilength==3
            if (readonly || ~strcmpi(item{3}, 'readonly'))
              aliases{n}  = item{1};
              names{n}    = item{2};
            else
              continue;
            end
          else
            continue;
          end
        end
        n = n + 1;
      end
      
    end
    
    function value = getOptionValue(obj, name)
      value = [];
      try
        value = obj.(name);
      end
      try
        if all(name(1:2)=='Is') %regexp(name, ['(^Is[A-Z])' '|' '(\w+Enabled$)' '|' '(\w+Visible$)'], 'Once'))
          value = isOn(value, 'on', 'off');
        end
      end
    end
    
  end
  
  
  methods (Static, Hidden)
    
    function checks = checkInheritence(obj, classname)
      if ~isValid('classname', 'char')
        classname = eval(CLASS);
      end
      
      try
        checks = isa(obj, classname);
      catch
        checks = false;
      end

    end
    
    function VerboseSet(hg, varargin)
      try
        properties = varargin(1:2:end);
        values = varargin(2:2:end);
        for i = 1:numel(properties)
          try
            property = properties{i};
            value = values{i};
            set(hg, property, value);
          catch err
            if ~isempty(strfind(err.identifier, 'BadHandle')) %ishandle(hg)
              %               dealwith(err);
            elseif ~isempty(strfind(err.identifier, 'hg:set_chck')) && ~isempty(value)
              disp([property '=' toString(value) ' [' err.message ']']);
              %               dealwith(err);
            else
              return;
            end
          end
        end
      catch err
        %         dealwith(err);
      end
    end
    
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
  
  methods(Abstract, Static, Hidden)
    options  = DefaultOptions()
  end
  
  
end

