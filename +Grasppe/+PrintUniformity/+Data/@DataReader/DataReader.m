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
    DataProperties    = {'CaseID', 'SetID', 'VariableID', 'SheetID'};
    
    %% Prototype Meta Properties
    DataReaderProperties  = {
      'CaseID',     'Case ID',          'Data Source',      'string',   '';   ...
      'SetID',      'Set ID',           'Data Source',      'int',      '';   ...
      'VariableID', 'Variable ID',      'Data Source',      'string',   '';   ...      
      'SheetID',    'Sheet ID',         'Data Source',      'int',      '';   ...
      };
    
    DataModels = struct( ...
      'Data',       'Grasppe.PrintUniformity.Models.UniformityData', ...
      'Parameters', 'Grasppe.PrintUniformity.Models.DataParameters' ...
      )
  end
  
  properties (AbortSet, Dependent)
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
  end
  
  properties
    GetCaseDataFunction       = [];
    GetSetDataFunction        = [];
    GetVariableDataFunction   = [];
    GetSheetDataFunction      = [];
  end
   
  properties (GetAccess=public, SetAccess=protected)
    State         = Grasppe.PrintUniformity.Data.ReaderStates.Uninitialized;
    PreloadTimer  = [];
  end
  
  events
    CaseChange
    SetChange
    VariableChange
    SheetChange
  end
  
  methods
    SetParameters(obj, newParameters);
    caseData      = GetCaseData     (obj, parameters, sourceData);
    setData       = GetSetData      (obj, parameters, caseData);
    variableData  = GetSheetData    (obj, parameters, setData);
    sheetData     = GetVariableData (obj, parameters, variableData);
  end
  
  methods (Static)
    data          = LoadSourceData(source);
  end
  
  
  %% Prototype Methods
  methods
    function obj = DataReader(varargin)      
      obj = obj@Grasppe.Data.Reader(varargin{:});
    end
  end
    
  methods (Access=protected)
  
    function createComponent(obj)
      obj.PrepareDataModels;
      obj.PreloadTimer = GrasppeKit.DelayedCall(@(s,e)obj.PreloadSheetData(), 0.5, 'persists');
      
      obj.createComponent@Grasppe.Core.Component;
      
      obj.PromoteState(Grasppe.PrintUniformity.Data.ReaderStates.Initialized);
    end
    
    %% State Routines
    function PromoteState(obj, targetState)
      if obj.State < targetState || obj.State.ID < targetState.ID
        obj.State = targetState;
      end
    end
    
    function DemoteState(obj, targetState)
      if obj.State > targetState || obj.State.ID > targetState.ID
        obj.State = targetState;
      end      
    end
    
  end
  
  %% Getters / Setters Parameters CaseID, SetID, VariableID, SheetID
  methods
        
    function set.CaseID(obj, caseID)
      parameters          = copy(obj.Parameters);
      parameters.CaseID   = caseID;
      obj.SetParameters(parameters);
    end
    
    function set.SetID(obj, setID)
      parameters          = copy(obj.Parameters);
      parameters.SetID    = setID;
      obj.SetParameters(parameters);
    end
    
    function set.VariableID(obj, variableID)
      parameters          = copy(obj.Parameters);
      parameters.VariableID  = variableID;
      obj.SetParameters(parameters);
    end
    
    function set.SheetID(obj, sheetID)
      parameters          = copy(obj.Parameters);
      parameters.SheetID  = sheetID;
      obj.SetParameters(parameters);
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
      
      if isempty(caseData), obj.GetCaseData; end
    end
    
    %% Get/Set Set Data
    function set.SetData(obj, setData)
      obj.Data.SetData = setData;
    end
    
    function setData = get.SetData(obj)
      setData        = [];
      try setData    = obj.Data.SetData; end
      
      if isempty(setData), obj.GetSetData; end    
    end
    
    %% Get/Set Variable Data
    function set.VariableData(obj, variableData)
      obj.Data.VariableData = variableData;
    end
    
    function variableData = get.VariableData(obj)
      variableData        = [];
      try variableData    = obj.Data.VariableData; end
      
      if isempty(variableData), obj.GetVariableData; end    
    end
    
        
    %% Get/Set Sheet Data
    function set.SheetData(obj, sheetData)
      obj.Data.SheetData = sheetData;
    end
    
    function sheetData = get.SheetData(obj)
      sheetData        = [];
      try sheetData    = obj.Data.SheetData; end
      
      if isempty(sheetData), obj.GetSheetData; end    
    end    
end  
  
  
  methods(Static, Hidden)
    function options  = DefaultOptions()
      options = [];
    end
  end
  
  
end

