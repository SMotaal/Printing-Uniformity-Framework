classdef upEventHandler < handle
  %UPEVENTHANDLER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    
    function [fcn token]  = callbackFunction(object, varargin)
      [token fcn] = Plots.upEventHandler.createCallbackToken(object, varargin{:});
    end
    
  end
  
  
  methods (Static)
    
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
      
      fcn   = {@Plots.upEventHandler.callbackEvent, token};
      
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
          isSourceObject = object.Primitive==source;
        end
        try
          caller  = [get(source, 'Name'  ) ' '];
        end
        try
          caller  = [caller '(' get(source, 'Type'  ) ')'];
        end
      end
      
      switch callsign
        case 'UpdateView'
          if (objectFound)
            object.updateView();
            stop(source); delete(source);
          end
        case 'CloseRequestFcn'
          if isSourceObject
            object.closeComponent();
          else
            delete(source);
          end
        case 'ResizeFcn'
          if isSourceObject
            object.resizeComponent();
          end
        case 'DeleteFcn'
          set(source, 'Visible', 'off');  delete(source);
        case {'WindowButtonDownFcn', 'WindowButtonMotionFcn', 'WindowButtonUpFcn', 'WindowKeyPressFcn', 'WindowKeyReleaseFcn', 'WindowScrollWheelFcn'}
        otherwise
          desc = sprintf('');
          if (~isempty(callback))
            try
              feval(callback{:});
            catch err
              warning('Grasppe:Component:CallbackError', err.message);
            end
          end
          event.action =  [callsign ': ' caller]; %  disp(event); disp(token);
      end
    end
  end
  
end

