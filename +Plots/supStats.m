function [ source parser params ] = supStats( source, varargin )
  %SUPSTATS Summary of this function goes here
  %   Detailed explanation goes here
  
  options.export      = {'none', {'png', 'mov', 'avi', 'eps'}};
  defaults.export     = {'none'};
  
  options.plotMode    = {'display', 'user', 'export'};
  defaults.plotMode   = {'display'};
  
  options.statMode    = {'sheet', 'axial', 'circumferential', 'region', 'zone', 'zoneband', 'regions', 'zones', 'pages'};
  defaults.statMode   = {'regions'};
  
  options.mode        = {options.plotMode{:},options.statMode{:}};
  defaults.mode       = {defaults.plotMode{:},defaults.statMode{:}};
  
  defaults.patchSet   = 100;
  
  reparsingParams     = any(strcmpi(class(source),{'inputParser','grasppeParser'}));
  
  if reparsingParams  % strcmpi(class(source),'inputParser')
    parser = source.createCopy;
    inputParams = source.Results;
    parser.parse(inputParams.dataSource, varargin{:});
  else
    parser = grasppeParser;
    
    %% Parameters: Data
    parser.addRequired('dataSource', @(x) ischar(x) | isstruct(x));
    
    parser.addOptional('dataPatchSet', [], ...
      @(x) (isempty(x) || (isnumeric(x) && x>=-100 && x<=100)) ...
      && numel(x)<=1);
    
    parser.addOptional('export', defaults.export, ...
      @(x) stropt(x, options.export));
    
    parser.addOptional('mode', defaults.mode, ...
      @(x) stropt(x, options.mode));
    
    parser.parse(source, varargin{:});
    inputParams = parser.Results;
    
    %% Parameters: Exporting
    parser.addParamValue('exportShots', false, @(x) isValid(x,'logical'));  ...
      parser.addParamValue('exportPNG', false, @(x) isValid(x,'logical'));  ...
      parser.addParamValue('exportEPS', false, @(x) isValid(x,'logical'));
    
    parser.addParamValue('exportVideo', false, @(x) isValid(x,'logical'));  ...
      parser.addParamValue('exportMOV', false, @(x) isValid(x,'logical'));  ...
      parser.addParamValue('exportAVI', false, @(x) isValid(x,'logical'));
    
    %% Parameters: Data Processing
    parser.addParamValue('dataSourceName', [], @(x) isempty(x) || ischar(x));
    parser.addParamValue('dataLoading',     false, @(x) isValid(x,'logical'));
    
    parser.addParamValue('dataSet', [], @(x) isempty(x) || isstruct(x));
    parser.addParamValue('dataProcessing',  false, @(x) isValid(x,'logical'));
    
    
    %% Parameters: Plot
    parser.addParamValue('plotMode', defaults.plotMode, @(x)stropt(x, options.plotMode, 1));
    parser.addParamValue('statMode', defaults.statMode, @(x)stropt(x, options.statMode));
    
    parser.addParamValue('plotSummary', true, @(x) isValid(x,'logical'));
    
    parser.parse(source, varargin{:});
    
  end
  
  
  %% Settings: Exporting
  params = parser.Results;
  
  params.export = inputParams.export;
  
  params.exportPNG = stropt('png', params.export);
  params.exportEPS = stropt('eps', params.export);
  params.exportShots = params.exportPNG || params.exportEPS;
  
  params.exportMOV = stropt('mov', params.export);
  params.exportAVI = stropt('avi', params.export);
  params.exportVideo = params.exportMOV || params.exportAVI;
  
  
  
  %% Settings: Data Source
  
  params.dataLoading = false;
  if ischar(params.dataSource)
    if isempty(params.dataSourceName)
      params.dataSourceName = params.dataSource;
      params.dataLoading = true;
    elseif ~strcmpi(params.dataSource, params.dataSourceName)
      params.dataLoading = true;
    end
  end
  
  params.dataSource = loadSource( params.dataSource );
  
  %% Settings: Data Processsing
  
  if (~isVerified('params.dataSet.patchSet', params.dataPatchSet))
    if isempty(params.dataPatchSet)
      params.dataPatchSet = defaults.patchSet;
    end
    
    params.dataSet = struct( ...
      'sourceName', params.dataSourceName, ...
      'patchSet', params.dataPatchSet, ...
      'patchFilter', prepareSetFilter(params.dataSource, params.dataPatchSet), ...
      'data', [] ...
      );
  end
  
  if (isempty(params.dataSet.data) || params.dataLoading)
    setCode = params.dataSet.patchSet;
    if (setCode<0 && setCode > -100)
      setCode = 200-setCode;
    end
    
    setVariable = genvarname([params.dataSourceName num2str(setCode, '%03.0f') ]);
    
    setStruct = Data.dataSources(setVariable);
        
    if (isempty(setStruct))    
      params.dataSet.data = Data.interpUPDataSet(params.dataSource, params.dataSet.patchFilter);
      Data.dataSources(setVariable, params.dataSet.data, true);
    else
      params.dataSet.data = setStruct;
    end
    
  end
  
  %% Settings: Plot
  
  
  
  %% End of Parameters/Settings Parsing
  parser.parse(params.dataSource, params);
  params = parser.Results;
  
  
  
end

function [ source ] = loadSource( source )
  source = Data.loadUPData(source);
end

function [ source ] = prepareUniformityData( source )
  
end

function [ patchSet ] = prepareSetFilter( source, patchValue )
  patchSet = source.sampling.PatchMap == patchValue;
end


