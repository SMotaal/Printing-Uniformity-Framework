classdef SetData < GrasppeAlpha.Data.Models.SimpleDataModel
  %SETDATA Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    function obj = SetData(varargin)
      obj                   = obj@GrasppeAlpha.Data.Models.SimpleDataModel(varargin{:});
    end
  end
  
end

