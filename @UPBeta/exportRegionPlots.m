cleardebug; cleardebug; clc;
global debugmode; debugmode=false;

RT = tic;

T = tic; fprintf(1,'Preparing plot figure... ');
m = Grasppe.PrintUniformity.UI.UniformityPlotMediator;

m.PlotFigure.handleSet('Position', [0 0 800 800]);

SourceIDs   = {'rithp7k01','rithp5501','ritsm7402a','ritsm7402b','ritsm7402c'};
PatchValues = [0 25 50 75 100]; %-1

toc(T);

nplots = 0;

for source = SourceIDs
  T = tic; fprintf(1,'\tLoading %s case data... ', char(source));
  m.DataSources{1}.CaseID = char(source);
  toc(T);
  for p = 1:numel(PatchValues)
    setID = PatchValues(p);
    T = tic; fprintf(1,'\t\tLoading %s %d%% set data... ', char(source), setID);
    m.DataSources{1}.SetID = setID;
    m.DataSources{1}.setSheet('sum');
    %m.DataSources{1}.PlotLabels.updateSubPlots;
    toc(T);
    T = tic; fprintf(1,'\t\t\tExporting %s summary plot... ', m.PlotFigure.Title); % char(source), setID); %d%%
    m.PlotFigure.Export;
    movefile(fullfile('output','export.pdf'), fullfile('output', sprintf('Plots - %s - %03.0f.pdf', char(source), setID)));
    toc(T);
    
    nplots = nplots+1;
  end
end

dispf('Finished exporting %d plots for %d sets in %d cases... Total time %1f seconds.', ...
  nplots, numel(SourceIDs), numel(PatchValues), toc(RT));
