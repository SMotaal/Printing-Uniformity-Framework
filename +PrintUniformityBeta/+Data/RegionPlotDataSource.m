classdef RegionPlotDataSource < PrintUniformityBeta.Data.PlotDataSource & PrintUniformityBeta.Data.UniformityMetricsDataSource
  %UNIFORMITYPLOTDATASOURCE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    PlotRegions                 = [];
    PlotValues                  = [];
    PlotStrings                 = {};
    
    %     try delete(obj.PlotOverlay); end %; catch err, debugStamp(err,1); end
    %     try
    %       obj.PlotOverlay = PrintUniformityBeta.Graphics.UniformityPlotOverlay; ...
    %         obj.registerHandle(obj.PlotOverlay);
    %
    %       obj.PlotOverlay.attachPlot(plotObject);
    %       obj.UpdatePlotLabels;
    
  end
  
  methods
    
    function obj = RegionPlotDataSource(varargin)
      % initializer = true; try initializer = ~isequal(evalin('caller', 'initializer'), true); end
      % disp([mfilename ' initializer: ' num2str(nargout) '<' num2str(initializer)]);
      
      obj                       = obj@PrintUniformityBeta.Data.PlotDataSource(varargin{:});
    end
    
    
    function processCaseData(obj, recursive)
      obj.processCaseData@PrintUniformityBeta.Data.UniformityMetricsDataSource(false);     % non-recursive
      % obj.processCaseData@PrintUniformityBeta.Data.PlotDataSource(false);     % non-recursive
      
      % obj.processRegionMetrics();
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processSetData(); end
    end
    
    function processSetData(obj, recursive)
      obj.processSetData@PrintUniformityBeta.Data.UniformityMetricsDataSource(false);      % non-recursive
      
      obj.resetAxesLimits();
      obj.resetColorMap();
      
      obj.notify('OverlayPlotsDataChange');
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processSheetData(); end
    end
    
    function processSheetData(obj, recursive)
      obj.processSheetData@PrintUniformityBeta.Data.UniformityMetricsDataSource(false);    % non-recursive
      
      if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.processVariableData(); end
    end
    
    function processVariableData(obj, recursive)
      obj.processVariableData@PrintUniformityBeta.Data.UniformityMetricsDataSource(false); % non-recursive
      
      obj.updatePlotData();
      
      obj.notify('OverlayLabelsDataChange');
      
      % if ~exist('recursive', 'var') || ~isequal(recursive, false), obj.updatePlotData(); end
    end
    
    function resetAxesLimits(obj, x, y, z, c)
      rows                        = obj.RowCount;
      columns                     = obj.ColumnCount;
      
      summaryOffset               = obj.summaryOffset;
      summaryLength               = obj.summaryLength;
      
      % offsetRange                 = 1:summaryOffset;
      % summaryRange                = summaryOffset + 1 + [0:summaryLength];
      summaryExtent               = summaryOffset+1+summaryLength;%max(summaryRange);
      
      % xColumns                    = columns+summaryExtent;
      % xColumnRange                = columns+1:xColumns;
      % xRows                       = rows+summaryExtent;
      % xRowRange                   = rows+1:xRows;
      
      obj.resetAxesLimits@PrintUniformityBeta.Data.PlotDataSource(obj, 0:columns+summaryExtent, 0:rows+summaryExtent);
      
    end
    
  end
  
  methods (Access=protected)
    function [X Y Z] = updatePlotData(obj)
      
      rows                      = obj.RowCount;
      columns                   = obj.ColumnCount;
      
      [X Y Z]                   = meshgrid(1:columns, 1:rows, NaN);   % % X = []; Y = []; Z = [];      
      
      sheetID                   = obj.SheetID;
      variableID                = obj.VariableID;
      
      if sheetID == 0, sheetID  = obj.SheetCount+1; end
      
      sheetStatistics           = [];
      try sheetStatistics       = obj.sheetStatistics{sheetID}; end
      
      if isempty(sheetStatistics), sheetStatistics = obj.processRegionStatistics(sheetID, variableID); end
      
      if ~isempty(sheetStatistics) %else  [X Y Z]         = meshgrid(1:obj.RowCount, 1:obj.ColumnCount, NaN);
        tries                   = 0;
        
        while tries < 2
          try
            newData             = sheetStatistics.Data; ...
              Z                 = squeeze(newData);
            [X Y]               = meshgrid(1:size(newData, 2), 1:size(newData, 1));
            
            obj.PlotRegions     = sheetStatistics.Masks;
            obj.PlotValues      = sheetStatistics.Values;
            obj.PlotStrings     = sheetStatistics.Strings;
            tries               = tries + 1;
          catch err
            try sheetStatistics      = obj.processRegionStatistics(sheetID, variableID); end
          end
        end
      end
      
      obj.setPlotData(X, Y, Z);
      
      %       rows                      = obj.RowCount;
      %       columns                   = obj.ColumnCount;
      %
      %       [X Y Z]                   = meshgrid(1:columns, 1:rows, 1);   % % X = []; Y = []; Z = [];
      %
      %       caseData                  = obj.CaseData;
      %       setData                   = obj.SetData;
      %       sheetData                 = obj.SheetData;
      %       variableData              = obj.VariableData;
      %
      %       targetFilter              = caseData.sampling.masks.Target~=1;
      %       patchFilter               = setData.filterData.dataFilter~=1;
      %
      %       if ~isempty(variableData)
      %         try
      %           Z(~patchFilter)       = variableData;
      %           Z(targetFilter)       = NaN;
      %           Z(patchFilter)        = NaN;
      %
      %           dataFilter            = ~isnan(Z);
      %
      %           if isnumeric(obj.ZLim)
      %             Z(Z>max(obj.ZLim) | Z<min(obj.ZLim)) = NaN;
      %           end
      %
      %           rawSurfaceData        = TriScatteredInterp(X(dataFilter), Y(dataFilter), Z(dataFilter), 'natural');
      %
      %           Z                     = rawSurfaceData(X, Y);
      %
      %           Z(targetFilter)       = NaN;
      %
      %         catch err
      %           debugStamp(err, 1, obj);
      %           % rethrow(err);
      %         end
      %       end
      % obj.setPlotData(X, Y, Z);
      
      
    end
    
  end
  
  methods (Static, Hidden)
    function OPTIONS  = DefaultOptions()
      VariableID = 'sections';
      
      GrasppeAlpha.Utilities.DeclareOptions;
    end
  end
  
end

