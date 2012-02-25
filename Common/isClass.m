function [ result ] = isClass( object, expectedClass )
  %ISVALID Validate class and check size
  %   Detailed explanation goes here
  
%   parser = inputParser;
%   
%   %% Parameters
%   parser.addRequired('object');
%   
%   parser.addRequired('expectedClass', @ischar);
%   
%   parser.parse(object, expectedClass);
%   
%   params = parser.Results;
  
  %% Validation
  
  try
    switch lower(expectedClass)
      case 'handle'
        validClass = ishandle(object);
      case 'object'
        validClass = isobject(object);
      case 'numeric'
        validClass = isnumeric(object);
      case 'cellstr'
        validClass = iscellstr(object);
      otherwise
        validClass = isa(object, expectedClass);
    end
    
    result = ~isempty(validClass) && all(validClass);
  catch err
    result = false;
  end
  
end

