function eventData = FireEvent(obj, type, varargin)
  %FIRECHANGEEVENT Trigger Object Events
  %   Detailed explanation goes here
  
  try
    eventData = [];
    eventData = obj.ChangeEventData;
    
    switch lower(type)
      case {'change',   'attempt',  'changeattempt', 'changing'};
        fireChangeAttemptEvent(obj, varargin{:});
      case {'changed',  'success',  'changesuccess'}
        fireChangeSuccessEvent(obj, varargin{:});
      case {'abort',    'aborted',  'changeabort'}
        fireChangeAbortEvent(obj, varargin{:});
      case {'fail',     'failed',   'changefailed'}
        fireChangeFailEvent(obj, varargin{:});
    end
  catch err
    if isa(eventData, 'event.EventData') && isvalid(eventData)
      rethrow(err);
    end
  end
  
end

function fireChangeAttemptEvent(obj)
  try
    obj.ChangeEventData.Activate();
  catch err
    obj.ResetEventData('Change');
    obj.ChangeEventData.Activate();
  end
  obj.notify('AttemptingChange', obj.ChangeEventData);
end

function fireChangeSuccessEvent(obj)
  obj.ChangeEventData.Complete();
  obj.notify('SuccessfulChange', obj.ChangeEventData);
  try obj.ResetEventData('delete', obj.ChangeEventData); end
end

function fireChangeAbortEvent(obj)
  obj.ChangeEventData.Abort('interrupt');
  obj.notify('AbortedChange', obj.ChangeEventData);
  try obj.ResetEventData('delete', obj.ChangeEventData); end
end

function fireChangeFailEvent(obj, exception)
  obj.ChangeEventData.Fail(exception);
  obj.notify('FailedChange', obj.ChangeEventData);
  try obj.ResetEventData('delete', obj.ChangeEventData); end
end
