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
x = Grasppe.PrintUniformity.Graphics.UniformityPlotFigure('PlotAxesLength', 3); 
endProfile(); snapnow(); newProfile();

mPos = get(0,'MonitorPositions');
set(x.Handle, 'Position', [mPos(1,1) mPos(4) mPos(3) 550]);
endProfile(); snapnow(); newProfile();

a1 = x.PlotAxes{1}; a2 = x.PlotAxes{2}; a3 = x.PlotAxes{3};
endProfile(); snapnow(); newProfile();

d1 = Grasppe.PrintUniformity.Data.RawUniformityDataSource('CaseID', 'rithp5501');
endProfile(); snapnow(); newProfile();

p1 = Grasppe.PrintUniformity.Graphics.UniformitySurf(a1, d1);
endProfile(); snapnow(); newProfile();

d2 = Grasppe.PrintUniformity.Data.UniformityPlaneDataSource('CaseID', 'rithp5501'); 
endProfile(); snapnow(); newProfile();

p2 = Grasppe.PrintUniformity.Graphics.UniformitySurf(a2, d2);
endProfile(); snapnow(); newProfile();

d3 = Grasppe.PrintUniformity.Data.LocalVariabilityDataSource('CaseID', 'rithp5501');
endProfile(); snapnow(); newProfile();

p3 = Grasppe.PrintUniformity.Graphics.UniformitySurf(a3, d3);
endProfile(); snapnow(); newProfile();

x.prepareMediator;
endProfile(); snapnow(); newProfile();

for i = 1:d1.getSheetCount
  d1.setSheet('+1');
  drawnow();
end
endProfile(); snapnow(); newProfile();

x.PlotMediator.CaseID = 'ritsm7402a';
endProfile(); snapnow(); newProfile();

for i = 1:d1.getSheetCount
  d1.setSheet('+1');
  drawnow();
end
endProfile(); snapnow(); newProfile();

x.PlotMediator.SetID = 50;
endProfile(); snapnow(); newProfile();

for i = 1:d1.getSheetCount
  d1.setSheet('+1');
  drawnow();
end
endProfile(); snapnow(); newProfile();

x.PlotMediator.CaseID = 'rithp7k01';
endProfile(); snapnow(); newProfile();

x.PlotMediator.CaseID = 'ritsm7402a';
endProfile(); snapnow(); newProfile();

for i = 1:d1.getSheetCount
  d1.setSheet('+1');
  drawnow();
end
endProfile(); snapnow(); newProfile();

delete(p1);
endProfile(); snapnow(); newProfile();

delete(p2);
endProfile(); snapnow(); newProfile();

delete(p3);
endProfile(); snapnow(); newProfile();

delete(a1);
endProfile(); snapnow(); newProfile();

delete(a2);
endProfile(); snapnow(); newProfile();

delete(a3);
endProfile(); snapnow(); newProfile();

delete(d1);
endProfile(); snapnow(); newProfile();

delete(d2);
endProfile(); snapnow(); newProfile();

delete(d3);
endProfile(); snapnow(); newProfile();

delete(x);

endProfile(); close all;

fprintf('Tests Complete in %f s.\n', toc(rId));

if exportProfiles
  disp('Saving Test Profiles...');
  
  rID = tic;
  % parfor pi = 1:numel(pInfo)
  %   profileName = ['GrasppeBeta' int2str(pi)];
  %   fprintf('Saving %s...\n', profileName);
  %   profsave( pInfo(pi), fullfile(cd, 'output', 'profile', profileName));
  % end
  profileName = 'GrasppeBeta';
  
  save(fullfile(cd, 'output', 'profile', profileName), 'pInfo');
  
  fprintf('Saving Profiles Complete in %f s.\n', toc(rId));
end

clc; try dbquit all, end;close all; cleardebug;

clear all;
