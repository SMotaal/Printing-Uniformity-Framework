function [ output_args ] = when( expression, varargin )
%WHEN Summary of this function goes here
%   Detailed explanation goes here

statement = '';
for vin = varargin
  statement = [statement ' ' char(vin)];
end
statement = strtrim(statement);

if ischar(expression)
  expression = evalin('caller', expression);
end

if islogical(expression)
  if (expression)
    evalin('caller', [statement ';']);
  end
end

end

