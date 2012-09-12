function [ output_args ] = recyclesSpaces( input_args )
  %RECYCLESSPACES Summary of this function goes here
  %   Detailed explanation goes here
  
  spaces = {'RITHP7K01', 'RITHP5501', 'RITSM7402A', 'RITSM7402B', 'RITSM7402C'}; %, 'RITSM7401'};
  
  for m = 1:numel(spaces)
    try Data.dataSources('recycle', spaces{m}); end
  end
    
end

