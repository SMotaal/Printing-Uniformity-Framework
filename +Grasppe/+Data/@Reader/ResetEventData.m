function eventData = ResetEventData( obj, type, varargin )
  %RESETEVENTDATA Summary of this function goes here
  %   Detailed explanation goes here
  eventData = [];
  switch lower(type)
    case {'change'}
      eventData = resetChangeData(obj, varargin{:});
    case {'delete'}
      try GrasppeKit.DeleteEvent(varargin{:}); end
  end
end

function eventData = resetChangeData(obj, parameter, newValue)
  
  import Grasppe.PrintUniformity.Data.*;
  
  %% Interrup any on going event
  try
    obj.FireEvent('abort');
  catch err
    debugStamp(err, 5);
  end
  
  %% Create new change event data
  previousValue       = [];
  try previousValue   = obj.Parameters.(parameter); end
  
  previousData        = [];
  %try previousData    = obj.Data; end
  
  if ~exist('parameter', 'var')
    parameter         = [];
    newValue          = [];
  end
  
  if ~exist('newValue', 'var')
    newValue          = [];
  end
  
  obj.ChangeEventData = ReaderEventData.CreateEventData(parameter, newValue, previousValue, previousData);
  
  if nargout > 0, eventData = obj.ChangeEventData; end
end
% 
% function deleteChangeData(eventData, force)
%   if ~exist('force', 'var') || isempty(force)
%     GrasppeKit.DelayedCall(@(s, e)deleteChangeEventData(eventData, 'force'), 5, 'start');
%   else
%     try delete(eventData); end
%   end
% end
