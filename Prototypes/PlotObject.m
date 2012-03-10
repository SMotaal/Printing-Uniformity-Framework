classdef PlotObject < InAxesObject
  %PLOTOBJECT Superclass for plot objects
  %   Detailed explanation goes here
  
  properties
    IsRefreshing = false; 
  end
  
  properties (Dependent)
    SourceID, SetID, SampleID    
  end
  
  methods (Access=protected)
    function obj = PlotObject(parentAxes, varargin)
      try parentAxes.clearAxes; end
      obj = obj@InAxesObject(varargin{:},'ParentAxes', parentAxes);
    end
    
    function createComponent(obj, type)
      debugStamp(obj.ID);
      obj.createComponent@GrasppeComponent(type);
      obj.ParentFigure.registerKeyEventHandler(obj);
    end    
  end
  
  methods    
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
  end
  
  methods
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
  
  methods
    function consumed = keyPress(obj, event, source)
      consumed = false;
      if event.consumed == true
        return;
      end
      if (stropt(event.Modifier, 'control command'))
        consumed = true;
        switch event.Key
          case 'uparrow'
            obj.setSheet('+1');
          case 'downarrow'
            obj.setSheet('-1');
          otherwise
            consumed = false;
        end
      end
    end    
    
    function refreshPlot(obj, dataSource)
      debugStamp(obj.ID);
      try obj.IsRefreshing = true; end
      
      if ~exists('dataSource')
        dataSource = [];
        try dataSource = obj.DataSource; end
      end
      
      try updating = obj.IsUpdating; end
      
      try properties = obj.DataProperties; end
      
      for property = obj.DataProperties
        try obj.IsUpdating = false; end
        try
          obj.(char(property)) = dataSource.(char(property));
        catch err
          try debugStamp(obj.ID); end                      
          if strcmp(err.identifier, 'MATLAB:noSuchMethodOrField')
            try disp(sprintf('\t%s ==> %s',err.identifier, char(property))); end
          else
            disp(err);
          end
        end
        try obj.IsUpdating = updating; end
      end
      
      obj.updatePlotTitle(dataSource.SourceID, dataSource.SampleID);
      
      try obj.IsRefreshing = false; end
    end
    
    function refreshPlotData(obj, source, event)
      debugStamp(obj.ID);
      try
        dataSource = event.AffectedObject;
        dataField = source.Name;
        obj.handleSet(dataField, dataSource.(dataField));
      catch err
        try debugStamp(obj.ID); end
        disp(err);
      end
    end
  end
  
end
