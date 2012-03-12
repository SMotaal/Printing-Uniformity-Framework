classdef EventHandler < GrasppeHandle
  %UPEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    
  end
  
  methods (Hidden=false)
    
    function [fcn token]  = callbackFunction(object, varargin)
      [token fcn] = EventHandler.createCallbackToken(object, varargin{:});
    end
    
    function registerEventHandler(obj, hanldersGroup, handler)
      handlers = obj.(hanldersGroup);
      
      if ~iscell(handlers)
        handlers = {};
      end
            
      if ~any(handlers==handler)
        handlers{end+1} = handler;
        obj.(hanldersGroup) = handlers;
      end
    end
    
    function attachEvents(obj, hooks)
      try
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
          if ~isClass(callback,'EventHandler.callbackEvent')
            callback = obj.callbackFunction(hook, callback);
          end
        end
        callbacks{i} = callback;
      end
      
      finalHooks = reshape({hooks{:}; callbacks{:}},1,[]);
      
      obj.setOptions(finalHooks{:});
      catch err
        halt(err, 'obj.ID');
        try debugStamp(obj.ID, 4); end
      end
      
    end
    
    
  end
  
  methods (Static, Hidden)
    
    function [token fcn] = createCallbackToken(object, name, callback)
      
      if (~isValid('object',    'object'))
        object    = [];
      end
      
      if (~isValid('name',      'char'))
        name      = [];
      end
      
      if (~isValid('callback','cell'))
        if (isValid('callback',  'char'))
          callback  = {callback};
        else
          callback  = [];
        end
      end
      
      token = struct('Object', object, 'Name', name, 'Callback', callback);
      
      fcn   = {@EventHandler.callbackEvent, token};
      
    end
    
    function callbackEvent(source, event, varargin)
      
      objectFound = false;
      object    = [];
      callsign  = [];
      callback  = [];
      caller    = [];
      isSourceObject  = false;
      
      if isstruct(varargin{1})
        token  =  varargin{1};
        validToken = stropt({'object', 'name', 'callback'}, fieldnames(token));
        if validToken && isSuper(eval(CLASS), token.Object)
          object = token.Object;
          objectFound = true;
        end
        if isValid('token.Name', 'char')
          callsign = token.Name;
        end
        if isValid('token.callback','cell')
          callback = token.callback;
        end
        
        token.ObjectID = object.ID;
      end
      
      
      if isValid('source.Name', 'char'  )
        caller  = source.Name;
      elseif isValidHandle('source')
        try
          isSourceObject = object.Handle==source;
        end
        try
          caller  = [obj.Get(source, 'Name'  ) ' '];
        end
        try
          caller  = [caller '(' obj.Get(source, 'Type'  ) ')'];
        end
      end
      
      try
      switch callsign
        case 'UpdateView'
%           if (objectFound)
            stop(source); delete(source);
            object.updateView();
%           end
        case 'DisableRotation'
          stop(source);
          object.toggleRotation('callback');
        case 'CloseRequestFcn'
%           if isSourceObject
            object.closeComponent();
%           else
%             delete(source);
%           end
        case 'ResizeFcn'
%           if isSourceObject
            object.windowResize(event);
%           end
        case 'DeleteFcn'
            object.deleteComponent();
        case {'KeyPressFcn', 'WindowKeyPressFcn'}
%           if isSourceObject
            object.keyPress(event);
%           end         
        case {'KeyReleaseFcn', 'WindowKeyReleaseFcn'};
%           if isSourceObject
            object.keyRelease(event);
%         case {'WindowButtonDownFcn', 'WindowButtonMotionFcn', 'WindowButtonUpFcn', 'WindowKeyPressFcn', 'WindowKeyReleaseFcn', 'WindowScrollWheelFcn'}
        case {'ButtonUpFcn', 'WindowButtonUpFcn'}
          object.mouseUp(event);
        case {'ButtonDownFcn', 'WindowButtonDownFcn'}
          object.mouseDown(event);
        otherwise
          desc = sprintf('');
          if (~isempty(callback))
            try
              feval(callback{:});
            catch err
              warning('Grasppe:Component:CallbackError', err.message);
            end
          end
      end
      end
      try      
          if (objectFound)
            event.target = [int2str(source) '>' object.ID];
          else
            event.target = source;
          end
          event.action =  [callsign ': ' caller]; %disp(token);
%           disp(toString(flat(structList(event))));
      end

    end
  end
  
  methods(Abstract, Static, Hidden)
    options  = DefaultOptions()
  end  
  
end

