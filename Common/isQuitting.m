function [ result ] = isQuitting( newState )
  %ISQUITTING persistent toggle called by a finish script
  
  persistent state;
  
  if (isValid('newState','logical'))
    state = newState;
    return;
  end
  
  if (~isValid('state','logical'))
    state = false;
  end
  
  result = state;  
  
end

