classdef MetricModel < handle
  %METRICMODEL Metric Descriptions
  %   Detailed explanation goes here
  
  properties
    ID                            = '';
    Name                          = '';
    Symbol                        = '';
    
    PrefixFunction                = @(m   ) [m.Symbol];
    SuffixFunction                = @(m   ) [''];
    ShortFormatFunction           = @(m, v) toString(v);
    LongFormatFunction            = @(m, v) [m.Prefix ': ' m.getShortFormat(v)];
  end
  
  properties(Dependent)
    Values
    
    Prefix
    Suffix
    ShortFormat
    LongFormat
  end
  
  properties(Hidden)
    shortFormat                   = {};
    longFormat                    = {};
    values                        = {};
  end
  
  methods
    
    function obj = MetricModel(values)
      % try obj.PrefixFunction      = obj.prefixFunction; end
      % try obj.SuffixFunction      = obj.suffixFunction; end
      % try obj.ShortFormatFunction = obj.shortFormatFunction; end
      % try obj.LongFormatFunction  = obj.longFormatFunction; end
      
      try obj.Values              = values; end
    end
    
    %% Standard Getters
    function values = get.Values(obj)
      values                      = obj.values;
    end
    
    function set.Values(obj, values)
      if ~isequal(values, obj.values)
        obj.shortFormat           = {};
        obj.longFormat            = {};
        obj.values                = values;
      end
    end
    
    %% Overridable Getters
    function id = get.ID(obj)
      try obj.ID                  = obj.id; end
      id                          = obj.ID;
    end
    
    function name = get.Name(obj)
      try obj.Name                = obj.name; end
      name                        = obj.Name;
    end
    
    
    function symbol = get.Symbol(obj)
      try obj.Symbol              = obj.symbol; end
      symbol                      = obj.Symbol;
    end
    
    
    function prefixFunction = get.PrefixFunction(obj)
      try obj.PrefixFunction      = obj.prefixFunction; end
      prefixFunction              = obj.PrefixFunction;
    end
    
    function suffixFunction = get.SuffixFunction(obj)
      try obj.SuffixFunction      = obj.suffixFunction; end
      suffixFunction              = obj.SuffixFunction;
    end
    
    function shortFormatFunction = get.ShortFormatFunction(obj)
      try obj.ShortFormatFunction = obj.shortFormatFunction; end
      shortFormatFunction         = obj.ShortFormatFunction;
    end
    
    function longFormatFunction = get.LongFormatFunction(obj)
      try obj.LongFormatFunction  = obj.longFormatFunction; end
      longFormatFunction          = obj.LongFormatFunction;
    end
    
    %% Processable Getters
    
    function prefix = get.Prefix(obj)
      prefix                      = obj.PrefixFunction(obj);
    end
    
    function suffix = get.Suffix(obj)
      suffix                      = obj.SuffixFunction(obj);
    end
    
    function shortFormat = get.ShortFormat(obj)
      shortFormat                 = obj.shortFormat;
      
      if ~isequal(size(obj.values), size(obj.shortFormat))
        shortFormat               = obj.getShortFormat(obj.values);
        obj.shortFormat           = shortFormat;
      end
    end
    
    function longFormat = get.LongFormat(obj)
      longFormat                  = obj.longFormat;
      
      if ~isequal(size(obj.values), size(obj.longFormat))
        longFormat                = obj.getLongFormat(obj.values);
        obj.longFormat            = longFormat;
      end
    end
    
    %% Processing Function
    function str = getFormat(obj, values, formatFunction)
      if ~iscell(values) && isscalar(values)
        str                       = '';
        try str                   = formatFunction(obj, values); end
      elseif iscell(values) || numel(values)>1
        str                       = cell(size(values));
        
        numericValues             = ~iscell(values);
        
        if numericValues, values  = {values}; end
        try str                   = cellfun(@(v)formatFunction(obj, v), values, 'UniformOutput',  false); end
        if numericValues, str     = char(str); end
      end
    end
    
    function str = getLongFormat(obj, v)
      str                         = obj.getFormat(v, obj.LongFormatFunction);
    end
    
    function str = getShortFormat(obj, v)
      str                         = obj.getFormat(v, obj.ShortFormatFunction);
    end
    
  end
  
end



        % values                    = obj.values;
        % longFormatFunction        = obj.LongFormatFunction;
        % longFormat                = arrayfun(@(v)longFormatFunction(obj, v), values, 'UniformOutput',  false);
        % obj.longFormat            = longFormat;
