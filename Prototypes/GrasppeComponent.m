classdef GrasppeComponent < GrasppeHandle
  %GRASPPECOMPONENTOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Dependent, Hidden)
    Defaults
  end
  
  properties (Hidden=true)
    OptionsTable
    pullEvents    = 0;
    pushEvents    = 0;
    pulledEvents  = 0;
    pushedEvents  = 0;
    IsPulling = false;
    IsPushing = false;
    IsSetting = false;
    
    DebugPropertySynching = false;
  end
  
  methods
    function defaults = get.Defaults(obj)
      defaults = obj.DefaultOptions;
    end
  end
  
  methods (Hidden=true)
    function obj = GrasppeComponent(varargin)
      if isValid('obj.Defaults','struct')
        obj.setOptions(obj.Defaults, varargin{:});
      else
        obj.setOptions(varargin{:});
      end
      
      obj.createComponent([]);
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
  
  methods (Hidden=true)
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
      try properties = [properties obj.CommonProperties]; end
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
    
  end
  
  methods (Access=protected, Hidden=true)
    
    function createComponent(obj, type, varargin)
      if obj.IsHandled, return; end
      
      if isempty(type), type    = obj.getComponentType(); end
      
      if isValidHandle('obj.Parent'), parent = obj.Parent;
      else parent = []; end
      
      handledOptions = obj.getHandleOptions([], false);
      
      switch lower(type)
        case {'figure'}
          graphicHandle = true;
        case {'axes', 'plot', 'patch', 'surface', 'surf', 'surfc'}
          graphicHandle = true;
        case {'colorbar'}
          graphicHandle = true;
          parent = [];
        case {'text'}
          graphicHandle = true;
        otherwise
          graphicHandle = false;
      end
      
      if graphicHandle
        options = obj.removeEmptyOptions(handledOptions);
        args = {type, obj.ID, parent, options{:}, 'UserData', obj, varargin{:}};
        switch lower(type)
          case {'colorbar'}
            idx   = find(strcmp(args,'peer'));
            peer  = args{idx+1};
            args  = args([1:idx-1 idx+2:end]);
            handle = colorbar('peer', peer);
            obj.handleSet(handle, args{6:end});
          otherwise
            handle = Components.CreateHandleObject(args{:});
        end
      else
        handle = [];
      end
      
      obj.Handle = handle;
            
      try obj.attachEvents(); end
      
      try obj.attachListeners(handle, handledOptions(1:2:end)); end
      
      %       np = {mc.PropertyList.Name}; np(cell2mat({mc.PropertyList.SetObservable}))
      %
      
    end
    
    function attachListeners(obj, handle, handleProperties)
      try
        %% Attach handle listeners

        if isValidHandle('handle'), handle = obj.Primitive; end %~exists('handle') || length(handle)~=1 || ~ishandle(handle)

        if isValidHandle('handle')
          if ~exists('handleProperties') || isempty(handleProperties)
            handledOptions = obj.getHandleOptions([], false);
            handleProperties = handledOptions(1:2:end);
          end

          if ~isempty(handleProperties)
            addlistener(handle, handleProperties,  'PostSet', @GrasppeComponent.refreshHandleProperty);
          end
        end

        %% Attach object listeners
        objProperties = {obj.MetaClass.PropertyList.Name};   %{mc.PropertyList.Name; mc.PropertyList.SetObservable}';
        objSetObserve = objProperties([obj.MetaClass.PropertyList.SetObservable]);

        if ~isempty(objSetObserve)
          addlistener(obj, objSetObserve, 'PreGet',  @GrasppeComponent.refreshHandleProperty);
          addlistener(obj, objSetObserve, 'PostSet', @GrasppeComponent.refreshObjectProperty);
        end
      catch err
        try debugStamp(obj.ID); end
        disp(err); %dealwith(err);
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
    
%     function forceSet(obj, varargin)
% %       if obj.IsSetting, return; else obj.IsSetting = true; end
%       
%       obj.forceSetOptions(varargin{:});
%       
% %       if obj.IsHandled %&& ~obj.IsUpdating
% %         %obj.IsUpdating = true;
% %         obj.pushHandleOptions();	obj.pullHandleOptions();
%         %obj.IsUpdating = false;
% %       end
%       
% %       obj.IsSetting = false;      
%     end
    
    
    function setOptions(obj, varargin)
      if obj.IsSetting, return; else obj.IsSetting = true; end
      
      obj.setOptions@GrasppeHandle(varargin{:});
      
      if obj.IsHandled && ~obj.IsUpdating
        obj.IsUpdating = true;
        obj.pushHandleOptions();	obj.pullHandleOptions();
        obj.IsUpdating = false;
      end
      
      obj.IsSetting = false;
    end
    
    function handlePropertyUpdate(obj, source, event)
      
%       persistent debugging;
%       
%       if isempty(debugging)
%         debugging = obj.DebugPropertySynching;
%       end
      
      obj.pullEvents = obj.pullEvents + 1;
      if ~obj.IsUpdating && ~obj.IsPushing
        obj.IsPulling = true;
        try
          [name alias] = obj.lookupOptionName(source.Name);
          obj.pulledEvents = obj.pulledEvents + 1;
          obj.pullHandleOptions({{alias, name}});
        end
        obj.IsPulling = false;
        if obj.DebugPropertySynching
          try fprintf('Pulling (%d/%d):\t\t%s <= %s]\n', obj.pulledEvents, obj.pullEvents, alias, name); end
        end
      end
    end
    
    function objectPropertyUpdate(obj, source, event)
      obj.pushEvents = obj.pushEvents + 1;
      if ~obj.IsUpdating && ~obj.IsPulling
        obj.IsPushing = true;
        try
          [name alias] = obj.lookupOptionName(source.Name, true);
          obj.pushedEvents = obj.pushedEvents+1;
          obj.pushHandleOptions({{alias, name}});
          if obj.DebugPropertySynching
            try fprintf('Pushing (%d/%d):\t\t%s => %s]\n', obj.pushedEvents, obj.pushEvents, alias, name); end
          end
        end
        obj.IsPushing = false;
      end
    end
    
  end
  
  methods(Static, Hidden)
    function refreshHandleProperty(source, event)
      if ~(isobject(source))
        obj = event.AffectedObject.UserData;
      else
        obj = event.AffectedObject;
      end
      if GrasppeComponent.checkInheritence(obj) && isvalid(obj)
        obj.handlePropertyUpdate(source, event);
      end
    end
    
    function refreshObjectProperty(source, event)
      obj = event.AffectedObject;
      if GrasppeComponent.checkInheritence(obj) && isvalid(obj)
        obj.objectPropertyUpdate(source, event);
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
  
  methods(Abstract, Static, Hidden)
    options  = DefaultOptions()
  end
  
end
