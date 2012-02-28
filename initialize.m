function [ output_args ] = initialize( input_args )
  %INITIALIZE Summary of this function goes here
  %   Detailed explanation goes here
  
  timerID     = 'InitializeTimer';
  delayTimer  = timerfind('Name','StartupTimer');
  
%   try
    
    if isempty(delayTimer)
      fprintf(1,'\n\nHello!\n');
      delayTimer = timer('Name','StartupTimer', 'StartDelay', 0.05, ...
        'TimerFcn', 'initialize;');
      start(delayTimer);
    else
      fprintf(2,'\nWorkspace: '); fprintf(1, 'Initializing\n');
      initializeScript();
      stop(delayTimer);
      delete(delayTimer);
    end
%   end
  
end

function initializeScript()
  PersistentSources('readonly');
  fprintf(2,'\nWorkspace: '); fprintf(1, 'Ready\n');
end
