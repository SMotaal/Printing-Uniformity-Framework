function change  = SetParameters(obj, eventData)
  
  try
  eventData.CheckStatusWithException();
  
  %   if ~exist('newParameters',  'var'), newParameters = []; end
  %   if ~exist('change',         'var'), change = 'all';     end
  
  %change            = obj.SetParameters@Grasppe.Data.Reader(newParameters, change);
  
  newParameters     = obj.Parameters;
  
  obj.Data.DataReader = obj;
  
  if isempty(eventData.Parameter)
    change          = 'all';
  else
    change          = eventData.Parameter;
    parameter       = eventData.Parameter;
    
    if iscell(parameter), parameter = parameter{1}; end
      
    newParameters.(parameter)  = eventData.NewValue;
  end
  
  allChange         = isequal(change, 'all');
  caseChange        = allChange || any(strcmpi('CaseID',     change));
  setChange         = allChange || any(strcmpi('SetID',      change));
  variableChange    = allChange || any(strcmpi('VariableID', change));
  sheetChange       = allChange || any(strcmpi('SheetID',    change));
  
  updateCase        = caseChange;
  updateSet         = setChange       ||  updateCase;
  updateVariable    = variableChange  ||  updateSet;
  updateSheet       = sheetChange     ||  updateVariable;
  
  caseUpdated       = false;
  setUpdated        = false;
  variableUpdated   = false;
  sheetUpdated      = false;
  
  if ~(updateCase || updateSet || updateVariable || updateSheet), return; end
    
  obj.DemoteState('Initialized');
  
  if updateCase,          obj.Data.resetCaseData;
  elseif updateSet,       obj.Data.resetSetData;
  elseif updateVariable,  obj.Data.resetVariableData;
  elseif updateSheet,     obj.Data.resetSheetData;
  end
  
  
  if updateCase
    % eventData.CheckStatusWithException();
    obj.GetCaseData(); %, eventData);
    caseUpdated     = true;
  end
  
  if updateSet
    % eventData.CheckStatusWithException();
    obj.GetSetData() %, eventData);
    setUpdated      = true;
  end
  
  if updateVariable
    % eventData.CheckStatusWithException();
    obj.GetVariableData() %, eventData);
    variableUpdated = true;
  end
  
  if updateSheet
    % eventData.CheckStatusWithException();
    obj.GetSheetData();
    sheetUpdated    = true;
  end
  
  change            = {};
  if allChange && caseUpdated && setUpdated && variableUpdated && sheetUpdated
    change          = 'all';
  else
    if caseUpdated,     change = [change, 'CaseID']; end
    if setUpdated,      change = [change, 'SetID']; end
    if variableUpdated, change = [change, 'VariableID']; end
    if sheetUpdated,    change = [change, 'SheetID']; end
  end
  
  eventData.CheckStatusWithException();
  
  if caseUpdated || setUpdated || variableUpdated || sheetUpdated
    
    errs = {};
    err  = [];
    
    try if caseChange
        obj.notify('CaseChange',      eventData); end
    catch err
      errs = [err, errs];
    end
    
    try if setChange
        obj.notify('SetChange',       eventData); end
    catch err
      errs = [err, errs];
    end
    
    try if variableChange
        obj.notify('VariableChange',  eventData); end
    catch err
      errs = [err, errs];
    end
    
    try if sheetChange
        obj.notify('SheetChange',     eventData); end
    catch err
      errs = [err, errs];
    end
    
    try
      err   = errs{1};
      
      for m = 2:numel(errs)
        err = addCause(errs{m});
      end
    end
    
    if isa(err, 'MException'), throw(err); end
  end
  
  catch err
    rethrow(err);
  end
  
end
