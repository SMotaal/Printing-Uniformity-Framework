classdef SurfaceObject < InAxesObject
  %SURFACEOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    ComponentType = 'surf';
    
    ComponentProperties = { ...
      'Clipping', ...
      'DisplayName', ...
      'CData', 'CDataMapping', ...
      'XData', 'YData', 'ZData', ...
      {'AntiAliasing' 'LineSmoothing'} ...
      };
    
    ComponentEvents = { ...
      };
    
    DataProperties = {'XData', 'YData', 'ZData'}; %, 'SampleID', 'SourceID', 'SetID'};
    IsRefreshing = false;
  end
  
  properties (SetObservable)
    Clipping, DisplayName='', CData, CDataMapping, XData, YData, ZData
    AntiAliasing = 'on';
  end
  
  properties (Dependent)
    SourceID, SetID, SampleID    
  end
  
  methods (Access=protected)
    function obj = SurfaceObject(parentAxes, varargin)
      obj = obj@InAxesObject(varargin{:},'ParentAxes', parentAxes);
    end
    
    function createComponent(obj, type)
      debugStamp(obj.ID);
      obj.createComponent@GrasppeComponent(type);
      obj.ParentFigure.registerKeyEventHandler(obj);
    end
    
  end
  
  methods
    function refreshPlot(obj, dataSource)
      debugStamp(obj.ID);
      obj.IsRefreshing = true;
      if ~exists('dataSource')
        dataSource = obj.DataSource;
      end
        updating = obj.IsUpdating;
        for property = obj.DataProperties
          try
            obj.IsUpdating = false; obj.(char(property)) = dataSource.(char(property));
          catch err
            disp(err);
          end
          obj.IsUpdating = updating;
        end
      obj.updatePlotTitle(dataSource.SourceID, dataSource.SampleID);
      obj.IsRefreshing = false;
    end
    
    function refreshPlotData(obj, source, event)
      debugStamp(obj.ID);
      try
        dataSource = event.AffectedObject;
        dataField = source.Name;
        try obj.forceSet(dataField, dataSource.(dataField)); end
        %         obj.(dataField) = dataSource.(dataField);
      end
    end
    
    function keyPress(obj, event, source)
      if (stropt(event.Modifier, 'control command'))
        switch event.Key
          case 'uparrow'
            obj.setSheet('+1');
          case 'downarrow'
            obj.setSheet('-1');
        end
      end
    end
    
    function set.SampleID(obj, value)
      obj.setSheet(value);
    end
    
    function value = get.SampleID(obj)
      value = [];
      try value = obj.DataSource.SampleID; end
    end
    
    function set.SourceID(obj, value)
      try obj.DataSource.SourceID = changeSet(obj.DataSource.SourceID, value); end;
      obj.updatePlotTitle;
    end
    
    function value = get.SourceID(obj)
      value = [];
      try value = obj.DataSource.SourceID; end
    end
    
    
    function setSheet(obj, value)
      debugStamp(obj.ID);
      try obj.DataSource.setSheet(value); end
      obj.updatePlotTitle;
    end
    
    function updatePlotTitle(obj, base, sample)      
      try
        obj.ParentFigure.BaseTitle = base;
      catch
        try obj.ParentFigure.BaseTitle = obj.SourceID; end;            
      end
      try
        obj.ParentFigure.SampleTitle = int2str(sample);
      catch      
        try obj.ParentFigure.SampleTitle = int2str(obj.SampleID); end;      
      end
    end
        
  end
  
  
  methods (Static, Hidden)
    function options  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = true;
      
      options = WorkspaceVariables(true);
    end
    
  end
  
  methods (Static)
    function obj = createPlotObject(parentAxes, varargin)
      obj = SurfaceObject(parentAxes, varargin{:});
    end
  end
  
end

