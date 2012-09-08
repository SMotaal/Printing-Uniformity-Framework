classdef DataSource < Grasppe.Data.Source
  %DATASOURCE Printing Uniformity Data Source
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    %% HandleComponent
    HandleProperties = {};
    HandleEvents = {};
    ComponentType = 'PrintingUniformityDataSource';
    ComponentProperties = '';
    
    %% Mediator-Controlled Properties
    DataProperties    = {'CaseID', 'SetID', 'VariableID', 'SheetID'};
    
    %% Prototype Meta Properties
    DataSourceProperties  = {
      'CaseID',       'Case ID',            'Data',       'string',   '';   ...
      'SetID',        'Set ID',             'Data',       'int',      '';   ...
      'VariableID',   'Variable ID',        'Data',       'string',   '';   ...
      'SheetID',      'Sheet ID',           'Data',       'int',      '';   ...
      'CaseName',     'Case Name',          'Data',       'string',   '';   ...
      'SetName',      'Set Name',           'Data',       'string',   '';   ...
      'VariableName', 'Variable Name',      'Data',       'string',   '';   ...
      'SheetName',    'Sheet Name',         'Data',       'string',   '';   ...      
      'SetCount',     'Number of Sets',     'Data',       'int',      '';   ...
      'SheetCount',   'Number of Sheets',   'Data',       'int',      '';   ...
      'RowCount',     'Number of Rows',     'Data',       'int',      '';   ...
      'SheetCount',   'Number of Columns',  'Data',       'int',      '';   ...
      };
    
    % DataModels = struct( ...
    %   'Data',       'Grasppe.PrintUniformity.Models.UniformityData', ...
    %   'Parameters', 'Grasppe.PrintUniformity.Models.DataParameters' ...
    %   )
  end
  
  properties (Dependent, SetObservable, GetObservable)
    CaseID,       SetID,        VariableID,     SheetID;
    CaseData,     SetData,      VariableData,   SheetData;
    CaseName,     SetName,      VariableName,   SheetName;
    
    SetCount,     SheetCount,   RowCount,       ColumnCount;
  end
  
  properties (Access=protected)
    caseID, setID, variableID, sheetID
  end
  
  properties (Dependent)
  end
  
  events
    CaseChange
    SetChange
    VariableChange
    SheetChange
    AttemptingChange
    FailedChange
    SuccessfulChange
  end
  
  methods
    function obj = DataSource(varargin)      
      obj = obj@Grasppe.Data.Source(varargin{:});
    end
    
  end
    
  methods (Access=protected)
    
    function fireReaderEvent(obj, source, eventData)
      
      try
        
        validReader    = isequal(source, obj.reader) && ~isempty(obj.reader);
        
        switch eventData.EventName
          case 'CaseChange'
            if validReader
              obj.caseID      = source.Parameters.CaseID; end
          case 'SetChange'
            if validReader
              obj.setID       = source.Parameters.SetID; end
          case 'VariableChange'
            if validReader
              obj.variableID  = source.Parameters.VariableID; end
          case 'SheetChange'
            if validReader
              obj.sheetID     = source.Parameters.SheetID; end
          case 'FailedChange'
            % if validReader
            %   obj.caseID      = source.Parameters.CaseID; end
          otherwise
            return;
        end
        
        obj.fireReaderEvent@Grasppe.Data.Source(source, eventData);
        
      catch err
        debugStamp(err, 1);
      end
      
    end
    
    
    function tf = attachReaderListeners(obj, reader)
      tf                  = false;
      
      listeners           = obj.readerListeners;
      
      eventNames          = { ...
        'CaseChange', 'SetChange', 'VariableChange', 'SheetChange', ...
        'AttemptingChange', 'FailedChange', 'SuccessfulChange'};
      
      for m = 1:numel(eventNames)
        eventName         = eventNames{m};
        listeners(end+1)  = reader.addlistener(eventName, @obj.fireReaderEvent);
      end
      
      obj.readerListeners = listeners;
      tf                  = true;
    end
        
  end
  
  methods
    function [caseData skip] = GetCaseDataFunction(obj, newData)
      caseData      = [];     % Replaced with sourceData if not skipping
      skip          = false;
    end
    
    function [setData skip] = GetSetDataFunction(obj, newData)
      setData       = [];     % Replaced with setData when skipped
      skip          = false;
    end
    
    function [variableData skip] = GetVariableDataFunction(obj, newData)
      variableData  = [];     % Amended with raw data field when skipped
      skip          = false;
    end
    
    function [sheetData skip] = GetSheetDataFunction(obj, newData, variableData)
      sheetData     = [];     % Replaced with raw sheetData when skipped
      skip          = false;
    end
    
    
    
  end
    
  
  methods
        
    
    %% Parameters Getters / Setters
    function set.CaseID(obj, caseID)
      if obj.IsReady, obj.reader.CaseID     = caseID;
      else obj.caseID                       = caseID;     end
    end
    
    function set.SetID(obj, setID)
      if obj.IsReady, obj.reader.SetID      = setID;
      else obj.setID                        = setID;      end
    end
    
    function set.VariableID(obj, variableID)
      if obj.IsReady, obj.reader.VariableID = variableID;
      else obj.variableID                   = variableID; end
    end
    
    function set.SheetID(obj, sheetID)
      if obj.IsReady, obj.reader.SheetID    = sheetID;
      else obj.sheetID                      = sheetID;    end
    end
    
    function caseID = get.CaseID(obj)
      caseID                      = [];
      if obj.IsReady, caseID      = obj.reader.CaseID;
      else caseID                 = obj.caseID; end
    end
    
    function setID = get.SetID(obj)
      setID                       = [];
      if obj.IsReady, setID       = obj.reader.SetID;
      else setID                  = obj.setID; end
    end
    
    function variableID = get.VariableID(obj)
      variableID                  = [];
      if obj.IsReady, variableID  = obj.reader.VariableID;
      else variableID             = obj.variableID; end
    end
    
    function sheetID = get.SheetID(obj)
      sheetID                     = [];
      if obj.IsReady, sheetID     = obj.reader.SheetID;
      else sheetID                = obj.sheetID; end
    end
    
    %% Data Getters / Setters
    
    function caseData = get.CaseData(obj)
      caseData                      = [];
      if obj.IsReady, caseData      = obj.reader.CaseData; end
    end
    
    function setData = get.SetData(obj)
      setData                       = [];
      if obj.IsReady, setData       = obj.reader.SetData; end
    end
    
    function variableData = get.VariableData(obj)
      variableData                  = [];
      if obj.IsReady, variableData  = obj.reader.VariableData; end
    end
    
    function sheetData = get.SheetData(obj)
      sheetData                     = [];
      if obj.IsReady, sheetData     = obj.reader.SheetData; end
    end
    
    %% CaseName, SetName, VariableName, SheetName
    function caseName = get.CaseName(obj)
      caseName                      = '';
      if obj.IsReady, caseName      = obj.reader.CaseName; end
    end
    
    function setName = get.SetName(obj)
      setName                       = '';
      if obj.IsReady, setName       = obj.reader.SetName; end
    end
    
    function variableName = get.VariableName(obj)
      variableName                  = '';
      if obj.IsReady, variableName	= obj.reader.VariableName; end
    end
    
    function sheetName = get.SheetName(obj)
      sheetName                     = '';
      if obj.IsReady, sheetName     = obj.reader.SheetName; end
    end
    
    %% SetCount, SheetCount, Rows, Columns, RegionCount, ZoneCount
    
    function sets = get.SetCount(obj)
      sets              = [];
      %try sets          = obj.CaseData.Datasets.Length; end
    end
    
    function sheets = get.SheetCount(obj)
      sheets            = [];
      try sheets        = obj.CaseData.length.Sheets; end
    end
    
    function rows = get.RowCount(obj)
      rows              = [];
      try rows          = obj.CaseData.length.Rows; end
    end
    
    function columns = get.ColumnCount(obj)
      columns           = [];
      try columns       = obj.CaseData.length.Columns; end
    end
    
    
    
  end  
  
  methods (Static)
    function reader  = GetNewReader(dataSource)
      
      options = { ...
        'GetCaseDataFunction',      @dataSource.GetCaseDataFunction, ...
        'GetSetDataFunction',       @dataSource.GetSetDataFunction, ...
        'GetVariableDataFunction',  @dataSource.GetVariableDataFunction, ...
        'GetSheetDataFunction',     @dataSource.GetSheetDataFunction};
      
      if ~isempty(dataSource.CaseID)
        options = [options,   'CaseID',     dataSource.CaseID     ]; end
      
      if ~isempty(dataSource.SetID)
        options = [options,   'SetID',      dataSource.SetID      ]; end
      
      if ~isempty(dataSource.VariableID)
        options = [options,   'VariableID', dataSource.VariableID ]; end
      
      if ~isempty(dataSource.SheetID)
        options = [options,   'SheetID',    dataSource.SheetID    ]; end
      
      reader    = Grasppe.PrintUniformity.Data.DataReader(options{:});
      
      if nargin>0 && isscalar(dataSource) && isa(dataSource, 'Grasppe.Data.Source')
        dataSource.attachReader(reader);
      end
      
      dataSource.caseID       = reader.CaseID;
      dataSource.setID        = reader.SetID;
      dataSource.variableID   = reader.VariableID;
      dataSource.sheetID      = reader.SheetID;
      
    end
  end
  
  
  methods(Static, Hidden)
    function options  = DefaultOptions()
      options = [];
    end
  end
  
  
  
end
