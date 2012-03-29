classdef Component < Grasppe.Core.Instance
  %GRASPPE.CORE.COMPONENT with enhanced get/set
  %   Detailed explanation goes here
  
  properties
    Defaults
  end
  
  properties (Access=private)
    ComponentOptions
  end
  
  methods
    function obj = Component(varargin)
      obj = obj@Grasppe.Core.Instance;
      
      obj.ComponentOptions = varargin;
      
      obj.createComponent;
      
    end
    
    function componentOptions = getComponentOptions(obj)
      componentOptions = obj.ComponentOptions;
    end
    
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      
      try
        componentType = obj.ComponentType;
      catch
        error('Grasppe:Component:MissingType', ...
          'Unable to determine the component type to create the component.');
      end
      
      obj.intializeComponentOptions;
      
    end
    
    function [names values] = intializeComponentOptions(obj)
      
      componentOptions  = obj.ComponentOptions;
      
      [defaultNames defaultValues]  = obj.setOptions(obj.Defaults);
      [initialNames initialValues]  = obj.setOptions(componentOptions{:});
      
      names   = unique([defaultNames, initialNames]);
      if ~isempty(names)
        options = obj.getOptions(names{:});
        values  = options(2:2:end);
      else
        values  = names;
      end
      
    end
    
    function options = getOptions(obj, varargin)
      
      switch nargin
        case 2
          names = varargin{1};
        case 1
          return;
        otherwise
          names = varargin;
      end
      
      options = cell(1, numel(names).*2);
      if isa(names, 'char')
        names = {names};
      end
      for i = 1:numel(names)
        name  = names{i};
        value = obj.(name);
        
        idx = 1+(i-1)*2;
        
        options(idx)    = {name};
        options(idx+1)  = {value};
      end
      
    end
    
    function [names values] = setOptions(obj, varargin)
      
      [names values paired pairs] = obj.parseOptions(varargin{:});
      
      if (paired)
        for i=1:numel(names)
          try
            if ~isequal(obj.(names{i}), values{i})
              obj.(names{i}) = values{i};
            end
          catch err
            if ~strcontains(err.identifier, 'noSetMethod')
              try debugStamp(obj.ID, 5); end
              disp(['Could not set ' names{i} ' for ' class(obj)]);
            end
          end
        end
      end
      
    end
    
    function [names values paired pairs] = parseOptions(obj, varargin)
      
      names        = varargin;
      extraArgs   = {};
      
      %% Parse Lead Structures
      while (~isempty(names) && isstruct(names{1}))
        stArgs    = structArgs(names{1});
        extraArgs = [extraArgs stArgs]; %#ok<*AGROW>
        
        if length(names)>1
          names = names(2:end);
        else
          names = {};
        end
        
      end
      
      names = [extraArgs, names];
      
      [pairs paired names values ] = pairedArgs(names{:});
      
    end
    
  end
  
  
  methods
    function defaults = get.Defaults(obj)
      defaults = obj.DefaultOptions;
    end
  end
  
  methods(Abstract, Static, Hidden)
    options  = DefaultOptions();
  end
  
end

