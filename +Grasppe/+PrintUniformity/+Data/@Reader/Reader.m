classdef Reader < Grasppe.Data.Reader
  %READER Printing Uniformity Data Reader
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    %% Grasppe HandleComponent Properties
    HandleProperties = {};
    HandleEvents = {};
    ComponentType = 'PrintingUniformityDataReader';
    ComponentProperties = '';
    
    %% Grasppe Mediator-Controlled Properties
    DataProperties = {'CaseID', 'SetID', 'SheetID'};
    
    %% Grasppe Prototype Meta Properties
    UniformityDataReaderProperties = {
      'CaseID',     'Case ID',          'Data Source',      'string',   '';   ...
      'SetID',      'Set ID',           'Data Source',      'int',      '';   ...
      'SheetID',    'Sheet ID',         'Data Source',      'int',      '';   ...
      'VariableID', 'Variable ID',      'Data Source',      'string',   '';   ...
      };
  end
  
  
  properties (AbortSet, Dependent)
    %% Parameters
    CaseID='', SetID=100, SheetID=1, VariableID='raw';
    
    %% Data
    CaseData, SetData, SheetData
  end
  
  properties (GetAccess=public, SetAccess=protected)
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
    function deleteDataModels(obj)
      obj.deleteDataModel('Data');
      obj.deleteDataModel('Parameters');
    end
    function createDataModels(obj)
      obj.createDataModel('Data', 'Grasppe.PrintUniformity.Models.UniformityData', 'Creator', obj);
      obj.createDataModel('Parameters', 'Grasppe.PrintUniformity.Models.DataParameters', 'Creator', obj);
    end
  end  
  
end

