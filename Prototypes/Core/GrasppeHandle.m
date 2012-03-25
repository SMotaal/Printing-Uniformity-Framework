classdef GrasppeHandle < GrasppeInstance & dynamicprops & hgsetget
  %GRASPPEHANDLE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Hidden=false)
    IsUpdating  = false;
    Debugging   = false;
  end
  
  properties (Dependent, Hidden=false)
    Handle
    IsHandled
  end
  
  properties (SetAccess=private, GetAccess=public, Hidden)
    Primitive
  end
  
  methods
    function obj = GrasppeHandle()
      obj = obj@GrasppeInstance;
      obj = obj@dynamicprops;
      obj = obj@hgsetget;
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
        
        while isa(args, 'cell') && length(args)==1
          args = args{1};
        end
        
        try
          values = get(handle, args{:});
        catch
          if isempty(args)
            return;
          end
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
    
    function pushHandleOptions(obj, names) %, emptyValues)
      
      try debugStamp(obj.ID, 5); catch, debugStamp('', 5); end;
      try
        
        %         default emptyValues true;
        
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
              [name alias]  = obj.reverseOptionLookup(names{i});
              names{i} = {alias, name};
            end
          end
          [options] = obj.getHandleOptions(names, false);
        end
        
        options = obj.removeEmptyOptions(options);
        
        obj.handleSet(options{:});
        
      catch err
        halt(err, 'obj.ID');
        
        try debugStamp(obj.ID, 4); catch, debugStamp('', 4); end;
      end
    end
    
    function [options handleOptions] = getHandleOptions(obj, names, readonly)
      
      %default readonly true;
      if (nargin<3) % || ~isequal(readonly, false)), readonly = true; end
        keyboard;
      end
      
      options={}; handleOptions={};
      
      [names aliases] = obj.getOptionNames(names, readonly);
      
      options           = obj.getOptions(aliases);
      options(1:2:end)  = names(:);
      
      if nargout==2 && obj.IsHandled
        try
          handleOptions           = cell(1,2*numel(names));
          handleValues            = get(obj.Handle, names);
          handleOptions(1:2:end)  = aliases;
          handleOptions(2:2:end)  = handleValues;
        end
      end
    end
    
    function handleOptions = pullHandleOptions (obj, names) %, updateLocal)
      
      %default updateLocal true;
      %       updateLocal = (nargin<2 || isequal(updateLocal, true));
      
      options = cell(1,2*numel(names));
      
      [names aliases] = obj.getOptionNames(names, true);
      
      handleOptions = obj.handleGet(names);
      
      options(1:2:end) = aliases;
      options(2:2:end) = handleOptions;
      
      obj.setOptions(options{:});
      
      %       if updateLocal
      %         obj.setOptions(options{:});
      %       end
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
      % default readonly true;
      if (nargin<3) % || ~isequal(readonly, false)), readonly = true; end
        readonly = true; %keyboard
      end
      
      if isa(list, 'char')
        names   = {list};
        aliases = names;
        return;
      else
        names   = cell(size(list));
        n = 1;
      end
      
      aliases = names;
      
      for i = 1:numel(list)
        try
          item = list{i};
          
          if isa(item, 'char') || length(item)==1
            names{n}    = char(item);
            aliases(n)  = names(n);  % aliases{n}  = char(item);
            n = n + 1;
          elseif isa(item, 'cell') && ...
              (length(item)==2 || (length(item)==3 && (readonly || ~isequal(item{3}, 'readonly'))))
            aliases(n)  = item(1);
            names(n)    = item(2);
            n = n + 1;
          end
          
        end
      end
      names = names(1:n-1);
      aliases = aliases(1:n-1);
    end
    
    function value = getOptionValue(obj, name)
      value = [];
      try
        value = obj.(name);
      end
      try
        if all(name(1:2)=='Is')
          value = isOn(value, 'on', 'off');
        end
      end
    end
    
  end
  
  
  methods (Static, Hidden)
    
    function checks = checkInheritence(obj, classname)
      checks = false;
      try
        checks = isa(obj, classname);
      catch
        try checks = isa(obj, eval(CLASS)); end
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
            if ~isempty(strfind(err.identifier, 'BadHandle'))
              dealwith(err);
            elseif ~isempty(strfind(err.identifier, 'hg:set_chck')) && ~isempty(value)
              disp([property '=' toString(value) ' [' err.message ']']);
            else
              continue;
            end
          end
        end
      catch err
        dealwith(err);
      end
    end
    
  end
  
  methods(Abstract, Static, Hidden)
    options  = DefaultOptions()
  end
  
  
end

