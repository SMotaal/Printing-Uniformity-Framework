function [ strID ] = generateUPID( dataSource, dataSet, dataClass )
  %DATASOURCEID generate source ID for data sources
  %   Detailed explanation goes here
  
  if ~exists('dataSource')
    dataSource = '';
  end
  
  if isstruct(dataSource)
    try
      dataSource = dataSource.name;
    catch
      dataSource = '';
    end
  end
  
  if ~exists('dataSet')
    dataSet='';
  else
    if isstruct(dataSet)
      try
        dataSource  = dataSet.sourceName;
      end      
      try
        dataSet     = dataSet.patchSet;
      catch
        dataSet = '';
      end
    end
  end
  
  if ~exists('dataClass')
    dataClass = '';
  end
  
  try
    dataSource = strtrim(dataSource);
    dataSource = lower(dataSource);
  end
  
  
  strID = [toString(dataSource) toString(dataSet) toString(dataClass)];
  
end

