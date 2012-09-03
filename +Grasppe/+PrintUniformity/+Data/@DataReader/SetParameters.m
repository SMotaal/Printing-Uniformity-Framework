function SetParameters(obj, newParameters, delay, oldParameters, oldData)
  import Grasppe.PrintUniformity.Data.*;
  import Grasppe.PrintUniformity.Models.*;
    
  try stop(obj.PreloadTimer);   end
  
  try
    
    %% Process Arguments
    if ~exist('oldParameters', 'var') || isempty(oldParameters)
      oldParameters             = copy(obj.Parameters);
    end
    
    if ~exist('oldData', 'var') || isempty(oldData)
      oldData                   = copy(obj.Data);
    end
    
    if ~exist('newParameters', 'var') || isempty(newParameters)
      newParameters             = copy(obj.Parameters);
    else
      obj.Parameters.CaseID     = newParameters.CaseID;
      obj.Parameters.SetID      = newParameters.SetID;
      obj.Parameters.VariableID = newParameters.VariableID;
      obj.Parameters.SheetID    = newParameters.SheetID;
    end
    
    if all(obj.Data.Parameters.Compare(newParameters)==1), return; end % No Change!
    
    %% Delayed Call (Threading)
    
    if exist('delay', 'var') && isequal(delay, true)
      try delete(obj.PreloadTimer); end
      obj.PreloadTimer = GrasppeKit.DelayedCall(@(s, e) obj.SetParameters([],[], oldParameters, oldData), 0.1, 'start');
      return;
    end    
    
    %% Check for Change
    
    caseChange          = ~obj.Parameters.Compare(newParameters, 'CaseID');
    setChange           = caseChange      ||  ~obj.Data.Parameters.Compare(newParameters, 'SetID');
    variableChange      = setChange       ||  ~obj.Data.Parameters.Compare(newParameters, 'VariableID');
    sheetChange         = variableChange  ||  ~obj.Data.Parameters.Compare(newParameters, 'SheetID');
    
    
    %% Prepare New Data
    newData             = obj.Data;
    newData.DataReader  = obj;
    
    if caseChange,          newData.resetCaseData;
    elseif setChange,       newData.resetSetData;
    elseif variableChange,  newData.resetVariableData;
    elseif sheetChange,     newData.resetSheetData;
    end
    
    %% Reset State
    
    obj.DemoteState('Initialized');
    
    %% Abort if no case!
    
    if isempty(obj.Parameters.CaseID)
      return;
    end
    
    %% Fallback to parameter defaults (if necessary)
    if isempty(obj.Parameters.SetID),       obj.Parameters.SetID      = obj.DefaultValue('SetID'); end
    if isempty(obj.Parameters.VariableID),  obj.Parameters.VariableID = obj.DefaultValue('VariableID'); end
    if isempty(obj.Parameters.SheetID),     obj.Parameters.SheetID    = obj.DefaultValue('SheetID'); end
    
    %% Get New Data
    
    if caseChange,      obj.GetCaseData();     end
    if setChange,       obj.GetSetData();      end
    if variableChange,  obj.GetVariableData(); end
    if sheetChange,     obj.GetSheetData();    end
        
    %% Notify Change
    
    if caseChange || setChange || variableChange || sheetChange
      eventData = Grasppe.PrintUniformity.Data.ReaderEventData(...
        obj.Parameters, obj.Data, oldParameters, oldData, ...
        sheetChange, variableChange, setChange, caseChange);
      if caseChange,      obj.notify('CaseChange',      eventData); return; end
      if setChange,       obj.notify('SetChange',       eventData); return; end
      if variableChange,  obj.notify('VariableChange',  eventData); return; end
      if sheetChange,     obj.notify('SheetChange',     eventData); return; end
    end
    
    %% Delete old Data & Parameters
    try delete(oldData); end
    try delete(oldParameters); end
    
  catch err
    
    %% Prepare exception

    if ~exist('oldParameters',  'var'), oldParameters  = []; end
    if ~exist('oldData',        'var'), oldData        = []; end
    
    if ~exist('newData', 'var')       || isempty(newData), obj.Data;         end
    if ~exist('newParameters', 'var') || isempty(newData), obj.Parameters;   end
    
    
    eventData = Grasppe.PrintUniformity.Data.ReaderEventData(...
      newParameters, newData, oldParameters, oldData);
    
    try eventData.Exception = err; end
    
    %% Reset to old Data & Parameters
    
    try obj.Data.CaseData           = oldData.CaseData;               end
    try obj.Data.SetData            = oldData.SetData;                end
    try obj.Data.VariableData       = oldData.VariableData;           end
    try obj.Data.SheetData          = oldData.SheetData;              end
    try obj.Parameters.CaseID       = oldData.Parameters.CaseID;      end
    try obj.Parameters.SetID        = oldData.Parameters.SetID;       end
    try obj.Parameters.VariableID   = oldData.Parameters.VariableID;  end
    try obj.Parameters.SheetID      = oldData.Parameters.SheetID;     end
    
    
    try
      %% Notify Failed
      obj.notify('FailedChange', eventData);
    catch err2
      %% Rethrow Exception (if notify fails)
      debugStamp(err, 1);
      %rethrow(err);
    end
  end
  
end
