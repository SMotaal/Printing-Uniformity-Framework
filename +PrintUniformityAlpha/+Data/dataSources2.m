function [ data ] = dataSources( sourceName, varargin )
  %DATASOURCES store & retrieve presistent variables by ID
  %   To facilitate the process of working with hugh data variables loaded
  %   from disk, dataSources can be used to store and retrieve the variable
  %   data using a source identifier string (sourceName). To store a
  %   variable, include both the source name and the data arguments in the
  %   call. To retrieve a variable, include only the source name. This will
  %   return the data associated with the identifier. Non-existant
  %   variables will return empty matrix ([]) and
  
  persistent verbose quota;
  
  %% Restore Persistent Source Data
  
  sources                       = [];
  try sources                   = DS.PersistentSources('dataSources'); end
  
  %% Declates and Defaults
  
  data                          = [];
  
  defaults.verbose              = true;                   % display debugging information
  defaults.quota                = 2^10;                   % 2^10==1024
  
  if isempty(verbose),  verbose = defaults.verbose; end   % default('verbose',    int2str(defaults.verbose)   );
  if isempty(quota),    quota   = defaults.quota;   end   % default('quota',  int2str(defaults.quota) );
  
  %% Display Data Sources Details
  if (~exist('sourceName', 'var')) % Refactored to GETSOURCEDETAILS
    displayDetails              = (nargout==0) && (numel(dbstack)>1);
    sourcesDetails              = getSourceDetails(sources, displayDetails);
    if displayDetails, data     = sourcesDetails; end
    return;
  end
  
  %% Dispatch Call Commands
  % clear, recycle, reset % lock, unlock
  if dispatchCall(sourceName, varargin), return; end
  
  %% Parse Arguments
  % name, data![out==0], protected![out==0], space![in==2], verbose?, quota?
  params                        = parseArguments(sourceName, nargout, varargin{:});
  
  %% Parse Verbose & Quota
  if ~isempty(params.verbose)
    if strcmpi(params.verbose,'reset')
      verbose                   = defaults.verbose;
      params.verbose            = verbose;
    else
      verbose                   = params.verbose;
    end
    warning('Grasppe:DataSources:Preferences', 'DataSources verbose mode: %i\n', verbose);
  end
  
  if ~isempty(params.quota)
    if strcmpi(params.quota,'reset')
      quota                     = defaults.quota;
      params.quota              = quota;
    else
      quota                     = params.quota;
    end
    warning('Grasppe:DataSources:Preferences', 'DataSources size limit: %5.2f MB\n', quota);
  end
  
  if isempty(params.name) && isempty(params.space), return; end
  
  %% Parse Space
  
  if (isempty(params.space))
    params.space                = 'base';
    space                       = params.space;
  else
    
    params.space                = upper(regexprep(params.space, '\W+', '_'));
    space                       = params.space;  % spaceFilename = FS.dataDir('Sources', [space '.mat']);
    
    spaces                      = [];
    try spaces                  = DS.PersistentSources('dataSpaces'); end
    
    if isempty(spaces), spaces  = struct(); end
    
    spaceSources                = [];
    try spaceSources            = spaces.(space); end
    
    if isempty(params.name), data = spaceSources; return; end;
    
  end % if isempty(inputParams.name) return; end
  
  %% Process Data
  
  params.name                   = regexprep(params.name, '\W+', '_');
  isChanged                     = false;
  isSetting                     = ~isempty(params.data);
  isClearing                    = ~isSetting && numel(varargin)==1 && isempty(varargin{1});
  isGetting                     = ~isSetting;
  
  if isSetting
    isChanged                   = setData(params,    sources,  spaceSources);
  elseif isClearing
    isChanged                   = clearData(params,  sources,  spaceSources);
  elseif isGetting
    [params data isChanged]     = getData(params,    sources,  spaceSources);
  end
  
  
  if isChanged
    if isequal(space, 'base')
      DS.PersistentSources('dataSources', sources); return;
    else
      % try save(spaceFilename, '-struct', 'spaceSources'); end
      spaces.(space)            = spaceSources;
      DS.PersistentSources('dataSpaces', spaces);
    end
    
    return;
  end
  
  if ~isequal(space, 'base')
    return;
  end
  
  sourcesDetails                = whos('sources');
  sourcesSize                   = sourcesDetails.bytes/2^20;
  
  while (sourcesSize > quota)
    sourcesFields               = fieldnames(sources);
    
    nFields                     = numel(sourcesFields);
    
    sourcesStamps               = zeros(nFields,1);
    
    for f = 1:nFields
      field = char(sourcesFields{f});
      fieldSource = sources.(field);
      if (~fieldSource.protected)
        sourcesStamps(f)        = sources.(field).lastCall;
      else
        sourcesStamps(f)        = NaN;
      end
    end
    
    [B, I]                      = sort(sourcesStamps);
    
    I = I;
    
    bufferWarning               = 'Buffered data exceeding memory limit (%5.2f / %5.2f MB)';
    
    try
      fieldName                 = sourcesFields{I(1)};
      
      if isnan(B(I))
        error('Grasppe:DataSources:GarbageCollection', 'Cannot clear buffered %s since it is protected', fieldName);
      end
      
      sources                   = rmfield(sources,fieldName);
      
      if (verbose)
        warning('Grasppe:DataSources:GarbageCollection', [bufferWarning ...
          '. %s data was cleared to free up memory for %s.\n'], sourcesSize, quota, fieldName, params.name);
      end
      
    catch err
      
      if (verbose)
        warning('Grasppe:DataSources:GarbageCollection', [bufferWarning ...
          '. No unprotected data to clear while adding %s!\n'], sourcesSize, quota, params.name);
      end
      
      DS.PersistentSources('dataSources', sources); return;
      
    end
    
    sourcesDetails              = whos('sources');
    sourcesSize                 = sourcesDetails.bytes/2^20;
  end
  
  DS.PersistentSources('dataSources', sources); % return;
  
