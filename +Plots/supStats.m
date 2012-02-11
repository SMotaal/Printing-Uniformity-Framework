function [ source parser ] = supStats( source, varargin )
  %SUPSTATS Summary of this function goes here
  %   Detailed explanation goes here
  
  options.export      = {'none', {'png', 'mov', 'avi', 'eps'}};
  defaults.export     = {'none'};
  
  options.plotMode    = {'display', 'user', 'export'};
  defaults.plotMode   = {'display'};
  
  options.plotType    = {'sheet', 'axial', 'circumferential', 'region', 'zone', 'zoneband', 'regions', 'zones', 'pages'};
  defaults.plotType   = {'regions'};
  
  options.plot        = {options.plotMode{:},options.plotType{:}};
  defaults.plot       = {defaults.plotMode{:},defaults.plotType{:}};
  
  reparsingParams = strcmpi(class(source),'inputParser');
  
  if reparsingParams  % strcmpi(class(source),'inputParser')
    parser = source.createCopy;
    inputParams = source.Results;
    parser.parse(inputParams.dataSource, varargin{:});
  else
    parser = inputParser;
    
    %% Parameters: Data
    parser.addRequired('dataSource', @(x) ischar(x) | isstruct(x));
    
    parser.addOptional('dataPatchSet', [], ...
      @(x) (isempty(x) || (isnumeric(x) && x>=-100 && x<=100)) ...
      && numel(x)<=1);
    
    parser.addOptional('export', defaults.export, ...
      @(x) stropt(x, options.export));
    
    parser.addOptional('plot', defaults.plot, ...
      @(x) stropt(x, options.plot));
    
    parser.parse(source, varargin{:});
    inputParams = parser.Results;
    
    %% Parameters: Exporting
    parser.addParamValue('exportShots', false, @(x) isValid(x,'logical'));  ...
      parser.addParamValue('exportPNG', false, @(x) isValid(x,'logical'));  ...
      parser.addParamValue('exportEPS', false, @(x) isValid(x,'logical'));
    
    parser.addParamValue('exportVideo', false, @(x) isValid(x,'logical'));  ...
      parser.addParamValue('exportMOV', false, @(x) isValid(x,'logical'));  ...
      parser.addParamValue('exportAVI', false, @(x) isValid(x,'logical'));
    
    %% Parameters: Plot
    parser.addParamValue('plotMode', defaults.plotMode, @(x)stropt(x, options.plotMode, 1));
    parser.addParamValue('plotType', defaults.plotType, @(x)stropt(x, options.plotType));
    
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
  
  params.dataSource = loadSource( params.dataSource );
  
  %% End of Parameters/Settings Parsing
  parser.parse(params.dataSource, params);
  params = parser.Results
  
end

function [ source ] = loadSource( source )
  source = Data.loadUPData(source);
  %   if (ischar(source))
  %
  %     if (exist(source, 'file')>0)
  %       source = source;
  %     else
  %       source = datadir('uniprint',source);
  %     end
  %
  %     try
  %       contents = whos('-file', source);
  %     catch err
  %       error('UniPrint:Stats:Load:SourceNotFound', 'Source %s is not found.', source);
  %     end
  %
  %     try
  %       name        = contents.name;
  %       source      = getfield(load(source), name);
  % %       source      = source.(name);
  %       source.name = contents.name;
  %     catch err
  %       disp(err);
  %     end
  %
  %     assert(isVerified('source.sourceTicket.subject', 'Print Uniformity Research Data'), ...
  %       'UniPrint:Stats:InvalidSourceStructure', 'Source structure is invalid.');
  %
  %
  %     % %     assert( exist(source,'file')>0, ...
  %     % %       'UniPrint:Stats:Load:SourceNotFound', 'Source %s is not found.', source);
  %     %
  %     %     runName = whos('-file', supFilePath);
  %     %     runName = runName.name;
  %     %     stepTimer = tic; runlog(['Loading ' runName ' uniformity data ...']);
  %     %     supLoad(supFilePath); click roundActions;
  %     %     runlog(['\n', structTree(supMat.sourceTicket,2), '\n']);
  %     %     runlog([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
  %     %     newPatchValue = 100;
  %     %     clear source;
end


