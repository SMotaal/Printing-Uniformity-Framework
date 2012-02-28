classdef upGrasppeHandle < dynamicprops
  %GRASPPEHANDLE Grasppe Handle Superclass
  
  
  properties (SetAccess = protected, GetAccess = public)
    Primitive                 % HG primitive handle
    Parent
    Busy
  end
  
  properties (Dependent = true)
    Defaults
  end
  
  properties (Constant = true, GetAccess = public, Transient = true)
    FigureProperties    = { 'Name', 'Renderer', 'Visible', 'Toolbar', 'Menubar', 'Color', 'Units', 'WindowStyle'}; %'Parent' };
    TitleProperties     = {{'Title', 'String'}};
    PlotAxesProperties  = {'Parent', 'Visible','HitTest'};
    PlotProperties      = {'Parent', 'Visible'};
    SurfaceProperties   = {'Parent'};
  end
  
  methods
    
    %% Property Functions
    function options = getComponentOptions(obj)
      try
        properties = obj.ComponentProperties;
        options = obj.getOptions(properties);
      catch
        options = {};
      end
    end
    
    function hParent = get.Parent(obj)
      hParent = obj.getParent();
      if (~isValidHandle(hParent))
        hParent = obj.Parent;
      end
    end
    
    function hParent = getParent(obj)
      if isValidHandle(obj.Primitive) && isValidHand(get(obj.Primitive,'Parent'))
        hParent = get(obj.Primitive,'Parent');
      else
        hParent = [];
      end
    end
    
    function [options properties] = getOptions(obj, names)
      options     = [];
      properties  = options;
      aliases     = names;
      
      if (~iscellstr(names) && length(names)>0)
        for i = 1:numel(names)
          name = names{i};
          if ischar(name)
            % object property name is same as alias!
          elseif (iscellstr(name) && length(name)==1)
            aliases{i}    = char(names{i});
            names{i} = char(names{i});
          elseif (iscellstr(name) && length(name)==2)
            aliases{i}    = names{i}{1};
            names{i} = names{i}{2};
          else
            aliases{i}    = '';
            names{i} = '';
          end
        end
      end
      
      if (iscellstr(names))
        options     = cell(1, numel(names).*2);
        properties  = options;
        pairs       = 0;
        
        for i = 1:numel(names)
          name = names{i};
          
          if isempty(name)
            continue
          end
          
          alias = aliases{i};
          
          value = obj.(alias);
          
          if (~isempty(value))
            index = (pairs)*2 + 1;
            pairs = pairs + 1;
            options{index}      = name;
            options{index+1}    = value;
            properties{index}   = alias;
            properties{index+1} = value;
          end
        end
        options     = options(1:pairs*2);
        properties  = properties(1:pairs*2);
      end
      
    end
    
    
    function [options] = get.Defaults(obj)
      try
        options = obj.getStatic('DefaultOptions');
      end
    end    
    
    
    function obj = setOptions(obj, varargin)
      
      obj.Busy = true;
      try
        [args values paired pairs] = Plots.upGrasppeHandle.parseOptions(obj, varargin{:});
        
        if (paired)
          for i=1:numel(args)
            obj.(args{i}) = values{i};
          end
        end
      end
      obj.Busy = false;
      
    end
    
    function handles   = getHandles(obj, tag, type, parent, varargin)
      handles = Plots.upGrasppeHandle.findObjects(tag, type, parent, varargin{:});
    end
    
    function handle = getHandle(obj, tag, type, parent, varargin)
      
      pVisibility = get(parent,'HandleVisibility');
      set(parent,'HandleVisibility', 'on');
      args = {tag, type, parent, varargin{:}};
      handle = Plots.upGrasppeHandle.findObjects(args{:});
      
      if numel(handle)>1
        delete(handle(2:end));
        handle = Plots.upGrasppeHandle.findObjects(args{:});
      end
      
      set(parent,'HandleVisibility', pVisibility);
      
    end
    
    %% Lower-Level Functions
    
    function value  = getStatic(obj, specifier)
      try
        if ischar(obj)
          className = obj;
        else
          className = class(obj);
        end
        value = eval([className '.' specifier]);
      catch err
        disp(err);
      end
    end
    
  end
  
  methods (Static)
    
    %% Static Property Functions
    
    function [args values paired pairs] = parseOptions(obj, varargin)
      
      pairs = 0;
      
      varargin{:};
      
      [nargs paired args values] = pairedArgs(varargin{:});
      
      if (nargs==0)
        return;
      end
      
      if (isstruct(varargin{1}))
        varStruct = varargin{1};
        nStruct   = 1;
        if length(varargin)>1 && isstruct(varargin{2})
          nStruct = 2;
          extraStruct = varargin{2};
          extraFields = fieldnames(extraStruct);
          for f = 1:numel(extraFields)
            field = extraFields{f};
            varStruct.(field) = extraStruct.(field);
          end
        end
        [args values pairs] = structPair(varStruct);
        paired    = pairs > 0;
        
        if (length(varargin) > nStruct)
          extras = varargin(nStruct+1:end);
          [nargs paired extraArgs extraValues] = pairedArgs(extras{:});
          
          if (paired && nargs > 0)
            args    = {args{:},   extraArgs{:}};
            values  = {values{:}, extraValues{:}};
          end
          
        end
      end
      
      pairs     = numel(args);
      paired    = (numel(args)==numel(values) && pairs>0);
      
    end
    
    %% Static Handle Functions
    
    function hobj = findObjects(tag, type, parent, varargin)
      
      args = {}; hobj = [];
      
      if (isValid('tag', 'char'))
        args = {args{:}, 'Tag', tag};
      end
      
      if (isValid('type', 'char'))
        args = {args{:}, 'Type', type};
      end
      
      if (~isempty(varargin))
        args = {args{:}, varargin{:}};
      end
      
      try
        if (isValidHandle('parent'))
          hobj = findobj(allchild(parent),args{:});
        else
          hobj = findobj(findall(0), args{:});
        end
      end
      
    end
    
  end
  
  methods(Abstract, Static)
    options  = DefaultOptions()
  end  
  
end

