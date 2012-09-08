function regions = GetRegionMetrics(obj)
  %GETREGIONMETRICS Printing Uniformity Sampling Metrics
  %   Detailed explanation goes here
  
  regions = [];
  
  [dataSource regions] = Metrics.generateUPRegions(obj.CaseData);
  
  if nargout==0,
    obj.Region = regions;
    clear regions;
  end
  
end

