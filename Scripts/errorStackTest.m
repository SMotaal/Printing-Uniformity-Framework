function [ result ] = stropt( string,  cellstr )
  %STROPT string compared against a given list.
  
  try
    result = wefqwf; %any(strcmpi(string, cellstr));
  catch err
    erra = MException('Grasppe:StrOpt:Exception', '');
    errx = erra;
    
    try
      assert(validCheck(string,'char'), 'Grasppe:StrOpt:WrongStringClass', ...
        'First argument must be a string.');
    catch errn
      errx = stackCause(errx, errn);
    end
    
    try
      assert(iscellstr(cellstr), 'Grasppe:StrOpt:WrongStringListClass', ...
        'Second argument must be a strings cell.');
    catch errn
      errx = stackCause(errx, errn);
    end
    
    if (errx~=erra) %~isempty(errx)
      throw(errx);
    else
      throw(err);
    end
  end
  
end

function [errx] = stackCause(errx, errn)
  if isempty(errx)
    errx = errn;
  else
    try
      %       errn.stack = errx.stack;
      errx = addCause(errx, errn);
    catch err
      disp(err);
    end
  end
end
