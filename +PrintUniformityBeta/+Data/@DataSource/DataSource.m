classdef DataSource < GrasppeAlpha.Data.Source & ...
    PrintUniformityBeta.Data.DataSourceModel & PrintUniformityBeta.Data.DataEventHandler
  %DATASOURCE Printing Uniformity Data Source
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    %% Debugging
    DebuggingDataEvents         = false;
    
    %% Parameters
    DelayedUpdate               = true;
    
    %% HandleComponent
    HandleProperties            = {};
    HandleEvents                = {};
    ComponentType               = 'PrintingUniformityDataSource';
    ComponentProperties         = '';
    
    %% Mediator-Controlled Properties
    DataProperties    = {'CaseID', 'SetID', 'SheetID', 'VariableID'};
    
    %% Prototype Meta Properties
    DataSourceProperties        = {
      'CaseID',       'Case ID',            'Data',       'string',   '';   ...
      'SetID',        'Set ID',             'Data',       'int',      '';   ...
      'SheetID',      'Sheet ID',           'Data',       'int',      '';   ...
      'VariableID',   'Variable ID',        'Data',       'string',   '';   ...
      'CaseName',     'Case Name',          'Data',       'string',   '';   ...
      'SetName',      'Set Name',           'Data',       'string',   '';   ...
      'SheetName',    'Sheet Name',         'Data',       'string',   '';   ...
      'VariableName', 'Variable Name',      'Data',       'string',   '';   ...
      'SetCount',     'Number of Sets',     'Data',       'int',      '';   ...
      'SheetCount',   'Number of Sheets',   'Data',       'int',      '';   ...
      'RowCount',     'Number of Rows',     'Data',       'int',      '';   ...
      'SheetCount',   'Number of Columns',  'Data',       'int',      '';   ...
      };
    
    % DataModels = struct( ...
    %   'Data',       'PrintUniformityBeta.Models.UniformityData', ...
    %   'Parameters', 'PrintUniformityBeta.Models.DataParameters' ...
    %   )
    
    dataReaderClass             = 'PrintUniformityBeta.Data.DataReader';
  end
  
