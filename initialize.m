function [ output_args ] = initialize( varargin )
  %INITIALIZE Summary of this function goes here
  
  addpath('Common', 'Scripts'); % , 'Algorithms', 'Test');
  
  % GrasppePrototype.InitializeGrasppePrototypes;
  
  timerID     = 'InitializeTimer';
  delayTimer  = timerfind('Tag','StartupTimer');
  
  if isempty(delayTimer)
    fprintf(1,'\n\nHello!\n');
    delayTimer = timer('Tag','StartupTimer', 'StartDelay', 0.5, ...
      'TimerFcn', @(src,evt)initialize()); % 'initialize');  %@(src,evt)initialize);
    start(delayTimer);
    fprintf(2,'\nWorkspace: '); fprintf(1, 'Loading...  \n');
  else
    try
      stop(delayTimer);
      delete(delayTimer);
    end
    initializeScript();
  end
end

function initializeScript()
  PersistentSources readonly;
  PersistentSources load; %PersistentSources load;  
  fprintf(2,'\nWorkspace: '); fprintf(1, 'Ready\n');
  status('',0);
  
end

