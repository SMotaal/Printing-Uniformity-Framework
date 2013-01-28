classdef StatsDataSource < PrintUniformityBeta.Data.DataSource
  
  %STATSDATASOURCE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    function [caseData skip]      = GetCaseDataFunction(obj, newData)
      caseData      = [];     % Replaced with sourceData if not skipping
      skip          = false;
    end
    
    function [setData skip]       = GetSetDataFunction(obj, newData)
      setData       = [];     % Replaced with setData when skipped
      skip          = false;
    end
    
    function [variableData skip]  = GetVariableDataFunction(obj, newData)
      variableData  = [];     % Amended with raw data field when skipped
      skip          = false;
    end
    
    function [sheetData skip]     = GetSheetDataFunction(obj, newData, variableData)
      sheetData     = [];     % Replaced with raw sheetData when skipped
      skip          = false;
    end
    
  end
  
end

