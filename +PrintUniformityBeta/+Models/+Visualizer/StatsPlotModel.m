classdef StatsPlotModel < GrasppeAlpha.Data.Models.SimpleDataModel
  %DATASETSMODEL Cases, Patch Sets and Metrics
  %   Detailed explanation goes here
  
  properties
    CaseID
    SetID
    RunData 
    RegionData
    AroundData
    AcrossData
  end
  
  properties
  end
  
  methods
    function obj = StatsPlotModel(varargin)
      obj                   = obj@GrasppeAlpha.Data.Models.SimpleDataModel(varargin{:});
    end    
  end
  
end

