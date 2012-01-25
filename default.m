function [ output_args ] = default( var, value, flag)
%DEFAULT Summary of this function goes here
%   Detailed explanation goes here

if evalin('caller',['~exist(''' var ''', ''var'')'])

  isstr = exist('flag', 'var') && strcmpi(flag,'str');
  istrue = strcmpi(value,'true');
  isfalse = strcmpi(value,'false');
  isboolean = istrue || isfalse;

  if ~isstr && istrue
    value = true;
  elseif  ~isstr && isfalse
    value = false;
  elseif ~isstr && ~istrue && ~isfalse
    try
      nvalue = str2num(value);
      value = nvalue;
      isnumber = true;
    catch err
      isnumber = false;
    end
  end
  
  if isstr || isboolean || isnumber % (strcmpi(flag,'str'))
    assignin('caller', var, value);
  else
    evalin('caller',[var ' = ' value ';']);
  end
end


end

