classdef HandleGraphicsComponent < Grasppe.Core.HandleComponent % & Grasppe.Core.EventHandler
  %HANDLEGRAPHICSOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    HandleGraphicsComponentProperties = {
      'IsVisible',    'Is Visible',       'View',     'logical',   '';   ...
      };
    
    
    HandleGraphicsComponentHandleProperties = {'Parent', {'Children', 'Children', 'readonly'}, ...
      {'CallbackQueueMode', 'BusyAction'}, {'CallbackInterruption', 'Interruptible'}, ...      
      'HandleVisibility', {'IsDestructing','BeingDeleted', 'readonly'}, ...
      {'IsHighlightable', 'SelectionHighlight'}, {'ContextMenu', 'UIContextMenu'}, ...
      {'IsVisible', 'Visible'}, {'IsSelected', 'Selected'}, {'IsClickable', 'HitTest'}, ...
      };
    
    
    HandleGraphicsComponentHandleFunctions = {{'CreateFunction', 'CreateFcn'}, ...
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
  end
  
  methods
    function obj = HandleGraphicsComponent(varargin)
      % obj = obj@Grasppe.Core.EventHandler();
      obj = obj@Grasppe.Core.HandleComponent(varargin{:});
    end
    
  end
  
  methods (Access=protected)
    
  end
  
  methods (Access=protected, Hidden=false)
    
  end
  
  methods (Hidden)
    
    function delete(obj)
      obj.OnDelete;
    end

    function OnCreate(obj, source, event)
      disp(['Creating handle for ' obj.ID]);
    end
    
    function OnDelete(obj, source, event)
      if isequal(obj.IsDestructing, true), return; end
      obj.IsDestructing = true;
      try
        children = obj.handleGet('Children');
        for m = 1:numel(children)
          try
            child = get(children(m), 'UserData');
            if isa(child, 'Grasppe.Graphics.HandleGraphicsComponent')
              try delete(child); end
            end
          end
        end
      end
      try delete(obj.Handle); end
      disp(['Deleting handle for ' obj.ID]);
    end
    
    function OnButtonDown(obj, source, event)
    end
  end
  
  methods % Getters / Setters
        
  end
  
  methods(Abstract, Static, Hidden)
    options  = DefaultOptions()
  end
  
  
end

