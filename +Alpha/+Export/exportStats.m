clear;
clc;

exporting.path = fullfile('Output',['statsVideo-' datestr(now, 'yymmdd')]);
exporting.diary = fullfile(exporting.path, 'exportStats.log');

warning off MATLAB:MKDIR:DirectoryExists;
opt mkdir (exporting.path);
warning on MATLAB:MKDIR:DirectoryExists;

runlog(exporting.diary,'clear');
runlog(['\n' datestr(now, 'mmmm dd, yyyy HH:MM:SS.FFF AM') '\n\n']);

runTimer = tic;

for source = {'rithp7k01', 'rithp5501', 'ritsm7402a','ritsm7402b','ritsm7402c'}

  source = char(source);

  for newPatchValue = [100 75 50 25 0]  % [100 75 50 25 0]
%     for plotType = {'zone', 'zoneBand', 'region', 'axial', 'circumferential'}
%       close all;
%       plotType = char(plotType);
      plotMode = 'regions';
      exportAll=true; % exportVideo=true; exportPng=true; exportEps=false;
      Alpha.supStatsSurf
      
%     end
  end
end

runlog(['\nExporting Complete \t\t' num2str(toc(runTimer)) '\t seconds\n']);

runlog(['\n' datestr(now, 'mmmm dd, yyyy HH:MM:SS.FFF AM') '\n\n']);
