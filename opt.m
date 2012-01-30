function [ err ] = opt( varargin )
%OPT Safely execute a statement returning any caught exceptions

statement = '';

for var = varargin
  var = strtrim(char(var));
  var = regexprep(var,'^"([^"]*)"$','''$1''');
  statement = strcat(statement,' ', var);
end

statement = strtrim(statement);

try
  evalin('caller', [statement ';']);
catch err
end

end

