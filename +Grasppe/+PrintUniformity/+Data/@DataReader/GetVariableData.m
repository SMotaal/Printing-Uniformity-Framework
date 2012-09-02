function [ variableData parameters ] = GetVariableData(obj, newData, parameters, setData)
  %GetVariableData Load and Get Variable Data
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
  
  variableData          = newData.VariableData;
  
  if updatedParameters || isempty(variableData)
    
    %% Get Container Data
    if ~exist('setData', 'var')
      setData                   = obj.GetSetData(newData);
    end
    
    %% Execute Custom Processing Function
    skip                        = false;
    
    if isa(obj.GetVariableDataFunction, 'function_handle')
      [variableData skip]       = obj.GetVariableDataFunction(newData.Parameters, setData);
    end
    
    %% Execute Default Processing Function
    if isequal(skip, false)
      if ~isequal(newData.Parameters.VariableID, 'Raw')
        newData.Parameters.VariableID   = 'Raw';
      end
      variableData = getRawData(newData.Parameters, setData);
    end
    
    %% Update Data Model
    newData.VariableData        = variableData;
    
  end
  
  %% Return
  if nargout<1, clear variableData; end
  if nargout<2, clear parameters;   end

end

function variableData = getRawData(parameters, setData)
  import Grasppe.PrintUniformity.Data.*;
  
  variableData          = [];
  
  %parameters          = parameters; %copy(obj.Parameters);  
  sheetRange            = [];
  try sheetRange        = [0:numel(setData.data)]; end
    
  sheetID               = parameters.SheetID;
  
  if isnumeric(sheetID) && isscalar(sheetID) && any(sheetRange==sheetID)
    sheetRange          = [sheetID sheetRange(sheetRange~=sheetID)];
  else
    sheetID             = 0;  % summary sheet
    parameters.SheetID  = 0;
  end
   
  for s = sheetRange
    sheetData             = getRawSheetData(setData, s);
    if isempty(variableData) 
      variableData          = zeros(numel(sheetRange+1), size(sheetData,2));
    end
    variableData(s+1,:) = sheetData;
  end
end

function sheetData = getRawSheetData(setData, sheetID)
  import Grasppe.PrintUniformity.Data.*;
  
  sheetData   = [];
  
  setData                 = (setData.SetData);
  
  setLength               = numel(setData.data);
  
  if isequal(sheetID, 0)
    sumData               = zeros([setLength size(setData.data(1).zData)]);
    
    for m = 1:setLength
      sumData(m,1,:)      = setData.data(m).zData;
    end
    
    meanData              = mean(sumData,1);
    sheetData(1,:)        = meanData;
  else
    try sheetData         = setData.data(sheetID).zData; end
  end
  
end

