classdef UniformityDataReader < GrasppeAlpha.Core.Component
  %UniformityDataReader Read Uniformity Data
  %   Detailed explanation goes here
  
  
  properties (Transient, Hidden)
    %% HandleComponent 
    HandleProperties = {};
    HandleEvents = {};
    ComponentType = 'PrintingUniformityDataReader';
    ComponentProperties = '';
    
    %% Mediator-Controlled Properties
    DataProperties = {'CaseID', 'SetID', 'SheetID'};
    
    %% Prototype Meta Properties
    UniformityDataReaderProperties = {
      'CaseID',     'Case ID',          'Data Source',      'string',   '';   ...
      'SetID',      'Set ID',           'Data Source',      'int',      '';   ...
      'SheetID',    'Sheet ID',         'Data Source',      'int',      '';   ...
      'VariableID', 'Variable ID',      'Data Source',      'string',   '';   ...
      };
    
  end
  
  
  properties (AbortSet, Dependent)
    CaseID='', SetID=100, SheetID=1, VariableID='raw';
  end
  
  properties (Hidden)
    CaseData, SetData, SheetData
  end
  
  properties
    Data;
  end
  
  properties (GetAccess=public, SetAccess=protected)
    Parameters    = [];
    AllData       = [];
    PreloadTimer  = [];
  end
  
  events
    CaseChange
    SetChange
    SheetChange
    VariableChange
  end
  
  methods
    
    function obj = UniformityDataReader(varargin)
      obj = obj@GrasppeAlpha.Core.Component(varargin{:});
      
      %       obj.PreloadTimer = timer('Tag',['PreloadTimer' obj.ID], ...
      %         'StartDelay', 0.5, ...
      %         'TimerFcn', @(s,e)obj.preloadSheetData() ...
      %         );
      
      obj.PreloadTimer = ...
        GrasppeKit.Utilities.DelayedCall(@(s,e)obj.preloadSheetData(), 0.5, 'persists');
    
    end
    
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      obj.initializeDataModels;
      obj.createComponent@GrasppeAlpha.Core.Component;
    end
  end
  
  methods
    
    %% CaseID
    
    function set.CaseID(obj, caseID)
      import PrintUniformityBeta.Data.*;
      import PrintUniformityBeta.Models.*;
      
      % obj.initializeDataModels;
      
      parameters      = obj.Parameters;
      
      setID   = 100;
      try setID       = obj.MetaProperties.SetID.NativeMeta.DefaultValue; end
      try if ~isempty(parameters.SetID),      setID     = parameters.SetID; end; end
      
      if ~isequal(obj.Parameters.CaseID, caseID)
        obj.resetDataModels;
        
        obj.Parameters.CaseID     = caseID;
        obj.SetID                 = setID;
        obj.SheetID               = 1;
        
        stop(obj.PreloadTimer);
        obj.AllData = [];
        
        obj.notify('CaseChange');
      end
      
    end
    
    function resetDataModels(obj)
      obj.initializeDataModels;
    end
    
    function deleteDataModels(obj)
      if isobject(obj.Data)
        delete(obj.Data);         obj.Data =[];
      end
      
      if isobject(obj.Parameters)
        delete(obj.Parameters);   obj.Parameters =[];
      end
    end
    
    function initializeDataModels(obj)
      if ~isa(obj.Data, 'PrintUniformityBeta.Models.UniformityData')
        obj.Data  = PrintUniformityBeta.Models.UniformityData('Creator', obj);
      end
      
      if ~isa(obj.Parameters, 'PrintUniformityBeta.Models.DataParameters')
        obj.Parameters = PrintUniformityBeta.Models.DataParameters('Creator', obj);
      end
    end
    
    
    function caseID = get.CaseID(obj)
      caseID = '';
      try caseID = obj.Parameters.CaseID; end
    end
    
    
    %% SetID
    
    function set.SetID(obj, setID)
      
      parameters      = obj.Parameters;
      
      sheetID = 1;
      try sheetID     = obj.MetaProperties.SheetID.NativeMeta.DefaultValue; end
      try if ~isempty(parameters.SheetID),    sheetID     = parameters.SheetID; end; end
      
      variableID = 1;
      try variableID  = obj.MetaProperties.VariableID.NativeMeta.DefaultValue; end
      try if ~isempty(parameters.VariableID), variableID  = parameters.VariableID; end; end
      
      if ~isequal(obj.Parameters.SetID, setID)
        obj.Parameters.SetID    = setID;
        obj.Data.SetData        = [];
        
        stop(obj.PreloadTimer);
        obj.AllData = [];
        
        obj.preloadSheetData;        
        
        obj.notify('SetChange');
      end
      
      obj.SheetID  = sheetID;
    end
    
    function setID = get.SetID(obj)
      setID = [];
      try setID = obj.Parameters.SetID; end
    end
    
    
    %% SheetID
    
    function set.SheetID(obj, sheetID)
      
      % obj.initializeDataModels;
      
      parameters      = obj.Parameters;
      
      variableID = 1;
      try variableID  = obj.MetaProperties.VariableID.NativeMeta.DefaultValue; end
      try if ~isempty(parameters.VariableID), variableID  = parameters.VariableID; end; end
      
      if ~isequal(obj.Parameters.SheetID, sheetID)
        obj.Parameters.SheetID  = sheetID;
        obj.notify('SheetChange');
      end
    end
    
    function sheetID = get.SheetID(obj)
      sheetID = [];
      try sheetID = obj.Parameters.SheetID; end
    end
    
    
    %% VariableID
    
    function set.VariableID(obj, variableID)
      if ~isequal(obj.Parameters.VariableID, variableID)
        obj.Parameters.VariableID  = variableID;
        obj.notify('VariableChange');
      end
    end
    
    function variableID = get.VariableID(obj)
      variableID = '';
      try variableID = obj.Parameters.VariableID; end
    end
    
    %% Case Data
    function set.CaseData(obj, caseData)
      obj.Data.CaseData = caseData;
      % data = obj.Data;
      % [data.CaseData changed] = changeSet(data.CaseData, caseData);
    end
    
    function caseData = get.CaseData(obj)
      caseData = [];
      
      %try caseData = obj.Data.CaseData; end
      if isempty(caseData), obj.getCaseData; end
      
      try caseData = obj.Data.CaseData; end
    end
    
    
    %% Set Data
    function set.SetData(obj, setData)
      obj.Data.SetData = setData;
      % data = obj.Data;
      % [data.SetData changed] = changeSet(data.SetData, setData);
    end
    
    function setData = get.SetData(obj)
      setData = [];
      
      if isempty(setData), obj.getSetData; end
      
      try setData = obj.Data.SetData; end
    end
    
    
    %% Sheet Data
    function set.SheetData(obj, sheetData)
      obj.Data.SheetData = sheetData;
      % data = obj.Data;
      % [data.SheetData changed] = changeSet(data.SheetData, sheetData);
    end
    
    function sheetData = get.SheetData(obj)
      sheetData = [];
      
      if isempty(sheetData), obj.getSheetData; end
      
      try sheetData = obj.Data.SheetData; end
    end
    
    %% Data
    function data = get.Data(obj)
      data = obj.Data;
    end
    
    function set.Data(obj, data)
      if isempty(data) || isa(data, 'PrintUniformityBeta.Models.UniformityData')
        obj.Data = data;
      end
    end
    
    function parameters = get.Parameters(obj)
      parameters = obj.Parameters;
    end
    
    function set.Parameters(obj, parameters)
      if isempty(parameters) || isa(parameters, 'PrintUniformityBeta.Models.DataParameters')
        obj.Parameters = parameters;
      end
    end
    
    
    function getCaseData(obj)
      import PrintUniformityBeta.Data.*;
      
      caseData  = [];   try caseData  = obj.Data.caseData;          end
      
      
      if isempty(obj.CaseID), return; end
      
      
      if isempty(caseData)
        obj.Data.SheetData  = [];
        obj.Data.SetData    = [];
        obj.Data.CaseData   = UniformityDataReader.loadCaseData(obj.Parameters, obj.Data);
      end
      
      
    end
    
    function getSetData(obj)
      import PrintUniformityBeta.Data.*;
      
      if isempty(obj.SetID), return; end
      
      obj.Data.SheetData  = [];
      obj.Data.SetData    = UniformityDataReader.loadSetData(obj.Parameters, obj.Data);
      
    end
    
    function getSheetData(obj)
      import PrintUniformityBeta.Data.*;
      
      if isempty(obj.SheetID), return; end
      
      obj.Data.SheetData  = UniformityDataReader.loadSheetData(obj.Parameters, obj.Data, obj.AllData);
      
    end
    
    function data = getAllData(obj)
      
      import PrintUniformityBeta.Data.*;
      
      data          = obj.AllData;      
      
      if ~isempty(obj.AllData), return; end;
      
      parameters    = copy(obj.Parameters);
      
      sheetRange    = [];
      
      try sheetRange  = obj.Data.CaseData.range.Sheets; end
      
      obj.AllData   = zeros(numel(sheetRange), 1);
      
      for s = sheetRange
        parameters.SheetID = s;
        data(s,:)  = UniformityDataReader.loadSheetData(parameters, obj.Data);
      end

    end
    
    function preloadSheetData(obj, varargin)
      try
      
      isRunning   = @(x) isequal(x.Running, 'on');
      
      preloading  = false;
      try preloading  = isRunning(obj.PreloadTimer); end
      
      if preloading
        stop(obj.PreloadTimer);
        
        obj.AllData = obj.getAllData();
      else
        if isempty(obj.AllData)
          start(obj.PreloadTimer);
        end
      end
      
      catch err
        try debugStamp(err, 1, obj); catch, debugStamp(); end;
      end
        
    end
    
  end
  
  methods (Static)
    function caseData = processCaseData(parameters, data)
      depricated;
    end
    
    function setData = processSetData(parameters, data)
      depricated;
    end
    
    function sheetData = processSheetData(parameters, data, allData)
      depricated;
    end    
    
    function caseData = loadCaseData(parameters, data)
      import PrintUniformityBeta.Data.*;
      
      caseData    = [];
      
      caseID      = parameters.CaseID;
      
      try if isequal(caseID, data.Parameters.CaseID)
          caseData = data.CaseData; end; end
      
      if isempty(caseData)
        data.Parameters.CaseID = [];
        
        try caseData  = Data.loadUPData(caseID); end
      end
      
      try data.CaseData 	= caseData;
        if ~isempty(caseData) data.Parameters.CaseID = caseID; end; end
      
    end  
    
    function setData = loadSetData(parameters, data)
      import PrintUniformityBeta.Data.*;
      
      setData     = [];
      
      caseID      = parameters.CaseID;
      setID       = parameters.SetID;
      
      try if isequal(setID, data.Parameters.SetID)
          setData = data.SetData; end; end
      
      if isempty(setData)
        data.Parameters.SetID = [];
        
        caseData  = UniformityDataReader.loadCaseData(parameters, data);
        
        setData   = struct( 'sourceName', caseID, 'patchSet', setID, ...
          'setLabel', ['tv' int2str(setID) 'data'], 'patchFilter', [], ...
          'data', [] );
        
        setData   = PrintUniformityAlpha.Data.filterUPDataSet(caseData, setData);
      end
      
      try data.SetData 	= setData;
        if ~isempty(setData) data.Parameters.SetID = setID; end;
      end
      
    end
    
    function sheetData = loadSheetData(parameters, data, allData)
      import PrintUniformityBeta.Data.*;
      
      sheetData   = [];
            
      caseID      = parameters.CaseID;
      setID       = parameters.SetID;
      sheetID     = parameters.SheetID;
      variableID  = parameters.VariableID;
      
      if nargin==3 && size(allData,1) >= sheetID
        %try
          sheetData = allData(sheetID, :);
          %sheetData = sheetData(:);
          %beep;
          return;
        %end
      end
      
      
      try if isequal(sheetID, data.Parameters.SheetID)
          sheetData = data.SheetData; end; end
      
      if isempty(sheetData)
        data.Parameters.SheetID = [];
        
        setData           = UniformityDataReader.loadSetData(parameters, data);
        
        setLength         = numel(setData.data);
        
        if isequal(sheetID, setLength+1)
          sumData         = zeros([setLength size(setData.data(1).zData)]);
          %sheetData       = {setData.data(:).zData};
          
          for m = 1:setLength
            sumData(m,1,:) = setData.data(m).zData; %sheetData{m}(:);
          end
          
          meanData        = mean(sumData,1);
          sheetData(1,:)  = meanData;
        else
          try sheetData   = setData.data(sheetID).zData; end
        end
      end
      
      try data.SheetData  = sheetData;
        if ~isempty(sheetData) data.Parameters.SheetID = sheetID; end; end
      
      sheetData           = data.SheetData;
    end
  end
  
  methods(Static, Hidden)
    function options  = DefaultOptions()
      options = [];
    end
  end
  
end

