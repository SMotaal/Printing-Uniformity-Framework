cleardebug; cleardebug; clc;
global debugmode; debugmode=false;

RT = tic;

T = tic; fprintf(1,'Preparing plot figure... ');
m = Grasppe.PrintUniformity.UI.UniformityPlotMediator({'Regions'}); %, 'Surface' ([], {'CaseID', 'ritsm7402a'});

m.PlotFigure.handleSet('Position', [0 0 800*1 800*1]);

SourceIDs   = {'rithp5501', 'rithp7k01', 'ritsm7402a', 'ritsm7402b', 'ritsm7402c'}; % 'ritsm7402a'}; %
PatchValues = fliplr([0 25 50 75 100]); %  [100];

toc(T);

nplots = 0;

caseID    = m.DataSources{1}.CaseID;
sourceIDs = [caseID, SourceIDs(~strcmpi(caseID,SourceIDs))];

for source = sourceIDs
  T = tic; fprintf(1,'\tLoading %s case data... ', char(source));
  if ~isequal(m.DataSources{1}.CaseID, char(source))
    m.DataSources{1}.CaseID = char(source);
  end
  toc(T);
  setID     = m.DataSources{1}.SetID;
  patchValues = [setID PatchValues(PatchValues~=setID)];
  for p = 1:numel(PatchValues)
    setID = PatchValues(p);
    T = tic; fprintf(1,'\t\tLoading %s %d%% set data... ', char(source), setID);
    if ~isequal(m.DataSources{1}.SetID, setID)
      m.DataSources{1}.SetID = setID;
    end
    m.DataSources{1}.setSheet('sum');
    %m.DataSources{1}.PlotLabels.updateSubPlots;
    toc(T);
    T = tic; fprintf(1,'\t\t\tExporting %s summary plot... ', m.PlotFigure.Title); % char(source), setID); %d%%
    m.PlotFigure.Export;
    movefile(fullfile('Output','export.pdf'), fullfile('Output', sprintf('Plots - %s - %03.0f.pdf', char(source), setID)));
    toc(T);
    nplots = nplots+1;
  end
end

dispf('Finished exporting %d plots for %d sets in %d cases... Total time %1f seconds.', ...
  nplots, numel(SourceIDs), numel(PatchValues), toc(RT));
