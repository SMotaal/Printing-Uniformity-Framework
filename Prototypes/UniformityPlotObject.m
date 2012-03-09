classdef UniformityPlotObject < GrasppeHandle
  %UNIFORMITYPLOTOBJECT Co-superclass for printing uniformity plot objects
  %   Detailed explanation goes here
  
  properties
    DataSource
  end
  
  properties (Dependent)
    SampleNumber
  end
  
  methods (Access=protected)
%     function obj = UniformityPlotObject(parentAxes, varargin)
%       obj = obj@PlotObject(parentAxes, varargin{:});
%     end    
    
    function createComponent(obj, type)
      if ~InAxesObject.checkInheritence(obj.DataSource, 'UniformityDataSource')
        obj.DataSource = RawUniformityDataSource.Create(obj);
      else
        obj.DataSource.attachPlotObject(obj);
      end
    end    
  end
  
end

