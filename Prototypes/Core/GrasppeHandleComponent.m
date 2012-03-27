classdef GrasppeHandleComponent < GrasppeComponent
  %GRASPPEHANDLECOMPONENT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    GrasppeHandleComponentHandleProperties = {{'ID', 'Tag'}, {'Type','Type','readonly'}};
  end
  
  properties (SetObservable, GetObservable, AbortSet)
    Type
  end
  
  
  properties
    HandleFunctions         % Struct holding handle functions
    ObjectPropertyMap       % Object-Handle Map
    HandlePropertyMap       % Handle-Object Map
    HandlePropertyMeta      % Struct holding meta.property for each handle-object property
    
    Handle = [];
    
    HandleObject
    JavaObject
  end
  
  methods
    function obj = GrasppeHandleComponent(varargin)
      obj = obj@GrasppeComponent(varargin{:});
    end
  end
  
  methods (Access=protected)
    function createComponent(obj)
      obj.createComponent@GrasppeComponent();
      obj.createHandlePropertyMap();      
      obj.createHandleObject();
      set(obj.Handle, 'UserData', obj);
      obj.HandleObject = handle(obj.Handle);
      obj.attachHandleProperties();
    end
    
    function createHandleObject(obj)
      error('Grasppe:HandleComponent:CreateMethodUndefined', ...
        'Unable to create the handle component due to undefined create method.');
    end
    
    function attachHandleProperties(obj)
      
      aliases = obj.ObjectPropertyMap.keys;
      names   = obj.ObjectPropertyMap.values;
      
      
      setObservableWarnState = warning('off', 'MATLAB:class:nonSetObservableProp');      
      for m = 1:numel(aliases)
        obj.attachHandleProperty(aliases{m}, names{m});
      end
      warning(setObservableWarnState);
      
    end
    
    function handleSet(obj, name, value)
      switch class(value)
        case 'logical'
          if isOn(value), value = 'on'; else value = 'off'; end
      end
      
      set(obj.Handle, name, value);
        
    end
    
    function value = handleGet(obj, name)
      %       switch class(value)
      %         case 'logical'
      %           if isOn(value), value = 'on'; else value = 'off'; end
      %       end
      
      value = get(obj.Handle, name);
      
    end

       
    function attachHandleProperty(obj, propertyAlias, propertyName)
           
      h = obj.Handle;
      hObj = obj.HandleObject;
      
      objectValue = obj.(propertyAlias);
      handleValue = get(h, propertyName);
      
      % Determine data type
      handleMeta.schema  = findprop(hObj, propertyName);
            
      % If a default value is defined locally, update the handle,
      % otherwise, update the local property to handle default.      
      
      if isempty(objectValue)
        try
          obj.(propertyAlias) = handleValue;
          objectValue = handleValue;
        end
      end
      
      
      % Determine if read-only
      try
        obj.handleSet(propertyName, objectValue);
      catch err
        disp(err);
      end
      
      try
        obj.(propertyAlias) = obj.handleGet(propertyName);
      end
      
      addlistener(obj,  propertyAlias,   'PostSet',  @obj.objectPostSet);
      % addlistener(obj,  propertyAlias,   'PreSet',   @obj.objectPreSet);  ...
      % addlistener(obj,  propertyAlias,   'PostGet',  @obj.objectPostGet); ...
      % addlistener(obj,  propertyAlias,   'PreGet',   @obj.objectPreGet);

      
      addlistener(h,  propertyName,   'PostSet',  @obj.handlePostSet);
      % addlistener(handle,  propertyName,   'PreSet',   @obj.handlePreSet);  ...
      % addlistener(handle,  propertyName,   'PostGet',  @obj.handlePostGet); ...
      % addlistener(handle,  propertyName,   'PreGet',   @obj.handlePreGet);

    end
    
    function attachHandleFunctions(obj)
      
    end
    
    function createHandlePropertyMap(obj)
      
      if isempty(obj.HandlePropertyMap) || isempty(obj.ObjectPropertyMap)
        handlePropertyTables = obj.getRecursiveProperty('HandleProperties');
        handlePropertyTable  = [handlePropertyTables{:}];
        
        nProperties       = numel(handlePropertyTable);
                       
        handleProperties  = cell(size(handlePropertyTable));
        objectProperties  = handleProperties;
        
        readonlyIndex     = [];
        
        for m = 1:nProperties;
          property = handlePropertyTable{m};
          
          if isa(property, 'char')
              objectProperties(m) = {property};
              handleProperties(m) = {property};            
          elseif isa(property, 'cell')
            
            objectProperties(m) = property(1);
            handleProperties(m) = property(2);
            
            try
              if strcmpi(property(3), 'readonly')
                readonlyIndex(end+1) = m;
              end
            end
          end
          
        end
        
        writableIdx = setdiff([1:nProperties], readonlyIndex);
        
        obj.ObjectPropertyMap = containers.Map(objectProperties(writableIdx), handleProperties(writableIdx));
        obj.HandlePropertyMap = containers.Map(handleProperties, objectProperties);
      end
    end
    
  end
  
  methods
    function set.Handle(obj, h)
      if isempty(obj.Handle) && ishandle(h)
        obj.Handle = h;
      end
    end
  end
  
  
  
  %% Property Update
  methods(Hidden)    
    function objectPostSet(obj, source, event)
      propertyAlias = source.Name;
      propertyName  = obj.ObjectPropertyMap(propertyAlias);
      
      obj.handleSet(propertyName, obj.(propertyAlias));
      
      obj.(propertyAlias) = obj.handleGet(propertyName);
      return;
    end
    
    
    function handlePostSet(obj, source, event)
      propertyName  = source.Name;
      propertyAlias = obj.HandlePropertyMap(propertyName);
      
      obj.(propertyAlias) = event.AffectedObject.(propertyName);
      return;
    end
    
    
    % function objectpreset(obj, source, event)
    %   return;
    % end
    %
    % function objectpreget(obj, source, event)
    %   return;
    % end
    %
    % function objectpostget(obj, source, event)
    %   return;
    % end
    %
    % function handlepreset(obj, source, event)
    %   return;
    % end
    %
    % function handlepreget(obj, source, event)
    %   return;
    % end
    %
    % function handlepostget(obj, source, event)
    %   return;
    % end
    
    
  end
  
  
  
end

