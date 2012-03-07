classdef GrasppeComponentEvents < GrasppeHandle & EventHandlerObject
  %GRASPPECOMPONENTEVENTS Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods (Hidden)
    
    function attachEvents(obj, hooks)
      
      if ~exists('hooks') || isempty(hooks) || ~iscell(hooks)
          [names aliases] = obj.getOptionNames(obj.getComponentHooks);
          hooks = aliases;
      end
      
      if ~iscell(hooks), return; end
      
      callbacks = cell(size(hooks));
      for i = 1:numel(hooks)
        hook  = hooks{i};
        callback = obj.(hook);
        if isempty(callback)
          callback = obj.callbackFunction(hook);
        else
          if ~isClass(callback,'EventHandlerObject.callbackEvent')
            callback = obj.callbackFunction(hook, callback);
          end
        end
        callbacks{i} = callback;
      end
      
      finalHooks = reshape({hooks{:}; callbacks{:}},1,[]);
      
      obj.setOptions(finalHooks{:});
      
    end
    
    function finalizeComponent(obj)
      delete(obj.Handle);
    end
    
    function resizeComponent(obj)
      
    end
    
    
    function closeComponent(obj)
      d = dbstack;
      isClose = any(strcmpi({d.('file')}, 'close.p'));
      
      try
        hType = obj.get('type');
        
        switch lower(hType)
          case 'figure'
            if (isClose || isQuitting())
              obj.finalizeComponent();
            else
              obj.setVisible(false);
              try
                disp(sprintf(['\n%s is closed but the figure is not deleted.\n\nYou can still '...
                  '<a href="matlab: %s.%s(%d);">reopen</a> it or ' ...
                  '<a href="matlab: delete(%d);">delete</a> it to '...
                  'reclaim resources.\n\n'], obj.WindowTitle, eval(CLASS), 'Show', obj.Handle, obj.Handle));
              end
            end
          otherwise
            obj.finalizeComponent();
            return;
        end
      end
    end
    
    function delete(obj)
      if isvalid(obj) && ~isOn(obj.IsDestructing)
        obj.IsDestructing = true;
        try delete(obj.Handle); end
        try delete(obj); end
      end
    end
    
  end
  
  methods (Static, Hidden)
    function Show(handle)
      try
        set(handle,'Visible', 'on');
        switch lower(get(handle,'type'))
          case 'figure'
            figure(handle);
          case 'axes'
            axes(handle);
        end
      catch err
        handle = 0;
      end
    end
  end
  
end

