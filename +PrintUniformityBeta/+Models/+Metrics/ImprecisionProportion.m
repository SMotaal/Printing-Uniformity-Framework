classdef ImprecisionProportion < PrintUniformityBeta.Models.Metrics.ProportionModel
  %ImprecisionScore Model & Metric Definition
  %   Detailed explanation goes here
  
  properties
    id                          = 'ImprecisionProportion';
    name                        = 'Imprecision Proportion';
    symbol                      = 'p(k)'; % sprintf('%s', 955);  % Small-Case Lambda
    
    % prefixFunction              = @(m   ) [m.Symbol];
    % suffixFunction              = @(m   ) ['/100'];
    % shortFormatFunction         = @(m, v) num2str(abs(round(v*100)), ['%d' m.Suffix]);
  end
    
  
  methods
    function obj = ImprecisionProportion(varargin)
      obj                       = obj@PrintUniformityBeta.Models.Metrics.ProportionModel(varargin{:});
    end
     
  end
  
end

