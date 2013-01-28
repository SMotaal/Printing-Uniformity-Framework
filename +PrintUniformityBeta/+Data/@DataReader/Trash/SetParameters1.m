function SetParameters(obj, newParameters, delay, oldParameters, oldData)
  import PrintUniformityBeta.Data.*;
  import PrintUniformityBeta.Models.*;
    
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
      obj.PreloadTimer          = GrasppeKit.Utilities.DelayedCall(@(s, e) obj.SetParameters([],[], oldParameters, oldData), 0.1, 'start');
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
    
    
    %% Notify Attempting Change
    if ~exist('oldParameters',  'var'),   oldParameters  = []; end
    if ~exist('oldData',        'var'),   oldData        = []; end
    
    if ~exist('newData', 'var')       || isempty(newData)
      newData       = obj.Data;             end
    if ~exist('newParameters', 'var') || isempty(newParameters)
      newParameters = obj.Parameters;   end
    
    
    eventData = PrintUniformityBeta.Data.ReaderEventData(...
      newParameters, newData, oldParameters, oldData);
    
    try
      obj.notify('AttemptingChange', eventData);
    catch err
      debugStamp(err, 1);
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
    eventData = PrintUniformityBeta.Data.ReaderEventData(...
      obj.Parameters, obj.Data, oldParameters, oldData, ...
      sheetChange, variableChange, setChange, caseChange);
      
    if caseChange || setChange || variableChange || sheetChange
      
      try
        if caseChange,      obj.notify('CaseChange',      eventData); end
        if setChange,       obj.notify('SetChange',       eventData); end
        if variableChange,  obj.notify('VariableChange',  eventData); end
        if sheetChange,     obj.notify('SheetChange',     eventData); end
      catch err, debugStamp(err, 1); end
      
      %% Notify Successful Change
      GrasppeKit.Utilities.DelayedCall(@(s, e) obj.notify('SuccessfulChange', eventData), 0.1, 'start');
      % obj.notify('SuccessfulChange', eventData);
      
      try 
        obj.GetVariableData();
        obj.GetSheetData();
      catch err, debugStamp(err, 1);  end
      
    end
    
    %% Delete old Data & Parameters
    try delete(oldData); end
    try delete(oldParameters); end
    
%     if ~exist('oldParameters',  'var'),   oldParameters  = []; end
%     if ~exist('oldData',        'var'),   oldData        = []; end
%     
%     if ~exist('newData', 'var')       || isempty(newData)
%       newData       = obj.Data;             end
%     if ~exist('newParameters', 'var') || isempty(newParameters)
%       newParameters = Dataobj.Parameters;   end
%     
%     
%     eventData = PrintUniformityBeta.Data.ReaderEventData(...
%       newParameters, newData, oldParameters, oldData);
%     
%     obj.notify('AttemptChange', eventData);
    
    
  catch err
    
    %% Prepare exception

    if ~exist('oldParameters',  'var')
      oldParameters   = []; end
    if ~exist('oldData',        'var')
      oldData         = []; end
    
    if ~exist('newData', 'var') || isempty(newData)
      newData         = obj.Data;
    end
    
    if ~exist('newParameters', 'var') || isempty(newParameters)
      newParameters   = obj.Parameters;
    end
    
    eventData = PrintUniformityBeta.Data.ReaderEventData( ...
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
      obj.GetVariableData();
      obj.GetSheetData(); 
    catch err, debugStamp(err, 1);  end

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

function evt = createChangeEvent(parameter, newValue, previousValue, previousData)
  evt = PrintUniformityBeta.Data.ReaderEventData.CreateEventData(parameter, newValue, previousValue, previousData);
end
