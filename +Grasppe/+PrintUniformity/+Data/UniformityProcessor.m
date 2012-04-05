classdef UniformityProcessor < Grasppe.Core.Component
  %UNIFORMITYPROCESSOR Summary of this class goes here
  %   Detailed explanation goes here
  
  
  properties (Transient, Hidden)
    HandleProperties = {};
    HandleEvents = {};
    ComponentType = 'PrintingUniformityDataProcessor';
    ComponentProperties = '';
    
    DataProperties = {'CaseID', 'SetID', 'SheetID'};
    
    UniformityProcessorProperties = {
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
    Parameters = [];
  end
  
  methods
    
    function obj = UniformityProcessor(varargin)
      obj = obj@Grasppe.Core.Component(varargin{:});
    end
    
    %% CaseID
    
    function set.CaseID(obj, caseID)
      import Grasppe.PrintUniformity.Data.*;
      import Grasppe.PrintUniformity.Models.*;
      
      parameters      = obj.Parameters;
      metaProperties  = obj.MetaProperties;
      
      setID   = 100;
      try setID       = metaProperties.SetID.NativeMeta.DefaultValue; end
      try if ~isempty(parameters.SetID),      setID     = parameters.SetID; end; end
      
      sheetID = 1;
      try sheetID     = metaProperties.SheetID.NativeMeta.DefaultValue; end
      try if ~isempty(parameters.SheetID),    sheetID     = parameters.SheetID; end; end
      
      variableID = 1;
      try variableID  = metaProperties.VariableID.NativeMeta.DefaultValue; end
      try if ~isempty(parameters.VariableID), variableID  = parameters.VariableID; end; end
      
      % Reset SetID/SheetID Parameters
      if ~isa(obj.Parameters, 'Grasppe.PrintUniformity.Models.DataParameters')
        obj.resetDataParamters;
      end
      
      obj.Parameters.CaseID     = caseID;
      obj.Parameters.SetID      = setID;
      obj.Parameters.SheetID    = sheetID;
      obj.Parameters.VariableID = variableID;
      
      obj.resetData;
    end
    
    function resetDataParamters(obj)
      if isobject(obj.Parameters) delete(obj.Parameters); end
      
      obj.Parameters  = Grasppe.PrintUniformity.Models.DataParameters;
    end
    
    function resetData(obj)
      if isobject(obj.Data) delete(obj.Parameters); end
      
      obj.Data  = Grasppe.PrintUniformity.Models.UniformityData;
      
      if ~isa(obj.Parameters, 'Grasppe.PrintUniformity.Models.DataParameters')
        obj.resetDataParamters;
      end
      
      obj.Data.Parameters = obj.Parameters;
    end
    
    function caseID = get.CaseID(obj)
      caseID = '';
      try caseID = obj.Parameters.CaseID; end
    end
    
    
    %% SetID
    
    function set.SetID(obj, setID)
      
      parameters      = obj.Parameters;
      
      sheetID = 1;
      try sheetID     = metaProperties.SheetID.NativeMeta.DefaultValue; end
      try if ~isempty(parameters.SheetID),    sheetID     = parameters.SheetID; end; end
      
      variableID = 1;
      try variableID  = metaProperties.VariableID.NativeMeta.DefaultValue; end
      try if ~isempty(parameters.VariableID), variableID  = parameters.VariableID; end; end
      
      obj.Parameters.SetID    = setID;
      obj.Parameters.SheetID  = sheetID;
    end
    
    function setID = get.SetID(obj)
      setID = [];
      try setID = obj.Parameters.SetID; end
    end
    
    
    %% SheetID
    
    function set.SheetID(obj, sheetID)
      
      parameters      = obj.Parameters;
      
      variableID = 1;
      try variableID  = metaProperties.VariableID.NativeMeta.DefaultValue; end
      try if ~isempty(parameters.VariableID), variableID  = parameters.VariableID; end; end
      
      obj.Parameters.SheetID  = sheetID;
    end
    
    function sheetID = get.SheetID(obj)
      sheetID = [];
      try sheetID = obj.Parameters.SheetID; end
    end
    
    
    %% VariableID
    
    function set.VariableID(obj, variableID)
      obj.Parameters.VariableID  = variableID;
    end
    
    function variableID = get.VariableID(obj)
      variableID = '';
      try variableID = obj.Parameters.VariableID; end
    end
    
    %% Case Data
    function set.CaseData(obj, caseData)
      obj.Data.CaseData = caseData;
    end
    
    function caseData = get.CaseData(obj)
      caseData = [];
      
      try caseData = obj.Data.CaseData; end
      if isempty(caseData), obj.getCaseData; end
      
      try caseData = obj.Data.CaseData; end
    end
    
    
    %% Set Data
    function set.SetData(obj, setData)
      obj.Data.SetData = setData;
    end
    
    function setData = get.SetData(obj)
      setData = [];
      
      try setData = obj.Data.SetData; end
      if isempty(setData), obj.getSetData; end
      
      try setData = obj.Data.SetData; end
    end
    
    
    %% Sheet Data
    function set.SheetData(obj, sheetData)
      obj.Data.SheetData = sheetData;
    end
    
    function sheetData = get.SheetData(obj)
      sheetData = [];
      
      try sheetData = obj.Data.SheetData; end
      if isempty(sheetData), obj.getSheetData; end
      
      try sheetData = obj.Data.SheetData; end
    end
    
    %% Data
    function data = get.Data(obj)
      % if isempty(obj.Data) obj.Data = UniformityProcessor; end
      data = obj.Data;
    end
    
    function set.Data(obj, data)
      if isempty(data) || isa(data, 'Grasppe.PrintUniformity.Models.UniformityData')
        obj.Data = data;
      end
    end
    
    function parameters = get.Parameters(obj)
      parameters = obj.Parameters;
    end
    
    function set.Parameters(obj, parameters)
      if isempty(parameters) || isa(parameters, 'Grasppe.PrintUniformity.Models.DataParameters')
        obj.Parameters = parameters;
      end
    end
    
    
    function getCaseData(obj)
      import Grasppe.PrintUniformity.Data.*;
      
      caseData  = [];   try caseData  = obj.Data.caseData;          end
      % caseID    = [];   try caseID    = obj.Parameters.CaseID;  end
      
      
      if isempty(obj.CaseID), return; end
      
      
      if isempty(caseData)
        obj.Data.SheetData  = [];
        obj.Data.SetData    = [];
        obj.Data.CaseData   = UniformityProcessor.processCaseData(obj.Parameters, obj.Data);
      end
      
      
    end
    
    function getSetData(obj)
      import Grasppe.PrintUniformity.Data.*;
      
      if isempty(obj.SetID), return; end
      
      obj.Data.SheetData  = [];
      obj.Data.SetData    = UniformityProcessor.processSetData(obj.Parameters, obj.Data);
      
    end
    
    function getSheetData(obj)
      import Grasppe.PrintUniformity.Data.*;
      
      if isempty(obj.SheetID), return; end
      
      obj.Data.SheetData  = UniformityProcessor.processSheetData(obj.Parameters, obj.Data);
      
    end
    
  end
  
  methods (Static)
    function caseData = processCaseData(parameters, data)
      import Grasppe.PrintUniformity.Data.*;
      
      caseData = Data.loadUPData(parameters.CaseID);
    end
    
    function setData = processSetData(parameters, data)
      import Grasppe.PrintUniformity.Data.*;
      
      setData = struct( 'sourceName', parameters.CaseID, ...
        'patchSet', parameters.SetID, 'setLabel', ['tv' int2str(parameters.SetID) 'data'], ...
        'patchFilter', [], 'data', [] );
      
      setData = Data.filterUPDataSet(data.CaseData, setData);
      
    end
    
    function sheetData = processSheetData(parameters, data)
      import Grasppe.PrintUniformity.Data.*;

      
    end
  end
  
  methods(Static, Hidden)
    function options  = DefaultOptions()
      options = [];
    end
  end
  
end

