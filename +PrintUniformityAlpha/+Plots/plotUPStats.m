function [ dataSource dataSet params parser ] = plotUPStats( dataSource, varargin )
  %SUPSTATS Summary of this function goes here
  %   Detailed explanation goes here
  
  import PrintUniformityBeta.Utilities.*;
  
  %% Defaults
   
  options.exportMode  = {'none', {'png', 'mov', 'avi', 'eps'}};
  defaults.exportMode = {'none'};
  
  options.plotMode    = {'display', 'user', 'export'};
  defaults.plotMode   = {'display'};
  
  options.statMode    = {'complete', 'sheet', 'axial', 'across', 'circumferential', 'around', 'region', 'regions', 'section', 'sections', 'zone', 'zones', 'zoneband', 'zonebands', 'band', 'bands'};
  defaults.statMode   = {'regions'};
  
  options.statField   = {'all', {'mean', 'std', 'lim'}};
  defaults.statField  = {'all'};
  
%   options.rebuildData = {'none', {'filterData, setData, 
  
  options.mode        = {options.plotMode{:},options.statMode{:}, options.exportMode{2}{:}};
  defaults.mode       = {defaults.plotMode{:},defaults.statMode{:}, options.exportMode{2}{:}};
  
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
        
    parser  = getInputParser(options, defaults);
    optargs = {};
    
    if (validCheck('varargin{1}','struct') && isVerified('varargin{1}.plotMode'))
      inputParams = varargin{1};
    end
        
    if (validCheck('varargin{1}','double') && validCheck('varargin{2}','struct') && isVerified('varargin{2}.plotMode'))
      inputParams = varargin{2};
      inputParams.dataPatchSet = varargin{1};
      optargs = varargin(3:end);
    end
    
    if (validCheck('inputParams','struct'))
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
  dataSet = params.dataSet;
  
  %% Settings: Exporting
  
  params = parseModeParamters(params, options, defaults);
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

  %% Settings: Data Filtering & Processsing
  
  if (params.dataLoading || ~isVerified('dataSet.patchSet', params.dataPatchSet))
    
    when(isempty(params.dataPatchSet),    'params.dataPatchSet = defaults.patchSet');
    when(isempty(params.dataSourceName),  'params.dataSourceName = dataSource.name');
    
    dataSet = struct( 'sourceName', params.dataSourceName, ...
      'patchSet', params.dataPatchSet, 'setLabel', ['tv' int2str(params.dataPatchSet) 'data'], ...
      'patchFilter', [], 'data', [] );
    
    opt dataSource.sets = deleteFields(dataSource.sets, );
  end

  if (isempty(dataSet.data))
    dataSet = PrintUniformityAlpha.Data.filterUPDataSet(dataSource, dataSet);
    
    % Data.filterUPDataSet produces Column-First data!
    % imshow(reshape(dataSet.data(2).surfData, 76, 52)',[])
  end

  
  %% Settings: Statistics
  
  if(~isVerified('dataSource.sampling.regions'))
    dataSource = Metrics.generateUPRegions(dataSource);
    deleteFields(dataSource, 'statistics', 'plotting');
    
    % Metrics.generateUPRegions produces Row-First masks!
    % imshow(reshape(squeeze(dataSource.sampling.regions.sections(1,:,:))', 76, 52)',[])
  end
  
  % Data.filterUPDataSet produces Column-First data!
  % Metrics.generateUPRegions produces Row-First masks!
  
  if(~isVerified('dataSource.statistics'))
    dataSource = Stats.generateUPStats(dataSource, dataSet);
    deleteFields(dataSource, 'plotting');
    
    % End up with local stats variables for each mask
  end
  
  %% Settings: Plot
  
  dataSet = Stats.mergeUPRegions(dataSource, dataSet, params, options);
  
  %% Plotting: Prepare Figure Window
  
  
  
  
  %% End of Parameters/Settings Parsing
  params.dataSource = dataSource;
  params.dataSet    = dataSet;
  
%   parser.parse(params.dataSource, [], [] params);
%   params = parser.Results;
  
end


function [ source ] = loadSource( source )
  import PrintUniformityBeta.Utilities.*;
  
  source = Data.loadUPData(source);
end

function [ source ] = prepareUniformityData( source )
  import PrintUniformityBeta.Utilities.*;
end

function [params] = parseModeParamters(params, options, defaults)
  import PrintUniformityBeta.Utilities.*;
  
  try
    paramsMode = params.mode;
    modes = regexp(paramsMode,'\w+', 'match');
  catch err
    paramsMode = '';
    return;
  end
  
  statModes = options.statMode;
  plotModes = options.plotMode;
  exportModes = options.exportMode{2};
  
  [statMode plotMode exportMode] = deal({});
  
  
  for m = 1:numel(modes)
    mode = char(modes{m});
    if stropt(mode, statModes)
      statMode  = {statMode{:}, mode};
      continue;
    end
    if stropt(mode, plotModes)
      plotMode  = {plotMode{:}, mode};
      continue;
    end    
    if stropt(mode, exportModes)
      exportMode  = {exportMode{:}, mode};
      continue;
    end

  end
  
  if (~isempty(statMode))
    
    if stropt('complete', statMode)
      statModes = {'across', 'around', 'sections', 'zones', 'zonebands'};
    else
      modes = statMode;   statMode = {};
      if isa(modes, 'char'), modes = {modes}; end
      for s  = 1:numel(modes)
        switch lower(char(modes{1}))
          case {'axial', 'across'}
            region  = 'across';
          case {'circumferential', 'around'}
            region  = 'around';
          case {'region', 'regions', 'section', 'sections'}
            region  = 'sections';
          case {'zone', 'zones'}
            region  = 'across';
          case {'zoneband', 'zonebands', 'band', 'bands'}
            region  = 'zoneBands';
          otherwise
            region  = '';
        end
        if ~isempty(region)
          statMode{end+1} = region;
        end
      end
      
      statMode = unique(statMode);

    end
    
    params.statMode = statMode;
  end

  if (~isempty(plotMode))
    params.plotMode = plotMode;
  end
    
  if (~isempty(exportMode))
    params.exportMode = exportMode;
%   else
%     params.exportMode = 'none';
  end
  
  return;  
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
        
    parser.addOptional('mode', defaults.mode, ...
      @(x) stropt(x, options.mode));
    
%     parser.addOptional('export', defaults.exportMode, ...
%       @(x) (isempty(x) || stropt(x, options.exportMode)));    
    
    %% Parameters: Exporting
    parser.addParamValue('exportMode', defaults.exportMode, ...
      @(x) (isempty(x) || stropt(x, options.exportMode)));
    
    parser.addParamValue('exportShots', false, @(x) isempty(x) || validCheck(x,'logical'));  ...
      parser.addParamValue('exportPNG', [], @(x) isempty(x) || validCheck(x,'logical'));  ...
      parser.addParamValue('exportEPS', [], @(x) isempty(x) || validCheck(x,'logical'));
    
    parser.addParamValue('exportVideo', false, @(x) isempty(x) || validCheck(x,'logical'));  ...
      parser.addParamValue('exportMOV', [], @(x) isempty(x) || validCheck(x,'logical'));  ...
      parser.addParamValue('exportAVI', [], @(x) isempty(x) || validCheck(x,'logical'));
    
    %% Parameters: Data Filtering & Processsing
    parser.addParamValue('dataSourceName', [], @(x) isempty(x) || ischar(x));
    parser.addParamValue('dataLoading',     false, @(x) validCheck(x,'logical'));
    
    parser.addParamValue('dataSet', [], @(x) isempty(x) || isstruct(x));
    parser.addParamValue('dataProcessing',  false, @(x) validCheck(x,'logical'));
    
    
    %% Parameters: Plot
    parser.addParamValue('plotMode',  defaults.plotMode,  @(x)stropt(x, options.plotMode,   1));
    parser.addParamValue('statMode',  defaults.statMode,  @(x)stropt(x, options.statMode     ));
    parser.addParamValue('statField', defaults.statField, @(x)stropt(x, options.statField    ));
    
    parser.addParamValue('plotSummary', true, @(x) validCheck(x,'logical'));
    
    return;
  
end
