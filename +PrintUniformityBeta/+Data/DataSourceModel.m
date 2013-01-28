classdef DataSourceModel < handle
  %DATASOURCEMODEL PrintUniformity Data Source Struct Model
  %   Detailed explanation goes here
  
  properties (AbortSet, Dependent, SetObservable, GetObservable)
    CaseID,       CaseData,     CaseName;
    SetID,        SetData,      SetName;
    SheetID,      SheetData,    SheetName;
    VariableID,   VariableData, VariableName;
  end
  
  properties (Dependent, SetObservable, GetObservable)
    SetCount,     SheetCount;
    RowCount,     ColumnCount;
  end
  
  properties (Access=protected)
    caseID,       caseData,     caseName;
    setID,        setData,      setName;
    sheetID,      sheetData,    sheetName;
    variableID,   variableData, variableName;
    
  end
  
  methods
    
    %% Parameters Getters / Setters
    
    function set.CaseID(obj, caseID)
      
      if ~ischar(caseID), caseID  = ''; end
      
      assert(obj.validateCaseID(caseID), 'PrintUniformity:DataSource:InvalidCaseID', ...
        'Cannot change to CaseID ''%s'' since the id is not valid', caseID);
      
      obj.caseData              = [];
      obj.setData               = [];
      obj.sheetData             = [];
      obj.variableData          = [];
      
      obj.caseID                = caseID;
    end
    
    function set.SetID(obj, setID)
      
      if ~isnumeric(setID), setID  = []; end
      
      assert(obj.validateSetID(setID), 'PrintUniformity:DataSource:InvalidSetID', ...
        'Cannot change to SetID ''%s'' since the id is not valid', setID);
      
      obj.setData               = [];
      obj.sheetData             = [];
      obj.variableData          = [];
      
      obj.setID                 = setID;
    end
    
    function set.SheetID(obj, sheetID)
      
      if ~isnumeric(sheetID), sheetID  = []; end
      
      assert(obj.validateSheetID(sheetID), 'PrintUniformity:DataSource:InvalidSheetID', ...
        'Cannot change to SheetID ''%s'' since the id is not valid', sheetID);
      
      obj.sheetData             = [];
      obj.variableData          = [];
      
      obj.sheetID               = sheetID;
    end
    
    function set.VariableID(obj, variableID)
      
      if ~ischar(variableID), variableID  = ''; end
      
      assert(obj.validateVariableID(variableID), 'PrintUniformity:DataSource:InvalidVariableID', ...
        'Cannot change to VariableID ''%s'' since the id is not valid', variableID);
      
      obj.variableData          = [];
      
      obj.variableID            = variableID;
    end
    
    function set.CaseData(obj, caseData)
      obj.caseData              = caseData;
    end
    
    function set.SetData(obj, setData)
      obj.setData               = setData;
    end
    
    function set.SheetData(obj, sheetData)
      obj.sheetData             = sheetData;
    end
    
    function set.VariableData(obj, variableData)
      obj.variableData          = variableData;
    end
    
    function set.CaseName(obj, caseName)
      obj.caseName              = caseName;
    end
    
    function set.SetName(obj, setName)
      obj.setName               = setName;
    end
    
    function set.SheetName(obj, sheetName)
      obj.sheetName             = sheetName;
    end
    
    function set.VariableName(obj, variableName)
      obj.variableName          = variableName;
    end
    
    function caseID = get.CaseID(obj)
      caseID                    = obj.caseID;
    end
    
    function setID = get.SetID(obj)
      setID                     = obj.setID;
    end
    
    function sheetID = get.SheetID(obj)
      sheetID                   = obj.sheetID;
    end
    
    function variableID = get.VariableID(obj)
      variableID                = obj.variableID;
    end
    
    function caseData = get.CaseData(obj)
      caseData                  = obj.caseData;
    end
    
    function setData = get.SetData(obj)
      setData                   = obj.setData;
    end
    
    function sheetData = get.SheetData(obj)
      sheetData                 = obj.sheetData;
    end
    
    function variableData = get.VariableData(obj)
      variableData              = obj.variableData;
    end
    
    function caseName = get.CaseName(obj)
      caseName                  = obj.caseName;
    end
    
    function setName = get.SetName(obj)
      setName                   = obj.setName;
    end
    
    function sheetName = get.SheetName(obj)
      sheetName                 = obj.sheetName;
    end
    
    function variableName = get.VariableName(obj)
      variableName              = obj.variableName;
    end
    
    %% SetCount, SheetCount, Rows, Columns, RegionCount, ZoneCount
    %
    %         obj.SetCount            = obj.caseData.length.Sets;
    %         obj.SheetCount          = obj.caseData.length.Sheets;
    %         obj.RowCount            = obj.caseData.length.Rows;
    %         obj.ColumnCount         = obj.caseData.length.Columns;
    %
    
    function sets = get.SetCount(obj)
      sets                      = 0;
      try sets                  = obj.CaseData.length.Sets; end
    end
    
    function sheets = get.SheetCount(obj)
      sheets                    = 0;
      try sheets                = obj.CaseData.length.Sheets; end
    end
    
    function rows = get.RowCount(obj)
      rows                      = 0;
      try rows                  = obj.CaseData.length.Rows; end
    end
    
    function columns = get.ColumnCount(obj)
      columns                   = 0;
      try columns               = obj.CaseData.length.Columns; end
    end
    
  end
  
  methods(Access=protected)
    function validCaseID = validateCaseID(obj, caseID)
      validCaseID               = false;
      try
        validCaseID             = ...
          ~isempty(DS.dataSources(caseID, caseID)) || ...
          exist(FS.dataDir('uniprint',  caseID), 'file') > 0;
      end
      % bufferedSource            = ~isempty(DS.dataSources(caseID, caseID));
      % diskSource                = exist(FS.dataDir('uniprint',  caseID), 'file') > 0;
    end
    
    function validSetID = validateSetID(obj, setID)
      validSetID                = false;
      try
        validSetID              = ...
          isempty(obj.caseData) || ...
          any(setID == obj.caseData.range.Sets);
      end
    end
    
    function validSheetID = validateSheetID(obj, sheetID)
      validSheetID              = false;
      try
        validSheetID            = ...
          isempty(obj.setData) || ...
          (sheetID>=0 && sheetID<=obj.SheetCount);
      end
    end
    
    function validVariableID = validateVariableID(obj, variableID)
      validVariableID           = false;
      try
        validVariableID         = true;       % TODO
      end
    end
    
  end
  
end

