classdef PlotDataSource < Grasppe.PrintUniformity.Data.DataSource
  %PLOTDATASOURCE Printing Uniformity Plot Data Source
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    %     HandleProperties = {};
    %     HandleEvents = {};
    %     ComponentType = 'PrintingUniformityPlotDataSource';
    %     ComponentProperties = '';
    %
    %     DataProperties = {'CaseID', 'SetID', 'XData', 'YData', 'ZData', 'SheetID'};
    
    PlotDataSourceProperties = {
      'PlotType',   'Plot Type',        'Plot'   'string',   '';   ...
      'ALim',       'Alpha Map Limits', 'Plot',      'limits',   '';   ...
      'CLim',       'Color Map Limits', 'Plot',      'limits',   '';   ...
      'XLim',       'X Axes Limits',    'Plot',      'limits',   '';   ...
      'YLim',       'Y Axes Limits',    'Plot',      'limits',   '';   ...
      'ZLim',       'Z Axes Limits',    'Plot',      'limits',   '';   ...
      };
  end
  
  properties
    
    UpdatePlotDataFunction     = [];
    
  end
  
  properties (SetObservable, GetObservable)
    
    AspectRatio
    XData, YData, ZData, CData
    CLim,       ALim                      %CLimMode   ALimMode
    XLim,       XTick,      XTickLabel    %XLimMode   XTickMode,  XTickLabelMode
    YLim,       YTick,      YTickLabel    %YLimMode   YTickMode,  YTickLabelMode
    ZLim,       ZTick,      ZTickLabel    %ZLimMode   ZTickMode,  ZTickLabelMode
    
  end
  
  properties (Hidden)
    LinkedPlotObjects = [];
    LinkedPlotHandles = [];
    PlotObjects       = [];
    SheetSteps        = 0;
    NextSheet         = [];
  end
  
  methods
    function xData = get.XData(obj)
      xData = obj.XData;
    end
    function yData = get.YData(obj)
      yData = obj.YData;
    end
    function zData = get.ZData(obj)
      zData = obj.ZData;
    end
    function cData = get.CData(obj)
      cData = obj.CData;
    end
  end
  
  methods
    
    function obj = PlotDataSource(varargin)
      obj = obj@Grasppe.PrintUniformity.Data.DataSource(varargin{:});
      
      args = varargin;
      plotObject = [];
      try
        if Grasppe.Graphics.PlotComponent.checkInheritence(varargin{1})
          plotObject = varargin{1};
          args = varargin(2:end);
        end
      end
      
      %obj.attachPlotObject(plotObject);
      
    end
    
    function [X Y Z] = UpdatePlotData(obj)
      rows        = obj.RowCount;
      columns     = obj.ColumnCount;
      
      dataReader  = obj.Reader;
      data        = dataReader.Data;
      
      [X Y Z] = meshgrid(1:columns, 1:rows, 1);
      
      customFunction        = false;
      
      try customFunction      = all(isa(obj.UpdatePlotDataFunction, 'function_handle')); end
      
      %% Execute Custom Processing Function
      skip                    = false;
      
      if customFunction
        [X Y Z skip]          = obj.UpdatePlotDataFunction(data);
      end
      
      %% Execute Default Processing Function
      if isequal(skip, false)
        %if isequal(dataReader.Parameters.VariableID, 'Raw')
        caseData              = dataReader.CaseData;
        setData               = dataReader.SetData;
        sheetData             = dataReader.SheetData;
        
        targetFilter          = caseData.sampling.masks.Target~=1;
        patchFilter           = setData.filterData.dataFilter~=1;
        
        if ~isempty(sheetData)
          try
            Z(~patchFilter)   = sheetData;
            Z(targetFilter)   = NaN;
            Z(patchFilter)    = NaN;
            
            dataFilter  = ~isnan(Z);
            
            F = TriScatteredInterp(X(dataFilter), Y(dataFilter), Z(dataFilter), 'natural');
            
            Z = F(X, Y);
            Z(targetFilter) = NaN;
          catch err
            debugStamp(err, 1);
            rethrow(err);
          end
        end
        
      end
      
      obj.setPlotData(X, Y, Z);
    end
    
  end
  
  methods (Access=protected)
    
    function fireReaderEvent(obj, source, eventData)
      
      try
        
        % validReader    = isequal(source, obj.reader) && ~isempty(obj.reader);
        
        
        %         try
        %           dispf('SheetID: %d\tNext: %d\tEvent: %s',...
        %             obj.SheetID , obj.NextSheet , eventData);
        %         end
        disp(eventData.EventName);
        switch eventData.EventName
          case 'AttemptingChange'
            try
              if isequal(char(Parameter), 'SheetID')
                if iscalar(obj.NextSheet) && isnumeric(obj.NextSheet) && ~isequal(eventData.NewValue, obj.NextSheet)
                  eventData.NewValue = obj.NextSheet;
                end
              end
            end
          case 'SuccessfulChange'
            if isequal(obj.SheetID, obj.NextSheet)
              obj.SheetSteps  = 0;
              obj.NextSheet   = obj.SheetID;
            elseif isscalar(obj.NextSheet) && isnumeric(obj.NextSheet)
              obj.Reader.SheetID = obj.NextSheet;
            end
          case 'SheetChange'
            obj.updateSheetData;
          case 'VariableChange'
            obj.updateVariableData;
          case 'SetChange'
            obj.updateSetData;
          case 'CaseChange'
            obj.updateCaseData;
          otherwise
        end
        
        obj.fireReaderEvent@Grasppe.PrintUniformity.Data.DataSource(source, eventData);
        
      catch err
        debugStamp(err, 1);
      end
      
    end
    
    function updateSheetData(obj)
      try obj.UpdatePlotData; end
    end
    
    function updateVariableData(obj)
      try obj.optimizeSetLimits; end
      obj.updateSheetData;
    end
    
    function updateSetData(obj)
      try obj.updateVariableData; end
    end
    
    function updateCaseData(obj)
      try obj.updateSetData; end
    end
    
    function setPlotData(obj, XData, YData, ZData)
      try debugStamp(obj.ID, 5); catch, debugStamp(); end;
      
      obj.XData = XData;
      obj.YData = YData;
      obj.ZData = ZData;
      obj.CData = ZData;
      
      obj.updatePlots();
    end
    
  end
  
  
  methods
    function optimizeSetLimits(obj, x, y, z, c)
      
      try debugStamp(obj.ID, 3); catch, debugStamp(); end;
      
      %% Optimize XLim & YLim
      xLim = 'auto';
      yLim = 'auto';
      
      try
        if nargin > 1 && ~isempty(x) % isnumeric(x) && size(x)==[1 2];
          xLim = x;
        else
          xLim = [0 obj.getColumnCount];
        end
      end
      
      try
        if nargin > 2 && ~isempty(y) % isnumeric(y) && size(y)==[1 2];
          yLim = y;
        else
          yLim = [0 obj.getRowCount];
        end
      end
      
      obj.XLim  = xLim;
      obj.YLim  = yLim;
      
      
      %% Optimize ZLim & CLim
      zLim = 'auto';
      cLim = 'auto';
      
      try
        if nargin > 3 && ~isempty(z) % isnumeric(z) && size(z)==[1 2];
          zLim = z;
        else
          setData   = obj.SetData;
          
          zData     = [setData.data(:).zData];
          zMean     = nanmean(zData);
          zStd      = nanstd(zData,1);
          zSigma    = [-3 +3] * zStd;
          
          
          zMedian   = round(zMean*2)/2;
          zRange    = [-3 +3];
          zLim      = zMedian + zRange;
        end
      end
      
      try
        if nargin > 4 && ~isempty(c) % isnumeric(c) && size(c)==[1 2];
          cLim      = c;
        else
          cLim      = zLim;
        end
      end
      
      obj.ZLim      = zLim;
      obj.CLim      = [min(cLim) max(cLim)];
      
      %% Update to LinkedPlots
      try
        plotObject = obj.LinkedPlotObjects;
        
        for m = 1:numel(plotObject)
          try
            plotObject(m).ParentAxes.XLim = obj.XLim;
            %plotObject(m).ParentAxes.handleSet('xlim', obj.XLim);
          end
          try
            plotObject(m).ParentAxes.YLim = obj.YLim;
            %plotObject(m).ParentAxes.handleSet('ylim', obj.YLim);
          end
          try
            plotObject(m).ParentAxes.ZLim = obj.ZLim;
            %plotObject(m).ParentAxes.handleSet('zlim', obj.ZLim);
          end
          try
            plotObject(m).ParentAxes.CLim = obj.CLim;
            %plotObject(m).ParentAxes.handleSet('clim', obj.CLim);
          end
        end
      end
      
      
      %% Display Limits
      limstr = '';
      limids = {'XLim', 'YLim', 'ZLim', 'CLim'};
      limval = {obj.XLim, obj.YLim, obj.ZLim, obj.CLim};
      for m = 1:numel(limids)
        try
          if ischar(limval{m})
            limstr = [limstr sprintf('\t%s[%s]', limids{m}, limval{m})];
          elseif isnumeric(limval{m})
            limstr = [limstr sprintf('\t%s[%2.1f, %2.1f]', limids{m}, limval{m})];
          end
        end
      end
      debugStamp([obj.ID ':' limstr], 4); % dispf('Lims: X [%2.1f, %2.1f] \t Y [%2.1f, %2.1f] \t Z [%2.1f, %2.1f] \t C [%2.1f, %2.1f] '
      
      
    end
    
    function attachPlotObject(obj, plotObject)
      
      if isempty(plotObject) || ~Grasppe.Graphics.PlotComponent.checkInheritence(plotObject)
        return;
      end
      
      try debugStamp(obj.ID, 3); catch, debugStamp(); end;
      
      plotObjects = obj.PlotObjects;
      if ~any(plotObjects==plotObject)
        try
          obj.PlotObjects(end+1) = plotObject;
        catch
          obj.PlotObjects = plotObject;
        end
      end
      
      obj.Reader.UpdateData();
      
      obj.linkPlot(plotObject);
      
      obj.optimizeSetLimits;
    end
    
    
    function sheet = setSheet (obj, sheet)
      
      try debugStamp(obj.ID, 5); catch, debugStamp(); end;
      
      currentSheet    = obj.NextSheet;
      firstSheet      = 1;
      lastSheet       = obj.SheetCount;
      nextSheet       = currentSheet;
      sumSheet        = 0;
      
      
      if ~isnumeric(currentSheet) || ~isscalar(currentSheet)
        currentSheet  = obj.SheetID;
      end
      
      %Parse sheet
      if isInteger(sheet)
        nextSheet = sheet;
      else
        step = 0;
        switch lower(sheet)
          case {'summary', 'sum'}
            nextSheet = sumSheet;
          case {'alpha', 'first', '#1'}
            nextSheet = firstSheet;
          case {'omega', 'last'}
            nextSheet = lastSheet;
          case {'forward',  'next', '+1', '<'}
            if currentSheet>lastSheet, currentSheet=0;
            end
            step = +1;
          case {'previous', 'back', '-1', '>'}
            if currentSheet>lastSheet, currentSheet=1;
            end
            step = -1;
          otherwise
            try
              switch(sheet(1))
                case '+'
                  step = +str2double(sheet(2:end));
                case '-'
                  step = -str2double(sheet(2:end));
              end
            end
        end
        %         obj.SheetSteps = obj.SheetSteps + step;
        %
        %         if ~isequal(obj.SheetSteps, 0)
        nextSheet = stepSet(currentSheet, step, lastSheet, 1);
        %         end
      end
      
      %       try
      %         dispf('SheetID:\tSource: %d\tReader: %d\tParameters: %d\tData: %d',...
      %           obj.SheetID , obj.Reader.SheetID, ...
      %           obj.Reader.Parameters.SheetID, obj.Reader.Data.Parameters.SheetID);
      %       catch err
      %         debugStamp(err,1)
      %       end
      
      % dispf('Sheet #%d >> %s', round(nextSheet), obj.ID);
      obj.NextSheet = nextSheet;
      obj.SheetID   = nextSheet;
      
    end
    
  end
  
  methods (Access=protected)
    
    
    function linkPlot(obj, plotObject)
      try
        if Grasppe.Graphics.PlotComponent.checkInheritence(plotObject)
          plotObject.XData    = 'xData'; ...
            plotObject.YData  = 'yData'; ...
            plotObject.ZData  = 'zData'; % ...
          % plotObject.CData  = 'cData';
          
          try
            obj.LinkedPlotObjects(end+1) = plotObject;
          catch
            obj.LinkedPlotObjects = plotObject;
          end
        end
      catch err
        debugStamp(err, 1);
      end
      obj.validatePlots();
      obj.updatePlots(plotObject.Handle);
    end
    
    function validatePlots(obj)
      try obj.LinkedPlotObjects = unique(obj.LinkedPlotObjects); end
      try obj.LinkedPlotHandles = unique([obj.LinkedPlotObjects.Handle]); end
    end
    
    function updatePlots(obj, linkedPlots)
      xData = obj.XData; yData = obj.YData; zData = obj.ZData;
      
      % cData = obj.CData;
      
      linkedPlots = [];
      
      try
        linkedPlots = unique(linkedPlots);
        if exist('plotObject', 'var') && ...
            Grasppe.Graphics.PlotComponent.checkInheritence(plotObject)
          linkedPlots = linkedPlots.Handle;
        end
      catch err
      end
      
      if isempty(linkedPlots)
        obj.validatePlots;
        linkedPlots = obj.LinkedPlotHandles;
      end
      
      linkedPlots = linkedPlots(ishandle(obj.LinkedPlotHandles));
      try
        refreshdata(linkedPlots, 'caller');
        % disp(['Refreshing Data for ' toString(linkedPlots(:))]);
      catch err
        disp(['Refreshing Data FAILED for ' toString(linkedPlots(:))]);
        % halt(err, 'obj.ID');
        try debugStamp(obj.ID, 2); end
      end
      
      for h = linkedPlots
        plotObject = get(h, 'UserData');
        try plotObject.refreshPlot(obj); end
        % try plotObject.updatePlotTitle; end
      end
    end
    
  end
  
end

