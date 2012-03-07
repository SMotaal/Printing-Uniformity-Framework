classdef GrasppeComponent < GrasppeHandle & GrasppeComponentEvents
  %GRASPPECOMPONENTOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Dependent, Hidden=false)
    Defaults
  end
  
  properties (Hidden=false)
    OptionsTable
  end
  
  methods
    function obj = GrasppeComponent(varargin)
      if isValid('obj.Defaults','struct')
        obj.setOptions(obj.Defaults, varargin{:});
      else
        obj.setOptions(varargin{:});
      end
      
      obj.createComponent([]);
    end
    
    function defaults = get.Defaults(obj)
      defaults = obj.DefaultOptions;
    end
    
    
    function [name alias] = lookupOptionName(obj, name, reverse)
      default reverse false;
      
      if isempty(obj.OptionsTable)
        [names aliases] = obj.getComponentFields();
        obj.OptionsTable = [names' aliases'];
      end
      
      OptionsTable = obj.OptionsTable;
      
      if isValid('name', 'char')
        switch reverse
          case {true, 'reverse', 'rev', 'r'}
            column = 2;
          case 'all'
            column = [1 2];
          otherwise %  case false
            column = 1;
        end
        row     = find(strcmpi(OptionsTable(:,column),name));
        name    = OptionsTable{row(1), 1};
        alias   = OptionsTable{row(1), 2};
      else
        name  = {}; 	alias = {};
      end
      
    end
    
  end
  
  methods (Access=protected)
    
    function createComponent(obj, type)
      
      if (obj.IsHandled)
        return;
      end
      
      if isempty(type)
        type    = obj.getComponentType();
      end
      
      if isValidHandle('obj.Parent')
        parent = obj.Parent;
      else
        parent = 0;
      end
      
      handledOptions = obj.getHandleOptions([], false);
      
      options = obj.removeEmptyOptions(handledOptions);
      
      handle = Components.CreateHandleObject(type, obj.ID, parent, options{:}, 'UserData', obj);
      
      obj.Handle = handle;
      
      obj.pullHandleOptions;
      
      addlistener(handle, handledOptions(1:2:end),  'PreSet', @GrasppeComponent.refreshHandleProperty);
      
      [names aliases] = obj.getOptionNames(obj.getComponentHooks);
      
      obj.attachEvents(aliases);
      
      switch lower(type)
        case 'figure'
        case {'axes', 'plot', 'patch', 'surface', 'surf', 'surfc'}
        case {'text'}
        otherwise
      end
    end
    
    function type = getComponentType(obj)
      try type = obj.ComponentType; end
    end
    
    function hooks = getComponentHooks(obj)
      hooks       = {};
      try hooks = obj.ComponentEvents; end
      try hooks = [hooks obj.HandleEvents]; end
    end
    
    function properties = getComponentProperties(obj)
      properties  = {};      
      try properties = obj.ComponentProperties; end
      try properties = [properties obj.HandleProperties]; end      
    end
    
    
    function [fields aliases] = getComponentFields(obj, names)
      
      hooks       = obj.getComponentHooks;
      properties  = obj.getComponentProperties;      
      
      fields = [properties hooks];
      
      if nargout==2
        [fields aliases] = obj.getOptionNames(fields);
      end
    end
    
    function handleOptions = pullHandleOptions(obj, names) %, names, emptyValues)
      default emptyValues true;
      default names;
      if isempty(names)
        names = obj.getComponentFields;
      end
      
      handleOptions = obj.pullHandleOptions@GrasppeHandle(names);
    end
        
    function pushHandleOptions(obj, names)
      default emptyValues true;
      default names;
      if isempty(names)
        names = obj.getComponentFields;
      end
      
      obj.pushHandleOptions@GrasppeHandle(names);
    end
    
    function [options handleOptions] = getHandleOptions(obj, names, readonly)
      default names;
      default readonly true;
      if isempty(names)
        names = obj.getComponentFields;
      end
      
      if nargout==1
        options = obj.getHandleOptions@GrasppeHandle(names, readonly);
      elseif nargout == 2
        [options handleOptions] = obj.getHandleOptions@GrasppeHandle(names, readonly);
      end
    end
    
    function setOptions(obj, varargin)
      obj.setOptions@GrasppeHandle(varargin{:});
      
      updating = obj.IsUpdating;
      if obj.IsHandled && ~updating
        obj.IsUpdating = true;
        obj.pushHandleOptions();
        obj.pullHandleOptions();
        obj.IsUpdating = updating;
      end
    end
    
  end
  
  methods(Static)
    function refreshHandleProperty(source, event)
      obj = event.AffectedObject.UserData;
      if GrasppeComponent.checkInheritence(obj) && isvalid(obj)
        obj.pullHandleOptions();
      end
    end
    
    function checks = checkInheritence(obj, classname)
      if ~isValid('classname', 'char')
        classname = eval(CLASS);
      end
      
      try      
        objClass  = class(obj);
        objSuper  = superclasses(objClass);
        
        checks = stropt(classname, {objClass, objSuper{:}});
      catch
        checks = false;
      end
    end
  end
  
  methods(Abstract, Static, Hidden=false)
    options  = DefaultOptions()
  end
  
end