end

function name = getSpaceFilename(space)
  name = FS.dataDir('Sources', [space '.mat']);
end

function data = loadSpaceData(space, name)
  
  data = [];
  spaceFilename = getSpaceFilename(space);
  s = warning('off', 'MATLAB:load:variableNotFound');
  try
    loadStruct = load(spaceFilename, '-mat', name);
    data = loadStruct.(name);
    if ~isempty(data)
      statusbar(0, sprintf('Loading %s:%s.', space, name));
    end
  end
  warning(s);
  
end

function saveSpaceData(space, name, data)
  
  saveStruct.(name) = data;
  
  spaceFilename = getSpaceFilename(space);
  %   dispf('Saving %s:%s.', space, name);
  try
    save(spaceFilename, '-append', '-struct', 'saveStruct', name);
    statusbar(0, sprintf('Appending %s:%s.', space, name));
    
    touchRecycleSpace(space) % recycleSpace(space);
  catch
    try
      save(spaceFilename, '-struct', 'saveStruct', name);
      statusbar(0, sprintf('Saving %s:%s.', space, name));
      touchRecycleSpace(space, false); %stop recycle timer for space % recycleSpace(space);
    catch err
      debugStamp(1);
      if ~isequal(err.identifier, 'MATLAB:save:permissionDenied')
        keyboard; % halt(err, 'Data.dataSources');
      end
    end
  end

end

function touchRecycleSpace(space, force)
  persistent timers
  
  if isempty(timers), timers  = struct(); end
  
  try stop(timers.(space)); end
  
  if nargin<2 || ~islogical(force), force = false; end
    
  if force
    try delete(timers.(space)); end
    try
      timers.(space)          = GrasppeKit.Utilities.DelayedCall(@(s, e) recycleSpace(space), 30, 'start');
      return;
    end 
    recycleSpace(space); % If all else fails!
  end
  
end

function recycleSpace(space)
  
  dispf('Recycling %s...', space);
  
  spaceFilename             = getSpaceFilename(space);
  
  s = load(spaceFilename, '-mat');
  save(spaceFilename, '-struct', 's');
  
end


