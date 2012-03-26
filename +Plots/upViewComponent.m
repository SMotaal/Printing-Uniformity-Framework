classdef upViewComponent < Plots.upGrasppeHandle & ...
    Plots.upStyledObject & Plots.upEventHandler & Plots.upInstanceComponent
  %UPPLOTVIEW Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (SetAccess = protected, GetAccess = protected)
    UpdatingView = false;     % To prevent Recursive-Updating
    UpdatingDelayTimer        % To delays Recursive-Updating
  end
  
  properties (SetAccess = public, GetAccess = public)
    Name
    Visible
    Tag
    HitTest
  end
  
  methods
    
    
    function obj = upViewComponent(varargin)
      
      if validCheck('obj.Defaults','struct')
        obj.setOptions(obj.Defaults, varargin{:});
      else
        obj.setOptions(varargin{:});
      end
      
      obj.Visible = resolve(strcmpi(obj.Visible,'on'), 'on', 'off');
      
      obj.createComponent([], []);
      
    end
    
    function obj = createComponent(obj, type, options)
      
      if (obj.Busy || isValidHandle('obj.Primitive'))
        return;
      end
      
      options = obj.getComponentOptions(options);
      
      type    = obj.getComponentType(type);
            
      if isValidHandle('obj.Parent')
        parent = obj.Parent;
      else
        parent = [];
      end
      
      hObj = obj.findObjects(obj.ID, type);
      
      switch lower(type)
        case 'figure'
        case {'axes', 'plot', 'patch', 'surface', 'surf', 'surfc'}
        case {'text'}
        otherwise
      end
      
      
      if isempty(hObj)
        obj.Primitive = obj.createHandleObject(type, obj.ID, parent, options{:});
      else
        obj.Primitive = hObj(1);
        if ~isempty(parent)
          obj.Set('Parent', parent);
        end
        obj.Set(options{:});
      end
      
      obj.updateView;
      
      if (strcmpi(obj.Visible,'on'))
        obj.show();
      end
      
      setUserData(hObj, obj );
      obj.Set('HandleVisibility', 'callback');
    end
    
    function tag = componentTag(obj, tag)
      tag = [obj.ID '.' tag];
    end
    
    function tag = createTag(obj, type, tag, parent)
      
      if isValidHandle(parent)
        parentTag = obj.Get(parent,'tag');
      else
        parentTag = '';
      end
      
      if isempty(tag)
        if isempty(parentTag)
          idx = numel(findall(0,'type',type)) + 1;
          tag = [constructor '_' int2str(idx)];
        else
          idx = numel(findobj(parent,'type',type)) + 1;
          tag = [parent '.' constructor '_' int2str(idx)];
        end
        tag = upper(tag);
      else
        if isempty(parentTag)
        end
      end
      
    end
    
    function hObj = createHandleObject (obj, type, tag, parent, varargin)
      
      if ~(validCheck('obj','object') && validCheck('type','char'))
        error('Grasppe:CreateHandleObject:InvalidParamters', ...
          'Attempting to create a handle object without a valid object or type.');
      end
      
      constructor = [];
      
      type = lower(type);
      
      args = {varargin{:}};
      
      switch lower(type)
        case 'figure'
          constructor = lower(type);
          args = {args{:}, 'Visible', 'off'};
        case {'axes', 'plot', 'patch', 'surface', 'surf', 'surfc'}
          constructor = lower(type);
          %           args = {'Parent', obj.Parent, args{:}};
        case {'text'}
          constructor = lower(type);
        otherwise
          error('Grasppe:CreateHandleObject:UnsupportedGraphicsObject', ...
            'Could not create a handle object of type ''%s''.', type);
      end
      
      if isValidHandle(parent)
        parentArgs  = find(strcmpi(args(1:2:end),'parent'));
        if ~isempty(parentArgs)
          args = args(setdiff(1:numel(args), [parentArgs*2 parentArgs*2-1]));
        end        
        args      = {args{:}, 'Parent', parent};
      end
      
      if ~any(strcmpi(args(1:2:end),'tag'))
        tag = obj.createTag(type, tag, parent);
        args = {args{:}, 'Tag', tag};
      end
      
      disp([constructor ':     ' toString(toString(args{:}))]);
      
      hObj = feval(constructor, args{:});
      
      
