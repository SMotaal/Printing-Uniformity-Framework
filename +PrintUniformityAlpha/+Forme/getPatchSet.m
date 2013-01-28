function [ patchSet ] = getPatchSet( data, patchValue )
  %SELECTUPSET Generate patch index for patch value from data
  
  patchSet   = data.patchMap == patchValue;
end

