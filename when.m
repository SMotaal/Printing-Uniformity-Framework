function [ output_args ] = when( expression, varargin )
%WHEN Summary of this function goes here
%   Detailed explanation goes here

statement = '';
for vin = varargin
  vt = strtrim(char(vin));
  vt = regexprep(vt,'^"([^"]*)"$','''$1''');
  statement = [statement ' ' vt];
end
statement = strtrim(statement);

if ischar(expression)
  expression = evalin('caller', expression)==1;
end

if islogical(expression)
  if (expression)
    evalin('caller', [statement ';']);
  end
end

end

