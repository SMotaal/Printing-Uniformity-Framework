classdef PlotDataEventHandler < PrintUniformityBeta.Data.DataEventHandler
  %PLOTDATALISTENER Plot Data Event Handler Superclass
  %   Detailed explanation goes here
  
  properties
  end
  
  events
    PlotChange            % Plot object has changed
    PlotDataChange        % Plot data has changed (need to refresh plot)
    PlotAxesChange        % Plot axes (lim, label... etc.) has changed
    PlotMapChange         % Plot map (colormap, clim... etc.) has changed
    PlotViewChange        % Plot view has changed
  end
  
  methods
    function obj = PlotDataEventHandler()
      obj = obj@PrintUniformityBeta.Data.DataEventHandler;  % Calls obj.attachDataEvents;
      
      obj.attachSelfEventListeners('PlotDataEventHandlers', {'PlotChange', 'PlotDataChange', 'PlotAxesChange', 'PlotMapChange', 'PlotViewChange'});
      % obj.attachSelfPropertyListeners('PlotDataEventHandlers', {});      
    end
        
    function registerPlotDataEventHandler(obj, handler)
      obj.registerEventHandler('PlotDataEventHandlers', handler);
    end
    
  end
  
  methods (Abstract)
    % consumed = OnPlotDataChange(obj, source, event)
    % consumed = OnPlotAxesChange(obj, source, event)
    % consumed = OnPlotMapChange(obj, source, event)
    % consumed = OnPlotViewChange(obj, source, event)
  end
  
end

