classdef UniformityPlotLabels < Grasppe.Core.Component
  %UNIFORMITYPLOTLABELS Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    LabelObjects    = {};
    LabelValues     = [];
    LabelRegions    = [];
    LabelPositions  = [];
    LabelActivePositions  = [];
    LabelAreas      = [];
    LabelElevation  = 100;
    SubPlotObjects  = cell(0,2);
    SubPlotMarkers  = {};
    SubPlotBoxes    = {};
    SubPlotData     = {};
    MarkerPositions = {};
    MarkerIndex     = 1;
    PlotObject
    ComponentType   = '';
    FontSize        = 6;
  end
  
  methods
    
    function obj = UniformityPlotLabels()
      obj = obj@Grasppe.Core.Component();
    end
    
    function set.PlotObject(obj, plotObject)
      try obj.deleteLabels; end
      
      obj.PlotObject = plotObject;
    end
    
    function attachPlot(obj, plotObject)
      
      obj.PlotObject = plotObject;
      
      %% Elevation
      zReverse = false;
      try zReverse = isequal(lower(plotObject.ZDir), 'reverse'); end
      
      z = 100;
      
      try
        if zReverse
          z = min(plotObject.HandleObject.ZLim) - 3;
        else
          z = max(plotObject.HandleObject.ZLim) + 3;
        end
      end
      
      obj.LabelElevation = z;
    end
    
    function clearLabels(obj)
      for m = 1:numel(obj.LabelObjects)
        obj.LabelObjects{m}.Text = '';
      end
    end
    
    function deleteSubPlots(obj)
      try
        for m = 1:numel(obj.SubPlotBoxes)
          try
            delete(obj.SubPlotBoxes{m});
          catch err
            debugStamp(err, 1);
          end
          obj.SubPlotBoxes{m} = [];
        end
      end
      
      % obj.SubPlotBoxes = {};
      
      try
        for m = 1:numel(obj.SubPlotMarkers)
          try
            delete(obj.SubPlotMarkers{m});
          catch err
            debugStamp(err, 1);
          end
          obj.SubPlotMarkers{m} = [];
        end
      end
      
      try
        for m = 1:numel(obj.SubPlotObjects)
          try 
            delete(obj.SubPlotObjects{m});
          catch err
            debugStamp(err, 1);
          end            
          obj.SubPlotObjects{m} = [];
        end
      end
    end
    
    function deleteLabels(obj)
      obj.deleteSubPlots;
      try
        for m = 1:numel(obj.LabelObjects)
          try 
            delete(obj.LabelObjects{m}); 
          catch err
            debugStamp(err, 1);
          end
          obj.LabelObjects{m} = [];
        end
      end
      try
        for m = 1:numel(obj.LabelObjects)
          try if isempty(obj.LabelObjects{m}), continue; end; end
          return;
        end
      end
      try
        obj.LabelObjects    = {};
        obj.LabelValues     = [];
        obj.LabelRegions    = [];
        obj.LabelPositions  = [];
      end
    end
    
    function delete(obj)
      obj.deleteSubPlots();
      obj.deleteLabels();
      obj.delete@Grasppe.Core.Component();
      obj.PlotObject = [];
      return;
    end
    
    function defineLabels(obj, regions, values)
      %obj.deleteLabels;
      obj.LabelRegions    = regions;
      obj.LabelValues     = values;
      obj.LabelPositions  = [];
    end
    
    function createLabels(obj)
      try
        values  = obj.LabelValues;
        regions = obj.LabelRegions;
        
        
        for m = 1:numel(obj.LabelValues)
          try
            region = eval(['regions(m' repmat(',:',1,ndims(regions)-1)  ')']);
            obj.createLabel(m, squeeze(region), values(m));
          end
        end
      catch err
        %disp(err);
      end
      
    end
    
    function createLabel(obj, index, region, value)
      try
        if ~isa(obj.PlotObject, 'Grasppe.Graphics.PlotComponent') || ...
            ~isa(obj.PlotObject.ParentAxes, 'Grasppe.Graphics.PlotAxes')
          return;
        end
      catch err
        return;
      end
      
      try
        
        %% Index
        if isempty(index)
          index = numel(obj.LabelObjects)+1;
        else
          label = [];
          try label = obj.LabelObjects{index}; end
        end
        
        %% Label
        if isempty(label) % Create Label
          try
            label = Grasppe.Graphics.TextObject(obj.PlotObject.ParentAxes, 'Text', int2str(index)); ...
              obj.registerHandle(label);
            
            label.HandleObject.HorizontalAlignment  = 'center';
            label.HandleObject.VerticalAlignment    = 'middle';
            % label.FontSize    = 5;
            label.IsClickable = false;
          catch err
            warning('Plot must be attached before creating labels');
            return;
          end
          obj.registerHandle(label);
          obj.LabelObjects{index} = label;
        end
        
        try label.FontSize = obj.FontSize; end
        
        %% Region (xmin ymin width height)
        if isequal(size(region), [1 4])
          % no change
        elseif isequal(size(region), [1 2])
          region  = [region 0 0];
        else % is a mask
          y       = nanmax(region, [], 2);
          y1      = find(y>0, 1, 'first');
          y2      = find(y>0, 1, 'last');
          
          x       = nanmax(region, [], 1);
          x1      = find(x>0, 1, 'first');
          x2      = find(x>0, 1, 'last');
          
          region  = [x1 y1 x2-x1 y2-y1];
        end
        
        dimension = region([3 4]);
        
        %% Position (centering)
        position  = region([1 2]) + dimension/2;
        
        
        try
          if all(dimension>7) %&& ~isempty([obj.SubPlotObjects{:}])  % && dimension>7
            position = position + [0 1];
          end
        end
        
        
        obj.LabelRegions(index, 1:4)    = region;
        obj.LabelPositions(index, 1:2)  = position;
        obj.LabelAreas(index, 1:2)      = dimension;
        
        %% Value
        if nargin < 3, value = []; end
        
        try if isempty(value), value = obj.LabelValues(index); end; end
        
        obj.LabelValues(index) = value;
        
        obj.updateLabel(index);
        obj.updateLabelPosition(index)
        
      catch err
        try debugStamp(err, 1, obj); catch, debugStamp(); end;
      end
      
      
    end
    
    function updateLabelPosition(obj, index)
      position = [-100 -100];
      try
        position = obj.LabelPositions(index, :);
        
        try
          extent = obj.LabelObjects{index}.HandleObject.Extent;
          region = obj.LabelAreas(index, :);
          
          if extent(3)*0.8 > region(1)
            position(2) = position(2) + (rem(index,2)*2-1)*1.5;
          end
          
          if extent(4)*0.8 > region(2)
            position(1) = position(1) + (rem(index,2)*2-1)*1.5;
          end
        end
      end
      
      try obj.LabelObjects{index}.Position = [position 200]; end %obj.LabelElevation]; end
      
    end
    
    function updateLabel(obj, index)
      try
        value = [];
        
        try value = obj.LabelValues(index); end
        
        if isa(value, 'double'), value = num2str(value, '%3.1f');
        end
        
        try obj.LabelObjects{index}.Text = toString(value); end
        
        
        %         position = [-100 -100];
        %         try
        %           position = obj.LabelPositions(index, :);
        %
        %           try
        %             extent = obj.LabelObjects{index}.HandleObject.Extent;
        %             region = obj.LabelAreas(index, :);
        %
        %             if extent(3)*0.8 > region(1)
        %               position(2) = position(2) + (rem(index,2)*2-1)*1.5;
        %             end
        %
        %             if extent(4)*0.8 > region(2)
        %               position(1) = position(1) + (rem(index,2)*2-1)*1.5;
        %             end
        %           end
        %         end
        %
        %         try obj.LabelObjects{index}.Position = [position 200]; end %obj.LabelElevation]; end
        try
          marker  = obj.SubPlotMarkers{index};
          xi      = obj.MarkerIndex;
          xd      = obj.MarkerPositions{index};
          %if isobject(marker) && ishandle(marker)
          try
            %marker.XData = [xd(xi) xd(xi)];
            %marker.Visible = 'on';
            set(marker, 'XData',  [xd(xi) xd(xi)],  'Visible', 'on');
          catch err
            set(marker, 'XData',  [xd(1)  xd(1)],   'Visible', 'off');
          end
        end
        
        
      catch err
        try debugStamp(err, 1, obj); catch, debugStamp(); end;
      end
    end
    
    function updateSubPlots(obj)
      
      try debugStamp(obj.ID, 1); catch, debugStamp(); end;
      
      try
        obj.deleteSubPlots;
        
        data        = cell2mat(obj.SubPlotData);
        
        markerIndex = obj.MarkerIndex;
        if isempty(markerIndex), markerIndex = 1; end;
        
        setData     = data';
        sheetCount  = size(setData, 1); % obj.PlotObject.DataSource.getSheetCount; %size(yvs, 1);
        zoneCount   = size(setData, 2);
        
        sheetMeans  = mean(setData,2);
        
        setMean     = mean(setData(:));
        setMin      = min(setData(:));
        setMax      = max(setData(:));
        setRange    = setMax-setMin;
        
        reflect     = @(x1, x2) [x1, fliplr(x2)];
        lace        = @(x, n) reshape(repmat(x, n, 1), size(x,1), []);
        
        parentAxes  = obj.PlotObject.ParentAxes.Handle;
        parentOpt   = {'Parent', parentAxes};
        
        for m = 1:zoneCount %numel(obj.LabelObjects)
          
          zoneLabel     = obj.LabelObjects{m};
          zoneArea      = obj.LabelAreas(m, :);
          zonePosition  = obj.LabelPositions(m, :);
          
          xLength       = zoneArea(1); %max(xExtent)-min(xExtent);          
          xExtent       = zonePosition(1) + [-1 0] + [-xLength xLength] /2;
          xOffset       = 0;
          xScale        = 1;
          
          xSteps        = linspace(min(xExtent), max(xExtent), sheetCount);
          xInterp       = linspace(min(xExtent), max(xExtent), sheetCount+1);
          xInterp       = [xInterp(1) lace(xInterp(2:end-1), 3) xInterp(end)];
          
          xData         = reflect(xInterp, xInterp);
          
          xMarker       = [xSteps(1) xSteps(1)];
          try xMarker   = [xSteps(markerIndex) xSteps(markerIndex)]; end
               
          yLength       = zoneArea(2)*2/4; 
          yExtent       = zonePosition(2) + [0 0] + [-yLength yLength]/2;
          yOffset       = -zoneArea(2)*1.25/4;
          yScale        = 1/3;
          
          yInterp       = @(y) spline(xSteps, y, xInterp);
          
          yFx           = @(y) lace(y/setRange * yLength * yScale, 3);
          yCenter       = min(yExtent) + yLength/2 + yOffset;
          
          zoneData      = (setData(:,m)   - setMin)';
          meanData      = (sheetMeans(:)  - setMin)';
          
          yZoneData     = yFx(zoneData);
          yZoneData     = yZoneData(1:end-1);
          yZoneData(3:3:end) = 0;
          yZoneData     = yCenter + reflect(yZoneData, -yZoneData);
          
          yMeanData     = yFx(meanData);
          yMeanData     = yMeanData(1:end-1);
          
          yMeanLines    = yMeanData;
          yMeanLines(3:3:end) = NaN;          
          
          yMeanData     = yCenter + reflect(yMeanData, -yMeanData);        
          yMeanLines    = yCenter + reflect(yMeanLines, -yMeanLines);
          
          zDataFcn      = @(z) ones(z) * setMax;
          zData         = zDataFcn(size(xData));
          
          if zoneArea(1)>7 && zoneArea(2)>7
            
            %% Sheet Marker
            try delete(obj.SubPlotMarkers{m}); end
            
            hold(parentAxes, 'on');
            marker  = line( ...
              xMarker, yExtent + [1 -1], zDataFcn(2) + 4, parentOpt{:}, ...
              'Color', [1 0.5 0.5], 'LineWidth', 2, 'LineStyle', '-', ...
              'Tag', '@Screen', 'Visible', 'on', 'HitTest', 'off');
            
            obj.SubPlotMarkers{m} = handle(marker);            
                        
            %% Zone Data
            %try delete(obj.SubPlotObjects{m, 1}); end
            
            hold(parentAxes, 'on');
            subPlot1 = fill3( ...
              xData, yZoneData, zData + 1.5, 'w', parentOpt{:}, ...
              'EdgeColor', [1 0 0], 'LineWidth', 0.125, ...
              'LineStyle', '-', 'FaceAlpha', 1, 'HitTest', 'off'); % [0.75 0.0 0.0]
            
            obj.SubPlotObjects{m, 1} = handle(subPlot1);
            
            %% Mean Data Underlay
            %try delete(obj.SubPlotObjects{m, 3}); end%
            
            hold(parentAxes, 'on');
            subPlot3 = fill3( ...
              xData, yMeanData, zData + 1.25, [0.5 0.25 0.25], parentOpt{:}, ...
              'LineStyle', 'none', 'FaceAlpha', 0.75, 'HitTest', 'off');
            
            obj.SubPlotObjects{m, 3} = handle(subPlot3);            
            
            %% Mean Data Overlay
            %try delete(obj.SubPlotObjects{m, 2}); end
            
            hold(parentAxes, 'on');
            subPlot2 = line( ...
              xData, yMeanLines, zData + 2, parentOpt{:}, ...
              'Color', [0 0 0], 'LineWidth', 0.125, 'LineStyle', '-', 'HitTest', 'off');
            
            obj.SubPlotObjects{m, 2} = handle(subPlot2);
            
            %% Center Line
            %try delete(obj.SubPlotMarkers{m}); end
            
            hold(parentAxes, 'on');
            centerline  = line( ...
              xExtent, [1 1] .* yCenter, zDataFcn(2) + 2.5, parentOpt{:}, ...
              'color', [1 0 0], 'linewidth', 0.125, 'LineStyle', '-', ...
              'Visible', 'on', 'HitTest', 'off'); %'Tag', '@Screen', 
            
            obj.SubPlotObjects{m, 4} = handle(centerline);
            
          else
            plotstr = sprintf('Skipping SubPlot %d: %0.1f x %0.1f', m, zoneArea(1), zoneArea(2));
            %disp(plotstr);
            debugStamp([obj.ID ':' plotstr], 1);
          end
          
          obj.MarkerPositions{m}   = xSteps;
        end
        
        plotstr = sprintf('\tSub Plots: %d\tMarkers: %d',numel(obj.SubPlotObjects), numel(obj.SubPlotMarkers));
        
        debugStamp([obj.ID ':' plotstr], 4);
        
        drawnow expose update;
        
      catch err
        debugStamp(err, 1);
      end
      
    end
    
    function updateLabels(obj)
      for m = 1:numel(obj.LabelObjects)
        obj.updateLabel(m);
      end
      
    end
  end
  
  methods (Access=protected)
    %     function createComponent(obj)
    %
    %       try
    %         componentType = obj.ComponentType;
    %       catch err
    %         error('Grasppe:Component:MissingType', ...
    %           'Unable to determine the component type to create the component.');
    %       end
    %
    %       obj.intializeComponentOptions;
    %
    %       obj.Initialized = true;
    %
    %     end
  end
  
  methods (Static)
    
    function OPTIONS  = DefaultOptions()
      Grasppe.Utilities.DeclareOptions;
    end
  end
  
  
end

