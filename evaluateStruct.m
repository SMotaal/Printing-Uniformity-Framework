function s = evaluateStruct(c)
  %PARSESTRUCT Evaluate Key-Value Cell Pairs Structure
  %   Detailed explanation goes here
  
  s = struct();
  
  %% Return empty struct
  if isempty(c),  return; end;
  
  %% Validate Inputs
  validKeyValuePairs    = size(c,2)==2;
  validKeyCells         = iscellstr(c(:,1));
  
  assert(validKeyValuePairs & validKeyCells, 'Grasppe:EvaluateStruct:InvalidInput', ...
    [ 'Arguments for evaluateStruct must be key-value pair cell (n x 2)' ...
    ' and key column (1) must be a cellstr']);
  
  % structString = '';
  
  invalidKeys           = {};
  
  %% Generate Struct
  for m = 1:size(c,1)
    fieldKey            = c{m,1};
    fieldValue          = c{m,2};
    try
      eval(['s.' fieldKey ' = fieldValue;']);
    catch err
      invalidKeys       = [invalidKeys, fieldKey];
    end
  end
  
  %% Warning
  if ~isempty(invalidKeys)
    warning('Grasppe:EvaluateStruct:InvalidKeys', ...
      'Some keys were ignored by evaluateStruct for not following MatLab naming convension: %s', ...
      toString(invalidKeys));
  end
  
end

