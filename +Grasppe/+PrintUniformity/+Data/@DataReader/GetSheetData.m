function [ sheetData parameters ] = GetSheetData(obj) %, newData, parameters, variableData)
  %GetSheetData Load and Get Sheet Data
  %   Detailed explanation goes here
  
  %% Data
  % if isempty(newData)
  newData           = obj.Data; % copy(obj.Data);
  dataReader        = newData.DataReader;
  % end
  
  %% Parameters
  %   if ~exist('parameters', 'var') || isempty(parameters)
  %     parameters          = newData.Parameters;
  %     updatedParameters   = false;
  %   else
  %     updatedParameters   = ~isvalid(newData.Parameters) || ~(newData.Parameters==parameters);
  %     newData.Parameters  = parameters;
  %   end
  
  %% Get State
  customFunction        = false;
  sheetReady            = false;
  sheetLoading          = false;
  variableReady         = false;
  
  try customFunction    = isa(obj.GetSheetDataFunction, 'function_handle'); end
  try sheetReady        = dataReader.CheckState('SheetReady'); end
  try variableReady     = dataReader.CheckState('VariableReady'); end
  
  sheetData             = newData.SheetData;
  sheetID               = dataReader.Parameters.SheetID;
  
  %if isempty(sheetData) %updatedParameters
  
  % try dataReader.PromoteState('SheetLoading'); end
  
  %% Get Container Data
  %if ~exist('variableData', 'var') || isempty(variableData)
    variableData            = obj.GetVariableData(sheetID);
  %end
  
  %% Execute Custom Processing Function
  skip                      = false;
  
  if isa(obj.GetSheetDataFunction, 'function_handle')
    [sheetData skip]        = obj.GetSheetDataFunction(newData, variableData);
  end
  
  %% Execute Default Processing Function
  if isequal(skip, false)
    if size(variableData.Raw,1)==1
      sheetData             = variableData.Raw(1, :);
    else
      sheetData             = variableData.Raw(sheetID+1, :);
    end
  end
  
  %% Update Data Model
  newData.SheetData           = sheetData;
  
  newData.Parameters.SheetID  = dataReader.Parameters.SheetID;
  
  %try newData.DataReader.PromoteState('SheetReady'); end
  
  %end
  
  %% Return
  if nargout<1, clear sheetData;  end
  if nargout<2, clear parameters; end
  
end
