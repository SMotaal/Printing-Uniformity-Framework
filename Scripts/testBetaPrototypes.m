clc; try dbquit all, end;close all; cleardebug;

pi = 1;
clear pInfo;

exportProfiles = true;
drawPause = 0.05;


disp('Cleared Debug Workspace.');
if exportProfiles
  newProfile  = @(varargin) evalin('caller', 'profile on; tId=tic;,'    );
  endProfile  = @(varargin) evalin('caller', ['toc(tId); profile off; ' ...
    'pInfo(pi) = profile(''info''); ' 'pi = pi+1; ' ]                   );
else
  newProfile  = @(varargin) evalin('caller', 'tId=tic;,');
  endProfile  = @(varargin) evalin('caller', 'toc(tId);');
end

rId = tic;

disp('Running Tests...');

newProfile();

x = Grasppe.Graphics.Figure('WindowStyle', 'docked');
endProfile(); snapnow(); newProfile();

a = Grasppe.Graphics.Axes('ParentFigure', x);
endProfile(); snapnow(); newProfile();

delete(a);
delete(x);

endProfile(); close all;

fprintf('Tests Complete in %f s.\n', toc(rId));

if exportProfiles
  disp('Saving Test Profiles...');
  
  rID = tic;
  for pi = 1:numel(pInfo)
    profileName = ['Prototypes' int2str(pi)];
    fprintf('Saving %s...\n', profileName);
    profsave( pInfo(pi), fullfile(cd, 'output', 'profile', profileName));
  end
  
  fprintf('Saving Profiles Complete in %f s.\n', toc(rId));
end

clc; try dbquit all, end;close all; cleardebug;

clear all;
