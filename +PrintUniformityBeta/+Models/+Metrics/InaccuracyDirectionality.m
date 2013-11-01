classdef InaccuracyDirectionality < PrintUniformityBeta.Models.Metrics.DirectionalityModel
  %InaccuracyScore Model & Metric Definition
  %   Detailed explanation goes here
  
  properties
    id                          = 'InaccuracyDirectionality';
    name                        = 'Inaccuracy Directionality';
    symbol                      = 'd(k)'; % sprintf('%s', 955);  % Small-Case Lambda
    
    % prefixFunction              = @(m   ) [m.Symbol];
    % suffixFunction              = @(m   ) ['/100'];
    % shortFormatFunction         = @(m, v) num2str(abs(round(v*100)), ['%d' m.Suffix]);
    % suffixFunction              = @(m   ) [''];
    shortFormatFunction         = @(m, v) [num2str(v(1)*100,'%1.0f') ':' num2str(v(2)*100,'%1.0f') m.Suffix]; %@(m, v) [int2str(round(v(2)*100)) ':' int2str(round(v(1)*100)) m.Suffix];
    %longFormatFunction          = @(m, v) [m.Prefix ': ' int2str(round(v(2)*100)) ':' int2str(round(v(1)*100)) m.Suffix];
    components                  = {'Circumfereniality', 'Axiality'};    
  end
    
  
  methods
    function obj = InaccuracyDirectionality(varargin)
      obj                       = obj@PrintUniformityBeta.Models.Metrics.DirectionalityModel(varargin{:});
    end
     
  end
  
end

