function [ dataSource params parser ] = plotUPStats( dataSource, varargin )
  %SUPSTATS Summary of this function goes here
  %   Detailed explanation goes here
  
  %% Defaults
  
  options.exportMode  = {'none', {'png', 'mov', 'avi', 'eps'}};
  defaults.exportMode = {'none'};
  
  options.plotMode    = {'display', 'user', 'export'};
  defaults.plotMode   = {'display'};
  
  options.statMode    = {'sheet', 'axial', 'circumferential', 'region', 'zone', 'zoneband', 'regions', 'zones', 'pages'};
  defaults.statMode   = {'regions'};
  
  options.mode        = {options.plotMode{:},options.statMode{:}};
  defaults.mode       = {defaults.plotMode{:},defaults.statMode{:}};
  
  defaults.patchSet   = 100;
  
  
  %% Exceptions
  
  ExIdent = 'Grasppe:UniPrint:InterpUPDataSet';
  
  sourceException = MException([ExIdent ':InvalidDataSource'], ...
    'A valid data source was not specified.');
  
  colorException = MException([ExIdent ':InvalidDataColorimetry'], ...
    'Unable to process the specified source coloriemtry.');
  
  tablesException = MException([ExIdent ':InvalidDataTables'], ...
    'Unable to process the specified source tables.');
  
  filterException = MException([ExIdent ':InvalidFilter'    ], ...
    ['A valid filter was not specified.\n' ...
    'Valid filters may be specified using tone value or case-senstive fieldname for a valid dataSource mask, or, a logical filter matrix.']);
  
  %% Paramters
  
  reparsingParams     = any(strcmpi(class(dataSource),{'inputParser','grasppeParser'}));
  
  if (reparsingParams )

    parser = dataSource.createCopy;
    parser.parse(dataSource.Results.dataSource, varargin{:}); % inputParams = dataSource.Results;
    
  else
    
%     inputParams = [];
    
    parser  = getInputParser(options, defaults);
    optargs = {};
    
    if (isValid('=varargin{1}','struct') && ~isVerified('varargin{1}.tables'))
      inputParams = varargin{1};
      optargs = varargin(2:end);
    end
    
    if (isValid('=varargin{1}','double') && isValid('=varargin{2}','struct') && ~isVerified('varargin{2}.tables'))
      inputParams = varargin{2};
      inputParams.dataPatchSet = varargin{1};
      optargs = varargin(3:end);
    end
    
    if (isValid('=inputParams','struct'))
      if ischar(dataSource)
        inputParams = deleteFields(inputParams, 'dataSource', 'dataSourceName');
      else
        dataSource = inputParams.dataSource;
      end
      
      parser.parse(dataSource, inputParams, optargs{:});
    else
      parser.parse(dataSource, varargin{:});
    end
    
  end
  
	inputParams = parser.Results;
  params = inputParams;
  dataSource = inputParams.dataSource;
  
  %% Settings: Exporting
  
  params = parseExportParameters(params);
  
  %% Settings: Data Source
  
  params.dataLoading = false;
  if ischar(dataSource)
    if isempty(params.dataSourceName)
      params.dataSourceName = dataSource;
      params.dataLoading = true;
    elseif ~strcmpi(dataSource, params.dataSourceName)
      params.dataLoading = true;
    end
  end
  
  dataSource                = loadSource( dataSource );
  params.dataSourceName     = dataSource.name;
  
%   dataSource = params.dataSource;

  %% Settings: Data Filtering & Processsing
  
  if (params.dataLoading || ~isVerified('params.dataSet.patchSet', params.dataPatchSet))
    
    when(isempty(params.dataPatchSet),    'params.dataPatchSet = defaults.patchSet');
    when(isempty(params.dataSourceName),  'params.dataSourceName = dataSource.name');
    
    params.dataSet = struct( 'sourceName', params.dataSourceName, ...
      'patchSet', params.dataPatchSet, 'setLabel', ['tv' int2str(params.dataPatchSet) 'data'], ...
      'patchFilter', [], 'data', [] );
    
    opt dataSource.sets = deleteFields(dataSource.sets, );
  end
  
