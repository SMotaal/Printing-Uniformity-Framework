function [ output_args ] = debugStamp( tag, level, obj )
  %DEBUGSTAMP Summary of this function goes here
  %   Detailed explanation goes here
  
  debugmode     = false;
  if ~debugmode, return; end
  
  persistent debugtimer debugstack stackdups stackloops stacktime;
  
  try
  
  verbose       = false;
  intrusive     = false;
  detailed      = false;
  stackLimit    = 5;
  latencyLimit  = stackLimit * 100;

  if isnumeric(tag)
    if nargin==2
      obj = level;
      level = tag; tag = '';
      try tag = obj.ID; end
      try if isempty(tag), tag = class(obj); end; end
    else
      level = tag; tag = '';
    end
    
  else
    if nargin<2
      level = 5;
    end
  end
  
  
  
  ds = dbstack('-completenames');
  
  dbstamp = '';
  for m = 2:min(numel(ds),4)
    d = ds(m);

    tx = [d.name ' (' int2str(d.line) ')'];

    dbstamp = [dbstamp sprintf('\t<a href="matlab: opentoline(%s, %d)">%s</a>', d.file, d.line, tx)];
  end
  
  n = stamp;
  
  if n==1
    debugstack  = '';
    stackdups   = '';
    stackloops  = 0;
  end  
 
  nextstack = sprintf('\n%s',['@' dbstamp]);

  try
    try if nargin>2 && isa(obj, Grasppe.Core.Prototype)
        tag = [obj.ID '.' tag]; end; end
    
    try if isa(tag, Grasppe.Core.Prototype)
      tag = [obj.ID '.' tag]; end; end

    if ischar(tag)
      nextstack = sprintf('\n%s:\t%s', tag, strtrim(dbstamp));
    end
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
      dispf('Stacks: %d \tLoops: %d \tDuration: %5.3f s',n , stackloops, duration);
    end
    stamp;
    if (intrusive) keyboard; end
  end
  end
  
  debugstack = [debugstack nextstack];
  
  if verbose || level < 5
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

