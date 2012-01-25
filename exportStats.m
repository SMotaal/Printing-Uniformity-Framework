clear;
clc;

exporting.path = fullfile('output','statsVideo');
exporting.diary = fullfile(exporting.path, 'exportStats.log');

runlog(exporting.diary,'clear');

runTimer = tic;

for source = {'rithp7k01', 'rithp5501', 'ritsm7402a','ritsm7402b','ritsm7402c'}

  source = char(source);

  for newPatchValue = [100 75 50 25 0]  % [100 75 50 25 0]
    for plotType = {'zone', 'zoneBand', 'region', 'axial', 'circumferential'}
      close all;
      
      plotType = char(plotType);
      exportVideo=false; exportPng=true; exportEps=false;
      
      testStats;
    end
  end
end

runlog(['\nExporting Complete \t\t' num2str(toc(runTimer)) '\t seconds\n']);