%   when (isempty(params.dataSet.data), ...
%     'params.dataSet = Data.filterUPDataSet(dataSource, params.dataSet)');
  when (isempty(params.dataSet.data), ...
    'params.dataSet = Data.filterUPDataSet(dataSource, params.dataSet)');

  
  dataSet = params.dataSet;
  
  %% Settings: Statistics
  
  if(~isVerified('dataSource.sampling.regions'))
    dataSource = Metrics.generateUPRegions(dataSource);
    deleteFields(dataSource, 'statistics', 'plotting');
  end
  
  if(~isVerified('dataSource.statistics'))
    dataSource = Stats.generateUPStats(dataSource, dataSet);
    deleteFields(dataSource, 'plotting');
  end
  
  %% Settings: Plot
  
  if(~isVerified('dataSource.data'))
    dataSource = Stats.mergeUPRegions(dataSource, dataSet);
  end
  
  %% Plotting: Prepare Figure Window
  
   
  
  
  %% End of Parameters/Settings Parsing
  params.dataSource = dataSource;
  parser.parse(params.dataSource, params);
  params = parser.Results;
  
end


function [ source ] = loadSource( source )
  source = Data.loadUPData(source);
end

function [ source ] = prepareUniformityData( source )
  
end

function [params] = parseExportParameters(params)
  
  try
    paramsExport = params.export;
  catch err
    paramsExport = '';
  end
  
  if ~isempty(paramsExport) && ~strcmpi(paramsExport,'none')
      params.exportPNG = stropt('png', paramsExport);
      params.exportEPS = stropt('eps', paramsExport);
      params.exportMOV = stropt('mov', paramsExport);
      params.exportAVI = stropt('avi', paramsExport);
  end
  
  params.exportShots = opt('params.exportPNG | params.exportEPS');  
  params.exportVideo = opt('params.exportMOV | params.exportAVI');
  
  params.export = '';
  
  [exportFields exportTokens] = regexp(fieldnames(params),'^export([A-Z]+)$', 'match', 'tokens');
  
  exportString = '';
  for f = 1:numel(exportFields)
    exportField = exportFields{f};  exportToken = exportTokens{f};
    try
      if (isVerified('params.(char(exportField))', true))
        exportString = [exportString ' ' lower(char(exportToken{:}))];
      end
    catch err
      warning(err.identifier, err. message);
    end
  end
  exportString = strtrim(regexprep(exportString,'(\s*)(\w+)(\s*)','$2 '));
  
  if isempty(exportString)
    exportString = 'none';
  end
  
  params.exportMode = exportString;
end


function [parser] = getInputParser(options, defaults)
    parser = grasppeParser;
    
    parser.StructExpand = true;
    parser.KeepUnmatched = true;
    
    %% Parameters: Essential Parameters
    parser.addRequired('dataSource', @(x) ischar(x) | isstruct(x));
    
    parser.addOptional('dataPatchSet', [], ...
      @(x) (isempty(x) || (isnumeric(x) && x>=-100 && x<=100)) ...
      && numel(x)<=1);
    
    parser.addOptional('export', defaults.exportMode, ...
      @(x) (isempty(x) || stropt(x, options.exportMode)));
    
    parser.addOptional('mode', defaults.mode, ...
      @(x) stropt(x, options.mode));
    
    %% Parameters: Exporting
    parser.addParamValue('exportMode', defaults.exportMode, ...
      @(x) (isempty(x) || stropt(x, options.exportMode)));
    
    parser.addParamValue('exportShots', false, @(x) isempty(x) || isValid(x,'logical'));  ...
      parser.addParamValue('exportPNG', [], @(x) isempty(x) || isValid(x,'logical'));  ...
      parser.addParamValue('exportEPS', [], @(x) isempty(x) || isValid(x,'logical'));
    
    parser.addParamValue('exportVideo', false, @(x) isempty(x) || isValid(x,'logical'));  ...
      parser.addParamValue('exportMOV', [], @(x) isempty(x) || isValid(x,'logical'));  ...
      parser.addParamValue('exportAVI', [], @(x) isempty(x) || isValid(x,'logical'));
    
    %% Parameters: Data Filtering & Processsing
    parser.addParamValue('dataSourceName', [], @(x) isempty(x) || ischar(x));
    parser.addParamValue('dataLoading',     false, @(x) isValid(x,'logical'));
    
    parser.addParamValue('dataSet', [], @(x) isempty(x) || isstruct(x));
    parser.addParamValue('dataProcessing',  false, @(x) isValid(x,'logical'));
    
    
    %% Parameters: Plot
    parser.addParamValue('plotMode', defaults.plotMode, @(x)stropt(x, options.plotMode, 1));
    parser.addParamValue('statMode', defaults.statMode, @(x)stropt(x, options.statMode));
    
    parser.addParamValue('plotSummary', true, @(x) isValid(x,'logical'));
  
end
