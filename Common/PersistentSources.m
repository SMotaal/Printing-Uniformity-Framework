function [varargout] = PersistentSources(varargin)
  %PERSISTENTSOURCES Lock Persistent Data Storage
  %   Detailed explanation goes here
  
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
        varargout = datastore;
      end
    end
    return;
  end
  
  if (nin==1 && nout==0 && ischar(varargin{1}))
    switch lower(varargin{1})
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
      case 'readwrite'
        readonly = false;
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
  elseif (nin==1 && nout==0 && isstruct(varargin{1}))
    datastore = varargin{1};
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


function datastore = loaddata(datastore, forced)
  persistent loaded;
  default loaded false;
  default forced false;
  if (~loaded || forced)
    if exist(datafile, 'file') > 0
      try
        statusbar(0, 'Loading data store... '); drawnow();
%         fprintf(2,'\nLoading data store... ');
        load(datafile, 'datastore');
        statusbar(0);
        loaded = true;
%         fprintf(1,'Done.\n\n');
      catch err
        disp(err);
      end
    else
      loaded = true;
    end
  end
end

function [] = savedata(datastore, forced)
  default forced false;
  
  mlock;
  
  saved = ~touchdata();
  
  if (~saved || forced)
    try
      statusbar(0, 'Saving data store... '); drawnow();
      if (isQuitting)
        fprintf(2,'\nSaving data store... ');
      end
      save(datafile, 'datastore');
      statusbar(0);
      touchdata(false);
      saved = true;
      if (isQuitting)
        fprintf(1,'Done.\n\n');
      end
    end
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

function filename = datafile()
  path      = fileparts(mfilename('fullpath'));
  filename  = fullfile(path, 'datastore.mat');
end
