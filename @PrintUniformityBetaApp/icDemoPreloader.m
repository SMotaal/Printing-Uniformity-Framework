%% Global Check

% global SOURCEPATH SETMETRICS REGIONSETDATA CACHELOADED;

%% Cleanup

cleardebug;

% if ~exist('SOURCEPATH',     'var'), SOURCEPATH    = [];     end
% if ~exist('CACHELOADED',    'var'), CACHELOADED   = false;  end
% if ~exist('SETMETRICS',     'var'), SETMETRICS    = [];     end
% if ~exist('REGIONSETDATA',  'var'), REGIONSETDATA = [];     end


% dispf('%s:\t', toString(SOURCEPATH));
% dispf('%s:\t', toString(CACHELOADED));
% dispf('%s:\t', toString(SETMETRICS));
% dispf('%s:\t', toString(REGIONSETDATA));

%% Pre-Cache

% if ~isequal(CACHELOADED, true)
%   ICPrereader         = PrintUniformityBeta.Data.StatsPlotDataSource();
%   ICPrereader.testPerformance();
%   CACHELOADED         = true;
% end

ICMap                 = containers.Map();

% %% X1 X1
% ICMap('X1X1')         = PrintUniformityBeta.UI.StatsPlotMediator([], ...
%   {'CaseID', 'X1', 'SetID', 100, 'VariableID', 'Inaccuracy'}, ...
%   {'CaseID', 'X1', 'SetID', 100, 'VariableID', 'Imprecision'});
% 
% % show.Map('X1X1').showFigure
% ICX1X1                = ICMap('X1X1');

% %% X1 X2
% ICMap('X1X2')         = PrintUniformityBeta.UI.StatsPlotMediator([], ...
%   {'CaseID', 'X2', 'SetID', 100, 'VariableID', 'Inaccuracy'}, ...
%   {'CaseID', 'X1', 'SetID', 100, 'VariableID', 'Inaccuracy'});
% 
% % show.Map('X1X2').showFigure;
% ICX1X2                = ICMap('X1X2');

% %% X1 L1
% ICMap('X1L1')         = PrintUniformityBeta.UI.StatsPlotMediator([], ...
%   {'CaseID', 'L1', 'SetID', 100, 'VariableID', 'Imprecision'}, ...
%   {'CaseID', 'X1', 'SetID', 100, 'VariableID', 'Imprecision'});
% 
% % show.Map('X1L1').showFigure;
% ICX1L1                = ICMap('X1L1');

%% L1
ICMap('L1')           = PrintUniformityBeta.UI.StatsPlotMediator([], ...
  {'CaseID', 'L1', 'SetID', 100, 'VariableID', 'Imprecision'}, ...
  {'CaseID', 'L1', 'SetID', 75, 'VariableID', 'Imprecision'}, ...
  {'CaseID', 'L1', 'SetID', 50, 'VariableID', 'Imprecision'}, ...
  {'CaseID', 'L1', 'SetID', 25, 'VariableID', 'Imprecision'});

ICL1                  = ICMap('L1');

% %% X1
% ICMap('X1')           = PrintUniformityBeta.UI.StatsPlotMediator([], ...
%   {'CaseID', 'X1', 'SetID', 100, 'VariableID', 'Imprecision'}, ...
%   {'CaseID', 'X1', 'SetID', 75, 'VariableID', 'Imprecision'}, ...
%   {'CaseID', 'X1', 'SetID', 50, 'VariableID', 'Imprecision'}, ...
%   {'CaseID', 'X1', 'SetID', 25, 'VariableID', 'Imprecision'});
% 
% % show.Map('L1All').showFigure;
% ICX1                  = ICMap('X1');

% ICList                = {'showX1X1', 'showX1X2', 'showX1L1', 'showL1'};
