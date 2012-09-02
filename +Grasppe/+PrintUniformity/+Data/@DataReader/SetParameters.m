function SetParameters(obj, newParameters)
  import Grasppe.PrintUniformity.Data.*;
  import Grasppe.PrintUniformity.Models.*;
  
  if ~exist('newParameters', 'var')
    newParameters     = copy(obj.Parameters);
  else
    
    noChange            = obj.Parameters.Compare(newParameters);
    
    caseChange          = obj.Parameters.Compare(newParameters, 'CaseID');
    setChange           = caseChange  ||  obj.Parameters.Compare(newParameters, 'SetID');
    sheetChange         = setChange   ||  obj.Parameters.Compare(newParameters, 'SheetID');
    variableChange      = sheetChange ||  obj.Parameters.Compare(newParameters, 'VariableID');
    
    
    if noChange, return; end
  end
  
  newData             = copy(obj.Data);
  newData.Parameters  = newParameters;
  
  if caseChange
    newData.resetCaseData;
  elseif setChange
    newData.resetSetData;
  elseif variableChange
    newData.resetVariableData;
  elseif sheetChange
    newData.resetSheetData;
  end
    
  if caseChange,      obj.GetCaseData(newData);     end
  if setChange,       obj.GetSetData(newData);      end
  if variableChange,  obj.GetVariableData(newData); end
  if sheetChange,     obj.GetSheetData(newData);    end
  
  obj.ReplaceDataModel('Data',        newData);
  obj.ReplaceDataModel('Parameters',  newData.Parameters);
  
  %% Notify Change
  if caseChange,      obj.notify('CaseChange');     return; end
  if setChange,       obj.notify('SetChange');      return; end
  if variableChange,  obj.notify('VariableChange'); return; end  
  if sheetChange,     obj.notify('SheetChange');    return; end
  
end

function loadCaseData(obj, newParameters)
  
  %data = Grasppe.PrintUniformity.Data
  
  obj.Parameters.CaseID = newParameters.CaseID;
end

function loadSetData(obj, newParameters)
  
  obj.Parameters.CaseID = newParameters.CaseID;
end

