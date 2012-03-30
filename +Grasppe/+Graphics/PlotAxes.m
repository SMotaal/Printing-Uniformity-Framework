classdef PlotAxes < Grasppe.Graphics.Axes
  %OVERLAYAXES Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    
    function obj = PlotAxes(varargin)
      obj = obj@Grasppe.Graphics.Axes(varargin{:});
    end  
    
    
    function panAxes(obj, panXY, panLength) % (obj, source, event)
      persistent lastPanTic lastPanXY
      %       dispf('%s <== %s (%s)', obj.ID, 'MousePan', toString(event.PanVector));
      
      panMultiplierRate   = 45;     % per second
      panStickyThreshold  = 5;
      panStickyAngle      = 45/2;
      
      lastPanToc  = 0;
      try lastPanToc = toc(lastPanTic); end
      
      if isempty(lastPanXY) || panLength==0;
        deltaPanXY  = [0 0];
      else
        deltaPanXY  = panXY - lastPanXY;
      end
      
      plotAxes = obj; % get(obj.handleGet('CurrentAxes'), 'UserData');
      
      try
        newView = plotAxes.View - deltaPanXY;
        
        if newView(2) < 0
          newView(2) = 0;
        elseif newView(2) > 90
          newView(2) = 90;
        end
        
        if panStickyAngle-mod(newView(1), panStickyAngle)<panStickyThreshold || ...
            mod(newView(1), panStickyAngle)<panStickyThreshold
          newView(1) = round(newView(1)/panStickyAngle)*panStickyAngle;
        end
        if panStickyAngle-mod(newView(2), panStickyAngle)<panStickyThreshold || ...
            mod(newView(2), panStickyAngle)<panStickyThreshold
          newView(2) = round(newView(2)/panStickyAngle)*panStickyAngle; % - mod(newView(2), 90)
        end
        
        currentView = plotAxes.View;
        plotAxes.View = newView;
        dispf('Panning: %s => %s = %s', toString(currentView), ...
          toString(newView), toString(plotAxes.View));
      end
      
      lastPanXY   = panXY;
      lastPanTic  = tic;
      
      %consumed = obj.mousePan@GraphicsObject(source, event);
    end
  end
  
  
  methods(Static, Hidden=true)
    function options  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = true;
      Box           = 'off';
      Units         = 'normalized';
      Position      = [0 0 1 1];
      Color         = 'none';
      
      AspectRatio   = [1 1 1];
      View          = [0 90];
      
      OuterPosition = [0.1 0.1 0.8 0.8];
      
      options       = WorkspaceVariables(true);
    end
    
  end
  
  
end

