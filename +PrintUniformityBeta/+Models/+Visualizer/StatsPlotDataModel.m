classdef StatsPlotDataModel < GrasppeAlpha.Data.Models.SimpleDataModel
  %DATASETSMODEL Cases, Patch Sets and Metrics
  %   Detailed explanation goes here
  
  properties
    % CaseID
    % SetID
    % RunData
    % RegionData
    % AroundData
    % AcrossData
  end
  
  properties
  end
  
  methods
    function obj = StatsPlotDataModel(varargin)
      obj                   = obj@GrasppeAlpha.Data.Models.SimpleDataModel(varargin{:});
      
      obj.DATA              = struct(...
        'CaseID', [], 'SetID', [], ...
        'RunData', [], 'RegionData', [], 'AroundData', [], 'AcrossData', []);
    end    
  end
  
end

