function [ output_args ] = substitute( matrix, value, sub )
  %SUBSTITUTE matrix values
  
  matrix(isnan(matrix)) = 0;
end

