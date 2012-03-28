classdef HandleGraphicsObject < GrasppeHandleComponent & GrasppeEventHandler
  %HANDLEGRAPHICSOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    GrasppeHandleComponentHandleProperties = {'Parent', {'Children', 'Children', 'readonly'}, ...
      {'CallbackQueueMode', 'BusyAction'}, {'CallbackInterruption', 'Interruptible'}, ...      
      'HandleVisibility', {'IsDestructing','BeingDeleted', 'readonly'}, ...
      {'IsHighlightable', 'SelectionHighlight'}, {'ContextMenu', 'UIContextMenu'}, ...
      {'IsVisible', 'Visible'}, {'IsSelected', 'Selected'}, {'IsClickable', 'HitTest'}, ...
      };
    
    
    GrasppeHandleComponentHandleFunctions = {{'CreateFunction', 'CreateFcn'}, ...
      {'DeleteFunction', 'DeleteFcn'}, {'ButtonDownFunction', 'ButtonDownFcn'}};
    
  end
  
  events
    Create, Delete, ButtonDown
  end
  
  properties (SetObservable, GetObservable, AbortSet)
    Parent
    Children    
    IsClickable           = true
    IsVisible             = true
    IsSelected            = false
    HandleVisibility      = true
    IsDestructing         = false
    IsHighlightable       = true
    CallbackQueueMode
    CallbackInterruption
    ContextMenu
  end
  
  properties (SetObservable, GetObservable, AbortSet, Hidden)
%     CreateFunction
%     DeleteFunction
%     ButtonDownFunction
  end
  
  methods
    function obj = GraphicsObject(varargin)
      obj = obj@GrasppeEventHandler();
      obj = obj@GrasppeHandleComponent();
    end
    
  end
  
  methods (Access=protected)
    
    function setObjectHandle(obj, name, value)
      type = regexp(name,'[A-Z][a-z]+$','match');
      handle = [];
      if isValidHandle(value) %&& strcmpi(get(value, 'type'), type)
        handle = value;
      end
      obj.([name 'Handle']) = handle;
    end
    
    function handle = getObjectHandle(obj, name)
      value = obj.([name 'Handle']);
      type = regexp(name,'[A-Z][a-z]+$','match');
      if isValidHandle(value) %&& strcmpi(get(value, 'type'), type)
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
      
      obj.pushHandleOptions({'IsVisible'});
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
  
  methods (Hidden)
    function setVisible(obj, value)
      obj.IsVisible = value;
    end
  end
  
  methods % Getters / Setters
    
    function set.IsVisible(obj, value)
      obj.IsVisible = changeSet(obj.IsVisible, value);
      obj.pushUpdates('Visibility');
    end
    
    function set.Parent(obj, value)
      obj.Parent = changeSet(obj.Parent, value);
      obj.pushUpdates('Parent');
    end
    
  end
  
  methods(Abstract, Static, Hidden)
    options  = DefaultOptions()
  end
  
  
end

