classdef UniformityRegions < PrintUniformityBeta.Graphics.UniformityPatch
  %UNIFORMITYREGIONS R2013-01
  %   Detailed explanation goes here
  
  properties
    PressArea
    SheetArea
    TargetArea
    
    RegionIDs
    RegionAreas
    RegionLabels
    
    RegionData
    RegionTrends
    
    RegionPrefix
    RegionClass
    
  end
  
  methods
    function obj = UniformityPatch(parentAxes, dataSource, varargin) % parentAxes, dataSource, varargin
      obj                   = obj@PrintUniformityBeta.Graphics.UniformityPatch(parentAxes, dataSource, varargin{:});
    end
  end
  
end

