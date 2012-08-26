function varargout = funstats( varargin )
  %FUNCALLS Function Call Statistics Tool
  %   Call mode in a the begining of a function: funcall;
  
  %% Define Stack
  stack     = dbstack;
  voidstack = numel(stack)==1;
  
  if ~voidstack, stack = stack(2:end); end
  
  %% Determine Mode
  mode = '';
  
  if nargin==1 && nargout==0 && voidstack, mode = 'call';
  end
  
  switch mode
    case 'call'
    %% Call Mode
    
    otherwise
  end
  
  
end

function storeStat(funName, funPath, funLine, callerName, callerPath, callerLine)
  
end

function st = readStat(funName)
end

function pth = logPath
  
end
