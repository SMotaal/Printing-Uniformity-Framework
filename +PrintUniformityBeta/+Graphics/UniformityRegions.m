classdef UniformityRegions < PrintUniformityBeta.Graphics.UniformityPlotComponent & GrasppeAlpha.Graphics.InAxesComponent % < PrintUniformityBeta.Graphics.UniformityPatch
  %UNIFORMITYREGIONS R2013-01
  %   Detailed explanation goes here
  
  properties
    % PressArea
    % SheetArea
    % TargetArea
    %
    % RegionIDs
    % RegionAreas
    % RegionLabels
    %
    % RegionData
    % RegionTrends
    %
    % RegionPrefix
    % RegionClass
    %
    % RegionPatches
    
    PlotLayout
    PlotData
    PlotObjects
    PlotRegions             = PrintUniformityBeta.Models.Visualizer.StatsPlotRegionModel.empty();
    OverlayAxes
    OverlayObjects
    PlotAnnotations         = PrintUniformityBeta.Models.Visualizer.StatsPlotRegionModel.empty();
    XData
    YData
    ZData
    % PlotLabels
    
    % Inherited Plot Component Properties
    % ParentAxes
    % ParentFigure
  end
  
  methods
    function obj = UniformityRegions(parentAxes, dataSource, varargin) % parentAxes, dataSource, varargin
      obj                         = obj@GrasppeAlpha.Graphics.InAxesComponent('ParentAxes', parentAxes);
      obj                         = obj@PrintUniformityBeta.Graphics.UniformityPlotComponent(dataSource, varargin{:});
      
      obj.ParentAxes.HandleObject.BusyAction = 'cancel';
      %try obj.ParentAxes          = parentAxes; end
    end
    
    function attachDataSource(obj, dataSource)
      obj.attachDataSource@PrintUniformityBeta.Graphics.UniformityPlotComponent();
      
      obj.dataSource              = dataSource;
      
      dataSource.attachPlotObject(obj);
      try obj.PlotData                = dataSource.getPlotData(); end
      try obj.OnPlotChange(dataSource); end
      
      if isempty(obj.ParentFigure.DataSources) || ~iscell(obj.ParentFigure.DataSources)
        obj.ParentFigure.DataSources = {};
      end
      
      obj.ParentFigure.DataSources{end+1} = obj.DataSource;
      
      % obj.PlotData                = dataSource.getPlotData();
      
    end
    
    function hLine = updatePlotLine(obj, hLine, yTrend, left, top, width, height, yThreshold)
      
      validHandle               = false;
      if exist('hLine', 'var') && ~isempty(hLine), validHandle = ~isempty(hLine) && all(ishghandle(hLine)); end
      parent                    = obj.ParentAxes.Handle;
      
      lineSpecs                 = [];
      if validHandle, lineSpecs = getappdata(hLine(1), 'RegionLineSpecs'); end
      if ~isstruct(lineSpecs)
        lineSpecs               = struct();
        lineSpecs.yThreshold    = 2.0;
        lineSpecs.zValue        = 0.9;
        lineSpecs.yFactor       = 1;
      end
      
      try
        yTrend                  = [yTrend(10:end-9)];%[yTrend(1:10) yTrend(end-9:end)];
      end
      
      updateTrend               = true;
      try updateTrend           = ~isequal(lineSpecs.yTrend(:), yTrend(:)); end
      
      if exist('yTrend', 'var')       && ~isempty(yTrend),      lineSpecs.yTrend      = reshape(yTrend, 1, []);  end
      if exist('left', 'var')         && ~isempty(left),        lineSpecs.left        = left;       end
      if exist('top', 'var')          && ~isempty(top),         lineSpecs.top         = top;        end
      if exist('width', 'var')        && ~isempty(width),       lineSpecs.width       = width;      end
      if exist('height', 'var')       && ~isempty(height),      lineSpecs.height      = height;     end
      if exist('yThreshold', 'var')   && ~isempty(yThreshold),  lineSpecs.yThreshold  = yThreshold; end
      
      if ~all(isfield(lineSpecs, {'yTrend', 'left', 'top', 'width', 'height', 'zValue', 'yFactor'})), return; end
      
      if updateTrend
        try
          yData               = [0 0 abs(lineSpecs.yTrend) 0 0]; % abs
          
          xSteps              = numel(yData);
          
          xData               = 1:xSteps;                 %linspace(0.5,lineSpecs.width+0.5, xSteps);
          zData               = ones(1, xSteps);
          
          plotType            = 'bars';
          
          switch lower(plotType)
            case 'lines'
              xLine               = min(xData/xSteps,             1)  * lineSpecs.width   + lineSpecs.left;
              yLine               = min(yData/lineSpecs.yFactor,  1)  * lineSpecs.height  + lineSpecs.top;
              if validHandle
                set(hLine, 'XData', xLine(:), 'YData', yLine(:)); %, 'ZData', zLine);
              else
                hLine            = handle(line(xLine(:), yLine(:), 'Parent', parent, ... % 'UserData', obj, ...
                  'LineSmoothing', 'on', 'Linewidth', 0.5, 'LineStyle', '-', 'HitTest', 'off'));
              end
            case 'bars'
              % yData1              = yData.*(yData >=  0);
              % yData2              = yData.*(yData <   0);
              
              xRect               = [xData-1; xData-1; xData; xData; xData-1;]/xSteps;
              yRect               = ([yData*0; yData; yData; yData*0; yData*0;])/lineSpecs.yThreshold/lineSpecs.yFactor; %*
              % yRect1              = ([yData1*0; yData1; yData1; yData1*0; yData1*0;])/lineSpecs.yFactor;
              % yRect2              = ([yData2*0; yData2; yData2; yData2*0; yData2*0;])/lineSpecs.yFactor;
              zRect               = ones(size(xRect));
              
              xLine               = max(min(xRect, 1),0)  * lineSpecs.width   + lineSpecs.left;
              yLine               = max(min(yRect, 1),0)  * lineSpecs.height  + lineSpecs.top;
              % yLine1              = (1/lineSpecs.yFactor + max(min(yRect1, 1),-1) ) * lineSpecs.height  + lineSpecs.top;
              % yLine2              = (1/lineSpecs.yFactor + max(min(yRect2, 1),-1) ) * lineSpecs.height  + lineSpecs.top;
              zLine               =     zRect     * lineSpecs.zValue;
              
              xLine               = [reshape(xLine, 1, []) xLine(1)];
              yLine               = [reshape(yLine, 1, []) yLine(1)];
              % yLine1              = [reshape(yLine1, 1, []) yLine1(1)];
              % yLine2              = [reshape(yLine2, 1, []) yLine2(1)];
              zLine               = [reshape(zLine, 1, []) zLine(1)];
              
              if validHandle
                set(hLine, 'XData', xLine(:), 'YData', yLine(:)); %, 'ZData', zLine);
              else                
                yGridSteps        = unique(max(min(([0:0.5:4])/lineSpecs.yThreshold/lineSpecs.yFactor, 1),0));
                yGridValues       = yGridSteps*lineSpecs.yThreshold*lineSpecs.yFactor;
                yGridMinor        = yGridSteps                          * lineSpecs.height  + lineSpecs.top;
                yGridMajor        = yGridSteps(mod(yGridValues, 1)==0)  * lineSpecs.height  + lineSpecs.top;
                
                yGridLines        = [yGridMinor(:) yGridMinor(:)];
                xGridLines        = repmat([min(xLine) max(xLine)]', 1, numel(yGridSteps))';
                
                for m = 1:numel(yGridSteps)
                  if any(yGridMajor==yGridMinor(m))
                    line(xGridLines(m, :), yGridLines(m, :), 'Parent', parent, ...
                      'LineSmoothing', 'off', 'LineWidth', 0.125, 'LineStyle', ':', 'Color', [1 1 1], ... 
                      'HitTest', 'off'); % hLines(end+1)    = handle();
                  else
                    line(xGridLines(m, :), yGridLines(m, :), 'Parent', parent, ...
                      'LineSmoothing', 'off', 'LineWidth', 0.125, 'LineStyle', ':', 'Color', [1 1 1] * 0.5, ... 
                      'HitTest', 'off'); % hLines(end+1)    = handle();
                  end
                end
                
                hLine             = handle(fill(xLine(:), yLine(:), 'w', 'Parent', parent, ... % 'UserData', obj, ...
                  'LineSmoothing', 'off', 'EdgeColor', [1 1 1] * 0.5, 'linewidth', 0.125, 'LineStyle', '-', ...
                  'HitTest', 'off'));
                
                
              end
              
              % if ~validHandle
              %   hLine(2)            = handle(fill(xLine(:), yLine2(:), 'k', 'Parent', parent, 'UserData', obj, ...
              %     'LineSmoothing', 'on', 'EdgeColor', [1 1 1] * 0.75, 'linewidth', 0.25, 'LineStyle', '-', ...
              %     'HitTest', 'off'));
              %   hLine(1)            = handle(fill(xLine(:), yLine1(:), 'w', 'Parent', parent, 'UserData', obj, ...
              %     'LineSmoothing', 'on', 'EdgeColor', [1 1 1] * 0.25, 'linewidth', 0.25, 'LineStyle', '-', ...
              %     'HitTest', 'off'));
              % end
              
            case 'stairs'
              
              xStairs             = [xData-1; xData; ]  / xSteps;
              yStairs             = [yData;   yData; ]  / lineSpecs.yFactor; %reshape([ 0*zoneData; zoneData; zoneData ], 1, []);
              zStairs             = ones(size(xStairs));
              
              xLine               = min(xStairs,  1)  * lineSpecs.width   + lineSpecs.left;
              yLine               = min(yStairs,  1)  * lineSpecs.height  + lineSpecs.top;
              zLine               =     zStairs       * lineSpecs.zValue;
              
              xLine               = [reshape(xLine, 1, [])];
              yLine               = [reshape(yLine, 1, [])];
              zLine               = [reshape(zLine, 1, [])];
              
              if validHandle
                set(hLine, 'XData', xLine(:), 'YData', yLine(:)); %, 'ZData', zLine);
              else
                hLine(1)          = handle(line(xLine(:), yLine(:), 'Parent', parent, ... % 'UserData', obj, ...
                  'LineSmoothing', 'on', 'linewidth', 1.00, 'LineStyle', '-', 'Color', 'k', ... % 'EdgeColor', [0.5 0.5 0.5],
                  'HitTest', 'off'));
                hLine(2)          = handle(line(xLine(:), yLine(:), 'Parent', parent, ... % 'UserData', obj, ...
                  'LineSmoothing', 'on', 'linewidth', 0.25, 'LineStyle', '-', 'Color', 'w', ... % 'EdgeColor', [0.5 0.5 0.5],
                  'HitTest', 'off'));
                
              end
              
              
              % xStairs             = min(xData/xSteps,             1)  * lineSpecs.width   + lineSpecs.left;
              % yStairs             = min(yData/lineSpecs.yFactor,  1)  * lineSpecs.height  + lineSpecs.top;
              %
              % if validHandle
              %   % set(hLine, 'XData', xLine(:), 'YData', yLine(:)); %, 'ZData', zLine);
              % else
              %   hLine            = handle(stairs(xStairs(:), yStairs(:), 'k', 'Parent', parent, 'UserData', obj, ...
              %     'LineWidth', 2));
              %   hLine            = handle(stairs(xStairs(:), yStairs(:), 'w', 'Parent', parent, 'UserData', obj, ...
              %     'LineWidth', 0.5));
              % end
              
          end
        catch err
          debugStamp(err, 1, obj);
        end
        
      end
      %try uistack(hLine,'bottom'); end
      
      try setappdata(hLine, 'RegionLineSpecs', lineSpecs); end
      
    end
    
    function hPatch = updatePlotPatch(obj, hPatch, value, column, row, width, height, xoffset, yoffset)
      
      validHandle             = nargin>1 && isscalar(hPatch) && ishghandle(hPatch);
      parent                  = obj.ParentAxes.Handle;
      
      patchSpecs              = [];
      if validHandle, patchSpecs = getappdata(hPatch, 'RegionPatchSpecs'); end
      if ~isstruct(patchSpecs), patchSpecs = struct(); end
      
      if exist('column', 'var')   && ~isempty(column),  patchSpecs.column   = column;   end
      if exist('row', 'var')      && ~isempty(row),     patchSpecs.row      = row;      end
      if exist('width', 'var')    && ~isempty(width),   patchSpecs.width    = width;    end
      if exist('height', 'var')   && ~isempty(height),  patchSpecs.height   = height;   end
      if exist('xoffset', 'var')  && ~isempty(xoffset), patchSpecs.xoffset  = xoffset;  end
      if exist('yoffset', 'var')  && ~isempty(yoffset), patchSpecs.yoffset  = yoffset;  end
      
      patchSpecs.zValue       = 0;
      
      if ~isfield(patchSpecs, {'column', 'row', 'width', 'height', 'xoffset', 'yoffset', 'zValue'}), return; end
      
      try
        x                     = (patchSpecs.column  - [0 1 1 0 0]) .* patchSpecs.width  + patchSpecs.xoffset;
        y                     = (patchSpecs.row     - [0 0 1 1 0]) .* patchSpecs.height + patchSpecs.yoffset;
        z                     = (patchSpecs.zValue  * [1 1 1 1 1]);
        if isscalar(value)
          c                   = (value              * [1 1 1 1 1]);
        else
          c                   = value;
        end
        
        % try x = x(1:4); y = y(1:4); z = z(1:4); c = c(1); end
        
        if validHandle
          if isscalar(value)
            set(hPatch, 'XData', x, 'YData', y, 'CData', c); % 'ZData', z,
          else
            set(hPatch, 'XData', x, 'YData', y, 'FaceColor', min(max(c, 0), 1)); % 'ZData', z,
          end
          
          try
            hBorder             = getappdata(hPatch, 'RegionBorderPatch');
            % try delete(hBorder); end  %
            set(hBorder, 'XData', x, 'YData', y);
          end
        else
          if isscalar(value)
            hPatch              = handle(patch(x, y, z, c, 'Parent', parent, ...
              'FaceColor', 'flat', 'EdgeColor', 'none', 'HitTest', 'off'));
          else
            hPatch              = handle(patch(x, y, z, 'Parent', parent, ... % ... 'UserData', obj, ...
              'FaceColor', c, 'EdgeColor', 'none', 'HitTest', 'off')); % , 'linesmoothing', 'on'));
          end
          
          hBorder             = handle(patch([x x(2)], [y y(2)], [z z(2)], 'Parent', parent, ...
            'LineWidth', 1, 'EdgeColor', 'k', 'LineStyle', '-', 'HitTest', 'off', 'FaceColor', 'none', 'Tag', 'BorderOverlay', 'linesmoothing', 'on'));
          
          
          try setappdata(hPatch, 'RegionBorderPatch', hBorder); end
          
          try uistack(hBorder,'top'); end
        end
      catch err
        debugStamp(err, 1, obj);
      end
      
      
      
      try setappdata(hPatch, 'RegionPatchSpecs', patchSpecs); end
      
    end
    
    
    function updateLayout(obj)
      
      try set(obj.ParentFigure.Handle, 'BusyAction', 'cancel'); end
      try set(obj.ParentFigure.Handle, 'RendererMode', 'manual'); end
      
      try
        
        
        try obj.PlotData            = obj.DataSource.PlotData; end
        dataSource                  = obj.DataSource;
        caseData                    = dataSource.CaseData; %  getCaseData();
        patchRows                   = size(caseData.Masks.Region, 2);
        patchColumns                = size(caseData.Masks.Region, 3);
        regionRows                  = caseData.Length.Rows;     % size(caseData.Masks.Around, 1);
        regionColumns               = caseData.Length.Columns;  % size(caseData.Masks.Across, 1);
        sheetCount                  = caseData.Length.Sheets;
        
        obj.PlotLayout              = evaluateStruct({
          'Patch.Rows',           patchRows;
          'Patch.Columns',        patchColumns;
          'Region.Count',         regionRows * regionColumns;
          'Region.Rows',          regionRows;
          'Region.Columns',       regionColumns;
          'Region.Width',         patchRows/regionRows;
          'Region.Height',        patchColumns/regionColumns;
          'Region.Gap',           4; %min(3, max(2, patchRows/regionRows/3));
          'Sheet.Count',          sheetCount;
          });
        
        layout                  = obj.PlotLayout;
        parent                  = obj.ParentAxes.Handle;
        
        %% Reset Parent Axes;
        try
          set(parent, 'Clipping', 'off', 'DataAspectRatio', [1 1 1], 'Box', 'on', ...
            'XTick',        [],   'YTick',        [],   'ZTick',     [],  ...
            'Visible', 'on');
        end
        
        %% Reset Plot Objects
        try delete(obj.PlotObjects);    end
        try delete(obj.OverlayAxes);    end
        try delete(obj.OverlayObjects); end
        try delete(obj.PlotRegions);    end
        
        try cla(obj.ParentAxes.Handle); end
        
        try set(obj.ParentAxes.Handle, 'NextPlot', 'add'); end
        
        xData                   = {};
        yData                   = {};
        zData                   = {};
        plotObjects             = [];
        overlayAxes             = [];
        overlayObjects          = [];
        plotRegions             = PrintUniformityBeta.Models.Visualizer.StatsPlotRegionModel.empty();
        
        plotData                = obj.PlotData;
        
        regionWidth             = layout.Region.Width;
        regionHeight            = layout.Region.Height;
        
        offset                  = layout.Region.Gap;
        xOffsets                = [zeros(1,layout.Region.Columns) offset 0];
        yOffsets                = [zeros(1,layout.Region.Rows)    offset 0];
        
        v                       = 1;
        
        obj.ParentAxes.XLim     = [-1 (1+layout.Region.Columns)*regionWidth+offset + 1];
        obj.ParentAxes.YLim     = [-1 (1+layout.Region.Rows)*regionHeight+offset   + 1];
        set(parent, 'LooseInset', get(parent, 'TightInset') + [2 20 2 2]);
        
        setID                   = dataSource.SetID;
        
        if setID==0
          yThreshold            = 2;
        else
          yThreshold            = min(max(round(4*(log(([setID]*2+1)))/2)/4-0.75, 1.0), 2.5);
                  % min(max(round(4*(log(([0 25 50 75 100]*2+1)))/2)/4-0.75, 1.0), 2.5)
        end
        
        for r = 1:layout.Region.Rows+1
          for c = 1:layout.Region.Columns+1
            
            plotObject            = [];
            labelObject           = [];
            linePlot              = [];
            
            x                     = (c-[0 1 1 0 0]) .* regionWidth  + xOffsets(c);
            y                     = (r-[0 0 1 1 0]) .* regionHeight + yOffsets(r);
            x1                    = (min(x)       );
            y1                    = (min(y)       );
            xCenter               = (max(x)-min(x))/2 + x1;
            yCenter               = (max(y)-min(y))/2 + y1;
            
            try % Patches          % plotObject = handle(patch(x, y, z*0, rand * z, 'Parent', parent));
              plotObject          = obj.updatePlotPatch([], v, c, r, regionWidth, regionHeight, xOffsets(c), yOffsets(r));
              plotObjects         = [plotObjects plotObject];
            end
            
            try % Labels
              labelObject         = handle(text(xCenter, yCenter + regionHeight/8, 1, sprintf('%d:%d', r, c), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'Parent', parent, 'HitTest', 'off', 'Margin', 2, ... 'UserData', obj
                'FontName', 'Gill Sans MT', 'FontSize', 8, 'FontWeight', 'bold')); % 'Interpreter', 'tex'
              
              overlayObjects      = [overlayObjects labelObject];
            end
            
            
            if isequal(obj.ParentFigure.LinePlotVisible, true)            
              try % Line Plots
                yTrend            = zeros(1, sheetCount);
                linePlot          = obj.updatePlotLine([], yTrend, x1, y1, regionWidth, regionHeight, yThreshold);
                overlayObjects    = [overlayObjects linePlot];
              end
            else
              linePlot            = [];
            end
            
            plotRegionsClass    = 'PrintUniformityBeta.Models.Visualizer.StatsPlotRegionModel';
            
            plotRegion          = [];
            try plotRegion      = plotRegions(r, c); end
            
            if ~isa(plotRegion, plotRegionsClass) || ~isvalid(plotRegion);
              plotRegion        = feval(plotRegionsClass);
            end
            
            plotRegion.PlotData   = plotData;
            plotRegion.PlotPatch  = plotObject;
            plotRegion.PlotLabel  = labelObject;
            plotRegion.PlotLine   = linePlot;
            
            plotRegions(r,c)      = plotRegion;
            
          end
        end
        
        %% Extra-Region Annotations
        fX                    = @(c) (c-[0 1 1 0 0]) .* regionWidth;  % + xOffsets(c);
        fY                    = @(r) (r-[0 0 1 1 0]) .* regionHeight; % + yOffsets(r);
        cX                    = @(c) (max(fX(c))-min(fX(c)))/2 + min(fX(c));
        cY                    = @(r) (max(fY(r))-min(fY(r)))/2 + min(fY(r));
        
        
        
        %% Update Object Properties
        
        obj.PlotObjects         = plotObjects;
        obj.OverlayAxes         = overlayAxes;
        obj.OverlayObjects      = overlayObjects;
        obj.PlotRegions         = plotRegions;
        
      catch err
        debugStamp(err, 1, obj);
      end
      
      
      % try uiresume(obj.ParentFigure.Handle); catch, uiresume; end
      
      % drawnow; % update expose;
      
      
      obj.updateData();
      
      % obj.ParentFigure.ColorBar.updateLimits;
      % obj.ParentFigure.ColorBar.createLabels;
      % obj.ParentFigure.ColorBar.createPatches;
      
      try set(obj.ParentFigure.Handle, 'RendererMode', 'auto'); end
      
      try set(obj.ParentFigure.Handle, 'BusyAction', 'queue'); end
      
    end
    
    function updateData(obj)
      
      % try uiwait(obj.ParentFigure.Handle, 3); catch, uiwait; end
      
      try set(obj.ParentFigure.Handle, 'BusyAction', 'cancel'); end
      try set(obj.ParentFigure.Handle, 'RendererMode', 'manual'); end
      
      
      try
        
        
        try obj.PlotData            = obj.DataSource.PlotData; end
        
        plotData                = obj.PlotData;
        plotRegions             = obj.PlotRegions;
        
        plotDataFields          = {'RunData', 'RegionData', 'AroundData', 'AcrossData'};
        
        validPlotData           = false;
        try validPlotData       = ~isempty(plotData) && all(isfield(plotData.DATA, plotDataFields)); end
        if ~validPlotData, return; end
        
        validPlotRegions        = ~isempty(plotRegions);
        
        if ~validPlotRegions
          % obj.updateLayout();
          return;
        end
        
        validPlotDataStructure  = false;
        try validPlotDataStructure = any(cellfun(@(x)isfield(plotData.(x),'Value'), plotDataFields)); end
        
        mismatchPlotData        = ~isequal(obj.PlotData, obj.DataSource.PlotData); % obj.DataSource.getPlotData());
        
        if ~validPlotDataStructure || mismatchPlotData
          try
            obj.PlotData        = obj.DataSource.getPlotData();
          catch err
            debugStamp(err, 1, obj);
            return;
          end
        end
        
        plotData                = obj.PlotData;
        
        runData                 = plotData.RunData;
        regionData              = plotData.RegionData;
        aroundData              = plotData.AroundData;
        acrossData              = plotData.AcrossData;
        
        % runRegion               = plotRegions(end, end);
        % runRegion.PlotLabel.String  = runData.Value.ShortFormat;
        
        try runData.Value.Limits; end
        
        obj.updatePlotRegions(plotRegions(end,      end     ),  runData);
        obj.updatePlotRegions(plotRegions(1:end-1,  1:end-1 ),  regionData);
        obj.updatePlotRegions(plotRegions(end,      1:end-1 ),  acrossData);
        obj.updatePlotRegions(plotRegions(1:end-1,  end     ),  aroundData);
        
        
        % drawnow expose update;
        
        % Hypothetical way to determine patch data without for loops
        % c = 1:10;
        % x=repmat(c',1,5)-repmat([0 1 1 0 0],numel(c),1); y=repmat(c',1,5)-repmat([0 0 1 1 0],numel(c),1);
        % patch(x', y', ones(size(x))');
        % This only makes diagonal patches
        % [x y]               = meshgrid(xPositions, yPositions');
        % z                   = v * ones(size(x));
        % x', y', z', z'
        
      catch err
        debugStamp(err, 1, obj);
      end
      
      try set(obj.ParentFigure.Handle, 'RendererMode', 'auto'); end
      try set(obj.ParentFigure.Handle, 'BusyAction', 'queue'); end
      
      refresh(obj.ParentFigure.Handle);
      % drawnow('update',  'expose')
      GrasppeKit.Utilities.DelayedCall(@(s, e)drawnow('update',  'expose'), 0.5,'start');
      
    end
    
    function updatePlotRegions(obj, roiRegions, roiData)
      
      
      roiValues                     = roiData.Value.Values;
      
      rows                          = size(roiRegions, 1);
      columns                       = size(roiRegions, 2);
      
      sheetID                       = [];
      try sheetID                   = obj.DataSource.SheetID; end
      
      sheetStrings                  = roiData.Value.ShortFormat;
      sheetValues                   = roiData.Value.Values;
      
      
      try
        if isscalar(sheetID)
          if rows==1 && columns==1
            sheetStrings            = roiData.Value.Samples.LongFormat(:,:,sheetID);
          else
            sheetStrings            = roiData.Value.Samples.ShortFormat(:,:,sheetID);
            try
              % if ~isempty(roiData.Ratio.Samples.Values) && ~any(isnan([roiData.Ratio.Values{:}]))
              %   sheetStrings        = strcat(roiData.Ratio.Samples.ShortFormat(:,:,sheetID), ' \newline ', sheetStrings);
              % end
            end
          end
          sheetValues               = roiData.Value.Samples.Values(:,:,sheetID);
        end
      end
      
      try
        %if isempty(sheetID) || isequal(sheetID, 0)
        % try
        %   if ~isempty(roiData.Rank.Values) && ~any(isnan([roiData.Rank.Values{:}]))
        %     sheetStrings        = strcat(roiData.Rank.ShortFormat, ' \newline ', sheetStrings);
        %   end
        % end
        try
          if ~isempty(roiData.Ratio.Values) && ~any(isnan([roiData.Ratio.Values{:}]))
            sheetStrings          = strcat(roiData.Ratio.ShortFormat, {' \newline '}, sheetStrings);
            % sheetStrings          = strcat('{\fontsize{8}', roiData.Ratio.ShortFormat, '}', {' \newline '}, sheetStrings);
          end
        end
        try
          if ~isempty(roiData.Factors.Values) && ~any(isnan([roiData.Factors.Values{:}]))
            sheetStrings          = strcat(sheetStrings, {' \newline '}, roiData.Factors.ShortFormat);
            %sheetStrings          = strcat(sheetStrings, {' \newline '}, '{\fontsize{8}', roiData.Factors.ShortFormat, '}');
          end
        end
        %end
      end
      
      clims                         = get(obj.ParentAxes.Handle, 'clim');
      
      updateColorBar                = false;
      
      try
        updateColorBar              = updateColorBar || ...
          min(obj.ParentFigure.ColorBar.LabelData(:))==clims(1) && ...
          max(obj.ParentFigure.ColorBar.LabelData(:))==clims(2);
      end
      
      try
        updateColorBar              = updateColorBar || ~isequal(clims, roiData.Value.Limits);
      end
      
      if ~updateColorBar
        %obj.DataSource.notify('PlotMapChange');
        try obj.ParentFigure.ColorBar.updateLimits(); end
        try obj.ParentFigure.ColorBar.createLabels(); end
        %beep();
      end
      
      cmap                          = colormap(obj.ParentFigure.Handle);
      clims                         = roiData.Value.Limits; % get(obj.ParentAxes.Handle, 'clim');
      set(obj.ParentAxes.Handle, 'clim', clims);
      
      %cform                         = makecform('srgb2lab');
      srgb2lab                      = @(c)Color.sRGB2Lab(c(:)); % ;applycform(c, cform);
      
      patchValues                   = min(max([sheetValues{:}], min(clims)), max(clims));
      patchColors                   = reshape(interp1(clims, [1 size(cmap,1)], patchValues), size(sheetValues));
      % interp1(clims, [1 size(cmap,1)], cvalue) % , 'spline', 'extrap'
      
      n = size(roiData.Series, 3);
      
      for r = 1:rows
        for c = 1:columns
          try
            region                    = roiRegions(r, c);
            region.PlotLabel.String   = regexpi(sheetStrings{r, c}, '[^"\s*\\newline\s*"]+', 'match');%[sheetStrings{r, c}];
            
            try
              regionSheetValues       = NaN(1, n);
              regionSheetValues(1:n)  = roiData.Series(r, c, :); % cell2mat());
              obj.updatePlotLine(region.PlotLine, regionSheetValues);
            catch err
              debugStamp(err, 1, obj);
            end
            try
              % sheetValue                  = sheetValues{r, c};
              % cvalue                      = min(max(sheetValue, min(clims)), max(clims));
              %patchColor                  = cmap(fix(interp1(clims, [1 size(cmap,1)], cvalue))); %interp1(1:size(cmap,1), cmap(:,:), interp1(clims, [1 size(cmap,1)], cvalue), 'spline', 'extrap');
              patchColor                  = cmap(fix(patchColors(r, c)), :);
              patchColor                  = min(max(patchColor, 0), 1);
              
              obj.updatePlotPatch(region.PlotPatch, patchColor);
              
              try
                
                % region.PlotLabel.BackgroundColor = patchColor;
                region.PlotLabel.BackgroundColor = 'none';
                
                patchLightness   =  1;
                %try patchLightness = rgb2hsv(patchColor); patchLightness = patchLightness(3); end
                try patchLightness = srgb2lab(patchColor); patchLightness = patchLightness(1)/100; end
                
                if patchLightness < 0.75 %max(patchLightness) < 0.75 && mean(patchLightness)<0.75
                  region.PlotLabel.Color = 'w';
                  try region.PlotLine.FaceColor = [1 1 1] * 0.5; end
                  try region.PlotLine.EdgeColor = 'k'; end
                else
                  region.PlotLabel.Color = 'k';
                  try region.PlotLine.FaceColor = 'w'; end
                  try region.PlotLine.EdgeColor = [1 1 1] * 0.5; end
                end
                
              catch err
                try region.PlotLabel.BackgroundColor = 'none'; end
              end
            catch err
              % debugStamp(err, 1, obj);
            end
            % regionSheetValues         = roiData.Value.Samples(r, c, :);
          catch err
            % debugStamp(err, 1, obj);
          end
          
          %try uistack(region.PlotLine,'bottom'); end
          %try uistack(region.PlotPatch,'bottom'); end
          %try uistack(region.PlotLabel,'top'); end
          
        end
      end
      
      obj.updatePlotTitle();
      
    end
    
    
    function updatePlotOverlay(obj)
      obj.updateLayout();
      %obj.updateData();
    end
    
    function updatePlotTitle(obj, base, sheetName, state)
      % obj.ParentFigure;
      % sheetName = '';
      
      try caseName  = obj.DataSource.Reader.GetCaseTag;  end
      try setName   = obj.DataSource.SetName;   end
      try if nargin<2 || isempty(sheetName), sheetName = obj.DataSource.SheetName; end; end
      
      %try
      if ~exist('state', 'var'), state = []; end
      
      if isempty(state) && ~isequal(obj.DataSource.NextSheetID, obj.DataSource.SheetID)
        state   = obj.DataSource.GetSheetName(obj.DataSource.NextSheetID);
      end
      %end
      
      try nextIndex   = state; end %int2str(obj.DataSource.NextSheetID); end
      try sheetIndex  = sheetName; end % int2str(obj.DataSource.SheetID); end
            
      titleStar     = '';
      try if obj.ParentFigure.ActivePlotAxes == obj.ParentAxes, titleStar = ' *'; end; end
      
      if ischar(state)
        try title(obj.ParentAxes.Handle, [caseName ' ' setName ' ' sheetName ' (' state ')' titleStar], 'FontSize', 9, 'FontUnit', 'point', 'FontName', 'Gill Sans MT', 'FontWeight', 'Bold'); end
        try obj.ParentFigure.SampleTitle = sheetIndex; end;
        try obj.ParentFigure.WindowTitle = ['Printing Uniformity - ' caseName ':' sheetIndex ' - ' nextIndex]; end;
        refresh(obj.ParentFigure.Handle);
        % beep();
      else
        try title(obj.ParentAxes.Handle, [caseName ' ' setName ' ' sheetName titleStar], 'FontSize', 9, 'FontUnit', 'point', 'FontName', 'Gill Sans MT', 'FontWeight', 'Bold'); end        
        try obj.ParentFigure.BaseTitle    = [caseName ' ' setName]; end;
        try obj.ParentFigure.SampleTitle  = sheetIndex; end;
        try obj.ParentFigure.WindowTitle = ['Printing Uniformity - ' sheetIndex '']; end;
      end
      
      % drawnow update;
      % drawnow expose update;
    end
    
    function OnPlotTitleChange(obj, source, event)        % Plot data has changed (need to refresh plot)
      obj.updatePlotTitle();
    end
    
    function OnPlotDataChange(obj, source, event)        % Plot data has changed (need to refresh plot)
      obj.updateData();
      obj.updatePlotTitle();
    end
    
    % function OnPlotMapChange(obj, source, event)        % Plot data has changed (need to refresh plot)
    %   % obj.ParentFigure.ColorBar.updateLimits;
    %   obj.ParentFigure.ColorBar.createPatches;
    %   obj.ParentFigure.ColorBar.createLabels;
    % end
    
    function OnOverlayPlotsDataChange(obj, source, event)        % Plot data has changed (need to refresh plot)
      obj.updateLayout();
      
      try obj.ParentFigure.ColorBar.updateLimits; end
      try obj.ParentFigure.ColorBar.createLabels; end
      try obj.ParentFigure.ColorBar.createPatches; end      
      %obj.updateData();
    end
    
    % function OnMouseDown(obj, source, event)
    % end
    %
    % function OnMouseUp(obj, source, event)
    % end
    %
    % function OnMouseMotion(obj, source, event)
    % end
    %
    % function OnMouseWheel(obj, source, event)
    % end
    %
    % function OnMouseClick(obj, source, event)
    %   beep();
    % end
    %
    % function OnMouseDoubleClick(obj, source, event)
    %   disp(event);
    % end
    %
    % function OnMousePan(obj, source, event)
    %   % disp(event.Data);
    % end
    %
    % function OnMouseScroll(obj, source, event)
    %   % disp(event.Data);
    %   % disp(event.Data.Scrolling.Vertical);
    % end
  end
  
  methods (Access=protected)
    function createComponent(obj)
      % obj.createComponent@GrasppeAlpha.Graphics.InAxesComponent();
      obj.intializeComponentOptions;
      
      mouseEvents = {'MouseDown', 'MouseUp', 'MouseMotion', 'MouseWheel', 'MouseClick', ...
        'MouseDoubleClick', 'MousePan', 'MouseScroll'};
      
      % for m = 1:numel(mouseEvents)
      %
      % end
      
      obj.ParentAxes.registerMouseEventHandler(obj);
      % obj.ParentFigure.registerMouseEventHandler(obj);
      
      obj.Initialized = true;
      
      % obj.createComponent@GrasppeAlpha.Core.Component();
      % obj.createHandlePropertyMap();
      % obj.createHandleObject();
      %
      % showComponent = isempty(obj.IsVisible) || isOn(obj.IsVisible);
      % obj.IsVisible = false;
      % if ishandle(obj.Handle)
      %   try obj.handleSet('UserData', obj); end
      %   obj.HandleObject = handle(obj.Handle);
      %   obj.registerHandle(obj.Handle);
      %   obj.attachHandleProperties();
      % end
      %
      % try refresh(obj.Handle); end
      %
      % if showComponent
      %   obj.IsVisible = true;
      % end
    end
  end
  
end


% x                   = (c-[0 1 1 0 0]) .* regionWidth  + xOffsets(c);
% y                   = (r-[0 0 1 1 0]) .* regionHeight + yOffsets(r);
% z                   = (v*[1 1 1 1 1]);
% xSteps              = 100;
% xTrend              = rand(1,xSteps);
% yTrend              = rand(1,xSteps);
% xLine               = min(x) + linspace(0,regionWidth, xSteps);
% yLine               = min(y) + yTrend*regionHeight/4;
% zLine               = ones(size(xLine))*0.9;

% handle(line( ...
%   xLine, yLine, zLine, 'Parent', parent, ...
%   'color', [0.5 0.5 0.5], 'linewidth', 1, 'LineStyle', '-', ...
%   'Visible', 'on', 'HitTest', 'off')); %'Tag', '@Screen',
