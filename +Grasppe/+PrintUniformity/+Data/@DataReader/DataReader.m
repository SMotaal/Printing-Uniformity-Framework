classdef DataReader < Grasppe.Data.Reader
  %READER Printing Uniformity Data Reader
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    %% HandleComponent
    HandleProperties = {};
    HandleEvents = {};
    ComponentType = 'PrintingUniformityDataReader';
    ComponentProperties = '';
    
    %% Mediator-Controlled Properties
    DataProperties    = Grasppe.PrintUniformity.Data.DataReader.GetDataParameters; %%{'CaseID', 'SetID', 'VariableID', 'SheetID'};
    
    %% Prototype Meta Properties
    DataReaderProperties  = {
      'CaseID',     'Case ID',          'Data',      'string',   '';   ...
      'SetID',      'Set ID',           'Data',      'int',      '';   ...
      'VariableID', 'Variable ID',      'Data',      'string',   '';   ...
      'SheetID',    'Sheet ID',         'Data',      'int',      '';   ...
      };
    
    DataModels = struct( ...
      'Data',       'Grasppe.PrintUniformity.Models.UniformityData', ...
      'Parameters', 'Grasppe.PrintUniformity.Models.DataParameters' ...
      )
  end
  
  properties (AbortSet, Dependent, SetObservable, GetObservable)
    CaseID        = '';
    SetID         = 100;
    VariableID    = 'raw';
    SheetID       = 1;
  end
  
  properties (Dependent)
    CaseData
    SetData
    VariableData
    SheetData
    CaseName
    SetName
    VariableName
    SheetName
  end
  
  properties
    GetCaseDataFunction       = [];
    GetSetDataFunction        = [];
    GetVariableDataFunction   = [];
    GetSheetDataFunction      = [];
  end
  
  properties (GetAccess=public, SetAccess=protected)
    %State         = Grasppe.PrintUniformity.Data.ReaderStates.Uninitialized;
    PreloadTimer  = [];
    TestTimer     = [];
  end
  
  events
    CaseChange
    SetChange
    VariableChange
    SheetChange
  end
  
  methods (Access=protected)
    change        = SetParameters(obj, eventData);
    caseData      = GetCaseData     (obj); %, data, parameters, sourceData);
    setData       = GetSetData      (obj); %, data, parameters, caseData);
    variableData  = GetVariableData (obj, sheetID); %, data, parameters, setData, sheetID);
    sheetData     = GetSheetData    (obj); %, data, parameters, variableData);
  end
  
  %% Prototype Methods
  methods
    function obj = DataReader(varargin)
      obj = obj@Grasppe.Data.Reader(varargin{:});
    end
    
    function eventData = UpdateData( obj, varargin)
      %% Fallback to parameter defaults (if necessary)
      if numel(varargin) == 0
        if isempty(obj.Parameters.SetID),       obj.Parameters.SetID      = obj.DefaultValue('SetID'); end
        if isempty(obj.Parameters.VariableID),  obj.Parameters.VariableID = obj.DefaultValue('VariableID'); end
        if isempty(obj.Parameters.SheetID),     obj.Parameters.SheetID    = obj.DefaultValue('SheetID'); end
      end
      
      eventData = obj.UpdateData@Grasppe.Data.Reader(varargin{:});
    end
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      obj.createComponent@Grasppe.Data.Reader;
    end
    
    function state = GetNamedState(obj, state)
      try state   = Grasppe.PrintUniformity.Data.ReaderStates.(state);
        return; end
      state       = obj.GetNamedState@Grasppe.Data.Reader(state);
    end
  end
  
  %% Getters / Setters Parameters CaseID, SetID, VariableID, SheetID
  methods
    
    function set.CaseID(obj, caseID)
      obj.UpdateData('CaseID', caseID);
    end
    
    function set.SetID(obj, setID)
      obj.UpdateData('SetID', setID);
    end
    
    function set.VariableID(obj, variableID)
      obj.UpdateData('VariableID', variableID);
    end
    
    function set.SheetID(obj, sheetID)
      obj.UpdateData('SheetID', sheetID);
    end
    
    function caseID = get.CaseID(obj)
      caseID = '';
      try caseID = obj.Parameters.CaseID; end
    end
    
    function setID = get.SetID(obj)
      setID = [];
      try setID = obj.Parameters.SetID; end
    end
    
    function variableID = get.VariableID(obj)
      variableID = '';
      try variableID = obj.Parameters.VariableID; end
    end
    
    function sheetID = get.SheetID(obj)
      sheetID = [];
      try sheetID = obj.Parameters.SheetID; end
    end
    
  end
  
  %% Getters / Setters Parameters CaseData, SetData, VariableData, SheetData
  methods
    
    %% Get/Set Case Data
    function set.CaseData(obj, caseData)
      obj.Data.CaseData = caseData;
    end
    
    function caseData = get.CaseData(obj)
      caseData        = [];
      try caseData    = obj.Data.CaseData; end
      
      if isempty(caseData)
        obj.UpdateData();
        caseData      = obj.GetCaseData();
      end
    end
    
    %% Get/Set Set Data
    function set.SetData(obj, setData)
      obj.Data.SetData = setData;
    end
    
    function setData = get.SetData(obj)
      setData        = [];
      try setData    = obj.Data.SetData; end
      
      if isempty(setData)
        obj.UpdateData();
        setData      = obj.GetSetData();
      end
      
    end
    
    %% Get/Set Variable Data
    function set.VariableData(obj, variableData)
      obj.Data.VariableData = variableData;
    end
    
    function variableData = get.VariableData(obj)
      variableData       = [];
      try variableData   = obj.Data.VariableData; end
      if isempty(variableData)
        obj.UpdateData();
        variableData     = obj.GetVariableData();
      end
    end
    
    
    %% Get/Set Sheet Data
    function set.SheetData(obj, sheetData)
      obj.Data.SheetData = sheetData;
    end
    
    function sheetData = get.SheetData(obj)
      sheetData         = [];
      try sheetData     = obj.Data.SheetData; end
      
      if isempty(sheetData)
        obj.UpdateData();
        sheetData       = obj.GetSheetData();
      end
    end
    
    %% CaseName, SetName, VariableName, SheetName
    function caseName = get.CaseName(obj)
     caseName = ''; pressName = ''; runCode = '';
      
      try pressName     = obj.CaseData.metadata.testrun.press.name; end
      
      try runCode       = obj.CaseData.name; end
      try runCode       = sprintf('#%s', char(regexpi(runCode, '[0-9]{2}[a-z]?$', 'match'))); end
      
      try caseName      = strtrim([pressName ' ' runCode]); end
    end
    
    function setName = get.SetName(obj)
      setName = '';
      %try setName = obj.SetData.setLabel; end
      try
        setName         = [int2str(obj.SetData.patchSet) '%'];
      end
      if isnumeric(setName)
        setName = int2str(setName);
      end
    end
    
    function variableName = get.VariableName(obj)
      variableName      = '';
      try variableName  = obj.VariableID; end
    end
    
    function sheetName = get.SheetName(obj)
      sheetName         = '';
      if isequal(obj.SheetID,0)
        sheetName       = 'Run Summary';
        return;
      end
      try sheetName     = obj.CaseData.index.Sheets(obj.SheetID); end
      if isnumeric(sheetName) && isscalar(sheetName)
        sheetName       = int2str(sheetName);
      else
        sheetName       = '';
      end      
    end    
    
    
    

  end
  
  
  methods(Static, Hidden)
    function options  = DefaultOptions()
      options = [];
    end
  end
  
  methods(Static)
    function parameters = GetDataParameters()
      parameters  = {'CaseID', 'SetID', 'VariableID', 'SheetID'};
    end
  end
  
  
  
end

