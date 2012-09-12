classdef TransientStats
  %UNIFORMITYSTATS Mean, Standard Deviation... etc.
  %   Detailed explanation goes here
    
  properties (SetAccess=immutable)
    
    Count           = 0;    
    Range           = [];
    
    Sum             = 0;
    
    Mean            = [];
    Median          = [];
    Mode            = [];
    
    Variance        = [];
    Kurtosis        = [];
    
    Bounds          = [];
    
    Histogram       = [];    
    
    Outliers        = [];
    Missing         = [];
    
    Reference       = struct.empty();
    Sample          = [];
    
  end
  
  properties (Dependent)
    Sigma
    Delta
    Peak
    UpperBound
    LowerBound
  end
  
  properties (SetAccess=protected, Transient)
    Data            = [];
  end
  
  methods
    function val = TransientStats(data, reference)
      
      try 
        if isnumeric(reference)
          reference         = reference(:);
          val.Reference     = struct('Mean', nanmean(reference(:)), 'Sigma', nanvar(reference(:)));
        elseif isstruct(reference)
          val.Reference     = reference;
        elseif isa(reference, eval(NS.CLASS));
          val.Reference     = struct('Mean', reference.Mean,  'Sigma', reference.Sigma);
        end
      end
      
      try
        if isstruct(val.Reference)
          val.Reference.Bounds  = val.Reference.Mean + val.Reference.Sigma * [-3 +3];
        end
      end
      
      val.Data              = data(:);
      
      data                  = val.Data;
      reference             = val.Reference;
      
      values                = data(~isnan(data));      
      numerals              = data(~isnan(data(:)));
      
      val.Missing           = find(isnan(data));
      
      val.Count             = numel(numerals);
      val.Range             = [min(numerals) max(numerals)];
      val.Sum               = sum(numerals);
      val.Mean              = mean(numerals);
      val.Median            = median(numerals);
      val.Mode              = mode(numerals);
      val.Variance          = var(numerals);
      val.Kurtosis          = kurtosis(numerals);
      
      val.Bounds            = val.Mean + val.Sigma * [-3 +3];
      
      [n, x]                = hist(numerals, min(val.Count, 100));
      val.Histogram         = [x' n'];
            
      sample                = numerals;
      
      outliers              = [];
      moreOutliers          = true;      
      
      while moreOutliers
        mu                  = mean(sample);
        sigma               = std(sample);
        bounds              = mu + sigma * [-3 +3];
        idx                 = sample < bounds(1) | sample > bounds(2);
        if any(idx)
          newOutliers       = sample(idx);
          outliers          = [outliers newOutliers(:)'];
          sample            = sample(~idx);
        else
          moreOutliers      = false;
          break;
        end
      end
      
      if ~isempty(outliers)
        outliers            = unique(outliers);
        [c ia]              = intersect(numerals, outliers, 'stable');
        val.Outliers        = ia;
        val.Sample          = feval(class(val), sample, val.Reference);
      else
        val.Sample          = val;
      end      
      
      val.Data              = [];
    end
    
  end
  
  methods
    
    function sigma = get.Sigma(val)
      sigma = [];
      try sigma = sqrt(val.Variance); end
    end
    
%     function sample = get.Sample(val)
%       sample = val.Sample;
%       if isempty(val.Sample) && isempty(val.Outliers) && val.Count>0
%         sample = val;
%       end
%     end
    
    function delta =  get.Delta(val)
      delta = [0 0];
      try delta = val.Reference.Bounds - val.Bounds; end
    end
    
    function peak = get.Peak(val)
      peak      = NaN;
      try 
        delta   = val.Delta;
        if delta(1) > delta(2),     peak  = val.Bounds(1);
        elseif delta(1) < delta(2), peak  = val.Bounds(2);
        end
      end
    end

    function bounds = get.UpperBound(val)
      bounds      = NaN;
      try bounds  = val.Bounds(2); end
    end
    
    function bounds = get.LowerBound(val)
      bounds      = NaN;
      try bounds  = val.Bounds(1); end
    end    
    
  end
  
end

