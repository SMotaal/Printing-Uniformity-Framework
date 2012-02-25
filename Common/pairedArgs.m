function [ nargs even names values ] = pairedArgs(varargin)
  %NVARARGIN number of variable arguments
  %   Return the number of arguments, if the number of arguments is even,
  %   the names from every other argument, and the values from every next
  %   other argument.
  
  even    = false;
  names   = {};
  values  = {};
  
%   try
%     args = evalin('caller', 'varargin{:}');

  args = varargin(:);
    
  nargs = numel(args);
    
%     if (isValid('firstArg','double') && firstArg > 0 && firstArg < nargs)
%       args  = args(firstArg:end);
%       nargs = numel(args);
%     end
%     
%   catch err
%     error('Grasppe:VarArgs:InvalidCaller', ...
%       'Attempt to execute varargs outside a function is invalid.');
%   end
  
  if nargout > 1
    even = rem(nargs,2)==0;
  end
  
  if nargout == 3
    names = args(1:2:end);
    if (~iscellstr(names))
      warning('Grasppe:VarArgs:InvalidOutputs', ...
          ['Invalid number of outputs. Names and values must be parsed together.\n' ...
          'Consider adding or removing one output to properly parse the names']);      
    end
  end
  
  if (nargout > 3 && even)
    names   = cell(1,nargs/2);
    values  = cell(1,nargs/2);
    pairs   = 0;
    voids   = [];
    
    for i=1:2:length(args)
      name  = args{i};
      value = args(i+1);
      
      if (ischar(name) && ~isempty(name))
        pairs = pairs+1;        
        names(pairs)  = {name};
        values(pairs) = value;
      else
        voids = [voids i];
      end
    end
    
    names   = names(1:pairs);
    values  = values(1:pairs);
    
    if (pairs ~= nargs/2)
%       warning('Grasppe:VarArgs:InvalidNames', ...
%         ['Invalid names fields [' int2str(voids) ']. These pairs were dropped.']);
    end
  end
  
end

