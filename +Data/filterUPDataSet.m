function [ dataSet ] = filterUPDataSet( dataSource, sourceName, patchSet )
  %FILTERUPDATASET buffered dataset for specific patch set
  %   Detailed explanation goes here
  
  %% Exceptions
  ExIdent = 'Grasppe:UniPrint:filterUPDataSet';
  
  nameException = MException([ExIdent ':InvalidSourceName'], ...
    'A valid source name was not specified.');
  
  patchSetException = MException([ExIdent ':InvalidPatchSetValue'], ...
    'A valid patch set value was not specified.');
  
  %   tablesException = MException([ExIdent ':InvalidDataTables'], ...
  %     'Unable to process the specified source tables.');
  
  filterException = MException([ExIdent ':InvalidFilter'    ], ...
    ['A valid filter was not specified.\n' ...
    'Valid filters may be specified using tone value or case-senstive fieldname for a valid dataSource mask, or, a logical filter matrix.']);
  
  
  %% Parameters
  if isValid('=sourceName','struct')
    dataSet = sourceName;
  else
    dataSet = emptyStruct('sourceName', 'patchSet', 'patchFilter', 'data');
    
    try
      if isValid('=sourceName', 'double')
        patchSet = sourceName;
      end
        
      if (~isValid('=sourceName','char'))
        dataSet.sourceName = dataSource.name;
      else
        dataSet.sourceName = sourceName;
      end
    catch err
      throw(addCause(nameException, err));
    end
    
    try
      dataSet.patchSet = patchSet;
    catch err
      throw(addCause(patchSetException, err));
    end
    
    %     dataSet = struct( ...
    %       'sourceName', sourceName, ...
    %       'patchSet', patchSet, ...
    %       'patchFilter', [], ...
    %       'data', [] ...
    %       );
  end
  
  validSourceName   = isValid('=dataSet.sourceName','char');
  validPatchSet     = isValid('=dataSet.patchSet', 'double');
  validPatchFilter  = islogical(dataSet.patchFilter);
  
  if (~validSourceName)
    throw(nameException);
  end
  
  if (~validPatchSet)
    throw(patchSetException);
  end
  
  try
    if (~validPatchFilter)
      dataSet.patchFilter = prepareSetFilter(dataSource, dataSet.patchSet);
    end
  catch err
    throw(addCause(filterException, err));
  end
  
  
  
%   if (isempty(params.dataSet.data) || params.dataLoading)
  %% Filter Data Set
%     setCode = dataSet.patchSet;
%     if (setCode<0 && setCode > -100)
%       setCode = 200-setCode;
%     end
%     
    setID = camelString(dataSet.sourceName, dataSet.patchSet);
    
    setStruct = Data.dataSources(setID);
    
    if (isempty(setStruct))
      dataSet.data = Data.interpUPDataSet(dataSource, dataSet.patchFilter);
      Data.dataSources(setID, dataSet.data, true);
    else
      dataSet.data = setStruct;
    end
  
end

function [ setName  ] = filterDataSetID(sourceName, patchSet)
  setCode = patchSet;
  if (setCode<0 && setCode > -100)
    setCode = 200-setCode;
  end

  setName = genvarname([sourceName num2str(setCode, '%03.0f') ]);  
end

function [ patchSet ] = prepareSetFilter( dataSource, patchValue )
  ExIdent = 'Grasppe:UniPrint:FilterUPDataSet';
  filterException = MException([ExIdent ':InvalidFilter'    ], ...
    ['A valid filter was not specified.\n' ...
    'Valid filters may be specified using tone value or case-senstive fieldname for a valid dataSource mask, or, a logical filter matrix.']);
  
  try
    patchSet =  dataSource.sampling.masks.(['TV' int2str(patchValue)]);
  catch err
    throw(addCause(filterException, err));
  end
  
end