%       if isempty(get(hObj,'tag'))
%         %         disp(get(hObj));
%       end
      
      obj.attachEvents(hObj);
      
      return;
      
    end
    
    function attachEvents(obj, hObj)
      
      try
      
      if ~validCheck('hObj', 'handle')
        hObj = obj.Primitive;
        
      end
      hProperties = obj.Get(hObj);
      
      isComponent = isequal(hObj, obj.Primitive);
      
      hHooks      = regexpi(fieldnames(hProperties),'^\w+Fcn$','match','noemptymatch');
      hHooks      = horzcat(hHooks{:});
      
      hCallbacks  = hHooks;
      
      restrictedHooks = {'WindowKeyPressFcn', 'WindowKeyReleaseFcn'};
      % 'WindowButtonDownFcn', 'WindowButtonMotionFcn', 'WindowButtonUpFcn'
      
      try
        componentHooks = obj.ComponentEvents;
      catch
        componentHooks = {};
      end
      
      if (isComponent && strcmpi(obj.Get(hObj, 'type'),'figure'));
        try
          hManager = uigetmodemanager(hObj);
          set(hManager.WindowListenerHandles,'Enable','off'); % zap the listeners
        catch err
          disp(err);
        end        
      end
      
      
      for i = 1:numel(hHooks)
        hook  = hHooks{i};
        if stropt(hook, componentHooks) && isComponent
          if isempty(obj.(hook))
            obj.setOptions(hook, obj.callbackFunction(hook));
          else
            obj.setOptions(hook, obj.(hook));
          end
        else
          if ~stropt(hook, restrictedHooks)
            callback        = obj.Get(hObj, hook);
            hCallbacks{2,i} = obj.callbackFunction(hook, callback);        
          else
            hCallbacks{2,i} = obj.callbackFunction(hook);        
          end
        end
      end
      
      obj.Set(hObj, hCallbacks{:});   
      catch err
        dealwith(err);
      end
    end
    
    function 	obj = show(obj)
      try
        h = Plots.upViewComponent.showHandle(obj.Primitive);
%         if (h==0)
%           if validCheck('obj.ComponentType', 'char')
%             obj.createComponent(obj.ComponentType);
%           end
%         end
      end
    end
    
    function obj = set.Visible(obj, value)
      obj.Visible = value;
      if (~obj.Busy && isValidHandle(obj.Primitive))
        %       try
        obj.Set('Visible',value);
        %       end
      end
    end
    
    function oldstate = markBusy(obj)
      oldstate = obj.Busy;
      obj.Busy = true;
    end
    
    function obj = updateComponent(obj)
      %       busy = obj.markBusy();
      %       try
      if ~isempty(obj.getComponentOptions) && isValidHandle(obj.Primitive)
        obj.Set(obj.getComponentOptions{:});
%       else
%         disp(obj.ID);
      end
      %       catch err
      %         warning(err.identifier, err.message);
      %       end
      %       obj.Busy = busy;
      
      %       drawnow();
      if (~obj.UpdatingView)
        updateView(obj);
      end
    end
    
    function obj = updateView(obj)
      
      if isequal(obj.Busy || obj.UpdatingView, true)
        delayTimer = obj.UpdatingDelayTimer;
        if ~isVerified('class(delayTimer)','timer');
        end
        try
          stop(delayTimer);
          start(delayTimer);
        end
        return;
      end
      
      obj.UpdatingView = true;
      obj.updateComponent;
      obj.UpdatingView = false;
      
    end
    
    
    %% Shared Property Wrappers
    
    function obj = resizeComponent(obj)
      
    end
    
    function obj = hide(obj)
      try
%         obj.Visible = 'off;'
      obj.Set('Visible','off');
      obj.setOptions('Visible','off');
      end
    end
    
    function obj = finalizeComponent(obj)
      delete(obj.Primitive);
    end
    
    function obj = closeComponent(obj)
      d = dbstack;
      isClose = any(strcmpi({d.('file')}, 'close.p'));
      
      try
        hType = obj.Get(obj.Primitive,'type');
        
        switch lower(hType)
          case 'figure'
            if (isClose || isQuitting())
              obj.finalizeComponent();
            else
              obj.hide();
              try
                disp(sprintf(['\n%s is closed but the figure is not deleted.\n\nYou can still '...
                  '<a href="matlab: %s.showHandle(%d);">reopen</a> it or ' ...
                  '<a href="matlab: delete(%d);">delete</a> it to '...
                  'reclaim resources.\n\n'], obj.Name, eval(CLASS), obj.Primitive, obj.Primitive));
%                 grasppeQueue([], ['Reopen ' obj.Name], ['click the link to reopen this figure'], ...
%                   sprintf('%s.showHandle(%d);', eval(CLASS), obj.Primitive));
%                 grasppeQueue([], ['Delete ' obj.Name], ['click the link to delete the figure'], ...
%                   sprintf('delete(%d);', obj.Primitive));
              end
            end
          otherwise
            obj.finalizeComponent();
            return;
        end
      end
    end
    
    function delete(obj)
      try
        delete(obj.Primitive);
      end
    end
    
  end
  
  %% Options & Preferences
  
  %% Callbacks
  methods (Static)
    function delayTimer = getDelayTimer(object, tag)
      
      TimerFunction = object.callbackFunction('UpdateView');
      TimerOpt      = {'ExecutionMode', 'singleShot', 'StartDelay', 1, 'Name','DelayTimer'};
      delayTimer = timer('TimerFcn', TimerFunction, TimerOpt{:});
      object.UpdatingDelayTimer = delayTimer;
      
    end
    
    function 	handle = showHandle(handle)
      try
        set(handle,'Visible', 'on');
        switch lower(get(handle,'type'))
          case 'figure'
            figure(handle)
          case 'axes'
            axes(handle);
        end
      catch err
        handle = 0;
      end
    end
    
  end
  
  methods(Abstract, Static)
    options  = DefaultOptions()
  end
  
end

