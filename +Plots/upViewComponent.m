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
      
      if isValid('obj.Defaults','struct')
        obj.setOptions(obj.Defaults, varargin{:});
      else
        obj.setOptions(varargin{:});
      end
      
      if strcmpi(obj.Visible,'on')
        obj.createComponent();
      end
    end   
    
    function obj = createComponent(obj, type, options)
      if (obj.Busy || isValidHandle('obj.Primitive'))
        return;
      end
      
      if (~isValid('options','cell') || isempty(options))
        options = obj.getComponentOptions;
      end
      
      if (~isValid('type','char'))
        try
          type = obj.ComponentType;
        catch err
          error('Grasppe:Component:MissingType', ...
            'Attempt to create component without specifying type.');
        end
      end
      
      if isValidHandle('obj.Parent')
        parent = obj.Parent;
      else
        parent = [];
      end
      
      hObj = obj.findObjects(obj.ID, type);
      
      if isempty(hObj)
        obj.Primitive = obj.createHandleObject(type, obj.ID, parent, options{:});
      else
        obj.Primitive = hObj(1);
        if ~isempty(parent)
          set(obj.Primitive, 'Parent', parent);
        end
        set(obj.Primitive, options{:});
      end
           
      obj.updateView;
      
      if (strcmpi(obj.Visible,'on'))
        obj.show();
      end
      
      setUserData(hObj, obj );
      set(hObj,'HandleVisibility', 'callback');
    end
    
    function tag = componentTag(obj, tag)
      tag = [obj.ID '.' tag];
    end
    
    function tag = createTag(obj, type, tag, parent)
      
      if isValidHandle(parent)
        parentTag = get(parent,'tag');
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
          %         else
          %           tag = [parentTag '.' tag];
        end
      end
      
    end
    
    function hObj = createHandleObject (obj, type, tag, parent, varargin)
      
      if ~(isValid('obj','object') && isValid('type','char'))
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
        args      = {args{:}, 'Parent', parent};
        %
        %         parentTag = get(parent,'tag');
        %       else
        %         parentTag = '';
      end
      
      tag = obj.createTag(type, tag, parent);
      
      %       if isempty(tag)
      %         if isempty(parentTag)
      %           idx = numel(findall(0,'type',type)) + 1;
      %           tag = [constructor '_' int2str(idx)];
      %         else
      %           idx = numel(findobj(parent,'type',type)) + 1;
      %           tag = [parent '.' constructor '_' int2str(idx)];
      %         end
      %         tag = upper(tag);
      %       else
      %         if isempty(parentTag)
      %         else
      %           tag = [parentTag '.' tag];
      %         end
      %       end
      
      
      disp([constructor ':     ' toString(toString(args{:}))]);
      
      hObj = feval(constructor, args{:}, 'Tag', tag);
      
      if isempty(get(hObj,'tag'))
        %         disp(get(hObj));
      end
      
      hProperties = get(hObj);
      
      hHooks      = regexpi(fieldnames(hProperties),'^\w+Fcn$','match','noemptymatch');
      hHooks      = horzcat(hHooks{:});
      
      hCallbacks  = hHooks;
      
      for i = 1:numel(hHooks)
        hook  = hHooks{i};
        callback        = get(hObj, hook);
        hCallbacks{2,i} = obj.callbackFunction(hook, callback);
      end
      
      set(hObj, hCallbacks{:});
      
      return;
      
    end
    
    function 	obj = show(obj)
      try
        h = Plots.upViewComponent.showHandle(obj.Primitive);
        if (h==0)
          if isValid('obj.ComponentType', 'char')
            obj.createComponent(obj.ComponentType);
          end
        end
      end
    end
    
    function obj = set.Visible(obj, value)
      obj.Visible = value;
      if (~obj.Busy && isValidHandle(obj.Primitive))
        %       try
        set(obj.Primitive, 'Visible',value);
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
        set(obj.Primitive, obj.getComponentOptions{:});
      else
        disp(obj.ID);
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
      obj.setOptions('Visible','off');
      set(obj.Primitive,'Visible','off');
    end
    
    function obj = finalizeComponent(obj)
      delete(obj.Primitive);
    end
    
    function obj = closeComponent(obj)
      if (isQuitting)
        obj.finalizeComponent();
        return;
      end
      try
        hType = get(obj.Primitive,'type');
        
        switch lower(hType)
          case 'figure'
            try
              grasppeQueue([], ['Reopen ' obj.Name], ['click the link to reopen this figure'], ...
                sprintf('%s.showHandle(%d);', eval(CLASS), obj.Primitive));
              grasppeQueue([], ['Delete ' obj.Name], ['click the link to delete the figure'], ...
                sprintf('delete(%d);', obj.Primitive));
            end
            obj.hide();
          otherwise
            obj.finalizeComponent();
        end
      catch
        %         delete(obj.Primitive);
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
    
%     function [token fcn] = createCallbackToken(object, name, callback)
%       
%       if (~isValid('object',    'object'))
%         object    = [];
%       end
%       
%       if (~isValid('name',      'char'))
%         name      = [];
%       end
%       
%       if (~isValid('callback','cell'))
%         if (isValid('callback',  'char'))
%           callback  = {callback};
%         else
%           callback  = [];
%         end
%       end
%       
%       token = struct('Object', object, 'Name', name, 'Callback', callback);
%       
%       fcn   = {@Plots.upViewComponent.callbackEvent, token};
%       
%     end
%     
%     function callbackEvent(source, event, varargin)
%       
%       objectFound = false;
%       object    = [];
%       callsign  = [];
%       callback  = [];
%       caller    = [];
%       isSourceObject  = false;
%       
%       if isstruct(varargin{1})
%         token  =  varargin{1};
%         if isValid('token.Object', eval(CLASS))
%           object = token.Object;
%           objectFound = true;
%         end
%         if isValid('token.Name', 'char')
%           callsign = token.Name;
%         end
%         if isValid('token.callback','cell')
%           callback = token.callback;
%         end
%         
%         token.ObjectID = object.ID;
%       end
%       
%       
%       if isValid('source.Name', 'char'  )
%         caller  = source.Name;
%       elseif isValidHandle('source')
%         try
%           isSourceObject = object.Primitive==source;
%         end
%         try
%           caller  = [get(source, 'Name'  ) ' '];
%         end
%         try
%           caller  = [caller '(' get(source, 'Type'  ) ')'];
%         end
%       end
%       
%       switch callsign
%         case 'UpdateView'
%           if (objectFound)
%             object.updateView();
%             stop(source); delete(source);
%           end
%         case 'CloseRequestFcn'
%           if isSourceObject
%             object.closeComponent();
%           else
%             delete(source);
%           end
%         case 'ResizeFcn'
%           if isSourceObject
%             object.resizeComponent();
%           end
%         case 'DeleteFcn'
%           set(source, 'Visible', 'off');  delete(source);
%         case {'WindowButtonDownFcn', 'WindowButtonMotionFcn', 'WindowButtonUpFcn', 'WindowKeyPressFcn', 'WindowKeyReleaseFcn', 'WindowScrollWheelFcn'}
%         otherwise
%           desc = sprintf('');
%           if (~isempty(callback))
%             try
%               feval(callback{:})
%             catch err
%               warning('Grasppe:Component:CallbackError', err.message);
%             end
%           end
%           event.action =  [callsign ': ' caller];
%           disp(event);
%           disp(token);
%       end
%     end
    
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

