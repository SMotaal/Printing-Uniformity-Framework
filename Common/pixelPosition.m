function [ position ] = pixelPosition( handle )
  %PIXELPOSITION Summary of this function goes here
  %   Detailed explanation goes here
  
  try
    units = get(handle, 'Units');
    set(handle, 'Units', 'pixels');
    try
      position = get(handle, 'Position');
    end
    set(handle, 'Units', units);
  end
  
end

