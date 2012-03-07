classdef UniformityDataSource < GrasppeComponent
  %UNIFORMITYDATASOURCE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    HandleProperties = {};
    HandleEvents = {};
    ComponentType = 'DataSource';
    ComponentProperties = '';
  end
  
  properties
    DataSource
    DataSet
    DataParameters    
  end
  
  methods (Hidden)
    function obj = UniformityDataSource(varargin)
      obj = obj@GrasppeComponent(varargin{:});      
    end

  end
  
  
  methods (Static, Hidden)
    function options  = DefaultOptions( )
      
      options = WorkspaceVariables(true);
    end
    
  end
  
  methods (Static)
    
    function obj = createDataSource(parentFigure, varargin)
%       obj = PlotAxesObject(parentFigure, varargin{:});
    end    
  end

end

