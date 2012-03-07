clc; try dbquit all, end;close all; cleardebug;

pi = 1;
clear pInfo;


disp('Cleared Debug Workspace.');

newProfile  = @(varargin) evalin('caller', 'profile on; tId=tic;,'    );
endProfile  = @(varargin) evalin('caller', ['toc(tId); profile off; ' ...
  'pInfo(pi) = profile(''info''); ' 'pi = pi+1; ' ]                   );

rId = tic;

disp('Running Tests...');

newProfile();

x = PlotFigureObject;
% endProfile(); newProfile();
% x.setVisible(true);
% endProfile(); newProfile();
% [dataSource params] = Plots.plotUPStats('ritsm7402c',params);
% endProfile(); newProfile();
% [dataSource params] = Plots.plotUPStats('ritsm7402c', 50, params);
% endProfile(); newProfile();
% [dataSource params] = Plots.plotUPStats('ritsm7402c',params);
% endProfile(); newProfile();
% [dataSource params] = Plots.plotUPStats('ritsm7402a');

endProfile();

fprintf('Tests Complete in %f s.\n', toc(rId));

disp('Saving Test Profiles...');

rID = tic;

for pi = 1:numel(pInfo)
  profileName = ['Prototypes' int2str(pi)];
  fprintf('Saving %s...\n', profileName);
  profsave( pInfo(pi), fullfile(cd, 'output', 'profile', profileName));
end

fprintf('Saving Profiles Complete in %f s.\n', toc(rId));
