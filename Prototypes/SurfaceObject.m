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
    
  end
   
  properties (SetObservable)
    Clipping, DisplayName, CData, CDataMapping, XData, YData, ZData
    SourceID, SetID, SampleID
    AntiAliasing = 'on';
  end
  
  properties (Dependent)
    
  end
  
  methods (Access=protected)
    function obj = SurfaceObject(parentAxes, varargin)
      obj = obj@InAxesObject(varargin{:},'ParentAxes', parentAxes);
    end
    function createComponent(obj, type)
      obj.createComponent@GrasppeComponent(type);
      obj.ParentFigure.registerKeyEventHandler(obj);
    end
  end
  
  methods
    function refreshPlotData(obj, source, event)
      try
        dataSource = event.AffectedObject;
        dataField = source.Name;
        obj.(dataField) = dataSource.(dataField);
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
      obj.SampleID = changeSet(obj.SampleID, value);
      try obj.ParentFigure.SampleTitle = int2str(value); end;
      try obj.DataSource.SampleID = changeSet(obj.DataSource.SampleID, value); end;
    end
    
    function set.SourceID(obj, value)
      obj.SourceID = changeSet(obj.SourceID, value);
      try obj.ParentFigure.BaseTitle = value; end;
      try obj.DataSource.SourceID = changeSet(obj.DataSource.SourceID, value); end;
    end
    
    
    function setSheet(obj, value)
      try obj.DataSource.setSheet(value); end
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

