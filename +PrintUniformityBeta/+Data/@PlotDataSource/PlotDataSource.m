classdef PlotDataSource < PrintUniformityBeta.Data.DataSource & ...
    PrintUniformityBeta.Data.PlotDataEventHandler & PrintUniformityBeta.Data.OverlayDataEventHandler
  %PLOTDATASOURCE Print Uniformity Plot Data Source
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    %     HandleProperties = {};
    %     HandleEvents = {};
    %     ComponentType = 'PrintingUniformityPlotDataSource';
    %     ComponentProperties = '';
    %
    %     DataProperties = {'CaseID', 'SetID', 'XData', 'YData', 'ZData', 'SheetID'};
    
    PlotDataSourceProperties = {
      'PlotType',   'Plot Type',          'Plot'      'string',     '';   ...
      'ALim',       'Alpha Map Limits',   'Plot',     'limits',     '';   ...
      'CLim',       'Color Map Limits',   'Plot',     'limits',     '';   ...
      'XLim',       'X Axes Limits',      'Plot',     'limits',     '';   ...
      'YLim',       'Y Axes Limits',      'Plot',     'limits',     '';   ...
      'ZLim',       'Z Axes Limits',      'Plot',     'limits',     '';   ...
      };
  end
  
  properties (AbortSet, SetObservable, GetObservable)
    
    AspectRatio
    XData, YData, ZData, CData
    CLim,       ALim                      %CLimMode   ALimMode
    XLim,       XTick,      XTickLabel    %XLimMode   XTickMode,  XTickLabelMode
    YLim,       YTick,      YTickLabel    %YLimMode   YTickMode,  YTickLabelMode
    ZLim,       ZTick,      ZTickLabel    %ZLimMode   ZTickMode,  ZTickLabelMode
    
    ColorMap
  end
  
  methods
    function obj = PlotDataSource(varargin)
      obj                       = obj@PrintUniformityBeta.Data.DataSource(varargin{:});
      obj                       = obj@PrintUniformityBeta.Data.PlotDataEventHandler();
      obj                       = obj@PrintUniformityBeta.Data.OverlayDataEventHandler();
      
    end
  end
  
  methods (Access=protected)
    function createComponent(obj)      
      obj.createComponent@PrintUniformityBeta.Data.DataSource;
    end
  end
  
  methods
    resetAxesLimits(obj, x, y, z, c);
    resetColorMap(obj, map);
  end
  
  methods
    function attachPlotObject(obj, plotObject)
      
      try debugStamp(obj.ID, 4); catch, debugStamp(5); end;
      
      try
        obj.resetPlotObjectOptions(plotObject);
        
        if isa(plotObject, 'PrintUniformityBeta.Data.PlotDataEventHandler')
          obj.registerEventHandler('PlotDataEventHandlers',     plotObject);
        end
        
        if isa(plotObject, 'PrintUniformityBeta.Data.OverlayDataEventHandler')
          obj.registerEventHandler('OverlayDataEventHandlers',  plotObject);
        end
        
      catch err
        debugStamp(err, 1, obj);
      end
    end
    
    function detatchPlotObject(obj, plotObject)
      try
        try obj.unregisterEventHandler('PlotDataEventHandlers', plotObject);    end   % if isa(plotObject, 'PrintUniformityBeta.Data.PlotDataEventHandler')
        try obj.unregisterEventHandler('OverlayDataEventHandlers', plotObject); end   % if isa(plotObject, 'PrintUniformityBeta.Data.OverlayDataEventHandler')
        
      catch err
        debugStamp(err, 1, obj);
      end
    end
    
    function resetPlotObjectOptions(obj, plotObject)
      assert(isa(plotObject, 'PrintUniformityBeta.Graphics.UniformityPlotComponent'), ...
        'PrintUniformity:ResetPlot:InvalidType', ...
        'Failed to reset plot object options for type ''%s''. ', class(plotObject));
      
      try plotObject.ParentAxes.setView([0 90], true);        end
      try plotObject.ParentAxes.Box       = false;            end
      try plotObject.ParentAxes.handleSet('Clipping', 'off'); end
    end
    
    function sheet = setSheet (obj, sheet)
      
      try debugStamp(obj.ID, 5); catch, debugStamp(); end;
      
      try
        currentSheet            = obj.SheetID;
        lastSheet               = obj.SheetCount;
        
        if isInteger(sheet)
          nextSheet             = sheet;
        elseif ischar(sheet) && numel(sheet)>0
          switch lower(sheet)
            case {'summary', 'sum'}
              nextSheet         = 0; % sumSheet;
            case {'alpha', 'first', '#1'}
              nextSheet         = 1; % firstSheet;
            case {'omega', 'last'}
              nextSheet         = lastSheet;
            case {'forward',  'next', '+1', '<'}
              if currentSheet>lastSheet, currentSheet = 0; end
              nextSheet         = stepSet(currentSheet, +1, lastSheet, 1); % step = +1;
            case {'previous', 'back', '-1', '>'}
              if currentSheet>lastSheet, currentSheet = 1; end
              nextSheet         = stepSet(currentSheet, -1, lastSheet, 1); % step = -1;
            otherwise
              switch(sheet(1))
                case '+', nextSheet = stepSet(currentSheet, +str2double(sheet(2:end)), lastSheet, 1); % step = +str2double(sheet(2:end));
                case '-', nextSheet = stepSet(currentSheet, -str2double(sheet(2:end)), lastSheet, 1); % step = -str2double(sheet(2:end));
                otherwise
                  error('Invalid Sheet');
              end
          end
        else
          error('Invalid Sheet');
        end
        
        obj.setSheetID(nextSheet);
        
      catch err
        if isnumeric(sheet) || islogical(sheet), sheet = num2str(sheet); end
        error('PrintUniformity:SetSheet:InvalidSheet', 'Could not set sheet to %s.', sheet);
      end

    end
    
  end
  
  methods (Access=protected)
    
    function [X Y Z] = updatePlotData(obj)
      rows                      = obj.RowCount;
      columns                   = obj.ColumnCount;
      
      [X Y Z]                   = meshgrid(1:columns, 1:rows, 1);   % % X = []; Y = []; Z = [];
      
      caseData                  = obj.CaseData;
      setData                   = obj.SetData;
      sheetData                 = obj.SheetData;
      
      targetFilter              = caseData.sampling.masks.Target~=1;
      patchFilter               = setData.filterData.dataFilter~=1;
      
      if ~isempty(sheetData)
        try
          Z(~patchFilter)       = sheetData;
          Z(targetFilter)       = NaN;
          Z(patchFilter)        = NaN;
          
          dataFilter            = ~isnan(Z);
          
          if isnumeric(obj.ZLim)
            Z(Z>max(obj.ZLim) | Z<min(obj.ZLim)) = NaN;
          end
          
          rawSurfaceData        = TriScatteredInterp(X(dataFilter), Y(dataFilter), Z(dataFilter), 'natural');
          
          Z                     = rawSurfaceData(X, Y);
          
          Z(targetFilter)       = NaN;
          
        catch err
          debugStamp(err, 1, obj);
          % rethrow(err);
        end
      end
      
      obj.setPlotData(X, Y, Z);
      
    end
    
    function setPlotData(obj, XData, YData, ZData)
      try debugStamp(obj.ID, 5); catch, debugStamp(); end;
      
      obj.XData = XData;
      obj.YData = YData;
      obj.ZData = ZData;
      obj.CData = ZData;
      
      obj.notify('PlotDataChange');
    end
    
  end
  
  methods
    
    function processCaseData(obj)
      obj.processCaseData@PrintUniformityBeta.Data.DataSource(false);     % non-recursive
      
      obj.processSetData();
    end
    
    function processSetData(obj)
      obj.processSetData@PrintUniformityBeta.Data.DataSource(false);      % non-recursive
      
      obj.resetAxesLimits();
      obj.resetColorMap();
      
      obj.processSheetData();
    end
    
    function processSheetData(obj)
      obj.processSheetData@PrintUniformityBeta.Data.DataSource(false);    % non-recursive
      
      obj.processVariableData();
    end    
    
    function processVariableData(obj)
      obj.processVariableData@PrintUniformityBeta.Data.DataSource(false); % non-recursive
      
      obj.updatePlotData();
    end
    
  end

  methods    
    
  end
  
  methods (Static, Hidden)
    
    function OPTIONS  = DefaultOptions()
      VariableID = 'raw';
      
      GrasppeAlpha.Utilities.DeclareOptions;
    end
  end
  
  
  
end
