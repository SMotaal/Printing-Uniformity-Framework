function [ sheetData ] = getSheetData(obj, sheetID, varargin) %, newData, parameters, variableData)
  %GetSheetData Load and Get Sheet Data
  %   Detailed explanation goes here
  
  sheetData                     = [];
  
  if nargin<2, sheetID          = obj.SheetID; end
  
  if isempty(sheetID), return; end
  
  sheetData                     = obj.SheetData;
  if ~isempty(sheetData), return; end
  
  setData                       = obj.getSetData();
  dataMap                       = setData.SheetData;
  
  if dataMap.isKey(sheetID)
    sheetData                   = dataMap(sheetID);
  else
    sheetData                   = getRawSheetData(setData, sheetID);
    
    dataMap(sheetID)            = sheetData;
  end
  
  if nargin<2, obj.SheetData    = sheetData; end
  
  %% Data
  %   % if isempty(newData)
  %   newData                     = obj.Data; % copy(obj.Data);
  %   dataReader                  = newData.DataReader;
  %
  %   if isempty(dataReader), dataReader = obj; end
  %   % end
  %
  %   %% Parameters
  %   %   if ~exist('parameters', 'var') || isempty(parameters)
  %   %     parameters          = newData.Parameters;
  %   %     updatedParameters   = false;
  %   %   else
  %   %     updatedParameters   = ~isvalid(newData.Parameters) || ~(newData.Parameters==parameters);
  %   %     newData.Parameters  = parameters;
  %   %   end
  %
  %   %% Get State
  %   customFunction        = false;
  %   sheetReady            = false;
  %   sheetLoading          = false;
  %   variableReady         = false;
  %
  %   try customFunction    = isa(obj.GetSheetDataFunction, 'function_handle'); end
  %   try sheetReady        = dataReader.CheckState('SheetReady'); end
  %   try variableReady     = dataReader.CheckState('VariableReady'); end
  %
  %   sheetData             = newData.SheetData;
  %   sheetID               = dataReader.Parameters.SheetID;
  %
  %   %if isempty(sheetData) %updatedParameters
  %
  %   % try dataReader.PromoteState('SheetLoading'); end
  %
  %   %% Get Container Data
  %   %if ~exist('variableData', 'var') || isempty(variableData)
  %     variableData            = obj.GetVariableData(sheetID);
  %   %end
  %
  %   %% Execute Custom Processing Function
  %   skip                      = false;
  %
  %   if isa(obj.GetSheetDataFunction, 'function_handle')
  %     [sheetData skip]        = obj.GetSheetDataFunction(newData, variableData);
  %   end
  %
  %   %% Execute Default Processing Function
  %   if isequal(skip, false)
  %
  %     %if ~isscalar(sheetID) || (isnumeric(sheetID) && sheetID > size(variableData.Raw+1
  %
  %     try
  %       if size(variableData.Raw,1)==1
  %         sheetData             = variableData.Raw(1, :);
  %       else
  %         sheetData             = variableData.Raw(sheetID+1, :);
  %       end
  %     catch err
  %       debugStamp(err, 1);
  %       rethrow(err);
  %     end
  %   end
  %
  %   %% Update Data Model
  %   newData.SheetData           = sheetData;
  %
  %   newData.Parameters.SheetID  = dataReader.Parameters.SheetID;
  %
  %   try newData.DataReader.PromoteState('SheetReady'); end
  %
  %   %end
  %
  %   %% Return
  %   if nargout<1, clear sheetData;  end
  %   if nargout<2, clear parameters; end
  
end

function sheetData = getRawSheetData(setData, sheetID)
  import PrintUniformityBeta.Data.*;
  
  sheetData             = [];
  
  % setData               = (setData.SetData);
  
  setLength             = numel(setData.data);
  
  if isequal(sheetID, 0)
    sumData             = zeros([setLength size(setData.data(1).zData)]);
    
    for m = 1:setLength
      sumData(m,1,:)    = setData.data(m).zData;
    end
    
    meanData            = mean(sumData,1);
    sheetData(1,:)      = meanData;
  else
    try sheetData       = setData.data(sheetID).zData; end
  end
end
