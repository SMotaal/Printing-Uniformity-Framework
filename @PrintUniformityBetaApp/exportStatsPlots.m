cleardebug; cleardebug; clc;
try evalin('base', 'GrasppeAlpha.Core.Prototype.ClearPrototypes'); end
% DS.PersistentSources('clear');

global debugmode; debugmode=false;

testing                     = false;
%exportPath                  = fullfile('Output');
exportFileName              = 'export.pdf';
%exportFilePath              = fullfile('Output','export.pdf');

outputFolder                = fullfile('Output', ['Stats-' datestr(now, 'yymmdd')]);
FS.mkDir(outputFolder);

RT                          = tic;

CaseIDs                     = {'L1', 'L2', 'L3', 'X1', 'X2'};
SetIDs                      = [100 75 50 25 0]; %fliplr([0 25 50 75 100]); %  [100];
VariableIDs                 = {'Inaccuracy', 'Imprecision'};
nplots                      = 0;

if testing
  CaseIDs                   = CaseIDs([4 1]);
  SetIDs                    = SetIDs([1]); % 3]);
  VariableIDs               = VariableIDs(1:2);
end

T                           = tic;
disp('Preparing StatsPlotMediator');

m                           = PrintUniformityBeta.UI.StatsPlotMediator([], ...
  {'CaseID', char(CaseIDs{1}), 'SetID', SetIDs(1), 'SheetID', 0, 'VariableID', VariableIDs{1}}); % 'StatsMode', statsMode,  'Surface' ([], {'CaseID', 'ritsm7402a'});

d                           = m.DataSources{1};
f                           = m.PlotFigure;

f.handleSet('Position', [0 0 800 600]);

toc(T);

caseIDs                     = unique([d.CaseID CaseIDs], 'stable');

for c = 1:numel(caseIDs);
  caseID                    = char(caseIDs{c});
  
  if ~isequal(d.CaseID, caseID)
    dispf('\tChange Case: \tCase: %s', caseID);
    %d.CaseID                = caseID;
    d.setParameter('case', caseID, true);
  end
    
  setIDs                    = unique([d.SetID SetIDs], 'stable');
  
  for s = 1:numel(setIDs)
    setID                   = setIDs(s);
    
    if ~isequal(d.SetID, setID)
      dispf('\t\tChange Set: \tCase: %s\tSet: %d', caseID, setID);
      % d.SetID               = setID;
      d.setParameter('set', setID, true);
    end
    
    
    variableIDs             = unique([d.VariableID VariableIDs], 'stable');
    for v = 1:numel(variableIDs)
      variableID            = char(variableIDs{v});
      
      if ~isequal(d.VariableID, variableID)
        dispf('\t\t\tChange Variable: \tCase: %s\tSet: %d\tVariable: %s', caseID, setID, variableID);
        d.setParameter('variable', variableID, true);
      end
      
      d.setParameter('sheet', 1, true);
      d.setParameter('sheet', 0, true);
                  
      try f.OnResize(); end
      try d.resetColorMap; end
      try d.resetAxesLimits; end
      try 
        p = getappdata(f.PlotAxes{1}, 'PlotComponent'); 
        p.updateLayout();
      end
      try f.ColorBar.createPatches; end
      try f.ColorBar.createLabels; end
      %try delete(f.ColorBar); end
            
      drawnow;
      

      caseFolder            = fullfile(outputFolder, d.CaseData.ID);
      

      plotsFolder           = fullfile(caseFolder, 'Plots');
      FS.mkDir(plotsFolder);
      
      fileName              = sprintf('Stats Plot - %s - TV%03.0f - %s.pdf', caseID, setID, variableID);      
      
      % if ~exist(exportPath ,'dir')>0,  mkdir(exportPath); end
      
      exportFilePath        = f.Export(exportFileName);
      
      movefile(exportFilePath, fullfile(plotsFolder, fileName));
      toc(T);
      nplots = nplots+1;
      
    end
    
  end

end

dispf('Finished exporting %d plots for %d sets in %d cases... Total time %1f seconds.', ...
  nplots, numel(SetIDs), numel(CaseIDs), toc(RT));
