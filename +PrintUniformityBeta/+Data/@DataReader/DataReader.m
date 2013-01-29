classdef DataReader < GrasppeAlpha.Data.Reader
  %READER Printing Uniformity Data Reader
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    %% HandleComponent
    HandleProperties = {};
    HandleEvents = {};
    ComponentType = 'PrintingUniformityDataReader';
    ComponentProperties = '';
    
    %% Mediator-Controlled Properties
    DataProperties    = PrintUniformityBeta.Data.DataReader.GetDataParameters; %%{'CaseID', 'SetID', 'VariableID', 'SheetID'};
    
    %% Prototype Meta Properties
    DataReaderProperties  = {
      'CaseID',     'Case ID',          'Data',      'string',   '';   ...
      'SetID',      'Set ID',           'Data',      'int',      '';   ...
      'SheetID',    'Sheet ID',         'Data',      'int',      '';   ...
      };
    
    DataModels = struct( ...
      'Data',       'PrintUniformityBeta.Models.UniformityData', ...
      'Parameters', 'PrintUniformityBeta.Models.DataParameters' ...
      )
  end
  
  properties (AbortSet, Dependent, SetObservable, GetObservable)
    CaseID                      = '';
    SetID                       = 100;
    SheetID                     = 0;
  end
  
  properties %(Dependent)
    CaseData
    SetData
    SheetData
    
    CaseName
    SetName
    SheetName
  end
  
  properties
    GetCaseDataFunction         = [];
    GetSetDataFunction          = [];
    GetSheetDataFunction        = [];
  end
  
  properties (GetAccess=public, SetAccess=protected)
  end
  
  
  methods %(Access=protected)
    [ caseData                ] = getCaseData     (obj, caseID);
    [ setData                 ] = getSetData      (obj, setID);
    [ sheetData               ] = getSheetData    (obj, sheetID);
  end
  
  %% Prototype Methods
  methods
    function obj = DataReader(varargin)   
      obj                       = obj@GrasppeAlpha.Data.Reader(varargin{:});
    end
    
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      obj.CaseID                = '';
      obj.SetID                 = [];
      obj.SheetID               = [];      
      obj.createComponent@GrasppeAlpha.Data.Reader;
    end
    
    function state = GetNamedState(obj, state)
      try state   = PrintUniformityBeta.Data.ReaderStates.(state);
        return; end
      state       = obj.GetNamedState@GrasppeAlpha.Data.Reader(state);
    end
  end
  
  %% Getters / Setters Parameters CaseID, SetID, VariableID, SheetID
  methods
    
    function setCaseID(obj, caseID)
      obj.Parameters.CaseID     = caseID;
      
      obj.CaseData              = [];
      try obj.Data.CaseData     = obj.getCaseData(caseID); end
      
      if isempty(obj.SetID)
        obj.setSetID(100);
      else
        obj.setSetID(obj.SetID);
      end
      
    end
    
    function setSetID(obj, setID)
      obj.Parameters.SetID      = setID;
      
      obj.SetData               = [];
      try obj.Data.SetData      = obj.getSetData(setID); end
      
      if isempty(obj.SheetID)
        obj.setSheetID(0);
      else
        obj.setSheetID(obj.SheetID);
      end
      
    end
    
    function setSheetID(obj, sheetID)
      obj.Parameters.SheetID    = sheetID;
      
      obj.SheetData             = [];      
      try obj.Data.SheetData    = obj.getSheetData(sheetID); end
      
    end
    
    
    function set.CaseID(obj, caseID)
      try if isequal(caseID, obj.Parameters.CaseID), return; end; end
      obj.setCaseID(caseID);
    end
    
    function set.SetID(obj, setID)
      try if isequal(setID, obj.Parameters.SetID), return; end; end
      obj.setSetID(setID);
    end
        
    function set.SheetID(obj, sheetID)
      try if isequal(sheetID, obj.Parameters.SheetID), return; end; end
      obj.setSheetID(sheetID);
    end
    
    function caseID = get.CaseID(obj)
      caseID                    = '';
      try caseID                = obj.Parameters.CaseID; end
    end
    
    function setID = get.SetID(obj)
      setID                     = [];
      try setID                 = obj.Parameters.SetID; end
    end
        
    function sheetID = get.SheetID(obj)
      sheetID                   = [];
      try sheetID               = obj.Parameters.SheetID; end
    end
    
  end
  
  %% Getters / Setters Parameters CaseData, SetData, VariableData, SheetData
  methods
        
    %% CaseName, SetName, VariableName, SheetName
    function caseName = get.CaseName(obj)
     caseName                   = obj.GetCaseName();
    end
    
    function setName = get.SetName(obj)
      setName                   = obj.GetSetName();
    end
    
    function sheetName = get.SheetName(obj)
      sheetName                 = obj.GetSheetName();
    end    
    
    function caseName = GetCaseName(obj, caseID)
      try if nargin<2, caseID   = obj.Parameters.CaseID; end; end

      pressName                 = '';
      try pressName             = obj.CaseData.metadata.testrun.press.name; end
      
      runCode                   = '';
      try runCode               = obj.CaseData.name; end
      try runCode               = sprintf('#%s', char(regexpi(runCode, '[0-9]{2}[a-z]?$', 'match'))); end
      
      caseName                  = '';
      try caseName              = strtrim([pressName ' ' runCode]); end
    end
    
    function caseTag = GetCaseTag(obj, caseID)
      try if nargin<2, caseID   = obj.Parameters.CaseID; end; end
      
      caseTag                   = '';
      
      try caseTag               = obj.GetCaseName(caseID); end
      
      caseTags                  = struct( ...
        'ritsm7401',  'L0', ...
        'ritsm7402a', 'L1', 'ritsm7402b', 'L2', 'ritsm7402c', 'L3', ...
        'rithp7k01',  'X1', 'rithp5501',  'X2'                            );
      
      try caseTag               = caseTags.(lower(caseID)); end
      
    end
    
    
    function setName = GetSetName(obj, setID)
      try if nargin<2, setID    = obj.Parameters.SetID; end; end
      
      setName                   = '';
      try setName               = [int2str(setID) '%']; end
    end
    
    function sheetName  = GetSheetName(obj, sheetID)
      try if nargin<2, sheetID  = obj.Parameters.SheetID; end; end
        
      sheetName                 = '';
      
      if isequal(sheetID,0)
        sheetName               = 'Run';
      else
        try sheetName           = int2str(obj.CaseData.index.Sheets(sheetID)); end
      end
    end
    

  end
  
  
  methods(Static, Hidden)
    function options  = DefaultOptions()
      options                   = [];
    end
  end
  
  methods(Static)
    % [ dataSource regions      ] = ProcessRegions(dataSource)
    [ dataSource              ] = ProcessDataMetrics(dataSource)
    % [ dataSource stats        ] = ProcessStatistics(dataSource, dataSet, regions)
    % [ strID                   ] = GenerateCacheID(dataSource, dataSet, dataClass)
    
    function parameters = GetDataParameters()
      parameters                = {'CaseID', 'SetID', 'SheetID'}; % Variable ID
    end
    
  end
  
  
  
end

