classdef CaseData < GrasppeAlpha.Data.Models.SimpleDataModel
  %CASEDATA Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    function obj = CaseData(varargin)
      obj                   = obj@GrasppeAlpha.Data.Models.SimpleDataModel(varargin{:});
    end    
  end
  
end

