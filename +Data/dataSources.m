function [ data ] = dataSources( sourceName, varargin )
  %DATASOURCES store & retrieve presistent variables by ID
  %   To facilitate the process of working with hugh data variables loaded
  %   from disk, dataSources can be used to store and retrieve the variable
  %   data using a source identifier string (sourceName). To store a
  %   variable, include both the source name and the data arguments in the
  %   call. To retrieve a variable, include only the source name. This will
  %   return the data associated with the identifier. Non-existant
  %   variables will return empty matrix ([]) and
  
  persistent verbose sizeLimit;
  
  %   mlock;
  try
    sources = PersistentSources('dataSources');
    %     disp(sources);
  catch
    sources = [];
  end
  %   onCleanup(@() PersistentSources('dataSources', sources));
  
  defaults.verbose=false;
  defaults.sizeLimit=1024; % defaults.sizeLimit =  200 * (2^20);
  
  default('verbose', int2str(defaults.verbose));
  default('sizeLimit', int2str(defaults.sizeLimit));
  
  data = [];
  
  if (~exist('sourceName', 'var'))
    %     disp(whos('sources'));
    whosDetails = whos('sources');
    sourcesDetails.name = whosDetails.name;
    sourcesDetails.megabytes = whosDetails.bytes/2^20;
    
    if isstruct(sources) && ~isempty(sources)
      sourcesDetails.elements = numel(fieldnames(sources));
      sourcesDetails.names = strtrim(reshape(char(strcat(fieldnames(sources),{' '}))',[],1)');%char(fieldnames(sources));
      sourcesDetails.names = regexprep(sourcesDetails.names,'\s+',' ');
    else
      sourcesDetails.elements = 0;
      sourcesDetails.names = '';
    end
    data = sourcesDetails;
    if (nargout==0) && (numel(dbstack)>1)
      disp(sourcesDetails);
      try
        disp(sourcesDetails.names);
      end
    end
    return;
  else
    if ~isempty(sourceName)
      switch (lower(sourceName))
        case 'clear'
          PersistentSources('dataSources', []); % clear sources;
          return;
        case 'lock'
          mlock;
          return;
        case 'unlock'
          munlock;
          return;
        case 'reset'
          Data.dataSources([], 'verbose', 'reset', 'sizeLimit', 'reset');
          return;
        otherwise
      end
    else
      disp([]);
    end
  end
  
  parser = grasppeParser;
  
  %% Parameters
  parser.addRequired('name',              @(x) isempty(x) || ischar(x) | isstruct(x));
  
  preCondition = ~isempty(sourceName) || isempty(varargin);
  
  %   if nargout == 0
  parser.addConditional(preCondition && nargout==0, 'data',      [],     @(x) true);
  parser.addConditional(preCondition && nargout==0, 'protected', false,  @(x) isValid(x,'logical'));
  %   end
  parser.addConditional(preCondition || (isempty(sourceName) && nargin==2), 'space',     '',     @(x) ischar(x));
  
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
  
  if isempty(inputParams.name) && isempty(inputParams.space)
    return;
  end
  
  if (isempty(inputParams.space))
    inputParams.space = 'base';
    space = inputParams.space;
  else
    inputParams.space = upper(genvarname(inputParams.space));
    space = inputParams.space;
    
    spaceFilename     = datadir('Sources', [space '.mat']);
    
    spaces = [];
    try spaces = PersistentSources('dataSpaces'); end
    if isempty(spaces)
      spaces = struct();
    end
    
    spaceSources        = [];
    try spaceSources    = spaces.(space); end
    if isempty(spaceSources)
      try spaceSources  = load(spaceFilename); end
      spaces.(space) = spaceSources;
      PersistentSources('dataSpaces', spaces);
    end
    
    if isempty(inputParams.name)
      data = spaceSources;
      return;
    end
  end
  
  inputParams.name = genvarname(inputParams.name);
  
  hasChanged = false;
  if (~isempty(inputParams.data))
    %% Set source data
    source = inputParams;
    source.added = now;
    source.lastCall = now;
    source.calls = 0;
    
    hasChanged = true;
    if isequal(space, 'base')
      try hasChanged = ~isequal(sources.(source.name).data, source.data); end
      sources.(source.name) = source;       % if hasChanged
    else
      try hasChanged = ~isequal(spaceSources.(source.name).data, source.data); end
      spaceSources.(source.name) = source;  % if hasChanged
      %       saveSources.(source.name) = source;
      try
        save(spaceFilename, '-append', '-struct', 'spaceSources', source.name);
      catch
        try
          save(spaceFilename, '-struct', 'spaceSources', source.name);
        catch err
          if ~isequal(err.identifier, 'MATLAB:save:permissionDenied')
            halt(err, 'Data.dataSources');
          end
        end
      end
    end
    
  else
    if (numel(varargin)==1)
      if isempty(varargin{1})
      source = []; data = [];
      %% Remove variable if data is empty
      try
        if isequal(space, 'base')
          sources = rmfield(sources,inputParams.name);
          hasChanged = true;
        else
          spaceSources.(inputParams.name) = [];
          try
            save(spaceFilename, '-append', '-struct', 'spaceSources', inputParams.name);
          catch
            try
              save(spaceFilename, '-struct', 'spaceSources', inputParams.name);
            catch err
              if ~isequal(err.identifier, 'MATLAB:save:permissionDenied')
                halt(err, 'Data.dataSources');
              end
            end
          end
          spaceSources = rmfield(spaceSources, inputParams.name);
          hasChanged = true;
        end
      end
      
      else 
        source = [];  data = [];
        %% Get source data
        if isequal(space, 'base')
          try source = sources.(inputParams.name); end
        else
          try source = spaceSources.(inputParams.name); end
        end

        if (~isempty(source))
          data = source.data;

          source.calls = source.calls + 1;
          source.lastCall = now;

          if isequal(space, 'base')
            sources.(source.name) = source;
          else
            spaceSources.(source.name) = source;
          end
        end
      end
    end
  end
  
  
  if hasChanged
    if isequal(space, 'base')
      PersistentSources('dataSources', sources); return;
    else
      % try save(spaceFilename, '-struct', 'spaceSources'); end
      spaces.(space) = spaceSources;
      PersistentSources('dataSpaces', spaces);
    end
    
    return;
  end
  
  if ~isequal(space, 'base')
    return;
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
      PersistentSources('dataSources', sources); return;
    end
    sourcesDetails = whos('sources');
    sourcesSize = sourcesDetails.bytes/2^20;
  end
  PersistentSources('dataSources', sources); return;
  
end

