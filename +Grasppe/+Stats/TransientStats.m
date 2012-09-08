classdef TransientStats
  %UNIFORMITYSTATS Mean, Standard Deviation... etc.
  %   Detailed explanation goes here
    
  properties (GetAccess=protected, SetAccess=immutable)
    
    Size            = [];
    Count           = [];
    
    Range           = [];
    Bounds          = [];
    
    Sum             = [];
    
    Mean            = [];
    Median          = [];
    Mode            = [];
    
    Variance        = [];
    Kurtosis        = [];
    
    Outliers        = [];
    Missing         = [];
    
    Histogram       = [];
    
    Reference       = struct.empty();
  end
  
  properties (Access=protected, Transient)
    Data            = [];
  end
  
  methods
    function val = TransientStats(data, reference)
      
      try 
        if isnumeric(reference)
          reference         = reference(:);
          val.Reference     = struct('Mean', nanmean(reference(:)), 'Variance', nanvar(reference(:)));
        elseif isa(reference, eval(NS.CLASS));
          val.Reference     = struct('Mean', reference.Mean,  'Variance', reference.Variance);
        end
      end
      
      val.Data              = data;
      val.Size              = size(data);
      
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
           
      if isstruct(reference)
        Mu                  = reference.Mean;
        Sigma               = sqrt(reference.Variance);
      else
        Mu                  = val.Mean;
        Sigma               = sqrt(val.Variance);
      end
      
      val.Bounds            = Mu + Sigma * [-3 +3];
      
      val.Outliers          = find(numerals < val.Bounds(1) | numerals > val.Bounds(2));
      
      bins                  = min(val.Count, 100);
      [n, x]                = hist(numerals, bins);
      val.Histogram         = [x' n'];
      
    end
    
  end
  
end

