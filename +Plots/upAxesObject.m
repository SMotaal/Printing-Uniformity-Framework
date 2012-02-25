classdef upAxesObject < Plots.upViewComponent
  %UPAXESOBJECT Printing Uniformity Axes Superclass
  %   Detailed explanation goes here
  
  properties
  end
  
  methods

    %% Figure Operations
    
%     function obj = createFigure(obj)
%       % http://www.mathworks.com/help/techdoc/matlab_oop/brgxk22-1.html
%       
%       figureOptions = getFigureOptions(obj);
%       
%       hfig = figure(figureOptions{:}, 'Visible', 'off');
%       
%       if (strcmpi(obj.Visible,'on'))
%         obj.show();
%       end
%       
%       obj.Primitive = hfig;
%       
%       obj.updateView;
%     end
    
    function handle = getFigure(obj)
      
      if (isempty(obj.Primitive))
        obj.createFigure;
      end
      
      handle = obj.Primitive;
      try
        set(0,'CurrentFigure',handle);
      catch
        obj.createFigure;
        handle = obj.getFigure;
      end
      
    end
    
    function options = getFigureOptions(obj)
      properties = obj.FigureProperties;
      options = obj.getOptions(properties);
    end
    
    
    %% Window Operations
    
    function obj = show(obj)
      hFigure = obj.getFigure;
      
      obj.setOptions('Visible', 'on');
      
      obj.updateView;
      
      figure(hFigure);
    end
    
    %% Update Operations
    
    function obj = updateView(obj)
      persistent updating delayTimer;
      
      if isVerified('updating',true)
        if ~isVerified('class(delayTimer)','timer');
          delayTimer = timer('Name','DelayTimer','ExecutionMode', 'singleShot', 'StartDelay', 1, ...
            'TimerFcn', {@Plots.upPlotFigure.callbackEvent,obj});
          start(delayTimer);
        else
          stop(delayTimer);
          start(delayTimer);
        end
        return;
      end
      
      updating = true;
      
      obj.updateFigure;
      
      updating = false;
    end
    
    
    function obj = updateFigure(obj)
      obj.updateTitle;
    end
    
    
  end 
  
end

