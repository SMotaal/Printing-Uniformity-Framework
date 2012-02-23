classdef upPlotFigure < handle
  %UPPLOTFIGURE Printing Uniformity Plot Figure
  %   Detailed explanation goes here
  
  properties (SetAccess = protected, GetAccess = protected)
    Primitive % HG primitive handle
    AxesHandle % Axes handle
  end
  
  properties
    Name
    
    Renderer
    
    Visible
    Toolbar
    MenuBar
    
    Color
    Units
  end
  
  methods
    
    function gobj = upPlotFigure(varargin)
      setFigureOptions(varargin);
      createFigure(gobj);
    end
    
    function gobj = createFigure(gobj)
      % http://www.mathworks.com/help/techdoc/matlab_oop/brgxk22-1.html
      
      figureOptions = getFigureOptions(gobj);
      
      h = figure(figureOptions{:});
      
      gobj.Primitive = h;   % gobj.AxesHandle = get(h,'Parent');
      
      
    end
    
    function gobj = setFigureOptions(gobj, varargin)
      % http://www.mathworks.com/help/techdoc/matlab_oop/brgxk22-1.html
      
      [nargs paired args values] = varargs;
      
      if (nargs==1 && isstruct(varargin{1}))
        argstruct = varargin{1};
        args      = fieldnames(argstruct);
        values    = struct2cell(argstruct);        
        pairs     = numel(args);
        paired    = pairs > 0;
      else
        pairs     = nargs / 2;
        paired    = paired && pairs>0;
      end

      if (paired)
        for i=1:numel(args)
          gobj.(args{i}) = values{i+1};
        end
      end
      
    end
    
    function options = getFigureOptions(gobj)
      properties = { ...
        'Name', ...
        'Renderer', 'Visible', ...
        'Toolbar', 'MenuBar', ...
        'Color', 'Units' ...
        };
      
      options = cell(1, numel(properties).*2);
      
      for i = 1:numel(properties)
        name = char(properties(i));
        
        value = gobj.(name);
        
        if (~isempty(value))
          options(i) = name;
          options(i+1) = value;
        end
      end
    end
  end
  
end

