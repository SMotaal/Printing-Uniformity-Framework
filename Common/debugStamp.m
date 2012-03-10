function [ output_args ] = debugStamp( tag )
  %DEBUGSTAMP Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent debugtimer debugstack stackdups stackloops stacktime;
  
  try
  debugmode     = false;
  verbose       = true;  
  intrusive     = false;
  detailed      = false;
  stackLimit    = 5;
  latencyLimit  = stackLimit * 100;
  
  if ~debugmode, return; end
  
  d = dbstack('-completenames');
  
  d = d(2);
  
  tx = [d.name ' (' int2str(d.line) ')'];
  
  dbstamp = sprintf('<a href="matlab: opentoline(%s, %d)">%s</a>', d.file, d.line, tx);
  
  n = stamp;
  
  if n==1
    debugstack='';
    stackdups='';
    stackloops=0;
  end  
 
  try
    nextstack = sprintf('\n%s',[tag ':' dbstamp]);
  catch
    nextstack = sprintf('\n%s',['@' dbstamp]);
  end
  
%   if n > 10
    if ~isempty(strfind(debugstack, strtrim(nextstack)))
      stackloops = numel(strfind(debugstack, stackdups));
      stackdups = [stackdups nextstack];
    end
%   end
  try
  if n>latencyLimit || stackloops>stackLimit
    stack = dbstack('-completenames'); 
    try
      duration = toc(stacktime);
    catch
      duration = 0;
    end
    if detailed
      disp(debugstack);
    else
      disp(sprintf('Stacks: %d \tLoops: %d \tDuration: %5.3f s',n , stackloops, duration));
    end
    stamp;
    if (intrusive) keyboard; end
  end
  end
  
  debugstack = [debugstack nextstack];
  
  if verbose
    disp(nextstack);
  end  
  
  if isempty(debugtimer) || ~isvalid(debugtimer)
    debugtimer = timer('Name','DebugStampTimer','ExecutionMode', 'fixedDelay', 'Period', 0.4, 'StartDelay', 1, 'TimerFcn', @stamp);
  else
    stop(debugtimer);
  end
  
  start(debugtimer);
  stacktime = tic;
  
  catch err
    disp(err);
  end
  
end

function value = stamp(varargin)
  persistent current
  
  if ~isnumeric(current)
    current = 0;
  end
  
  if nargout>0
    current = current+1;
    value = current;
  else
    current = 0;
  end
  
end

