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
    
    GetPlotDataFunction     = [];
    
  end
  
  properties (AbortSet, SetObservable, GetObservable)
    
    AspectRatio
    XData, YData, ZData, CData
    CLim,       ALim                      %CLimMode   ALimMode
    XLim,       XTick,      XTickLabel    %XLimMode   XTickMode,  XTickLabelMode
    YLim,       YTick,      YTickLabel    %YLimMode   YTickMode,  YTickLabelMode
    ZLim,       ZTick,      ZTickLabel    %ZLimMode   ZTickMode,  ZTickLabelMode
    
    PatchGrid = [];
  end
  
  properties (Hidden)
    LinkedPlotObjects = [];
    LinkedPlotHandles = [];
    PlotObjects       = [];
    SheetSteps        = 0;
    NextSheet         = 0;
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
      
      % if ~isempty(obj.VariableID, obj.Reader.VariableID = obj.VariableID; end
      
%       try obj.Reader.Parameters.CaseID = obj.CaseID; end
%       try obj.Reader.Parameters.SetID = obj.SetID; end
%       try obj.Reader.Parameters.VariableID = obj.VariableID; end
%       try obj.Reader.Parameters.SheetID = obj.SheetID; end
      
      obj.Reader.UpdateData();
      %obj.attachPlotObject(plotObject);
      
    end
  end
  
  methods
    
    function ProcessCaseData(obj, eventData)
      obj.ProcessCaseData@Grasppe.PrintUniformity.Data.DataSource(eventData);
      obj.ProcessSetData();
    end
    
    function ProcessSetData(obj, eventData)
      if nargin>1
        obj.ProcessSetData@Grasppe.PrintUniformity.Data.DataSource(eventData);
      end
      obj.ProcessVariableData();
    end
    
    function ProcessVariableData(obj, eventData)
      try obj.optimizeSetLimits;  end
      try obj.ResetColorMaps;     end
      if nargin>1
        obj.ProcessVariableData@Grasppe.PrintUniformity.Data.DataSource(eventData);
      end
      obj.ProcessSheetData();
    end
    
    function ProcessSheetData(obj, eventData)
      if nargin>1
        dispf('Plot Source Process %s:\tCurrent:%d\tPrevious:%d\tNew:%d\tReader:%d\tNext:%d', eventData.EventName, eventData.CurrentValue, eventData.PreviousValue, eventData.NewValue, obj.Reader.SheetID,  obj.NextSheet);
        try if any(strcmpi(eventData.Parameter, 'SheetID')) && ~isequal(obj.NextSheet, eventData.NewValue), return; end; end;
      end
      obj.UpdatePlotData;
      if nargin>1      
        obj.ProcessSheetData@Grasppe.PrintUniformity.Data.DataSource(eventData);
      end
    end
    
    function OnDataLoad(obj, eventData)
      try Parameter = eventData.Parameter;  end
      try Value     = eventData.NewValue;   end
      if isequal(char(Parameter), 'SheetID')
        try obj.LinkedPlotObjects(1).ParentFigure.SampleTitle = obj.Reader.GetSheetName(obj.NextSheet); end
        drawnow expose update;
        
        if isscalar(obj.NextSheet) && isnumeric(obj.NextSheet) && ~isequal(eventData.NewValue, obj.NextSheet)
          eventData.Abort('interrupt');
          return;
        end
%       else
%         state = 'Loading...';
%         try state = ['Loading ' eventData.Parameter ' ' toString(eventData.NewValue) '...' ]; end
%         try UI.setStatus(state, obj.PlotObjects(1).ParentFigure.Handle); end
      end
      
      % state = 'Loading...';
      % try state = ['Loading ' eventData.Parameter ' ' toString(eventData.NewValue) '...' ]; end
      % try UI.setStatus(state, obj.PlotObjects(1).ParentFigure.Handle); end
      
      
      obj.OnDataLoad@Grasppe.PrintUniformity.Data.DataSource(eventData);
    end
    
    function OnDataSuccess(obj, eventData)
      try
        try Parameter = eventData.Parameter;  end
        try Value     = eventData.NewValue;   end
        if isequal(char(Parameter), 'SheetID')
          
          if isequal(obj.Reader.SheetID, obj.NextSheet)
            obj.SheetSteps  = 0;
            %obj.NextSheet   = obj.SheetID;
          elseif isscalar(obj.NextSheet) && isnumeric(obj.NextSheet)
            obj.Reader.SheetID = obj.NextSheet;
            %error('Grasppe:Abort:Error', 'Nothing really!');
          end
          
          %dispf('Success: %d %d %d', eventData.NewValue, obj.Reader.SheetID,  obj.NextSheet);
%         else
%           try UI.setStatus('Updating...', obj.PlotObjects(1).ParentFigure.Handle); end
        end
        
      end
      
      % try UI.setStatus('Updating...', obj.PlotObjects(1).ParentFigure.Handle); end
      
      obj.OnDataSuccess@Grasppe.PrintUniformity.Data.DataSource(eventData);
      
      % try GrasppeKit.DelayedCall(@(s, e) UI.setStatus('', obj.PlotObjects(1).ParentFigure.Handle), 1, 'start'); end
    end
    
    function OnDataFailure(obj, eventData)
      % try UI.setStatus('Terminating...', obj.PlotObjects(1).ParentFigure); end
      obj.OnDataFailure@Grasppe.PrintUniformity.Data.DataSource(eventData);
      % try UI.setStatus('', obj.PlotObjects(1).ParentFigure.Handle); end
    end
    
    
    function [X Y Z] = UpdatePlotData(obj)
      rows        = obj.RowCount;
      columns     = obj.ColumnCount;
      
      dataReader  = obj.Reader;
      data        = dataReader.Data;
           
      customFunction          = false;
      
      try customFunction      = all(isa(obj.GetPlotDataFunction, 'function_handle')); end
      
      %% Execute Custom Processing Function
      X = []; Y = []; Z = [];
      skip                    = false;
      
      if customFunction
        [X Y Z skip]          = obj.GetPlotDataFunction(data);
      end
      
      %% Execute Default Processing Function
      if isequal(skip, false)
        if isempty(X) || isempty(Y) || isempty(Z)
          [X Y Z] = meshgrid(1:columns, 1:rows, 1);
        end
        
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
            
            if isnumeric(obj.ZLim)
              Z(Z>max(obj.ZLim) | Z<min(obj.ZLim)) = NaN;
            end
            
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
          xLim = [0 obj.ColumnCount];
        end
      end
      
      try
        if nargin > 2 && ~isempty(y) % isnumeric(y) && size(y)==[1 2];
          yLim = y;
        else
          yLim = [0 obj.RowCount];
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
          try plotObject(m).ParentAxes.XLim = obj.XLim; end
          try plotObject(m).ParentAxes.YLim = obj.YLim; end
          try plotObject(m).ParentAxes.ZLim = obj.ZLim; end
          try plotObject(m).ParentAxes.CLim = obj.CLim; end
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
      
      obj.ResetColorMaps;
      
      obj.PlotObjects(1).ParentFigure.ColorBar.createPatches;
      obj.PlotObjects(1).ParentFigure.ColorBar.createLabels;
      
      
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
      
      %obj.Reader.UpdateData();
      
      obj.linkPlot(plotObject);
      
      obj.optimizeSetLimits;
      
      obj.ResetColorMaps;
    end
    
    
    function sheet = setSheet (obj, sheet)
      
      try debugStamp(obj.ID, 5); catch, debugStamp(); end;
      
      currentSheet    = obj.NextSheet;
      firstSheet      = 1;
      lastSheet       = obj.SheetCount;
      nextSheet       = [];
      sumSheet        = 0;
      
      
      if ~isnumeric(currentSheet) || ~isscalar(currentSheet)
        currentSheet  = obj.SheetID;
        obj.NextSheet = obj.SheetID;
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

        if isempty(nextSheet)
          nextSheet = stepSet(currentSheet, step, lastSheet, 1);
        end
        %         end
      end

      obj.LinkedPlotObjects(1).ParentFigure.SampleTitle = obj.Reader.GetSheetName(nextSheet);
      drawnow expose update;
      
      obj.NextSheet = nextSheet;
      obj.SheetID   = nextSheet;
      
    end
    
  end
  
  methods (Access=protected)
    
    function ResetPlot(obj, plotObject)
      try
        if Grasppe.Graphics.PlotComponent.checkInheritence(plotObject)
          plotObject.ParentAxes.AspectRatio = [10 10 2];
          plotObject.ParentAxes.ViewLock    = false;
          plotObject.ParentAxes.Box         = false;
        end
      end
    end
    
    function ResetColorMaps(obj, map)
      try
        cmap = [ ...
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
          
%         smap          = diff(obj.CLim)/2;
%         cmap(:,1)     = ...
%           [linspace(0,  0,  smap)  0     0          1/4     1/4     1/2   linspace(1, 1, smap)  ];
%         cmap(:,2)     = ...
%           [linspace(0,  7/8,  smap)  7/8     7/8     1      1     1     linspace(1, 0, smap) ];
%         cmap(:,3)     = ...
%           [linspace(1,  1,  smap)  1/2   1/4   1/4     0       0     linspace(0, 0, smap)    ];
%         cmap(:,2)     = linspace(0.95, 0, size(cmap,1));
%         cmap(:,3)     = cmap(:,2);
        
        %cmap = [flipud(cmap); cmap(2:end,:)];
        
        cmap = flipud(cmap);
        
        plotObject = obj.LinkedPlotObjects;
        
        for m = 1:numel(plotObject)
          hax         = plotObject(m).ParentAxes.Handle;
          try colormap(hax, cmap); end
          try set(hax, 'XTick', [], 'YTick', [], 'ZTick', []); end
        end
      end
      
    end
    
    function linkPlot(obj, plotObject)
      try
        if Grasppe.Graphics.PlotComponent.checkInheritence(plotObject)
          obj.ResetPlot(plotObject);
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
      z = zData; z(isnan(z)) = 100;
      obj.PatchGrid = z;
      
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
      
      % try UI.setStatus('', obj.PlotObjects(1).ParentFigure.Handle); end      
    end
    
  end
  
end