%   properties (AbortSet, SetObservable, GetObservable)
%     State                       = GrasppeAlpha.Core.Enumerations.TaskStates.Initializing;
%   end
  
  properties (Access=protected)
    parameterSetTimer;                            % Threaded parameter Set timer
    parameterSetDelay           = 0.25;           % Threaded parameter Set delay
    
    %caseState                   = ;
    %setState                    = GrasppeAlpha.Core.Enumerations.TaskStates.Initializing;
    %sheetState                  = GrasppeAlpha.Core.Enumerations.TaskStates.Initializing;
    %variableState               = GrasppeAlpha.Core.Enumerations.TaskStates.Initializing;
    states                      = struct( ...
      'GetCase',      GrasppeAlpha.Core.Enumerations.TaskStates.Ready, ...
      'GetSet',       GrasppeAlpha.Core.Enumerations.TaskStates.Ready, ...
      'GetSheet',     GrasppeAlpha.Core.Enumerations.TaskStates.Ready, ...
      'GetVariable',  GrasppeAlpha.Core.Enumerations.TaskStates.Ready       );
    
  end
  
  
  methods
    function obj = DataSource(varargin)
      % initializer = true; try initializer = ~isequal(evalin('caller', 'initializer'), true); end
      % disp([mfilename ' initializer: ' num2str(nargout) '<' num2str(initializer)]);      
      
      obj                       = obj@PrintUniformityBeta.Data.DataSourceModel();
      obj                       = obj@GrasppeAlpha.Data.Source(varargin{:});
      obj                       = obj@PrintUniformityBeta.Data.DataEventHandler();
      
      if obj.DebuggingDataEvents, disp(obj.State); end
      
      obj.attachSelfPropertyListeners('DataEventHandlers', { ...
        'CaseID', 'SetID', 'SheetID', 'VariableID', ...
        'CaseData', 'SetData', 'SheetData', 'VariableData', ...
        'CaseName', 'SetName', 'SheetName', 'VariableName', ...
        'State', ...
        });
      
      obj.State                 = GrasppeAlpha.Core.Enumerations.TaskStates.Ready;
      obj.updateState;
      
      if obj.DebuggingDataEvents, disp(obj.State); end
      
      if ~isempty(obj.CaseID), obj.OnCaseIDChange(); end
    end
    
  end
  
  methods (Access=protected)
    function createComponent(obj)
      obj.createComponent@GrasppeAlpha.Data.Source;
    end
  end
  
  methods
    
    %% Threaded Parameters Getters / Setters
    function setCaseID(obj, caseID)
      obj.setParameter('case', caseID);
    end
    
    function setSetID(obj, setID)
      obj.setParameter('set', setID);
    end
    
    function setSheetID(obj, sheetID)
      obj.setParameter('sheet', sheetID);
    end
    
    function setVariableID(obj, variableID)
      obj.setParameter('variable', variableID);
    end
    
    function setParameter(obj, name, value, immediate)
      
      switch lower(name)
        case {'caseid', 'case'}
          name                  = 'CaseID';
          obj.states.GetCase    = GrasppeAlpha.Core.Enumerations.TaskStates.Starting;
        case {'setid', 'set'}
          name                  = 'SetID';
          obj.states.GetSet     = GrasppeAlpha.Core.Enumerations.TaskStates.Starting;
        case {'sheetid', 'sheet'}
          name                  = 'SheetID';
          obj.states.GetSheet   = GrasppeAlpha.Core.Enumerations.TaskStates.Starting;
          if obj.DebuggingDataEvents, disp(value); end
        case {'variableid', 'variable'}
          name                  = 'VariableID';
          obj.states.GetVariable  = GrasppeAlpha.Core.Enumerations.TaskStates.Starting;
        otherwise
          error('PrintUniformity:DataSource:InvalidParameterTarget', ...
            'Could not reset parameter timer due to an invalid target.');
      end
      
      if isequal(obj.DelayedUpdate, false) ||  exist('immediate', 'var') && isequal(immediate, true)
          obj.(name)            = value;    % disp(value);
        return;
      end
      
      callback                  = @(src, evt) obj.setParameter(name, value, true);
      
      if ~isscalar(obj.parameterSetTimer) || ~isa(obj.parameterSetTimer, 'timer') || ~isvalid(obj.parameterSetTimer);
        obj.parameterSetTimer   = GrasppeKit.Utilities.DelayedCall(callback, obj.parameterSetDelay, 'persists');
      else
        stop(obj.parameterSetTimer);
        obj.parameterSetTimer.TimerFcn  = callback;
      end
      
      start(obj.parameterSetTimer);
      
    end
    
    
    %% CaseID, SetID, SheetID, VariableID change event handling
    
    function OnCaseIDChange(obj, source, event)
      % consumed                  = false;
      
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      
      obj.states.GetCase        = GrasppeAlpha.Core.Enumerations.TaskStates.Running;
      
      if ~isequal(obj.Reader.CaseID, obj.CaseID)
        obj.Reader.CaseID         = obj.CaseID;
        obj.setID                 = [];
        try if obj.DebuggingDataEvents, disp(event); end; end
        obj.processCaseData();
      end
    end
    
    function OnSetIDChange(obj, source, event)
      % consumed                  = false;
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      
      obj.states.GetSet         = GrasppeAlpha.Core.Enumerations.TaskStates.Running;
      
      if ~isequal(obj.Reader.SetID, obj.SetID)
        obj.Reader.SetID          = obj.SetID;
        obj.sheetID               = [];
        obj.processSetData();
      end
    end
    
    function OnSheetIDChange(obj, source, event)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      % consumed                  = false;
      obj.states.GetSheet       = GrasppeAlpha.Core.Enumerations.TaskStates.Running;
      obj.Reader.SheetID        = obj.SheetID;
      obj.processSheetData();
    end
    
    function OnVariableIDChange(obj, source, event)
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      % consumed                  = false;
      obj.states.GetVariable    = GrasppeAlpha.Core.Enumerations.TaskStates.Running;
      obj.processVariableData();
    end
    
    %% CaseData, SetData, SheetData, VariableData Processing (on ID change)
    
    function processCaseData(obj, recursive)
      
      if ~isequal(obj.caseID, obj.Reader.CaseID) || isempty(obj.CaseData) || isempty(obj.CaseName)
        % obj.SetData             = [];
        % obj.SheetData           = [];
        
        obj.caseID              = obj.Reader.CaseID;          % skip ID change event
        obj.CaseData            = obj.Reader.getCaseData();   % fire Data change event
        obj.CaseName            = obj.Reader.GetCaseTag();    % fire Name change event %obj.Reader.CaseName;
        
        if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processSetData(); end      % obj.processSheetData(obj); obj.processVariableData(obj);
      end
      
    end
    
    function processSetData(obj, recursive)
      if ~isequal(obj.setID, obj.Reader.SetID) || isempty(obj.SetData) || isempty(obj.SetName)
        % obj.SheetData           = [];
                
        obj.setID               = obj.Reader.SetID;           % skip ID change event
        obj.SetData             = obj.Reader.getSetData();    % fire Data change event
        obj.SetName             = obj.Reader.SetName;         % fire Name change event
        
        if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processSheetData(); end
      end
    end
    
    function processSheetData(obj, recursive)
      % if ~isequal(obj.sheetID, obj.Reader.SheetID) || isempty(obj.SheetData) || isempty(obj.SheetName)
      obj.sheetID               = obj.Reader.SheetID;         % skip ID change event
      obj.SheetData             = obj.Reader.getSheetData();  % fire Data change event
      obj.SheetName             = obj.Reader.SheetName;       % fire Name change event
      % end
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processVariableData(); end
    end
    
    function processVariableData(obj, recursive)
      % obj.variableID            = obj.VariableID;           % skip ID change event
      obj.VariableData          = obj.SheetData;              % fire Data change event
      obj.VariableName          = '';                         % fire Name change event
    end
    
    
    function OnCaseDataChange(obj, source, event)
      % % consumed                  = false;
      obj.states.GetCase        = GrasppeAlpha.Core.Enumerations.TaskStates.Ready;
      obj.notify('DataChange', event);
    end
    
    function OnSetDataChange(obj, source, event)
      % consumed                  = false;
      obj.states.GetSet         = GrasppeAlpha.Core.Enumerations.TaskStates.Ready;
      obj.notify('DataChange', event);
    end
    
    function OnSheetDataChange(obj, source, event)
      % consumed                  = false;
      obj.states.GetSheet       = GrasppeAlpha.Core.Enumerations.TaskStates.Ready;
      obj.notify('DataChange', event);
    end
    
    function OnVariableDataChange(obj, source, event)
      % consumed                  = false;
      obj.states.GetVariable    = GrasppeAlpha.Core.Enumerations.TaskStates.Ready;
      obj.notify('DataChange', event);
    end
    
    
    function set.states(obj, states)
      obj.states                = states;
      obj.updateState;
    end    
    
    function updateState(obj)
      
      if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end;
      
      statesFields              = {'GetCase', 'GetSet', 'GetSheet', 'GetVariable'};
      
      currentState              = GrasppeAlpha.Core.Enumerations.TaskStates.Ready;
      
      for m = 1:numel(statesFields)
        currentState            = obj.states.(statesFields{m});
        if ~isequal(currentState, GrasppeAlpha.Core.Enumerations.TaskStates.Ready), break; end
      end
      
      if ~isequal(obj.State, currentState), obj.State = currentState; end
      
    end
    
    function caseName = GetCaseName(obj, varargin)
      caseName                  = '';
      try caseName              = obj.Reader.GetCaseTag(varargin{:}); end
    end

    function setName = GetSetName(obj, varargin)
      setName                   = '';
      try setName               = obj.Reader.GetSetName(varargin{:}); end
    end
    
    function sheetName = GetSheetName(obj, varargin)
      sheetName                 = '';
      try sheetName             = obj.Reader.GetSheetName(varargin{:}); end
    end
    
    function variableName  = GetVariableName(obj, variableID)
      variableName              = '';
      % try variableName          = obj.reader.GetCaseName(varargin{:}); end
    end    
    
  end
  
  
  methods (Static)
    function reader = GetNewReader(dataSource)
      
      options                   = {}; %  ...
      
      if ~isempty(dataSource.CaseID)
        options                 = [options,   'CaseID',     dataSource.CaseID     ]; end
      
      if ~isempty(dataSource.SetID)
        options                 = [options,   'SetID',      dataSource.SetID      ]; end
      
      if ~isempty(dataSource.SheetID)
        options                 = [options,   'SheetID',    dataSource.SheetID    ]; end
      
      % if ~isempty(dataSource.VariableID)
      %   options                 = [options,   'VariableID', dataSource.VariableID ]; end
      
      reader                    = feval(dataSource.dataReaderClass, options{:}); % PrintUniformityBeta.Data.DataReader
      
      if nargin>0 && isscalar(dataSource) && isa(dataSource, 'GrasppeAlpha.Data.Source')
        dataSource.attachReader(reader);
      end
      
      dataSource.caseID         = reader.CaseID;
      dataSource.setID          = reader.SetID;
      dataSource.sheetID        = reader.SheetID;
      % dataSource.variableID     = reader.VariableID;
      
    end
  end
  
  
  methods(Static, Hidden)
    function options  = DefaultOptions()
      options                   = [];
    end
  end
  
  
  
end
