classdef DataSetsModel < GrasppeAlpha.Data.Models.SimpleDataModel
  %DATASETSMODEL Cases, Patch Sets and Metrics
  %   Detailed explanation goes here
  
  properties
    Cases
    PatchSets
    DataSets
  end
  
  properties
    cases
    patchSets
    dataSets
  end
  
  methods
    function obj = DataSetsModel(varargin)
      obj                   = obj@GrasppeAlpha.Data.Models.SimpleDataModel(varargin{:});
    end    
  end
  
end

