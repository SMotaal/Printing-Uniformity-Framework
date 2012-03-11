classdef MultiPlotFigureObject < PlotFigureObject
  %UPFIGUREOBJECTSMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  %#ok<*MCSUP>
  
  properties
    PlotAxesTargets = []; % = struct('id', [], 'idx', [], 'object', []);
    PlotAxesStack   = [];
    PlotAxesLimit   = 5;
  end
  
  
  methods (Hidden)
    function obj = MultiPlotFigureObject(varargin)
      obj = obj@PlotFigureObject(varargin{:});
    end
  end
  
  %% Functional Properties Getters / Setters
  methods
    
    function updatePlotTitle(obj)
      obj.Title = [obj.BaseTitle ' (' obj.SampleTitle ')']; 
    end
    
  end
  
  methods (Access=protected, Hidden)
    function createComponent(obj, type)
      obj.createComponent@GrasppeComponent(type);
      obj.OverlayAxes = OverlayAxesObject.Create(obj);
      obj.TitleText   = TitleTextObject.Create(obj.OverlayAxes);

      obj.preparePlotAxesStack();
      
      obj.TitleText.updateTitle;
    end
  end
  
  methods
    function preparePlotAxesStack(obj)
      debugStamp(obj.ID);
      plotLimit   = obj.PlotAxesLimit;
      plotStack   = obj.PlotAxesStack;
      plotTargets = obj.PlotAxesTargets;      
      
      if ~iscell(obj.PlotAxes) || ~isstruct(obj.PlotAxesTargets) || ~isnumeric(obj.PlotAxesStack) %|| any(cellfun('isempty',obj.PlotAxes))
        obj.PlotAxesStack = 1:plotLimit;
        obj.PlotAxesTargets = struct('id', [], 'object', []);        
        obj.PlotAxesTargets(1:plotLimit) = struct('id', [], 'object', []);
        obj.PlotAxes = cell(size(obj.PlotAxesTargets));
        obj.createPlotAxes([], []);
        return;
      end
            
      if ~isnumeric(plotStack) || length(plotStack)~=plotLimit
        plotStack   = 1:obj.plotLimit;
        try
          newStacks = setdiff(plotStack, obj.PlotAxesStack);
          plotStack = [newStacks, obj.PlotAxesStack];
        end
      end
      
      if ~isstruct(plotTargets) || length(plotTargets)~=plotLimit
        plotTargets(1:plotLimit) = struct('id', [], 'object', []);
        try
          currentLength = length(obj.PlotAxesTargets);
          plotTargets(1:currentLength) = obj.PlotAxesTargets(:);
        end
      end

      obj.PlotAxesTargets = plotTargets;
      obj.PlotAxesStack   = plotStack;
      obj.PlotAxes        = plotTargets.object;
      
    end
    
    function [plotAxes idx id] = getPlotAxes(obj, target)
      debugStamp(obj.ID);
      idx = []; id = ''; plotAxes =[];
      try
        if isValid('target', 'char')
          try
            id = target;
            idx = strcmpi(target, {obj.PlotAxesTargets.id});
            if any(idx)
              plotAxes = obj.PlotAxesTargets(idx).object;
            end
          end
        elseif isInteger('target')
          try
            plotAxes = obj.PlotAxes{target};
          end
        end
      catch err
      end
      if isempty(plotAxes) || ~PlotAxesObject.checkInheritence(plotAxes)
        [plotAxes idx id] = obj.createPlotAxes(idx, id);
      end

    end
    
    function [plotAxes idx id] = createPlotAxes(obj, idx, id)
      debugStamp(obj.ID);
      nextIdx = idx;  nextID  = id;
      
      nAxes = length(obj.PlotAxes);
      
      plotAxesStruct = struct('id', [], 'object', []);
      
      emptyIdx  = cellfun('isempty', {obj.PlotAxesTargets.object});
      
      if ~isempty(nextID) && ischar(nextID)
        targetIdx = strcmpi(nextID, {obj.PlotAxesTargets.id});
        if any(targetIdx)
          nextIdx = find(targetIdx,1,'first');
        else
          nextIdx = [];
        end
