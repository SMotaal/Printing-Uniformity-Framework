function [ result args ] = upPlot( dataSourceName, patchSet, varargin )
  %SUPPLOT Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent params sourceName;
  
  if strcmpi(dataSourceName,'clear')
    clear params sourceName;
    return;
  end  
  
  default dataSourceName '';
  default sourceName '';
  default patchSet 100;
  
  
  if exists('params') && isVerified('params.plotMode')
    args = {params, varargin{:}};
    
    if isempty(dataSourceName)
      dataSourceName = params.dataSourceName;
    end
    
  else
    args = {varargin{:}};
  end
  
  if validCheck(patchSet, 'double')
    args = {patchSet, args{:}};
  end
  
  
  if isempty(dataSourceName)
    if (~isempty(sourceName))
      dataSourceName = sourceName;
    else
      error('Source name is missing!');
    end
  end
  
  args = {dataSourceName, args{:}};
  
  [dataSource newParams] = Plots.plotUPStats( args{:} );
  
  
  params = newParams;
  sourceName = params.dataSourceName;
  
  result = params;
  
end

