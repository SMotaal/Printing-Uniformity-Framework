cleardebug; cleardebug; clc; 
m = Grasppe.PrintUniformity.UI.UniformityPlotMediator; %m.showFigure;

m.PlotFigure.handleSet('Position', [0 0 1000 1000]);

SourceIDs   = {'rithp7k01','rithp5501','ritsm7402a','ritsm7402b','ritsm7402c'};
PatchValues = [0 25 50 75 100]; %-1

m.DataSources{1}.setSheet('+1');

rt = tic;
for source = SourceIDs
  m.DataSources{1}.CaseID = char(source);
  for p = 1:numel(PatchValues)
    setID = PatchValues(p);
    m.DataSources{1}.SetID = setID;
    m.DataSources{1}.setSheet('sum');
    m.DataSources{1}.PlotLabels.updateSubPlots;
    m.PlotFigure.Export;
    
    m.DataSources{1}.setSheet('+1');
    
    movefile('export.pdf', fullfile('output', sprintf('Plots - %s - %03.0f.pdf', char(source), setID)));
  end
end
