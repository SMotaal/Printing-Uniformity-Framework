classdef UniformitySurfaceObject < UniformityPlotObject & SurfaceObject
  %UNIFORMITYSURFACEPLOT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
%     IsLinked = false;
      ExtendedDataProperties = {};
  end
  
  properties (Dependent)
%     IsLinked;
  end
    
  methods (Access=protected)
    function obj = UniformitySurfaceObject(parentAxes, varargin)
      obj = obj@UniformityPlotObject();      
      obj = obj@SurfaceObject(parentAxes, varargin{:});
    end
    function createComponent(obj, type)
      obj.createComponent@PlotObject(type);
      obj.createComponent@UniformityPlotObject(type);      
    end    
  end
  
  
  methods
    function refreshPlot(obj, dataSource)
      dataProperties = obj.ExtendedDataProperties;
      if isempty(obj.XDataSource)
        dataProperties = {dataProperties{:}, 'XData'};
      end
      if isempty(obj.YDataSource)
        dataProperties = {dataProperties{:}, 'YData'};
      end
      if isempty(obj.ZDataSource)
        dataProperties = {dataProperties{:}, 'ZData'};
      end
      obj.DataProperties = dataProperties;
      if ~isempty(dataProperties) && ~isempty(obj.DataSource)
        obj.refreshPlot@SurfaceObject();
      end
%       debugStamp(obj.ID);
%       try obj.IsRefreshing = true; end
%       if ~exists('dataSource')
%         dataSource = [];
%         try dataSource = obj.DataSource; end
%       end
%       try updating = obj.IsUpdating; end
%       try properties = obj.DataProperties; end
%       for property = obj.DataProperties
%         try obj.IsUpdating = false; end
%         try
%           obj.(char(property)) = dataSource.(char(property));
%         catch err
%           try debugStamp(obj.ID); end                      
%           if strcmp(err.identifier, 'MATLAB:noSuchMethodOrField')
%             try disp(sprintf('\t%s ==> %s',err.identifier, char(property))); end
%           else
%             disp(err);
%           end
%         end
%         try obj.IsUpdating = updating; end
%       end
%       obj.updatePlotTitle(dataSource.SourceID, dataSource.SampleID);
%       try obj.IsRefreshing = false; end
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
  
  methods (Static)
    function obj = Create(parentAxes, varargin)
      obj = UniformitySurfaceObject(parentAxes, varargin{:});
    end
  end
  
  
  methods (Static, Hidden)
    function options  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = true;
%       IsLinkable    = true;
      
      options = WorkspaceVariables(true);
    end
    
  end
  
end

