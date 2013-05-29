classdef InaccuracyProportion < PrintUniformityBeta.Models.Metrics.ProportionModel
  %InaccuracyScore Model & Metric Definition
  %   Detailed explanation goes here
  
  properties
    id                          = 'InaccuracyProportion';
    name                        = 'Inaccuracy Proportion';
    symbol                      = 'p(a)'; % sprintf('%s', 955);  % Small-Case Lambda
    
    % prefixFunction              = @(m   ) [m.Symbol];
    % suffixFunction              = @(m   ) ['/100'];
    % shortFormatFunction         = @(m, v) num2str(abs(round(v*100)), ['%d' m.Suffix]);
  end
    
  
  methods
    function obj = InaccuracyProportion(varargin)
      obj                       = obj@PrintUniformityBeta.Models.Metrics.ProportionModel(varargin{:});
    end
     
  end
  
end

