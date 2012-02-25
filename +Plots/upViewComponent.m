classdef upViewComponent < grasppeHandle
  %UPPLOTVIEW Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (SetAccess = protected, GetAccess = protected)
    UpdatingView = false;     % To prevent Recursive-Updating
    UpdatingDelayTimer        % To delays Recursive-Updating
    InstanceID
    InstanceLimit = 20;
  end
  
  properties (SetAccess = public, GetAccess = public)
    Name
    Visible
    Tag
  end
  
  properties (SetAccess = protected, GetAccess = protected)
    Primitive                 % HG primitive handle
  end
  
  properties (Dependent = true)
    ID
    Type
    
    Styles
    Defaults
    
    ClassName
    ClassPath
  end
  
  properties (Constant = true, GetAccess = private)
    
  end
  
  methods
    
    function id = get.ID(obj)
      instanceID = obj.InstanceID;
      if (isempty(instanceID) || ~ischar(instanceID))
        instanceID = Plots.upViewComponent.InstanceRecord(obj);
        if (isempty(instanceID) || ~ischar(instanceID))
          obj.InstanceID = genvarname([obj.ClassName '_' int2str(rand*10^12)]);
        else
          obj.InstanceID = instanceID;
        end
      end
      id = obj.InstanceID;
    end
    
    function type = get.Type(obj)
      type = obj.ClassName;
    end
    
    function className = get.ClassName(obj)
      superName = eval(CLASS);
      className = class(obj);
      if (strcmpi(superName, className))
        warning('Grasppe:Component:ClassName:Unexpected', ...
          ['Attempting to access a component''s super class (%s) instead of the ' ...
          'actual component. Make sure this is the intended behaviour.'], superName);
      end
    end
    
    function classPath = get.ClassPath(obj)
      classPath = fullfile(which(obj.ClassName));
    end
    
    
    function obj = createComponent(obj, type, options)
      
      hObj = obj.createHandleObject(type, options{:}, 'Visible', 'off');
      
      obj.Primitive = hObj;
      
      obj.updateView;
      
      if (strcmpi(obj.Visible,'on'))
        obj.show();
      end
      
      set(hObj,'HandleVisibility', 'callback');
    end
    
    function hObj = createHandleObject (obj, type, varargin)
      
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
        case {'axes', 'plot', 'patch', 'surf', 'surfc'}
          constructor = lower(type);
          args = {args{:}, 'Parent', obj.Primitive};
        case {'text'}
          constructor = lower(type);
        otherwise
          error('Grasppe:CreateHandleObject:UnsupportedGraphicsObject', ...
            'Could not create a handle object of type ''%s''.', type);
      end
      
      hObj = feval(constructor, args{:});
      
      if isempty(get(hObj,'tag'))
        disp(get(hObj));
      end
      
      hProperties = get(hObj);
      
      hHooks      = regexpi(fieldnames(hProperties),'^\w+Fcn$','match','noemptymatch');
      hHooks      = horzcat(hHooks{:});
      
      hCallbacks  = hHooks;
      
      for i = 1:numel(hHooks)
        hook  = hHooks{i};
        callback        = get(hObj, hook);
        hCallbacks{2,i} = obj.callbackFunction(obj, hook, callback);
      end
      
      set(hObj, hCallbacks{:});
      
      return;
      
    end
    
    function 	obj = show(obj)
      try
        obj.setOptions('Visible', 'on');
        
        switch lower(get(obj.Primitive,'type'))
          case 'figure'
            figure(obj.Primitive)
          case 'axes'
            axes(obj.Primitive);
        end
      catch
        set(obj.Primitive, 'Visible', 'on');
      end
    end
    
    function obj = set.Visible(obj, value)
      try
        set(obj.Primitive, 'Visible',value);
      end
    end
    
    function obj = updateView(obj)
      %       persistent updating delayTimer;   % Prevent Recursive Updating
      
      updating = obj.UpdatingView;
      
      if isVerified('updating',true)
        delayTimer = obj.UpdatingDelayTimer;
        if ~isVerified('class(delayTimer)','timer');
          %           delayTimer = timer( ...
          %             'Name','DelayTimer',, ...
          %             'TimerFcn', {@Plots.upViewComponent.callbackEvent,obj});
          %           obj.UpdatingDelayTimer = delayTimer;
        end
        try
          stop(delayTimer);
          start(delayTimer);
        end
        return;
      end
      
      obj.UpdatingView = true; %updating = true;
      %       obj.updateView;
      obj.updateComponent;
      
      obj.UpdatingView = false;
      
    end
    
    
    %% Shared Property Wrappers
    
    function [options] = get.Defaults(obj)
      persistent DefinedOptions;
      
      if isempty(DefinedOptions)
        DefinedOptions = obj.getStatic('DefaultOptions'); %  %eval([obj.ClassName '.getDefaultStyles']);
      end
      
      options = DefinedOptions;
    end
    
    function [styles] = get.Styles(obj)
      persistent DefinedStyles;
      
      if isempty(DefinedStyles)
        DefinedStyles = obj.getStatic('DefaultStyles'); %  %eval([obj.ClassName '.getDefaultStyles']);
      end
      
      styles = DefinedStyles;
    end
    
  end
  
  %% Options & Preferences
  methods (Static)
    
    function [ID instance] = InstanceRecord(object)
      persistent instances hashmap
      
      %       dbstop('in',eval(CLASS),'if','error');  dbstop('in',eval(CLASS),'if','caught', 'error');
      
      if (~exist('object','var'))
        disp(hashmap);
        return;
      end
      
      instance = struct( 'class', class(object), 'created', now(), 'object', object );
      
      if (isempty(hashmap) || ~iscell(hashmap))
        hashmap = {};
      end
      
      row = [];
      
      GetInstance = @(r)  instances.(hashmap(r, 2))(hashmap(r, 3));
      
      SafeName    = @(t)  genvarname(regexprep(t,'[^\w]+','_'));
      
      if (~isempty(object.InstanceID) && ischar(object.ID) && size(hashmap,1)>0) % Rows
        row = find(strcmpi(hashmap(:, 1),object.ID));
      end
      
      if (numel(row)>1)
        warning('Grasppe:Componenet:InvalidInstanceRecords', ...
          ['Instance records are out of sync and showing duplicates ' ...
          'for the instance %s. A new ID will be created for this object.'], object.ID);
      end
      
      if (numel(row)==1)
        try
          stored  = GetInstance(row); %instances.(hashgroup(row))(hasindex(row));
          
          if (~strcmpi(stored.class, instance.class) || stored.object ~= instance.object)
            row = []; % Wrong record
          else
            instance = stored;
          end
        catch err
          row   = [];
        end
      end
      
      group 	= SafeName(instance.class);                                 %genvarname(strrep(instance.class,',','_'));
      % genvarname(regexprep([instance.class '.' int2str(instance.index)],'[^\w]+','_'));    %genvarname([instance.class '-' int2str(instance.index)]);
      
      if (numel(row)~=1)
        try
          groupInstances  = instances.(group);
          index   = numel(groupInstances) + 1;
        catch err
          index   = 1;
        end
        
        id = SafeName([instance.class '.' int2str(index)]);
        
        instances.(group)(index) = instance;
        hashmap(end+1,:) = {id, group, index};
        
      end
      
      ID  = id;
      
    end
    
    function options  = DefaultOptions( )
      
      Name      = 'Printing Uniformity Plot';
      Title     = 'Printing Uniformity';
      Color     = 'white';
      Toolbar   = 'none';  Menubar = 'none';
      Renderer  = 'opengl';
      
      options = WorkspaceVariables(true);
    end
    
    function styles   = DefaultStyles()
      
      %% Declarations
      Define            = @horzcat;
      
      %% Font Declarations
      Type.Face           = 'FontName';
      Type.Angle          = 'FontAngle';
      Type.Weight         = 'FontWeight';
      Type.Unit           = 'FontUnits';
      Type.Size           = 'FontSize';
      
      Type.SansSerif      = {Type.Face,     'Gill Sans'};  % 'Linotype Syntax Com Medium'
      Type.Serif          = {Type.Face,     'Bell MT'};
      Type.MonoSpaced     = {Type.Face,     'Lucida Sans Typewriter'};
      
      Type.BookWeight     = {Type.Weight,   'Normal'};
      Type.BoldWeight     = {Type.Weight,   'Bold'};
      
      Type.StraightAngle  = {Type.Angle,    'Normal'};
      Type.ObliqueAngle   = {Type.Angle,    'Italic'};
      
      Type.PointSize      = {Type.Unit,     'Point'};
      
      Type.Tiny           = Define(Type.PointSize,    Type.Size,  8       );
      Type.Small          = Define(Type.PointSize,    Type.Size,  10      );
      Type.Medium         = Define(Type.PointSize,    Type.Size,  12      );
      Type.Large          = Define(Type.PointSize,    Type.Size,  14      );
      Type.Huge           = Define(Type.PointSize,    Type.Size,  16      );
      
      Type.Regular        = Define(Type.BookWeight,   Type.StraightAngle  );
      Type.Bold           = Define(Type.BoldWeight,   Type.StraightAngle  );
      Type.Italic         = Define(Type.BoldWeight,   Type.ObliqueAngle   );
      Type.BoldItalic     = Define(Type.BoldWeight,   Type.ObliqueAngle   );
      
      %% Font Styles
      TextFont        = Define(Type.Serif,        Type.Italic,    Type.Medium );
      EmphasisFont    = Define(Type.Serif,        Type.Regular,   Type.Medium );
      LabelFont       = Define(Type.SansSerif,    Type.Regular,   Type.Medium );
      TitleFont       = Define(Type.SansSerif,    Type.Bold,      Type.Huge   );
      HeadingFont     = Define(Type.SansSerif,    Type.Bold,      Type.Large  );
      LegendFont      = Define(Type.SansSerif,    Type.Regular,   Type.Small  );
      OverlayFont     = Define(Type.SansSerif,    Type.Regular,   Type.Tiny   );
      TableFont       = Define(Type.MonoSpaced,   Type.Regular,   Type.Medium );
      CodeFont        = Define(Type.MonoSpaced,   Type.Regular,   Type.Small  );
      
      %% Layout Styles
      Layout.Horizontal   = 'HorizontalAlignment';
      Layout.Vertical     = 'VerticalAlignment';
      
      Layout.Left         = {Layout.Horizontal, 'Left'      };
      Layout.Center       = {Layout.Horizontal, 'Center'    };
      Layout.Right        = {Layout.Horizontal, 'Right'     };
      Layout.Top          = {Layout.Vertical,   'Top'       };
      Layout.Middle       = {Layout.Vertical,   'Middle'    };
      Layout.Bottom       = {Layout.Vertical,   'Bottom'    };
      Layout.Caps         = {Layout.Vertical,   'Cap'       };
      Layout.Baseline     = {Layout.Vertical,   'Baseline'  };
      
      
      
      %% Graphic Styles
      Axes.SmoothLines    = {'LineSmoothing', 'on'};
      
      Axes.Orthographic   = {'Projection', 'Orthographic'};
      Axes.Perspective    = {'Projection', 'Perspective'};
      
      Axes.BoxClipped     = {'Box','on'};
      Axes.Clipped        = {'Box','off', 'Clipping', 'on'};
      Axes.Unclipped      = {'Box','off', 'Clipping', 'off'};
      
      
      Grid.MajorLine      = 'GridLineStyle';
      Grid.MinorLine      = 'MinorGridLineStyle';
      Grid.XColor         = 'XColor';
      Grid.YColor         = 'YColor';
      Grid.ZColor         = 'YColor';
      
      Line.None           = {'LineStyle', 'none'; 'LineWidth', 0.00};
      
      Line.Hairline       = {'LineWidth', 0.25};
      Line.Thin           = {'LineWidth', 0.50};
      Line.Medium         = {'LineWidth', 0.50};
      Line.Thick          = {'LineWidth', 1.50};
      
      Line.Solid          = {'LineStyle', 'none'};
      Line.Dotted         = {'LineStyle', 'none'};
      Line.Dashed         = {'LineStyle', 'none'};
      Line.Mixed          = {'LineStyle', 'none'};
      
      
      %% Defined Styles
      NormalStyle         = Define(TextFont);
      AxesStyle           = Define(LegendFont);
      DataStyle           = Define(OverlayFont);
      TitleStyle          = Define(TitleFont, Layout.Center, Layout.Middle);
      
      clear Define;
      styles              = WorkspaceVariables(true);
      
    end
    
    function [fcn token]  = callbackFunction(object, varargin)
      [token fcn] = Plots.upViewComponent.createCallbackToken(object, varargin{:});
    end
    
    function obj = resizingComponent(obj)
      
    end
    
    function obj = closingComponent(obj)
      delete(obj.Primitive);
    end
    
  end
  
  %% Callbacks
  methods (Static)
    function delayTimer = getDelayTimer(object, tag)
      
      %       Name          = obj.getInstanc
      TimerFunction = object.callbackFunction('UpdateView');
      
      TimerOpt      = {'ExecutionMode', 'singleShot', 'StartDelay', 1, 'Name','DelayTimer'};
      
      delayTimer = timer('TimerFcn', TimerFunction, TimerOpt{:});
      
      object.UpdatingDelayTimer = delayTimer;
    end
    
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
      
      fcn   = {@Plots.upViewComponent.callbackEvent, token};
      
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
        if isValid('token.Object', eval(CLASS))
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
      elseif isValid('source',  'handle')
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
            object.closingComponent(object);
          else
              delete(source);
          end
          disp(token);
        case 'ResizeFcn'
          if isSourceObject
            object.resizingComponent(object);
          end
        case 'DeleteFcn'
          set(source, 'Visible', 'off');
          drawnow;
%           delete(source);
        case {'WindowButtonDownFcn', 'WindowButtonMotionFcn', 'WindowButtonUpFcn', 'WindowKeyPressFcn', 'WindowKeyReleaseFcn', 'WindowScrollWheelFcn'}
        otherwise
          if (~isempty(callback))
            try
              feval(callback{:})
            catch err
              warning('Grasppe:Component:CallbackError', err.message);
            end
          end
          event.action =  [callsign ': ' caller];
          disp(event);
          disp(token);
      end
    end
  end
  
  methods (Abstract)
    
    obj = updateComponent(obj);
  end
  
end

