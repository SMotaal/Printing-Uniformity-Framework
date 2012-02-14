function [ data ] = dataSources( sourceName, varargin )
  %DATASOURCES store & retrieve presistent variables by ID
  %   To facilitate the process of working with hugh data variables loaded
  %   from disk, dataSources can be used to store and retrieve the variable
  %   data using a source identifier string (sourceName). To store a
  %   variable, include both the source name and the data arguments in the
  %   call. To retrieve a variable, include only the source name. This will
  %   return the data associated with the identifier. Non-existant
  %   variables will return empty matrix ([]) and
  
  persistent sources verbose sizeLimit;
  
  defaults.verbose=false;
  defaults.sizeLimit=256; % defaults.sizeLimit =  200 * (2^20);
  
  default('verbose', int2str(defaults.verbose));
  default('sizeLimit', int2str(defaults.sizeLimit));
  
  if (~exist('sourceName', 'var'))
    %     disp(whos('sources'));
    sourcesDetails = whos('sources');
    if isstruct(sources) && ~isempty(sources)
      sourcesDetails.elements = numel(fieldnames(sources));
      sourcesDetails.names = strtrim(reshape(char(strcat(fieldnames(sources),{' '}))',[],1)');%char(fieldnames(sources));
      sourcesDetails.names = regexprep(sourcesDetails.names,'\s+',' ');
    end
    data = sourcesDetails;
    if (nargout==0)
      disp(sourcesDetails);
    end
    return;
  end
  
  parser = grasppeParser;
  
  %% Parameters
  parser.addRequired('name',              @(x) isempty(x) || ischar(x) | isstruct(x));
  
  preCondition = ~isempty(sourceName) || isempty(varargin);
  
  parser.addConditional(preCondition, 'data',      [],     @(x) true);
  parser.addConditional(preCondition, 'protected', false,  @(x) isValid(x,'logical'));
  parser.addConditional(preCondition, 'space',     '',     @(x) ischar(x));
  
  parser.addParamValue('verbose',     [],     @(x) isempty(x) || isValid(x,'logical') || strcmpi(x,'reset'));
  parser.addParamValue('sizeLimit',   [],     @(x) isempty(x) || isValid(x,'double')  || strcmpi(x,'reset'));
  
  parser.parse(sourceName, varargin{:});
  
  inputParams = parser.Results;
  
  if ~isempty(inputParams.verbose)
    if strcmpi(inputParams.verbose,'reset')
      verbose = defaults.verbose;
      inputParams.verbose = verbose;
    else
      verbose   = inputParams.verbose;
    end
    warning('Grasppe:DataSources:Preferences', 'DataSources verbose mode: %i\n', verbose);
  end
  
  if ~isempty(inputParams.sizeLimit)
    if strcmpi(inputParams.sizeLimit,'reset')
      sizeLimit = defaults.sizeLimit;
      inputParams.sizeLimit = sizeLimit;
    else
      sizeLimit   = inputParams.sizeLimit;
    end    
    warning('Grasppe:DataSources:Preferences', 'DataSources size limit: %5.2f MB\n', sizeLimit);
  end
  
  if isempty(inputParams.name)
    return;
  end
  
  inputParams.name = genvarname(inputParams.name);
  
  if (isempty(inputParams.space))
    inputParams.space = 'base';
  else
    inputParams.space = genvarname(inputParams.space);
  end
  
  space = inputParams.space;
  
  
  if (~isempty(inputParams.data))
    %% Set source data
    source = inputParams;
    source.added = now;
    source.lastCall = now;
    source.calls = 0;
    sources.(source.name) = source;
  else
    if (numel(varargin)==1)
      %% Remove variable if data is empty
      try
        sources = rmfield(sources,inputParams.name);
      catch err
      end
      source = [];
      data = [];
      return;
    else
      %% Get source data
      try
        source = sources.(inputParams.name);
      catch err
        source = [];
        data = [];
      end
      
      if (~isempty(source))
        data = source.data;
        
        source.calls = source.calls + 1;
        source.lastCall = now;
        
        sources.(source.name) = source;
      end
      
    end
  end
  
  
  sourcesDetails = whos('sources');
  sourcesSize = sourcesDetails.bytes/2^20;
  
  while (sourcesSize > sizeLimit)
    sourcesFields = fieldnames(sources);
    
    nFields = numel(sourcesFields);
    
    sourcesStamps = zeros(nFields,1);
    
    for f = 1:nFields
      field = char(sourcesFields{f});
      fieldSource = sources.(field);
      if (~fieldSource.protected)
        sourcesStamps(f) = sources.(field).lastCall;
      else
        sourcesStamps(f) = NaN;
      end
    end
    
    [B, I] = sort(sourcesStamps);
    
    I = I;
    
    bufferWarning = 'Buffered data exceeding memory limit (%5.2f / %5.2f MB)';
    
    try
      fieldName = sourcesFields{I(1)};      
      if isnan(B(I))
        error('Grasppe:DataSources:CollectingGarbageError', 'Cannot clear buffered %s since it is protected', fieldName);
      end
      sources = rmfield(sources,fieldName);
      if (verbose)
        warning('Grasppe:DataSources:CollectingGarbage', [bufferWarning ...
          '. %s data was cleared to free up memory for %s.\n'], sourcesSize, sizeLimit, fieldName, inputParams.name);
      end
    catch err
      if (verbose)
        warning('Grasppe:DataSources:CollectingGarbage', [bufferWarning ...
          '. No unprotected data to clear while adding %s!\n'], sourcesSize, sizeLimit, inputParams.name);
      end
      return;
    end
    sourcesDetails = whos('sources');
    sourcesSize = sourcesDetails.bytes/2^20;
  end
  
end

