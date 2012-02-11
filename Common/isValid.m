function [ result ] = isValid( object, expectedClass, varargin )
%ISVALID Validate class and check size
%   Detailed explanation goes here

  parser = inputParser;
  
  %% Parameters
  parser.addRequired('object');
  
  parser.addRequired('expectedClass', @ischar);
  
  parser.addOptional('expectedSize', [1 1], ...
    @(x) isnumeric(x) && ...
    ( (size(x,1)==1 && ndims(x)==2) || (numel(x)==1)  ) );
  
  parser.parse(object, expectedClass, varargin{:});
  
  params = parser.Results;
  
  expectedSize = params.expectedSize;
  
  %% Validation
  validClass  = isa(object, expectedClass);
  
  if numel(expectedSize) == 1
    validSize = numel(object) == expectedSize;
  else
    validSize = all(size(object) == expectedSize) && ...
      all(size(size(object)) == size(expectedSize));
  end
  
  result = validClass && validSize;
  
  
end

