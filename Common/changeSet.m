function [ newValue change ] = changeSet( currentValue, newValue)
  %CHANGESET Summary of this function goes here
  %   Detailed explanation goes here

  change = ~isequal(currentValue, newValue);
  
  if change
    return;
  else
    if nargout==1
      evalin('caller', 'return;');
    end
  end
  
%   if ~ischar(object)
%     object = inputname(1);
%   end
%   
%   property = [object '.' property];
%   
%   currentValue = evalin('caller', property);
%   
%   change = ~isequal(currentValue, value);
%   
%   if change
%     assignin('caller', 'newvalue', value);
%     evalin('caller', [property '=newvalue']);
%     evalin('caller', 'clear newvalue');
%   else
%     if nargout==0
%       evalin('caller', 'returning=true, return;');
%     end
%   end
  
end

