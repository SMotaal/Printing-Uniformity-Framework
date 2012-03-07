function [ check ] = isInteger( object )
  %ISINTEGER Determine if values are round integers
  %   Detailed explanation goes here
  
  try
    check = all(round(object)==object);
  catch err
    check = false;
  end
end

