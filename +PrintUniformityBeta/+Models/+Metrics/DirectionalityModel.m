classdef DirectionalityModel < PrintUniformityBeta.Models.Metrics.MetricModel
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

    Components                      = {};
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
    function obj = DirectionalityModel(varargin)
      obj                       = obj@PrintUniformityBeta.Models.Metrics.MetricModel(varargin{:});
      obj.ShortFormatFunction   = @(m, v) [num2str(v(1)*10,'%1.0f') ':' num2str(v(2)*10,'%1.0f') m.Suffix];
    end
    
    function components = get.Components(obj)
      try obj.Components        = obj.components; end
      components                = obj.Components;
    end
    
  end
    
end
