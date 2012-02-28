classdef upSurface < Plots.upAxesObject
  %UPSURFACE Printing Uniformity Surface Object
  
  properties (Constant = true, Transient = true)
    ComponentType = 'surf';
    ComponentProperties = Plots.upGrasppeHandle.SurfaceProperties;
  end
  
  properties
    DataSource
    DataSet
    DataParameters
    PlotParameters
    PlotSource
    PlotData
    XData
    YData
    ZData
    CData
    Sheet
    Modified
  end
  
  methods
    function obj = upSurface(parentFigure, varargin)
      obj = obj@Plots.upAxesObject(parentFigure, varargin{:});
      obj.createComponent;      
      obj.Modified = 1;
    end
    
%     function obj = getPatentFigure(obj)
%       persistent locked;
%       
%       if isVerified('locked', true), return; end; locked = true;
%       
%       try
%         if ~isValidHandle(obj.ParentFigure)
%           obj.ParentFigureObject = Plots.upPlotFigure('WindowStyle','docked');
%           obj.ParentFigure = obj.ParentFigureObject.Primitive;
%         end
%       catch err
%         locked = false; rethrow(err);
%       end
%       
%       locked = false;
%     end
%     function obj = set.ParentFigure(obj, hFigure)
%       if isValidHandle(hFigure)
%         validParent = isValidHandle('obj.ParentFigureObject.Primitive');
%         if (~isequal(hFigure,obj.ParentFigureObject.Primitive))
%           obj.ParentFigureObject = getUserData(hFigure);
%         end
%       end
%       if ~isequal(obj.Parent, obj.PlotAxes)
%         obj.setOptions('Parent', obj.PlotAxes);
%       end
%       if isValidHandle('obj.ParentFigureObject.Primitive')
%         if isequal(obj.ParentFigureObject.Primitive, value)
%           return;
%         else
%         end
%       else
%         obj.ParentFigureObject = get(obj.ParentFigure,'UserData');
%       end
%       if ~isequal(obj.ParentFigureObject, value)
%       
%     end    
    
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
      
      region    = subrange( fieldnames(surfs),           {1});
      field     = subrange( fieldnames(surfs.(region)),  {1});
      
      setData   = obj.PlotData.surfs.(region).(field);
      
      sheetData = squeeze( setData(sheet,:,:,:)  );
      sheetData = substitute(sheetData, nan, 0);
      sheetData = sum(sheetData,1);
      
      Z = reshape(sheetData,size(Z));
      
      obj.setPlotData(X, Y, Z);
      
    end
    
    function obj = setPlotData(obj, XData, YData, ZData)
      obj.setOptions('XData', XData, 'YData', YData, 'ZData', ZData);
    end
    
    function obj = refreshPlotData(obj)
      if isValidHandle(obj.Primitive)
        obj.Set('XData', obj.XData, 'YData', obj.YData, 'ZData', obj.ZData);
      end
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
    
%     
%     function hFigure = get.ParentFigure(obj)
% %       obj.getPatentFigure();
%       if isValidHandle('obj.ParentFigureObject.Primitive')
%         hFigure = obj.ParentFigureObject.Primitive;
%       else
%         hFigure = [];
%       end
%     end
    
    
    %     function hParent = getParent(obj)
    %       obj.getPatentFigure();
    %
    %       hParent = obj.ParentFigureObject.PlotAxes();
    %
    %       if ~isequal(hParent, obj.Parent)
    %         setOptions('Parent', obj.Parent);
    %       end
    %
    %     end
    
    %     function hAxes = getParentAxes(obj)
    %       obj.getPatentFigure();
    %
    %       hFigure = obj.ParentFigure;
    %       oFigure = obj.ParentFigureObject;
    %
    %       hAxes =  oFigure.getHandle('Plot Axes', 'axes', hFigure);
    %       if ~isValid([hAxes],'handle')
    %         hAxes   = obj.createHandleObject('axes', hFigure, 'Tag', 'Plot Axes');
    %       end
    %     end
    
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
%       obj.getPatentFigure();
      
      obj.updateComponent;  % obj.Parent = obj.getParentAxes();
            
      obj.show@Plots.upViewComponent;
      
      try
        obj.ParentFigureObject.show();
      end
      %       obj.ParentFigureObject.enableRotation();
%       commandwindow;
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
    function options  = DefaultOptions()
      Sheet = 1;
      
      options = WorkspaceVariables(true);
    end
  end
  
  
end