function details = getSourceDetails(sources, displayDetails)
  
  whosDetails               = whos('sources');
  sourcesDetails.name       = whosDetails.name;
  sourcesDetails.megabytes  = whosDetails.bytes/2^20;
  
  if isstruct(sources) && ~isempty(sources)
    sourcesDetails.elements = numel(fieldnames(sources));
    sourcesDetails.names    = strtrim(reshape(char(strcat(fieldnames(sources),{' '}))',[],1)');%char(fieldnames(sources));
    sourcesDetails.names    = regexprep(sourcesDetails.names,'\s+',' ');
  else
    sourcesDetails.elements = 0;
    sourcesDetails.names    = '';
  end
  
  details                   = sourcesDetails;
  
  try
    if nargin>1 && isequal(displayDetails, true)
      disp(sourcesDetails);
      disp(sourcesDetails.names);
    end
  end
  
end

function consumed = dispatchCall(sourceName, varargin)
  consumed                  = false;
  
  try
    switch (lower(sourceName))
      case 'clear'
        DS.PersistentSources('dataSources', []);
        consumed            = true;
      case 'lock'
        debugStamp('LockingDataSources',    1);
        % mlock;
        consumed            = true;
      case 'unlock'
        debugStamp('UnlockingDataSources',  1);
        % munlock;
        consumed            = true;
      case 'recycle'
        recycleSpace(varargin{:});
        consumed            = true;
      case 'reset'
        Data.dataSources([], 'verbose', 'reset', 'quota', 'reset');
        consumed            = true;
      otherwise
        debugStamp('NotKeepingHouse',       1);
    end
  end
end

function params = parseArguments(sourceName, nout, varargin)
  
  try
    parser                    = grasppeParser;
    
    %% Parameters
    parser.addRequired('name', @(x) isempty(x) || ischar(x) || isstruct(x));
    
    preCondition              = ~isempty(sourceName) || isempty(varargin);
    
%     if preCondition && nargout==0
%       parser.addRequired('data',      [],     @(x) true);
%       parser.addRequired('protected', false,  @(x) validCheck(x,'logical'));
%     end
%     
%     if preCondition || (isempty(sourceName) && nargin==2)
%       parser.addRequired('space',     '',     @(x) ischar(x));
%     end
    preCondition = ~isempty(sourceName) || isempty(varargin);
    
    parser.addConditional(preCondition && nout==0, 'data',      [],     @(x) true);
    parser.addConditional(preCondition && nout==0, 'protected', false,  @(x) validCheck(x,'logical'));
    parser.addConditional(preCondition || (isempty(sourceName) && nargin==3), 'space',     '',     @(x) ischar(x));

    parser.addParamValue('verbose', [], @(x) isempty(x) || validCheck(x,'logical') || strcmpi(x,'reset'));
    parser.addParamValue('quota',   [], @(x) isempty(x) || validCheck(x,'double')  || strcmpi(x,'reset'));
    
    parser.parse(sourceName, varargin{:});
    
    params = parser.Results;
    
  catch err
    debugStamp(1);
  end
  
  
  %   % parser = grasppeParser;
  %   %
  %   % %% Parameters
  %   % parser.addRequired('name',              @(x) isempty(x) || ischar(x) || isstruct(x));
  %   %
  %   % preCondition = ~isempty(sourceName) || isempty(varargin);
  %   %
  %   % %   if nargout == 0
  %   % parser.addConditional(preCondition && nargout==0, 'data',      [],     @(x) true);
  %   % parser.addConditional(preCondition && nargout==0, 'protected', false,  @(x) validCheck(x,'logical'));
  %   % %   end
  %   % parser.addConditional(preCondition || (isempty(sourceName) && nargin==2), 'space',     '',     @(x) ischar(x));
  %   %
  %   % parser.addParamValue('verbose', [], @(x) isempty(x) || validCheck(x,'logical') || strcmpi(x,'reset'));
  %   % parser.addParamValue('quota',   [], @(x) isempty(x) || validCheck(x,'double')  || strcmpi(x,'reset'));
  %   %
  %   % parser.parse(sourceName, varargin{:});
  %   %
  %   % inputParams = parser.Results;
  
end

function [changed sources spaceData] = setData(source, sources, spaceData)
  
  try
    
    changed                 = false;
    if nargin<2,  sources   = evalin('caller', 'sources'); end
    if nargin<2,  spaceData = evalin('caller', 'spaceSources'); end
    
    %% Set source data
    % source = inputParams;
    source.added            = now;
    source.lastCall         = now;
    source.calls            = 0;
    
    changed                 = true;
    name                    = source.name;
    space                   = source.space;
    data                    = source.data;
    
    if isequal(space, 'base')
      try changed           = ~isequal(sources.(name).data, data); end
      sources.(name)        = source;
    else
      try changed           = ~isequal(spaceData.(name).data, data); end
      spaceData.(name)      = source;
      saveSpaceData(space, name, spaceData.(name).data);
    end
    
    if nargout<1, clear changed; end
    if nargout<2, assignin('caller',  'sources',      sources);   clear sources;    end
    if nargout<3, assignin('caller',  'spaceSources', spaceData); clear spaceData;  end

  catch err
    debugStamp(1);
  end
  
  %   % %% Set source data
  %   % source                  = inputParams;
  %   % source.added            = now;
  %   % source.lastCall         = now;
  %   % source.calls            = 0;
  %   %
  %   % isChanged = true;
  %   % if isequal(space, 'base')
  %   %   try isChanged = ~isequal(sources.(source.name).data, source.data); end
  %   %   sources.(source.name) = source;       % if isChanged
  %   % else
  %   %   try isChanged = ~isequal(spaceSources.(source.name).data, source.data); end
  %   %   spaceSources.(source.name) = source;  % if isChanged
  %   %   saveSpaceData(space, source.name, spaceSources.(source.name).data);
  %   % end
  
end

function [changed sources spaceData] = clearData(source, sources, spaceData)
  
  try
    
    changed                 = false;
    if nargin<2,  sources   = evalin('caller', 'sources'); end
    if nargin<2,  spaceData = evalin('caller', 'spaceSources'); end
    
    name                    = source.name;
    space                   = source.space;
    
    try
      if isequal(space, 'base')
        sources             = rmfield(sources,  name);
      else
        spaceData.(name)    = [];
        saveSpaceData(space, name, []);
        spaceData           = rmfield(spaceData, name);
      end
      changed               = true;
    end
    
    if nargout<1, clear changed; end
    if nargout<2, assignin('caller',  'sources',      sources);   clear sources;    end
    if nargout<3, assignin('caller',  'spaceSources', spaceData); clear spaceData;  end
    
  catch err
    debugStamp(1);
  end
  
  %   % if (numel(varargin)==1)
  %   %   if isempty(varargin{1})
  %   %     source = []; data = [];
  %   %     %% Remove variable if data is empty
  %   %     try
  %   %       if isequal(space, 'base')
  %   %         sources         = rmfield(sources,inputParams.name);
  %   %         isChanged      = true;
  %   %       else
  %   %         spaceSources.(inputParams.name) = [];
  %   %         saveSpaceData(space, inputParams.name, []);
  %   %         spaceSources = rmfield(spaceSources, inputParams.name);
  %   %         isChanged = true;
  %   %       end
  %   %     end

end

function [source data changed sources spaceData] = getData(source, sources, spaceData)
  
  try
    data                    = [];
    changed                 = false;
    if nargin<2,  sources   = evalin('caller', 'sources'); end
    if nargin<2,  spaceData = evalin('caller', 'spaceSources'); end
    
    name                    = source.name;
    space                   = source.space;
    
    if isequal(space, 'base')
      try source            = sources.(name); end
    else
      try source            = spaceData.(name);  end
      if isempty(source)
        source.added        = now;
        source.lastCall     = now;
        source.calls        = 0;
        source.data         = loadSpaceData(space, name);
      end
    end
    
    if (~isempty(source))
      data                  = source.data;
      
      source.calls          = source.calls + 1;
      source.lastCall       = now;
      
      if isequal(space, 'base')
        sources.(name)      = source;
      else
        spaceData.(name)    = source;
        changed             = true;
      end
    end
    
    if nargout<3, clear changed; end
    if nargout<4, assignin('caller',  'sources',      sources);   clear sources;    end
    if nargout<5, assignin('caller',  'spaceSources', spaceData); clear spaceData;  end
    
  catch err
    debugStamp(1);
  end
  
    %   if isempty(varargin{1}) ...
    %   else
    %     source = [];  data = [];
    %     %% Get source data
    %     if isequal(space, 'base')
    %       try source = sources.(inputParams.name); end
    %     else
    %       try source = spaceSources.(inputParams.name); end
    %       if isempty(source)
    %         source = inputParams;
    %         source.added = now;
    %         source.lastCall = now;
    %         source.calls = 0;
    %         source.data = loadSpaceData(space, inputParams.name);
    %       end
    %     end
    %
    %     if (~isempty(source))
    %       data = source.data;
    %
    %       source.calls = source.calls + 1;
    %       source.lastCall = now;
    %
    %       if isequal(space, 'base')
    %         sources.(source.name) = source;
    %       else
    %         spaceSources.(source.name) = source;
    %         isChanged = true;
    %       end
    %     end
    %   end
  
end


%% Clear Get Refactored
    % else
    % if (numel(varargin)==1)
    %   if isempty(varargin{1})
    %     source = []; data = [];
    %     %% Remove variable if data is empty
    %     try
    %       if isequal(space, 'base')
    %         sources         = rmfield(sources,inputParams.name);
    %         isChanged      = true;
    %       else
    %         spaceSources.(inputParams.name) = [];
    %         saveSpaceData(space, inputParams.name, []);
    %         spaceSources = rmfield(spaceSources, inputParams.name);
    %         isChanged = true;
    %       end
    %     end
    %
    %   else
    %     source = [];  data = [];
    %     %% Get source data
    %     if isequal(space, 'base')
    %       try source = sources.(inputParams.name); end
    %     else
    %       try source = spaceSources.(inputParams.name); end
    %       if isempty(source)
    %         source = inputParams;
    %         source.added = now;
    %         source.lastCall = now;
    %         source.calls = 0;
    %         source.data = loadSpaceData(space, inputParams.name);
    %       end
    %     end
    %
    %     if (~isempty(source))
    %       data = source.data;
    %
    %       source.calls = source.calls + 1;
    %       source.lastCall = now;
    %
    %       if isequal(space, 'base')
    %         sources.(source.name) = source;
    %       else
    %         spaceSources.(source.name) = source;
    %         isChanged = true;
    %       end
    %     end
    %   end
    % end
