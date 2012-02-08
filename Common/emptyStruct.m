function [ structure ] = emptyStruct( varargin )
  %EMPTYSTRUCT Summary of this function goes here
  %   Detailed explanation goes here
  
  args = cell(numel(varargin)*2,1);

  args(1:2:end) = varargin(:);
  
  structure = struct(args{:});
  
end
