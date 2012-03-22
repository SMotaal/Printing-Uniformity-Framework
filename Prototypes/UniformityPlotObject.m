classdef UniformityPlotObject < GrasppePrototype & GrasppeHandle
  %UNIFORMITYPLOTOBJECT Co-superclass for printing uniformity plot objects
  %   Detailed explanation goes here
  
  properties (SetObservable, GetObservable)
    DataSource
    LinkedProperties
  end
  
  properties (Dependent)
    %     IsLinked;
  end
  
  methods (Access=protected)
    %     function obj = UniformityPlotObject(parentAxes, varargin)
    %       obj = obj@PlotObject(parentAxes, varargin{:});
    %     end
    
    function createComponent(obj, type)
      if ~UniformityPlotObject.checkInheritence(obj.DataSource, 'UniformityDataSource')
        obj.DataSource = RawUniformityDataSource.Create(obj);
      end
      
      obj.DataSource.attachPlotObject(obj);
    end
  end
    
  methods
    function set.DataSource(obj, value)
      try obj.DataSource = value; end
      value.attachPlotObject(obj);
      %       try value.attachPlotObject(obj); end
    end    
  end
  
end

