function [ result ] = dispf( varargin )
  %DISPF disp using sprintf
  %   Detailed explanation goes here
  
  result = disp(sprintf(varargin{:}));
end

