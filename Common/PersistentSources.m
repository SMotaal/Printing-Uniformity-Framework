function varargout = PersistentSources(varargin)
  %PERSISTENTSOURCES Lock Persistent Data Storage
  
  persistent datastore locked readonly;
  
  %% Exceptions
  E.identity    = 'Grasppe:PersistentSources';
  E.NAMING      = MException([E.identity  ':InvalidName'  ],  ...
    'Illegal variable name.');
  E.SETTING     = MException([E.identity  ':SettingFailed'],  ...
    'Variable setting failed.');
  E.GETTING     = MException([E.identity  ':GettingFailed'],  ...
    'Variable getting failed.');
  E.UNEXPECTED  = MException([E.identity  ':Unexpected'   ],  ...
    'Operation failed due to an unexpected error.');
  
  if (isempty(locked) || locked)
    mlock;
  end
  
  if (isempty(readonly))
    readonly = false;
  end
  
  [nout]  = nargout;
  [nin]   = nargin;
  
  if (nin==0)
    try
      if nout == 0
        disp(datastore);
      elseif nout==1
        varargout = {datastore};
      end
    end
    return;
  end
  
  if (nout==0)
    
    if (nin==1)
      firstArg = varargin{1};
      if ischar(firstArg)
        switch lower(firstArg)
          case 'clear'
            clear datastore;
            touchdata(true);
            return;
          case 'load'
            datastore = loaddata(datastore);
            return;
          case 'save'
            if (~readonly)
              savedata(datastore);
            end
            return;
          case 'force load'
            datastore = loaddata(datastore, true);
            return;
          case 'readonly load'
            datastore = loaddata(datastore, true);
            readonly  = true;
            return;
          case 'readonly'
            readonly = true;
            return;
          case 'readwrite'
            readonly = false;
            return;
          case 'force save'
            if (~readonly)
              savedata(datastore, true);
            end
            return;
          case 'readonly save'
            savedata(datastore, true);
            return;
          case 'lock'
            mlock;
            locked = true;
            return;
          case 'unlock'
            munlock;
            locked = false;
            return;
        end
      elseif (isstruct(firstArg))
        datastore = firstArg;
      end
    elseif (nin==2)
      firstArg  = varargin{1};
      secondArg = varargin{2};
      switch lower(firstArg)
        case {'load', 'save'}
          try
            filename = datafile(secondArg);
            PersistentSources(['force ' firstArg]);
          catch err
            dealwith(err);
          end
          return;
      end
    end
  end
  
  
  [pargin ineven innames invalues] = pairedArgs(varargin{:});
  
  datastore   = loaddata(datastore);
  
  try
    if (pargin>0 && ineven && iscellstr(innames) && nout==0)
      datastore = setValues(datastore, innames, invalues, E);
      touchdata(true);
      return;
    end
    if (iscellstr(varargin) && nin>0 && (nout==nin || nout==1))
      innames   = varargin;
      values    = getValues(datastore, innames, E);
      if (nin==nout)
        varargout = values;
      elseif (nin==1)
        valuestruct = struct();
        for i = 1:numel(innames)
          valuestruct.(genvarname(innames{i}))=values{i};
        end
        varargout = valuestruct;
      end
      return;
    end
    
%     if (nin==0 && nout==1)
%       varargout{1} = datastore;
%       return;
%     end
  catch err
    rethrow(err);
  end
  
  varargout = cell(1,numel(nout));
  
end

function sources = setValues(sources, names, values, E)
  EXCEPT = {};
  for i = 1:numel(names)
    try
      name  = names{i};
      value = values{i};
      
      if (ischar(name) && ~isempty(name) && (strcmpi(name, genvarname(name))))
        sources.(name) = value;
      else
        throw(extendException(E.UNEXPECTED,[], 'The variable ''%s'' could not be set.', name));
      end
    catch err
      EXCEPT = {EXCEPT{:}, err};
    end
  end
  EXCEPT = addExceptions(E.SETTING, [], EXCEPT{:});
  trigger(EXCEPT);
end

function values = getValues(insources, names, E)
  EXCEPT = {};
  values = cell(size(names));
  for i = 1:numel(names)
    try
      name      = names{i};
      values{i} = insources.(name);
    catch err
      err = extendException(E.NAMING,[], 'The variable ''%s'' is undefined.', name);
      EXCEPT = {EXCEPT{:}, err};
    end
  end
  EXCEPT = addExceptions(E.GETTING, [], EXCEPT{:});
  trigger(EXCEPT);
end

function forcedraw()
  pause(0.05); 
  drawnow();
  pause(0.05);
end


function datastore = loaddata(datastore, forced)
  persistent loaded;
  default loaded false;
  default forced false;
  if (~loaded || forced)
    if exist(datafile, 'file') > 0
      try
        statusbar(0, 'Loading data store... '); forcedraw();  % fprintf(2,'\nLoading data store... ');
        data = load(datafile, 'datastore');
        datastore = data.datastore;
        loaded = true;
        statusbar(0, 'Processing persistent data...'); forcedraw(); % fprintf(1,'Done.\n\n');
      catch err
        disp(err);
      end
    else
      loaded = true;
    end
    statusbar(0,'');
  end
end

function [] = savedata(datastore, forced)
  default forced false;
  
  mlock;
  
  saved = ~touchdata();
  
  if (~saved || forced)
    try
      statusbar(0, 'Saving data store... '); forcedraw();
      if (isQuitting)
        fprintf(2,'\nSaving data store... ');
      end
      save(datafile, 'datastore');
      touchdata(false);
      saved = true;
      if (isQuitting)
        fprintf(1,'Done.\n\n');
      end
      statusbar(0, 'Processing persistent data...'); forcedraw();
    end
    statusbar(0);    
  end
end

function touched = touchdata(reset)
  persistent modified;
  default modified false;
  
  mlock;
  
  if isValid('reset','logical')
    modified = reset;
  end
  
  %   modified  = isequal(reset,true) || modified;
  touched   = modified;
end

function filename = datafile(filename)
  persistent lastFile defaultFile;
 
  defaultFile = 'datastore';

  if exists('filename') && ischar(filename)
      [pathstr filename ext] = fileparts(filename);
      lastFile = filename;
  end
  
  if isempty(lastFile)
    lastFile = defaultFile;
  end

  filename  = datadir('Sources', [lastFile '.mat']);	%fullfile(path, 'datastore.mat');
end
