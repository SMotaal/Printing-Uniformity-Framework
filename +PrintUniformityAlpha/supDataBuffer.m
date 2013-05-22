function [ data SID MID ] = supDataBuffer( source )
  %SUPDATABUFFER Summary of this function goes here
  %   Detailed explanation goes here
  
  import PrintUniformityAlpha.*;
  
  if ischar(source)
    data    = [];
  elseif isstruct(source) && validCheck('source.Filename','char')  % Setting
    data    = source;
    source = data.Filename;    
  end    
  
  SRC   = upper(source);
  MID   = [ SRC 'Alpha'];
  SID   = [ MID 'Data'  ];
  
  if isempty(data)
    data  = Data.dataSources(SID, MID);
  elseif (nargout==0)
    Data.dataSources(SID, data, true, MID);
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
