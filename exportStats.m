clear;
runTimer = tic;

for source = {'ritsm7402a'}; % {'rithp7k01', 'rithp5501', 'ritsm7402a','ritsm7402b','ritsm7402c'}

  source = char(source);

  for newPatchValue = [100 75 50 25 0]  % [100 75 50 25 0]
    for plotType = {'zone', 'region', 'axial', 'circumferential'}
      close all;
      
      plotType = char(plotType);
      
      exportVideo = true;
      testStats;
    end
  end
end

fprintf(['\nExporting Complete \t\t' num2str(toc(runTimer)) '\t seconds\n']);
