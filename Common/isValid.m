function [ result ] = isValid( object, expectedClass, varargin )
  %ISVALID Validate class and check size
  %   Detailed explanation goes here
  
  parser = inputParser;
  
  %% Parameters
  parser.addRequired('object'); %, @(x) ischar(x) | isobject(x));
  
  parser.addRequired('expectedClass', @ischar);
  
  parser.addOptional('expectedSize', [1 1], ...
    @(x) isnumeric(x) && ...
    ( (size(x,1)==1 && ndims(x)==2) || (numel(x)==1)  ) );
  
  parser.parse(object, expectedClass, varargin{:});
  
  params = parser.Results;
  
  result = false;
  
  object = params.object;
  expectedSize = params.expectedSize;
  
  if ischar(object) && ~isempty(regexp(object,'^=[^=]*$'))
    try
      object = evalin('caller', object(2:end));
    catch err
      % error('Grasppe:IsValid:InvalidObject', 'Evaluation of object in caller failed.');
      return;
    end
  end
  
  %% Validation
  validClass = isClass(object, expectedClass);
  %   validClass  = isa(object, expectedClass);
  %
  %   if ~validClass && strcmpi(expectedClass, 'cellstr')
  %     validClass = iscellstr(object);
  %   end
  
  if numel(expectedSize) == 1
    validSize = numel(object) == expectedSize;
  else
    validSize = all(size(object) == expectedSize) && ...
      all(size(size(object)) == size(expectedSize));
  end
  
  result = validClass && (validSize || ischar(object));
  
  
end

