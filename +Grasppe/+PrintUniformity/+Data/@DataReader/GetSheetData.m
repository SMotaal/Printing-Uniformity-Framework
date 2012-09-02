function [ sheetData parameters ] = GetSheetData(obj, newData, parameters, variableData)
  %GetSheetData Load and Get Sheet Data
  %   Detailed explanation goes here
  
  %% Data
  if isempty(newData)
    newData           = copy(obj.Data);
  end
  
  %% Parameters
  if ~exist('parameters', 'var')
    parameters          = newData.Parameters;
    updatedParameters   = false;
  else
    updatedParameters   = ~isvalid(newData.Parameters) || ~(newData.Parameters==parameters);
    newData.Parameters  = parameters;
  end
  
  sheetData             = newData.SheetData;
  
  if updatedParameters || isempty(sheetData)
    
    %% Get Container Data
    if ~exist('variableData', 'var')
      variableData            = obj.GetVariableData(newData);
    end
    
    %% Execute Custom Processing Function
    skip                      = false;
    
    if isa(obj.GetSheetDataFunction, 'function_handle')
      [sheetData skip]        = obj.GetSheetDataFunction(newData.Parameters, variableData);
    end
    
    %% Execute Default Processing Function
    if isequal(skip, false)
      sheetID                 = newData.Parameters.SheetID;
      sheetData               = variableData(sheetID+1, :);
    end
    
    %% Update Data Model
    newData.SheetData         = sheetData;

  end
  
  %% Return
  if nargout<1, clear sheetData;  end
  if nargout<2, clear parameters; end
  
end
