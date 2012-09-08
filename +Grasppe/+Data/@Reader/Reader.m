classdef Reader < Grasppe.Core.Component
  %READER Abstract Data Reader
  %   Detailed explanation goes here
  
  properties (GetAccess=public, SetAccess=protected)
    Data
    Parameters
    State
    ChangeEventData
  end
  
  properties (Access=private)
    updateDelayTimer;
  end
  
  events
    AttemptingChange
    FailedChange
    SuccessfulChange
    AbortedChange
  end
  
  methods
    function obj = Reader(varargin)
      obj = obj@Grasppe.Core.Component(varargin{:});
    end
  end
   
  methods (Access=protected)
    eventData   = FireEvent(obj, type, varargin);
    eventData   = ResetEventData( obj, type, varargin );
    tf          = UpdateState(obj, mode, targetState, abortOnFail);
  end
  
  methods
    eventData   = UpdateData( obj, parameter, value );
  end
  
  methods (Access=protected, Abstract)
    change        = SetParameters(obj, eventData);
  end
  
  methods
    function data = get.Data(obj)
      %data = [];
      try obj.Data.DataReader = obj;        end
      try data                = obj.Data;   end
    end
  end
  
  
  %% Grasppe Prototype Methods
  methods (Access=protected)
    function createComponent(obj)
      obj.PrepareDataModels;
      
      componentOptions  = obj.getComponentOptions;
      parameters        = obj.DataParameters();
      
      if ~isempty(componentOptions) && ~isempty(parameters)
        for m = 1:numel(parameters)
          property      = parameters{m};
          idx           = find( strcmpi(property, componentOptions), 1, 'last');
          try obj.(property)            = componentOptions{ idx  + 1}; end
          try obj.Parameters.(property) = componentOptions{ idx  + 1}; end
        end
      end
      
      try
        obj.UpdateData();
      catch err
        debugStamp(err, 1);
      end
      
      obj.createComponent@Grasppe.Core.Component;
    end
  end
  
  methods (Access = protected)
    
    %% State Routines
    
    function state = GetNamedState(obj, state)
      if ~exist('state', 'var') || ~ischar(state), state = '.';
      else state = [' ' state]; end
      
      error('Grasppe:State:NamesNotDefined', 'Cannot get named state %s', state);
    end
    
    function tf = PromoteState(obj, varargin)
      tf = obj.UpdateState('Promote', varargin{:});
    end
    
    function tf = DemoteState(obj, varargin)
      tf = obj.UpdateState('Demote', varargin{:});
    end
    
    function tf = CheckState(obj, varargin)
      tf = obj.UpdateState('Check', varargin{:});
    end
    
    
    function parameters = DataParameters(obj, parameter)
      parameters            = feval([class(obj) '.GetDataParameters']);
      
      if nargin>1 && iscellstr(parameters) && ~isempty(parameters)
        try
          parameters        = parameters(find(strcmpi(parameter, parameters), 1));
        catch err
          parameters        = '';
        end
      end
    end
    
    
  end
  
  methods (Hidden)
    function tf = TestState(obj, terminate)
      if exist('terminate', 'var') && isequal(terminate, true)
        tf = obj.UpdateState('stop test');
      else
        tf = obj.UpdateState('start test');
      end
    end
  end
  
  %% Grasppe Model Methods
  methods (Access=protected)
    
    function CreateDataModel(obj, field, class, varargin)
      obj.DeleteDataModel(field);
      obj.PrepareDataModel(field, class, varargin{:});
    end
    
    function DeleteDataModel(obj, field, condition)
      if ~exist('condition', 'var') || condition
        if isobject(obj.(field)), delete(obj.(field)); end
        obj.(field) = [];
      end
    end
    
    function PrepareDataModel(obj, field, class, varargin)
      if ~isa(obj.(field), class) || isempty(obj.(field))
        obj.(field) = feval(class, varargin{:});
      end
    end
    
    function PrepareDataModels(obj)
      if ~isstruct(obj.DataModels) || isempty(fieldnames(obj.DataModels)), return;  end
      modelFields = fieldnames(obj.DataModels);
      for m = 1:numel(modelFields)
        obj.PrepareDataModel(modelFields{m}, obj.DataModels.(modelFields{m}));
      end
    end
    
    function DeleteDataModels(obj)
      if ~isstruct(obj.DataModels) || isempty(fieldnames(obj.DataModels)), return;  end
      modelFields = fieldnames(obj.DataModels);
      for m = 1:numel(modelFields)
        obj.DeleteDataModel(modelFields{m});
      end
    end
    
    function CreateDataModels(obj)
      if ~isstruct(obj.DataModels) || isempty(fieldnames(obj.DataModels)), return;  end
      modelFields = fieldnames(obj.DataModels);
      for m = 1:numel(modelFields)
        obj.CreateDataModel(modelFields{m}, obj.DataModels.(modelFields{m}));
      end
    end
    
  end
  
  methods (Abstract, Static)
    parameters =  GetDataParameters();
  end
  
end

%     function change = GetChangeParameters(obj, newParameters)
%       currentParameters       = obj.Parameters;
%       parameters              = obj.DataParameters();
%       change                  = {};
%
%       %% What changed?
%       for m = 1:numel(parameters)
%         try
%           parameter           = parameters{m};
%           if ~isequal(currentParameters.(parameter), newParameters.(parameter));
%             change            = [change, parameter];
%           end
%         end
%       end
%     end

%     function change = SetParameters(obj, eventData, parameter, value)
%       if ~exist('parameter',  'var')
%         parameter = eventData.parameter;
%       end
%       if ~exist('change', 'var') || isequal(change, 'all')
%         change              = obj.GetChangeParameters(newParameters);
%       end
%     end

%     function tf = TestState(obj, terminate)
%       
%       if isempty(obj.TestTimer) || ~isscalar(obj.TestTimer) || ~isa(obj.TestTimer, 'timer') || ~isvalid(obj.TestTimer)
%         obj.TestTimer = timer('Tag',['TestStatusDelayTimer'], ...
%           'ExecutionMode', 'fixedSpacing', 'TasksToExecute', 3, ...
%           'BusyMode',   'drop', 'StartDelay', 0.1, 'Period', 1, ...
%           'ObjectVisibility',  'on', ...  %'StartFcn',   @displayStart, ... % eval('disp(''StartFcn'');  disp(s);  disp(e);  disp(e.Data);'), 'StopFcn',    @(s, e) delete(s), ...
%           'TimerFcn',   @(s, e)disp(obj.State) ...           %'ErrorFcn',   @displayError ...
%           );
%       end
%       
%       if exist('terminate', 'var') && isequal(terminate, true)
%         try stop(obj.TestTimer); end
%       else
%         try start(obj.TestTimer); end
%       end
%     end
