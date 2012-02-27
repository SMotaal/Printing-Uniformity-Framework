classdef upSurface < Plots.upViewComponent
  %UPSURFACE Printing Uniformity Surface Object
  
  properties (Constant = true, Transient = true)
    ComponentType = 'surf';
    ComponentProperties = grasppeHandle.SurfaceProperties;
  end
  
  properties
    DataSource
    DataSet
    DataParameters
    PlotParameters
    PlotSource
    PlotData
    ParentFigure
    ParentFigureObject
    XData
    YData
    ZData
    CData
    Sheet
    Modified
    Parent
  end
  
  methods
    function obj = upSurface(varargin)
      obj.setOptions(obj.Defaults, varargin{:});
      obj.getPatentFigure();
      
      Modified = 1;
    end
    
    function obj = getPatentFigure(obj)
      if isempty(obj.ParentFigure) || ~ishandle(obj.ParentFigure)
        obj.ParentFigure = Plots.upPlotFigure('WindowStyle','docked').Primitive;
%         set(obj.ParentFigure,'WindowStyle','docked');
      end
      try
        obj.ParentFigureObject = get(obj.ParentFigure,'UserData');
      end
    end
    
    function obj = processPlotData(obj)
      try
        obj.retrieveSourceData;
      catch err
        disp(err);
        return;
      end
      
      rows      = obj.PlotSource.metrics.sampleSize(1);
      columns   = obj.PlotSource.metrics.sampleSize(2);
      
      sheet     = obj.Sheet;
      
      [X Y Z]   = meshgrid(1:columns, 1:rows, 1);
      
      surfs     = obj.PlotData.surfs;
      
      regions   = subsref( fieldnames(surfs),           1);      
      fields    = subsref( fieldnames(surfs.(region)),  1);
      
      setData   = obj.PlotData.surfs.(region).(field);
      
      sheetData = squeeze( setData(sheet,:,:,:)  );
      sheetData = substitute(sheetData, nan, 0);
      sheetData = sum(sheetData,1);
      
      Z = reshape(sheetData,size(Z));
      
      setPlotData(X, Y, Z);
      
    end
    
    function obj = setPlotData(XData, YData, ZData)
      obj.setOptions('XData', XData, 'YData', YData, 'ZData', ZData);      
    end
    
    function obj = refreshPlotData(obj)
      set(obj.Primitive, 'XData', obj.XData, 'YData', obj.YData, 'ZData', obj.ZData);
      drawnow expose;
    end
    
    
    function obj = set.Sheet(obj, value)
      obj.Sheet = value;
      obj.Modified = true;
      if ~(obj.Busy)
        obj.updateComponent;
      end
    end
    
    function obj = set.DataParameters(obj, value)
      obj.DataParameters  = value;
      if ~(obj.Busy)
        obj.updateComponent;
      end
    end
    
    function hAxes = get.Parent(obj)
      obj.getPatentFigure();
      
      hFigure = obj.ParentFigure;
      
      hAxes   = obj.ParentFigureObject.getHandle('Plot Axes', 'axes', hFigure);
      if ~isValid('hAxes','handle')
        hAxes   = obj.createHandleObject('axes', hFigure, 'Tag', 'Plot Axes');
      end      
    end
    
    function hAxes = getParentAxes(obj)
      obj.getPatentFigure();
      
      hFigure = obj.ParentFigure;
      oFigure = obj.ParentFigureObject;
      
      hAxes =  oFigure.getHandle('Plot Axes', 'axes', hFigure);
      if ~isValid([hAxes],'handle')
        hAxes   = obj.createHandleObject('axes', hFigure, 'Tag', 'Plot Axes');
      end
    end
    
    function obj = updateComponent(obj)
      if (obj.Modified)
        obj.processPlotData;
      end
      try
        obj.refreshPlotData;
      catch err
        obj.processPlotData;
        obj.refreshPlotData;
      end
      obj.Modified = false;
      obj.updateComponent@Plots.upViewComponent();
    end
    
    
    function [value] = get.DataParameters(obj)
      obj.Busy = true;
      try
        if isempty(obj.DataParameters)
          obj.DataParameters = {100};
        end
        
        if~iscell(obj.DataParameters)
          obj.DataParameters = {obj.DataParameters};
        end
      catch err
        disp(err);
      end
      obj.Busy = false;
      
      value = obj.DataParameters;
    end
    
    function obj = show(obj)
      obj.updateComponent;  % obj.Parent = obj.getParentAxes();
      
      obj.createComponent;
      
      obj.show@Plots.upViewComponent;
      
      try
        obj.ParentFigureObject.show();
      end
      obj.ParentFigureObject.enableRotation();
      commandwindow;
    end
    
    function obj = retrieveSourceData(obj)
      
      args = {};
      
      source = obj.DataSource;
      
      if isValid(source, 'char')
        args = {source, args{:}};
      else
        obj.DataSource = [];
        return;
      end
      
      params = obj.DataParameters;
      
      if isClass(params, 'cell') && ~isempty(params);
        args = {args{:}, params{:}};
      end
      
      [source data params] = Plots.plotUPStats(args{:});
      
      obj.setOptions('DataSource', source.name, 'DataSet', params.dataPatchSet, ...
        'PlotSource', source, 'PlotData', data, 'PlotParamters', params);
      
    end
    
    
    
  end
  
  methods(Static)
    function options  = DefaultOptions( )
      Sheet = 1;
      
      options = WorkspaceVariables(true);
    end
  end
  
  
end

