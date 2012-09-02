function [ caseData parameters ] = GetCaseData(obj, newData, parameters, sourceData)
  %GetCaseData Load and Get Case Data
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
  
  caseData              = newData.CaseData;
  
  if updatedParameters || isempty(caseData)
    
    
    %% Get Container Data
    if ~exist('sourceData', 'var')
      sourceData        = feval([eval(NS.CLASS) '.LoadSourceData'], newData.Parameters.CaseID);
    end
    
    %% Execute Custom Processing Function
    skip                = false;
    
    if isa(obj.GetCaseDataFunction, 'function_handle')
      [caseData skip]   = obj.CaseDataFunction(newData.Parameters, sourceData);
    end
    
    %% Execute Default Processing Function
    if isequal(skip, false)
      caseData          = sourceData;
    end
    
    %% Update Data Model
    newData.CaseData    = caseData;
    
  end
  
  %% Return
  if nargout<1, clear caseData;   end
  if nargout<2, clear parameters; end
end

