classdef GraphicsEventHandler < EventHandler & KeyEventHandler & MouseEventHandler
  %GRASPPECOMPONENTEVENTS Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    WindowEventHandlers
  end
  
  methods (Hidden)
    
    function registerWindowEventHandler(obj, handler)
      obj.registerEventHandler('WindowEventHandlers', handler);
    end
    
    
    function finalizeComponent(obj, source, event)
      obj.delete;
    end
    
    function windowResize(obj, source, event)
      obj.resizeComponent();
      handlers = obj.WindowEventHandlers;
      if iscell(handlers) && ~isempty(handlers)
        for i = 1:numel(handlers)
          try
            handlers{i}.resizeComponent();
          end
        end
      end
    end
    
    %     function windowClosed(obj, source, event)
    %       obj.resizeComponent();
    %       handlers = obj.WindowEventHandlers;
    %       if iscell(handlers) && ~isempty(handlers)
    %         for i = 1:numel(handlers)
    %           try
    %             handlers{i}.resizeComponent();
    %           end
    %         end
    %       end
    %     end
    
    
    function resizeComponent(obj)
    end
    
    
    function closeComponent(obj)
      d = dbstack;
      isClose = any(strcmpi({d.('file')}, 'close.p'));
      
      try
        hType = obj.handleGet('type');
        
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
    
    function delete(obj, source, event)
      s = warning('off', 'MATLAB:hg');
      try
        obj.IsDestructing = true;
        try delete(obj.Handle); end
      catch err
        try debugStamp(obj.ID); end
        disp(err);
      end
      warning(s);
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

