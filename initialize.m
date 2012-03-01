function [ output_args ] = initialize( input_args )
  %INITIALIZE Summary of this function goes here
  
  timerID     = 'InitializeTimer';
  delayTimer  = timerfind('Tag','StartupTimer');
  
  %     warning off all;
  if isempty(delayTimer) % && ~isequal(completed, true)
    fprintf(1,'\n\nHello!\n');
    delayTimer = timer('Tag','StartupTimer', 'StartDelay', 5, ...
      'TimerFcn', 'initialize;');
    start(delayTimer);
    fprintf(2,'\nWorkspace: '); % fprintf(1, 'Ctrl+c to cancel...  ');
    % state=terminated(false);
    %while(isequal(terminated, false));
    %  timecheck();
    %  pause(0.01);
    %end
    %completed=false;
    %pause;
    %cancelled=true;
    %try
    %  initialize;
    %end
  else
    %terminated(true);
    try
      stop(delayTimer);
      delete(delayTimer);
    end
    %checks = timecheck();
    %if checks %isequal(state, false)
      initializeScript();
    %end    
%     terminated(true);
    %end
    %completed = true;
    %         warning on all;
    %         error('Initialization terminated by user!');
    %else
    %  try
    %    delete(timerfind('Tag', 'StartupTimer'));
    %  end
    %end
  end
  %     warning on all;
end

function initializeScript()
  PersistentSources('readonly');
  PersistentSources('load');
  fprintf(2,'\nWorkspace: '); fprintf(1, 'Ready\n');
end

% function checks = timecheck()
%   persistent t;
%   
%   if (nargout==0)
%     t = tic;
%   else
%     checkdiff = toc(t);
%     checks=checkdiff<0.5;
%   end
% end
% 
% function state = terminated(state)
%   persistent runstate;
%   
%   try
%     runstate = state;
%   end
%   state = runstate;
%   
% end
