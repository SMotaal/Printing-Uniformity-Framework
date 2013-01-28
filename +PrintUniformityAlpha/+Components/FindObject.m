function [ handle ] = FindObject( tag, type, parent, varargin )
  
  import Components.*;
  
  handles = FindObjects(tag, type, parent, varargin);
  
  if ~isempty(handles)
    handle = handles(1);
  else
    handle = [];
  end
  
end

