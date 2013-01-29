function regions = getRegionMetrics(obj)
  %GETREGIONMETRICS Printing Uniformity Sampling Metrics
  %   Detailed explanation goes here
  
  regions = [];

  
  regionMetrics         = PrintUniformityBeta.Data.UniformityMetricsDataSource.ProcessRegionMetrics(obj.CaseData);
    
  obj.RegionMetrics     = 
  
end

