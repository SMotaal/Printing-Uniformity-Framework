function [ result ] = isValid( expression, expected )
  %ISVALID Validate expression and compare value
  %   IsValid evaluates passed expression in the caller workspace and
  %   returns true if result is produced without error. If an expected
  %   value is passed, the validation is followed by a comparison of the
  %   expected value against the actual result of the expression called.
  
  
  result = false;
  
  try
    actual = evalin('caller', expression);
    if (exist('expected','var'))
%       if ischar(expected)
%         result = strcmp(actual, expected);
%       else
        try
          result = all(actual==expected);
        catch err
          result = false;
        end
%       end
    else
      result = true;
    end
  catch err
    result = false;
  end
  
  
end

