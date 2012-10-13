cleardebug; cleardebug; clc;
DS.PersistentSources('clear');

global debugmode; debugmode=false;

testing     = false;

RT = tic;

SourceIDs   = {'ritsm7402a', 'ritsm7402b', 'ritsm7402c', 'rithp7k01', 'rithp5501'}; %, 'rithp5501', 'rithp7k01',  'ritsm7402c'};
PatchValues = [100 75 50 25 0]; %fliplr([0 25 50 75 100]); %  [100];
nplots      = 0;

if testing
  SourceIDs = SourceIDs([1 4]);
end

sourceIDs = SourceIDs;

statsMode = 'Mean'; % 'PeakMeans';

for source = sourceIDs
  for p = 1:numel(PatchValues)
    setID = PatchValues(p);
    
    T = tic; fprintf(1,'Preparing plot figure... ');
    m = Grasppe.PrintUniformity.UI.UniformityPlotMediator({'New Regions'}, ...
      {'CaseID', char(source), 'StatsMode', statsMode, 'SetID', setID, 'SheetID', 0}); %, 'Surface' ([], {'CaseID', 'ritsm7402a'});
    
    m.PlotFigure.handleSet('Position', [0 0 800*1 1200*1]);
    
    toc(T);
    
    while ~isequal(m.DataSources{1}.SetID, setID)
      dispf('\t\tChangeSet: %s\tCaseID: %s\tSetID: %d\tSheetID: %d', ...
        char(m.DataSources{1}.Reader.State), m.DataSources{1}.CaseID, m.DataSources{1}.SetID, m.DataSources{1}.SheetID);
      m.DataSources{1}.SetID = setID;
      m.DataSources{1}.ProcessSetData;
      m.DataSources{1}.ProcessVariableData;
      m.DataSources{1}.optimizeSetLimits;
      pause(5);
    end
    
    while ~isequal(m.DataSources{1}.SheetID, 0) %m.DataSources{1}.Reader.State, Grasppe.PrintUniformity.Data.ReaderStates.SheetReady)
      dispf('\t\tChangeSheet: %s\tCaseID: %s\tSetID: %d\tSheetID: %d', ...
        char(m.DataSources{1}.Reader.State), m.DataSources{1}.CaseID, m.DataSources{1}.SetID, m.DataSources{1}.SheetID);
      m.DataSources{1}.SheetID = 0;
      pause(5);
    end
    
    dispf('\t\tReady: %s\tCaseID: %s\tSetID: %d\tSheetID: %d', ...
      char(m.DataSources{1}.Reader.State), m.DataSources{1}.CaseID, m.DataSources{1}.SetID, m.DataSources{1}.SheetID);
    
    T = tic; fprintf(1,'\t\t\tExporting %s summary plot... ', m.PlotFigure.Title); % char(source), setID); %d%%
    
    m.PlotFigure.Export;
    movefile(fullfile('Output','export.pdf'), fullfile('Output', sprintf('Plots - %s - %03.0f.pdf', char(source), setID)));
    toc(T);
    nplots = nplots+1;
    
    pause(2);
    
    try delete(m); end
  end
end

try evalin('base', 'Grasppe.Core.Prototype.ClearPrototypes'); end

dispf('Finished exporting %d plots for %d sets in %d cases... Total time %1f seconds.', ...
  nplots, numel(PatchValues), numel(SourceIDs), toc(RT));
