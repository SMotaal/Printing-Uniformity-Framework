classdef InaccuracyScore < PrintUniformityBeta.Models.Metrics.ScoreModel
  %InaccuracyScore Model & Metric Definition
  %   Detailed explanation goes here
  
  properties
    id                          = 'InaccuracyScore';
    name                        = 'Inaccuracy Score';
    symbol                      = 's(a)'; %sprintf('%s', 955);  % Small-Case Lambda
    
    % prefixFunction              = @(m   ) [m.Symbol];
    % shortFormatFunction         = @(m, v) [num2str(abs(round(v*100)), '-%d' m.Suffix)];
  end
    
  
  methods
    function obj = InaccuracyScore(varargin)
      obj                       = obj@PrintUniformityBeta.Models.Metrics.ScoreModel(varargin{:});
    end
     
  end
  
end

