classdef HandleGraphicsObject < GrasppeComponent
  %HANDLEGRAPHICSOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Constant, GetAccess = public, Transient, Hidden=false)
    HandleProperties = { ...
      'Parent', 'Children', ...
      {'ID', 'Tag'}, {'Type','Type','readonly'} , 'HandleVisibility', ...
      {'CallbackQueueMode', 'BusyAction'}, {'CallbackInterruption', 'Interruptible'}, ...
      {'IsHighlightable', 'SelectionHighlight'}, {'IsClickable', 'HitTest'}, {'ContextMenu', 'UIContextMenu'}, ...
      {'IsDestructing','BeingDeleted', 'readonly'}, {'IsVisible', 'Visible'}, {'IsSelected', 'Selected'}, ...
%       {'Object', 'UserData'} ...
      };
    
    HandleEvents = {'CreateFcn', 'DeleteFcn', 'ButtonDownFcn'};
    
  end
    
  properties (GetAccess=public, SetAccess=public)
    Parent
    IsClickable=true
    IsVisible=true
    IsSelected=false
  end
  
  properties (Hidden=false, GetAccess=public, SetAccess=public)
    Type
    HandleVisibility='on'
    Children
    IsDestructing=false
    IsHighlightable=true
    CallbackQueueMode
    CallbackInterruption
    ContextMenu
  end
  
  %% Hooks
  properties (Hidden=false)
    CreateFcn, DeleteFcn, ButtonDownFcn,
  end
  
  properties (Hidden=false)
    Object
    UpdateQueue
  end
  
  methods
    function obj = HandleGraphicsObject(varargin)
      obj = obj@GrasppeComponent(varargin{:});
    end
  end
  
  methods (Access=protected)
    
    function setObjectHandle(obj, name, value)
      type = regexp(name,'[A-Z][a-z]+$','match');
      handle = [];
      if isValidHandle(value) && strcmpi(get(value, 'type'), type)
        handle = value;
      end
      obj.([name 'Handle']) = handle;
    end
    
    function handle = getObjectHandle(obj, name)
      value = obj.([name 'Handle']);
      type = regexp(name,'[A-Z][a-z]+$','match');
      if isValidHandle(value) && strcmpi(get(value, 'type'), type)
        handle = value;
      else
        handle = [];
      end
    end
    
  end
  
  methods (Access=protected, Hidden=false)
    
    function updateParent(obj)
      obj.pushHandleOptions('Parent');
    end
    
    function updateChildren(obj)
      obj.pushHandleOptions('Children');
    end
    
    function updateVisibility(obj)
      
      obj.pushHandleOptions('Visible');
    end
    
    function updatePosition(obj)
      obj.pushHandleOptions('Position');
    end
    
    function pushUpdates(obj, context)
      
      if iscellstr(context)
        updating = obj.IsUpdating;
        obj.IsUpdating = true;
        for item = context
          obj.pushUpdates(char(item));
        end
        obj.IsUpdating = updating;
      end
      
      if ischar(context)
        context(1) = upper(context(1));
        if isempty(obj.UpdateQueue)
          obj.UpdateQueue = {context};
        else
          obj.UpdateQueue = unique([obj.UpdateQueue, context]);
        end
      end
      
      if ~obj.IsUpdating && ~isempty(obj.UpdateQueue)
        for item = obj.UpdateQueue
          obj.(['update' char(item)]);
        end
      end
      
    end
    
  end
  
  methods % Getters / Setters
    
    function set.IsVisible(obj, value)
      obj.IsVisible = value;
      obj.pushUpdates('Visibility');
    end
    
    function setVisible(obj, value)
      obj.IsVisible = value;
    end
    
    function set.Parent(obj, value)
      obj.Parent = value;
      obj.pushUpdates('Parent');
    end
    
  end
  
  methods(Abstract, Static)
    options  = DefaultOptions()
  end
  
  
end

