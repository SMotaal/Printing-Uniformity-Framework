function [ data SID MID ] = supDataBuffer( source )
  %SUPDATABUFFER Summary of this function goes here
  %   Detailed explanation goes here
  
  if ischar(source)
    data    = [];
  elseif isstruct(source) && isValid('source.Filename','char')  % Setting
    data    = source;
    source = data.Filename;    
  end    
  
  MID   = [ upper(source) 'Alpha' ];
  SID   = [ MID           'Data'  ];
  
  if isempty(data)
    data  = Data.dataSources(SID);
  elseif (nargout==0)
    Data.dataSources(SID, data, true);
  end
  
end

% try
%   if ischar(source)
%       sourceData  = supDataBuffer([], source);
%   elseif isstruct(source)
%       sourceData  = source;
%   end
% catch err;
% end
