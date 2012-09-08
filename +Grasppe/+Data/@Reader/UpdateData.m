function eventData = UpdateData( obj, parameter, value )
  %UPDATEDATA Summary of this function goes here
  %   Detailed explanation goes here
  try
    try stop(obj.updateDelayTimer);     end
    
    if nargin==1
%       timerRunning = false;
%       try timerRunning = ~isequal(obj.updateDelayTimer.Running, 'off'); end
%       if timerRunning, return; end
      eventData = obj.ResetEventData('Change', [], []);
      delay     = 0.5;
    elseif nargin==3
      eventData = obj.ResetEventData('Change', parameter, value);
      delay     = 0.1;
    else
      error('Grasppe:UpdateData:MissingArguments', ...
        'UpdateData requires neither or both parameter and value.');
    end
    
    
    updateCallBack = @(s, e) updateData(obj, eventData);
    
    resetUpdateTimer(obj, updateCallBack, delay);
    
    try start(obj.updateDelayTimer); end
  catch err
    debugStamp(err, 1);
    rethrow(err);
  end
end

function updateData(obj, eventData)
  obj.FireEvent('Changing');  
  try    
    try stop(obj.updateDelayTimer); end
    obj.SetParameters(eventData);
    
    %     try
    %       parameters = fieldnames(eventData.Source.Parameters)
    %       for m = 1:numel(parameters)
    %         try
    %           parameter = parameters{m};
    %           eventData.Source.Parameters.(parameter) = eventData.Source.Data.Parameters.(parameter);
    %         end
    %       end
    %
    %     end
    
  catch err
    interrupted           = false;
    try interrupted       = ~eventData.CheckStatus; end
    if ~interrupted
      %debugStamp(err, 1);
      restoreData(obj, eventData);
      obj.FireEvent('Failed', err);
      %throw(err);
    end
    return;
  end
  %obj.FireEvent('success')
  GrasppeKit.DelayedCall(@(s, e) obj.FireEvent('success'), 0.1, 'start');
end

function restoreData(obj, eventData)
  try
    parameter = eventData.Parameter;
    if iscell(parameter), parameter = parameter{1}; end
    eventData.Source.Parameters.(parameter) = eventData.PreviousValue;    
  end
  try
    datafields = fieldnames(eventData.PreviousData);
%     for m = 1:numel(
%     end
% 
  end
end
% 
% function restoreFeld(data, field, oldValue)
%   
% end

% function newParameters = getNewParameters (obj, parameter, value)
%   parameter   = obj.DataParameters(parameter);
%   
%   newParameters             = struct(obj.Parameters);
%   
%   if nargin<3 || isempty(value) || isempty(parameter) || ~ || 
%     return;
%   elseif nargin==3 && ~(isempty(value) || isa(value, class(obj.(parameter))))
%     error('Grasppe:GetNewParameters:InvalidArguments', 'New parameters are invalid.');
%   end
%   
%   newParameters.Previous    = newParameters;
%   newParameters.(parameter) = value;
% end

function resetUpdateTimer(obj, updateCallBack, delay)
  if ~exist('updateCallBack', 'var') || ~isa(updateCallBack, 'function_handle')
    updateCallBack                = obj.UpdateData();
  end
  
  try stop(obj.updateDelayTimer); end
  
  if isa(obj.updateDelayTimer, 'timer') && isvalid(obj.updateDelayTimer)
      obj.updateDelayTimer.TimerFcn = (updateCallBack);
      obj.updateDelayTimer.Period   = delay;
  else
    try delete(obj.updateDelayTimer); end
    obj.updateDelayTimer = GrasppeKit.DelayedCall(updateCallBack, delay);
  end
end


% if nargin == 1
    %   changedParameters   = 'all';
    % elseif narging == 2 && isstruct(parameter)
    %   changedParameters   = 'all';
    %   newParameters       = parameter;
    %   elseif nargin == 3 && ischar(parameter)
    %     changedParameters   = parameter;
    %     newParameters       = getNewParameters (obj, parameter, value);
    % end
