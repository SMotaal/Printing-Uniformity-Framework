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
      try debugStamp(obj.ID); catch, debugStamp(); end;
      obj.createComponent@GrasppeComponent(type);
      obj.ParentFigure.registerKeyEventHandler(obj);
    end
    
    function attachDataListeners(obj)
      try
        %% Attach object listeners
        obvProperties = obj.DataProperties;
        
        if ~isempty(obvProperties)
          addlistener(obj, obvProperties, 'PreGet', @PlotObject.gettingDataProperty);
          addlistener(obj, obvProperties, 'PreSet', @PlotObject.settingDataProperty);
        end
      catch err
        try debugStamp(obj.ID); end
        disp(err); %dealwith(err);
      end
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
      try debugStamp(obj.ID); end
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
      try debugStamp(obj.ID); catch, debugStamp(); end;
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
            try debugStamp(obj.ID); end
            disp(err);
          end
        end
        try obj.IsUpdating = updating; end
      end
      
      obj.updatePlotTitle(dataSource.SourceID, dataSource.SampleID);
      
      try obj.IsRefreshing = false; end
    end
    
    function refreshPlotData(obj, source, event)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      try
        dataSource = event.AffectedObject;
        dataField = source.Name;
        obj.handleSet(dataField, dataSource.(dataField));
      catch err
        try debugStamp(obj.ID); end
        disp(err);
      end
    end
    
    function dataSet(obj, property, value)
      try
        if isequal(lower(value), 'auto')
          obj.handleSet([property 'Mode'], 'auto');
          return;
        end
      end
      try
        if ischar(value)
          obj.handleSet([property 'Source'], value);
          return;
        end
      end
      if isnumeric(value)
        obj.handleSet(property, value);
        return;
      end
      try debugStamp(obj.ID);
        disp(sprintf('Could not set %s for %s', property, obj.ID));
      end
    end
    
    function value = dataGet(obj, property)
      try
        value  = obj.handleGet([property 'Source']);
        if ischar(value) && ~isempty(value)
          return;
        end
      end      
      try
        value  = obj.handleGet([property 'Mode']);
        if isequal(lower(value), 'auto')
          return;
        end
      end
      value = obj.handleGet(property);
    end
    
  end
  
  methods (Static)
    function settingDataProperty(source, event)
%       try
%         obj = event.AffectedObject;
%         property = source.name;
%         value = event.
%         obj.handleSet(
      try debugStamp(); catch, debugStamp(); end;
%       disp(event);
    end       
    function gettingDataProperty(source, event)
      try debugStamp(); catch, debugStamp(); end;
%       disp(event);
    end      
%       if ~(isobject(source))
%         obj = event.AffectedObject.UserData;
%       else
%         obj = event.AffectedObject;
%       end
%       if GrasppeComponent.checkInheritence(obj) && isvalid(obj)
%         obj.handlePropertyUpdate(source, event);
%       end
  end
  
end
