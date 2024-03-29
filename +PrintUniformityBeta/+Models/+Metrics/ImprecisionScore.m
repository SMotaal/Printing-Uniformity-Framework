classdef ImprecisionScore < PrintUniformityBeta.Models.Metrics.ScoreModel
  %ImprecisionScore Model & Metric Definition
  %   Detailed explanation goes here
  
  properties
    id                          = 'ImprecisionScore';
    name                        = 'Imprecision Score';
    symbol                      = 's(k)'; %sprintf('%s',954);  % Small-Case Kappa
    
    % prefixFunction              = @(m   ) [m.Symbol];
    % suffixFunction              = @(m   ) ['%'];
    % shortFormatFunction         = @(m, v) num2str(abs(round(v*100)), ['%d' m.Suffix]);
  end
  
  properties (Hidden)
    limits                          = [-2.0 2.0];
    unit                            = 'Percentage';    
  end  
    
  
  methods
    function obj = ImprecisionScore(varargin)
      obj                       = obj@PrintUniformityBeta.Models.Metrics.ScoreModel(varargin{:});
      % obj.SuffixFunction        = @(m   ) ['%'];
      obj.ShortFormatFunction   = @(m, v) [num2str(abs(round(v*100)), ['%d']) m.Suffix];  
    end
     
  end
  
end

