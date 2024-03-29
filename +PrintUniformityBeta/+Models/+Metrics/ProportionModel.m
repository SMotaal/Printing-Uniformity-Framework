classdef ProportionModel < PrintUniformityBeta.Models.Metrics.MetricModel
  %FACTORMODEL Factor Metrics Descriptions
  %   Detailed explanation goes here
  
  properties
    % ID                            = '';
    % Name                          = '';
    % Symbol                        = '';
    %
    % PrefixFunction                = @(m   ) [m.Name ': '];
    % SuffixFunction                = @(m   ) [''];
    % ShortFormatFunction           = @(m, v) [toString(v(1)) ':' toString(v(2))];
    % LongFormatFunction            = @(m, v) [m.Prefix m.getShortFormat(v) m.Suffix];
  end
  
  properties(Dependent)
    % Values
    %
    % Prefix
    % Suffix
    % ShortFormat
    % LongFormat
  end
  
  properties(Hidden)
    % shortFormat                   = {};
    % longFormat                    = {};
    % values                        = [];
    limits                          = [0 1];
    unit                            = 'Percentage';    
  end
  
  methods
    function obj = ProportionModel(varargin)
      obj                       = obj@PrintUniformityBeta.Models.Metrics.MetricModel(varargin{:});
      obj.SuffixFunction        = @(m   ) ['%'];
      obj.ShortFormatFunction   = @(m, v) [num2str(abs(round(v*100)), '%d') m.Suffix];
    end
    
  end
  
end