%       else
%         nextID = '';
      end

      if isempty(nextIdx) || ~isnumeric(nextIdx) || nextIdx > nAxes || nextIdx < 1
        if any(emptyIdx);
          nextIdx   = find(emptyIdx,1,'first');          
        else
          obj.PlotAxesStack = obj.PlotAxesStack([2:end 1]);
          nextIdx   = obj.PlotAxesStack(end);
        end
      end
      
      if isempty(nextID) || ~ischar(nextID)
        nextID = '';
      end
      
      plotAxesStruct = obj.PlotAxesTargets(nextIdx);
      
      plotAxesStruct.id = nextID;      
      
      try
        plotAxesStruct.object.clearAxes()
        if ~plotAxesStruct.object.isvalid
          plotAxesStruct.object = PlotAxesObject.Create(obj);
        end
      catch
        plotAxesStruct.object = PlotAxesObject.Create(obj);
      end
      
      obj.PlotAxesTargets(nextIdx)  = plotAxesStruct;
      obj.PlotAxes(nextIdx)         = {plotAxesStruct.object};
      
      plotAxes  = plotAxesStruct.object;
      idx       = nextIdx;      
      id        = nextID;
      
      obj.layoutPlotAxes();
    end
    
  end
  
  %% Plot Objects Getters / Setters
  methods
    
  end
  
  methods (Hidden)
    function resizeComponent(obj)
      try obj.OverlayAxes.resizeComponent; end
      try obj.layoutPlotAxes; end
      try obj.TitleText.resizeComponent; end
    end
    
    function layoutPlotAxes(obj)
      try
      nAxes = obj.PlotAxesLimit;
      
      parentPosition  = pixelPosition(obj.Handle);
      margins         = [20 20 20 40]; % L/B/R/T
      spacing         = 60; %-50;
      padding         = [30 30 30 10];
      minimumSize     = [250 200]; %W/H
      sizingRatio     = 1;
      
      plottingWidth   = parentPosition(3) - margins(1) - margins(3);
      plottingHeight  = parentPosition(4) - margins(2) - margins(4);
      fittingWidth    = plottingWidth; 
      fittingHeight   = plottingHeight;
      fittingRatio    = plottingWidth/plottingHeight; % Width to height ratio;
      
      if fittingRatio > 8/5
        columns       = ceil((nAxes)/(1+fittingRatio) * fittingRatio);
        rows          = floor((nAxes)/columns);
        columns       = ceil((nAxes)/rows);
      elseif fittingRatio < 5/8
        rows          = ceil((nAxes)/(1+fittingRatio));
        columns       = floor((nAxes)/rows);
        rows          = ceil((nAxes)/columns);
      else
        rows          = round((nAxes)/(1+fittingRatio));
        columns       = round((nAxes)/rows);
      end
      
%       disp ([fittingRatio 1/fittingRatio plottingHeight plottingWidth rows columns]);
      
      cellWidth       = floor(plottingWidth/columns);
      cellHeight      = floor(plottingHeight/rows);
      
      fittingWidth    = cellWidth*columns;
      fittingHeight   = cellHeight*rows;
      
      fittingLeft     = margins(1) + (plottingWidth-fittingWidth) / 2;
      fittingBottom   = margins(2) + (plottingHeight-fittingHeight) / 2;
      
      plotWidth       = cellWidth   - spacing;
      plotHeight      = cellHeight  - spacing;
      
      if plotWidth>plotHeight*sizingRatio
        plotWidth = plotHeight*sizingRatio;
      elseif plotHeight>plotWidth/sizingRatio;
        plotHeight = plotWidth/sizingRatio;
      end
      
      plotWidth       = max(minimumSize(1), plotWidth);
      plotHeight      = max(minimumSize(2), plotHeight);
      
      cellWidth       = max(cellWidth, plotWidth);
      cellHeight      = max(cellHeight, plotHeight);
      
      plotSize        = [plotWidth-padding(1)-padding(3) plotHeight-padding(2)-padding(4)];      
           
      cellLeft        = (cellWidth - plotWidth) / 2;
      cellBottom      = (cellHeight - plotHeight) / 2;
     
      
      for i = 1:nAxes
        [row column]  = ind2sub([rows columns], i);
        plotLeft      = fittingLeft   + cellLeft   + padding(1) + (cellWidth  * (column - 1));
        plotBottom    = fittingBottom + cellBottom + padding(2) + (cellHeight * (rows-row));
        if plotBottom < (plottingHeight)
          plotPosition  = round([plotLeft plotBottom plotSize]);
        else
          plotPosition  = round([plotLeft plotBottom [1 1]]);
        end
          %         disp([row column plotPosition]);
          try
            if ~isempty(obj.PlotAxes{i}) && ishandle(obj.PlotAxes{i}.Handle)
              obj.PlotAxes{i}.handleSet('ActivePositionProperty', 'OuterPosition', ...
                'Units', 'pixels', 'Position', plotPosition);
            end
          catch err
            try debugStamp(obj.ID); end
            disp(err);
            disp(obj.PlotAxes{i});
          end
%         else
%           obj.PlotAxes{i}.handleSet('Visible', 'off');
%         end
      end
      
      catch err
        try debugStamp(obj.ID); end
        disp(err);
      end
      
    end
  end
  
  
  methods (Static, Hidden)
    function options  = DefaultOptions( )
      
      WindowTitle   = 'Printing Uniformity Plot';
      BaseTitle     = 'Printing Uniformity';
      Color         = 'white';
      Toolbar       = 'none';  Menubar = 'none';
      WindowStyle   = 'normal';
      Renderer      = 'opengl';
      Parent        = 0;
      
      options = WorkspaceVariables(true);
    end
  end
  
  
end

