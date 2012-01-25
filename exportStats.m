clear;
clc;

exporting.path = fullfile('output','statsVideo');
exporting.diary = fullfile(exporting.path, 'exportStats.log');
try
  warning off MATLAB:DELETE:FileNotFound
  delete(exporting.diary)
end
diary(exporting.diary);

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

fprintf(['\nExporting Complete \t\t' num2str(toc(runTimer)) '\t seconds\n']);
diary off;

