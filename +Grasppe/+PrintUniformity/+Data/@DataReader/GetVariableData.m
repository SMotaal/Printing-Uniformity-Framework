function [ variableData parameters ] = GetVariableData(obj, sheetID) % newData, parameters, setData, )
  %GetVariableData Load and Get Variable Data
  %   Detailed explanation goes here
  
  %% Data
  %if isempty(newData)
  newData               = obj.Data; %copy(obj.Data);
  dataReader            = newData.DataReader;
  %end
  
  %% Parameters
  %   if ~exist('parameters', 'var') || isempty(parameters)
  %     parameters            = newData.Parameters;
  %     updatedParameters     = false;
  %   else
  %     updatedParameters     = ~isvalid(newData.Parameters) || ~(newData.Parameters==parameters);
  %     newData.Parameters    = parameters;
  %   end
  
  variableData            = newData.VariableData;
  
  %% Get State
  customFunction          = false;
  variableReady           = false;
  variableLoading         = false;
  setReady                = false;
  
  try customFunction      = all(isa(obj.GetVariableDataFunction, 'function_handle')); end
  try variableReady       = dataReader.CheckState('VariableReady'); end
  try variableLoading     = dataReader.CheckState('VariableLoading'); end
  try setReady            = dataReader.CheckState('SetReady'); end
  
  %% Get single sheet
  if ~variableReady && exist('sheetID', 'var') 
    if isscalar(sheetID)
      while ~setReady % isempty(newData.SetData)
        obj.GetSetData();
        setReady            = dataReader.CheckState('SetReady');
      end

      variableData          = getRawData(newData.Parameters, newData.SetData, sheetID);
      return;
    else
      throw(Grasppe.PrintUniformity.Data.ReaderException.SheetRangeError([], sheetID, dataReader.Parameters));
    end
  end
  
  %% Load Data
  if ~variableLoading || ~variableReady || isempty(variableData) % || updatedParameters
    
    %% Get Container Data
    %if ~setReady || ~exist('setData', 'var') % || isempty(setData) %
    while ~setReady % isempty(newData.SetData)
      obj.GetSetData();
      setReady              = dataReader.CheckState('SetReady');
    end
    %end
    
    setData                 = newData.SetData;
    
    try dataReader.PromoteState('VariableLoading', true); end
    
    %% Execute Custom Processing Function
    skip                    = false;
    
    if customFunction
      [variableData skip]   = obj.GetVariableDataFunction(newData);
    end
    
    %% Execute Default Processing Function
    if isequal(skip, false)
      if ~isequal(dataReader.Parameters.VariableID, 'Raw')
        dataReader.Parameters.VariableID     = 'Raw';
      end
      variableData.Raw              = getRawData(dataReader.Parameters, setData);
    end
    
    %% Update Data Model
    newData.VariableData            = variableData;
    
    newData.Parameters.VariableID   = dataReader.Parameters.VariableID;
    
    try dataReader.PromoteState('VariableReady', true); end
    
  end
  
  %% Return
  if nargout<1, clear variableData; end
  if nargout<2, clear parameters;   end
  
end

function variableData = getRawData(parameters, setData, sheetID)
  import Grasppe.PrintUniformity.Data.*;
  
  try
    
    if exist('sheetID', 'var')
      variableData.Raw(1, :)  = getRawSheetData(setData, sheetID);
      return;
    end
    
    variableData          = [];
    
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
    
    
  catch err
    throw( ...
      Grasppe.PrintUniformity.Data.ReaderException.SheetRangeError(err, sheetID, parameters));
  end
  
end

function sheetData = getRawSheetData(setData, sheetID)
  import Grasppe.PrintUniformity.Data.*;
  
  sheetData               = [];
  
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

