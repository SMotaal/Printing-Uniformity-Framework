function resetColorMap(obj, cmap)
  %RESETCOLORMAP Summary of this function goes here
  %   Detailed explanation goes here
  
  try
    
    if ~exist('cmap', 'var')
      cmap                      = [ ...
      4/4 0/4 0/4 % 6
      4/4 2/4 0/4 % 5
      4/4 3/4 0/4 % 4
      4/4 4/4 0/4 % 3
      3/4 4/4 0/4 % 2
      2/4 4/4 0/4 % 1
      0/4 4/4 0/4 % 0
      3/8 7/8 3/8 % 1
      4/8 7/8 4/8 % 2
      4/8 6/8 4/8 % 3
      4/8 4/8 4/8 % 4
      3/8 3/8 3/8 % 5
      2/8 2/8 2/8 % 6
      ];
    
    end
    
    obj.ColorMap                = flipud(cmap);
    
    obj.notify('PlotMapChange');
  end
end
