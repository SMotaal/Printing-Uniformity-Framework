function [ result ] = isClass( object, expectedClass )
%ISVALID Validate class and check size
%   Detailed explanation goes here

  parser = inputParser;
  
  %% Parameters
  parser.addRequired('object');
  
  parser.addRequired('expectedClass', @ischar);
    
  parser.parse(object, expectedClass);
  
  params = parser.Results;
   
  %% Validation
  validClass  = isa(object, expectedClass);
  
  if ~validClass && strcmpi(expectedClass, 'cellstr')
    validClass = iscellstr(object);
  end
  
  if ~validClass && strcmpi(expectedClass, 'numeric')
    validClass = isnumeric(object);
  end
    
  result = validClass;
  
  
end

