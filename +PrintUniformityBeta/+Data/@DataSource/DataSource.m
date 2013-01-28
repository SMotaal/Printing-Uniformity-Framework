classdef DataSource < GrasppeAlpha.Data.Source & ...
    PrintUniformityBeta.Data.DataSourceModel & PrintUniformityBeta.Data.DataEventHandler
  %DATASOURCE Printing Uniformity Data Source
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
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
  end
  
  properties (AbortSet, SetObservable, GetObservable)
  end
  
  properties (Access=protected)
    parameterSetTimer;                            % Threaded parameter Set timer
    parameterSetDelay           = 0.05;           % Threaded parameter Set delay
  end
  
  
  methods
    function obj = DataSource(varargin)
      obj                       = obj@PrintUniformityBeta.Data.DataSourceModel();
      obj                       = obj@GrasppeAlpha.Data.Source(varargin{:});
      obj                       = obj@PrintUniformityBeta.Data.DataEventHandler();
      
      obj.attachSelfPropertyListeners('DataEventHandlers', { ...
        'CaseID', 'SetID', 'SheetID', 'VariableID', ...
        'CaseData', 'SetData', 'SheetData', 'VariableData', ...
        'CaseName', 'SetName', 'SheetName', 'VariableName', ...
        });
      
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
        case {'setid', 'set'}
          name                  = 'SetID';
        case {'sheetid', 'sheet'}
          name                  = 'SheetID';
        case {'variableid', 'variable'}
          name                  = 'VariableID';
        otherwise
          error('PrintUniformity:DataSource:InvalidParameterTarget', ...
            'Could not reset parameter timer due to an invalid target.');
      end
      
      if exist('immediate', 'var') && isequal(immediate, true), obj.(name) = value; return; end
      
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
    
    function consumed = OnCaseIDChange(obj, source, event)
      consumed                  = false;
      obj.Reader.CaseID         = obj.CaseID;
      try disp(event); end
      obj.processCaseData();
    end
    
    function consumed = OnSetIDChange(obj, source, event)
      consumed                  = false;
      obj.Reader.SetID          = obj.SetID;
      obj.processSetData();
    end
    
    function consumed = OnSheetIDChange(obj, source, event)
      consumed                  = false;
      obj.Reader.SheetID        = obj.SheetID;
      obj.processSheetData();
    end
    
    function consumed = OnVariableIDChange(obj, source, event)
      consumed                  = false;
      obj.processVariableData();
    end
    
    %% CaseData, SetData, SheetData, VariableData Processing (on ID change)
    
    function processCaseData(obj, recursive)
      obj.caseID                = obj.Reader.CaseID;          % skip ID change event
      obj.CaseData              = obj.Reader.getCaseData();   % fire Data change event
      obj.CaseName              = obj.Reader.CaseName;        % fire Name change event
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processSetData(); end      % obj.processSheetData(obj); obj.processVariableData(obj);
    end
    
    function processSetData(obj, recursive)
      obj.setID                 = obj.Reader.SetID;           % skip ID change event
      obj.SetData               = obj.Reader.getSetData();    % fire Data change event
      obj.SetName               = obj.Reader.SetName;         % fire Name change event
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processSheetData(); end
    end
    
    function processSheetData(obj, recursive)
      obj.sheetID               = obj.Reader.SheetID;         % skip ID change event
      obj.SheetData             = obj.Reader.getSheetData();  % fire Data change event
      obj.SheetName             = obj.Reader.SheetName;       % fire Name change event
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processVariableData(); end
    end
    
    function processVariableData(obj, recursive)
      % obj.variableID            = obj.VariableID;           % skip ID change event
      obj.VariableData          = [];                         % fire Data change event
      obj.VariableName          = '';                         % fire Name change event
    end
    
    
    function consumed = OnCaseDataChange(obj, source, event)
      consumed                  = false;
      obj.notify('DataChange', event);
    end
    
    function consumed = OnSetDataChange(obj, source, event)
      consumed                  = false;
      obj.notify('DataChange', event);
    end
    
    function consumed = OnSheetDataChange(obj, source, event)
      consumed                  = false;
      obj.notify('DataChange', event);
    end
    
    function consumed = OnVariableDataChange(obj, source, event)
      consumed                  = false;
      obj.notify('DataChange', event);
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
      
      reader                    = PrintUniformityBeta.Data.DataReader(options{:});
      
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
