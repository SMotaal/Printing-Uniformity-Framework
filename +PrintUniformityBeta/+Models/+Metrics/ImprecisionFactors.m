classdef ImprecisionFactors < PrintUniformityBeta.Models.Metrics.FactorModel
  %ImprecisionFactor Model & Metric Definition
  %   Detailed explanation goes here
  
  properties
    id                          = 'ImprecisionFactors';
    name                        = 'Imprecision Factors';
    symbol                      = 'f(e/v)'; %sprintf('%s',954);  % Small-Case Kappa
    
    % prefixFunction              = @(m   ) [m.Symbol];
    suffixFunction              = @(m   ) [''];
    shortFormatFunction         = @(m, v) [int2str(round(v(1)*100)) ':' int2str(round(v(2)*100)) m.Suffix];
    longFormatFunction          = @(m, v) [m.Prefix ': ' int2str(round(v(1)*100)) ':' int2str(round(v(2)*100)) m.Suffix];
    components                  = {'Unevenness', 'Unrepeatability'};
  end
  
  properties (Hidden)
    limits                          = [0 1];
    unit                            = 'Percentage';
  end
  
  
  methods
    function obj = ImprecisionFactors(varargin)
      obj                       = obj@PrintUniformityBeta.Models.Metrics.FactorModel(varargin{:});
    end
  end
  
end

