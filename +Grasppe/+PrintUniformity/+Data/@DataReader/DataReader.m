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
    FailedChange
  end
  
  methods
    SetParameters(obj, newParameters, delayed, oldParameters, oldData);
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
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      obj.PrepareDataModels;
      %obj.PreloadTimer = GrasppeKit.DelayedCall(@(s,e)obj.PreloadSheetData(), 0.5, 'persists');
      
      obj.createComponent@Grasppe.Core.Component;
      
      obj.PromoteState(Grasppe.PrintUniformity.Data.ReaderStates.Initialized);
      %obj.SetParameters;
    end
    
    %% State Routines
    function PromoteState(obj, targetState, abortOnFail)
      
      try
        if ischar(targetState)
          targetState = Grasppe.PrintUniformity.Data.ReaderStates.(targetState);
        end
        
        if all(obj.State < targetState) || all(obj.State.ID < targetState.ID)
          obj.State = targetState;
        elseif exist('abortOnFail', 'var') && isequal(abortOnFail, true)
          evalin('caller', 'return;'); return;
        end
      catch err
        debugStamp(err,1);
      end
    end
    
    function DemoteState(obj, targetState, abortOnFail)
      
      try
        
        if ischar(targetState)
          targetState = Grasppe.PrintUniformity.Data.ReaderStates.(targetState);
        end
        
        if obj.State > targetState || obj.State.ID > targetState.ID
          obj.State = targetState;
        elseif exist('abortOnFail', 'var') && isequal(abortOnFail, true)
          evalin('caller', 'return;'); return;
        end
      catch err
        debugStamp(err,1);
      end
    end
    
    function tf = CheckState(obj, targetState, abortOnFail)
      
      tf = false;
      
      try
        
        if ischar(targetState)
          targetState = Grasppe.PrintUniformity.Data.ReaderStates.(targetState);
        end
        
        try tf = obj.State >= targetState; end
        
        if ~isequal(tf, true) && exist('abortOnFail', 'var') && isequal(abortOnFail, true)
          evalin('caller', 'return;'); return;
        end
        
      catch err
        debugStamp(err,1);
      end
      
      tf = isequal(tf, true);
      try tf = isequal(all(tf), true); end
      
    end
    
    
  end
  
  %% Getters / Setters Parameters CaseID, SetID, VariableID, SheetID
  methods
    
    function set.CaseID(obj, caseID)
      parameters          = copy(obj.Parameters);
      obj.Parameters.CaseID   = caseID;
      obj.SetParameters([], true);
    end
    
    function set.SetID(obj, setID)
      parameters          = copy(obj.Parameters);
      obj.Parameters.SetID    = setID;
      obj.SetParameters([], true);
    end
    
    function set.VariableID(obj, variableID)
      parameters          = copy(obj.Parameters);
      obj.Parameters.VariableID  = variableID;
      obj.SetParameters([], true);
    end
    
    function set.SheetID(obj, sheetID)
      parameters          = copy(obj.Parameters);
      obj.Parameters.SheetID  = sheetID;
      obj.SetParameters([], true);
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
      
      if isempty(caseData),
        %try stop(obj.PreloadTimer);   end
        obj.SetParameters;
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
        %try stop(obj.PreloadTimer);   end
        obj.SetParameters;
        setData      = obj.GetSetData();
      end
      
    end
    
    %% Get/Set Variable Data
    function set.VariableData(obj, variableData)
      obj.Data.VariableData = variableData;
    end
    
    function variableData = get.VariableData(obj)
      variableData        = [];
      try variableData    = obj.Data.VariableData; end
      if isempty(variableData)
        %try stop(obj.PreloadTimer);   end
        obj.SetParameters;
        variableData      = obj.GetVariableData();
      end
    end
    
    
    %% Get/Set Sheet Data
    function set.SheetData(obj, sheetData)
      obj.Data.SheetData = sheetData;
    end
    
    function sheetData = get.SheetData(obj)
      sheetData        = [];
      try sheetData    = obj.Data.SheetData; end
      
      if isempty(sheetData)
        %try stop(obj.PreloadTimer);   end
        obj.SetParameters;
        sheetData      = obj.GetSheetData();
      end
    end
  end
  
  
  methods(Static, Hidden)
    function options  = DefaultOptions()
      options = [];
    end
  end
  
  
end

