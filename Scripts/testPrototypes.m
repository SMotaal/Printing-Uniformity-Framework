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

x = PlotFigureObject('WindowStyle', 'docked');
endProfile(); snapnow(); newProfile();

d = LocVarUniformityDataSource('CaseID', 'ritsm7402a');
endProfile(); newProfile();

p = x.PlotAxes;
endProfile(); newProfile();

s = UniformitySurfaceObject.Create(p, 'DataSource', d);
endProfile(); snapnow(); newProfile();

b = ColorBarObject.Create(p);
endProfile(); newProfile();

x.setVisible(true);
endProfile(); snapnow(); newProfile();

for i = 1:d.getSheetCount
  s.setSheet('+1');
  drawnow();
end
endProfile(); snapnow(); newProfile();

delete(x);
endProfile(); newProfile();


x = MultiPlotFigureObject('WindowStyle', 'normal');
endProfile(); snapnow(); newProfile();

d     = LocVarUniformityDataSource('CaseID', 'ritsm7402a');
d(2)  = LocVarUniformityDataSource('CaseID', 'ritsm7402b');
d(3)  = LocVarUniformityDataSource('CaseID', 'ritsm7402c');
endProfile(); newProfile();

for i = 1:numel(d)
  p(i)  = x.getPlotAxes(i);
end
endProfile(); newProfile();

for i = 1:numel(d)
  s(i)  = UniformitySurfaceObject.Create(p(i), 'DataSource', d(i));
end
endProfile(); newProfile();

x.setVisible(1);
endProfile(); snapnow(); newProfile();

x.WindowStyle = 'normal';
set(x.Handle, 'Position', [100 300 1240 500]);
drawnow expose; endProfile();
set(x.Handle, 'Position', [100 300 1240 500]);
snapnow(); newProfile();


for j = 1:d(1).getSheetCount-1
  for i = 1:numel(s)
    s(i).setSheet('+1');
  end
  drawnow expose; %pause(drawPause);
end
endProfile(); snapnow(); newProfile();

for i = 1:numel(s)
  s(i).setSheet('+1');
end
drawnow expose; %pause(drawPause);
endProfile(); snapnow(); newProfile();

delete(x);
delete(s);
delete(d);

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
