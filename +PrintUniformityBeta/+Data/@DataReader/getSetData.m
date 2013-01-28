function [ setData ] = getSetData(obj, setID) % , newData, parameters, caseData)
  %GetSetData Load and Get Set Data
  %   Detailed explanation goes here

  setData                       = [];
  
  if nargin<2, setID            = obj.SetID; end
  if isempty(setID), return; end
  
  setData                       = obj.SetData;
  if ~isempty(setData), return; end
  
  caseID                        = obj.CaseID;
  if isempty(caseID), return; end

  setData                       = struct( 'sourceName', caseID, 'patchSet', setID, ...
    'setLabel', ['tv' int2str(setID) 'data'], 'patchFilter', [], ...
    'data', [] );
  
  caseData                      = obj.getCaseData();
  dataMap                       = caseData.SetData;
  
  if dataMap.isKey(setID)
    setData                     = dataMap(setID);
  else
    setData                     = filterUPDataSet(caseData, setData);
    setData.SheetData           = containers.Map('KeyType', 'int32', 'ValueType', 'any');

    dataMap(setID)              = setData;
  end
  
  if nargin<2, obj.SetData     	= setData; end
  
  %   %% Data
  %   newData           = obj.Data;
  %   dataReader        = newData.DataReader;
  %
  %   setData               = newData.SetData;
  %
  %   %% Get State
  %   customFunction  = false;
  %   setReady        = false;
  %   setLoading      = false;
  %   caseReady       = false;
  %
  %   try customFunction    = isa(obj.GetSetDataFunction, 'function_handle'); end
  %   try setReady          = dataReader.CheckState('SetReady'); end
  %   try caseReady         = dataReader.CheckState('CaseReady'); end
  %   try setLoading        = dataReader.CheckState('SetLoading'); end
  %
  %   if ~setLoading || ~setReady || isempty(setData) % || || updatedParameters
  %
  %     %% Get Container Data
  %     %if ~caseReady || ~exist('caseData', 'var') % || isempty(caseData)
  %     while ~caseReady %isempty(newData.CaseData)
  %       obj.GetCaseData();
  %       caseReady       = dataReader.CheckState('CaseReady');
  %     end
  %     % end
  %
  %     caseData            = newData.CaseData;
  %
  %     try dataReader.PromoteState('SetLoading', true); end
  %
  %     %% Execute Custom Processing Function
  %     skip                    = false;
  %
  %     if customFunction
  %       [setData skip]        = obj.GetSetDataFunction(newData);
  %     end
  %
  %     %% Execute Default Processing Function
  %     if isequal(skip, false)
  %
  %       caseID                = newData.Parameters.CaseID;
  %       setID                 = dataReader.Parameters.SetID;
  %
  %       if isempty(setID)
  %         setID               = obj.DefaultValue('SetID', 100);
  %       end
  %
  %       setData   = struct( 'sourceName', caseID, 'patchSet', setID, ...
  %         'setLabel', ['tv' int2str(setID) 'data'], 'patchFilter', [], ...
  %         'data', [] );
  %
  %       setData   = filterUPDataSet(caseData, setData);
  %
  %       if ~isequal(dataReader.Parameters.SetID, setData.patchSet)
  %         dataReader.Parameters.SetID  = setData.patchSet;
  %       end
  %     end
  %
  %     %% Update Data Model
  %     newData.SetData         = setData;
  %
  %     newData.Parameters.SetID = dataReader.Parameters.SetID;
  %
  %     try dataReader.PromoteState('SetReady', true); end
  %   end
  %
  %   %% Return
  %   if nargout<1, clear setData;    end
  %   if nargout<2, clear parameters; end
end


function [ dataSet ] = filterUPDataSet( dataSource, sourceName, patchSet )
  %FILTERUPDATASET buffered dataset for specific patch set
  %   Detailed explanation goes here
  
  Forced = false;
  
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
  if validCheck('sourceName','struct')
    dataSet = sourceName;
  else
    dataSet = emptyStruct('sourceName', 'patchSet', 'patchFilter', 'data');
    
    try
      if validCheck('sourceName', 'double')
        patchSet = sourceName;
      end
      
      if (~validCheck('sourceName','char'))
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

  end
  
  validSourceName   = validCheck('dataSet.sourceName','char');
  validPatchSet     = validCheck('dataSet.patchSet', 'double');
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
  
  
  
  setID     = [dataSet.sourceName, int2str(dataSet.patchSet)];
  filterID  = [setID 'Filters'];
  
  sourceSpace = dataSet.sourceName;
  
  setStruct     = DS.dataSources(setID,     sourceSpace);
  filterStruct  = DS.dataSources(filterID,  sourceSpace);
  
  if (isempty(setStruct) || isempty(filterStruct)) || Forced % || true
    [dataSet.data dataSet.filterData] = interpUPDataSet(dataSource, dataSet.patchSet);
    DS.dataSources(setID,     dataSet.data,       true, sourceSpace);
    DS.dataSources(filterID,  dataSet.filterData, true, sourceSpace);
  else
    dataSet.data        = setStruct;
    dataSet.filterData  = filterStruct;
  end
  
  if ~isfield(dataSet.data, 'lZData')
      % Y2V                 = @(Y, Yn)  -log10(Y./Yn);
      % Y2L                 = @(Y, Yn)  (116.*(Y./Yn).^(1./3))-16;
      % V2Y                 = @(D, Yn)  Yn./10.^D;
      % L2Y                 = @(L, Yn)  ((L+16)./116).^3.*Yn;
      L2V                       = @(L)      -log10(((L+16)./116).^3);
      % V2L                 = @(D)      (116./10.^(D./3))-16;
    
    try
      for m = 1:numel(dataSet.data)
        dataSet.data(m).lZData  = dataSet.data(m).zData;
        dataSet.data(m).zData   = L2V(dataSet.data(m).zData);
      end
    catch err
      debugStamp;
    end
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



function [ setData filterData] = interpUPDataSet( dataSource, setFilter )
  %SUPINTERP Summary of this function goes here
  %   Detailed explanation goes here
  
  import Color.*;
  
  
  %% Exceptions
  ExIdent = 'Grasppe:UniPrint:InterpUPDataSet';
  
  sourceException = MException([ExIdent ':InvalidDataSource'], ...
    'A valid data source was not specified.');
  
  colorException = MException([ExIdent ':InvalidDataColorimetry'], ...
    'Unable to process the specified source coloriemtry.');
  
  tablesException = MException([ExIdent ':InvalidDataTables'], ...
    'Unable to process the specified source tables.');
  
  filterException = MException([ExIdent ':InvalidFilter'    ], ...
    ['A valid filter was not specified.\n' ...
    'Valid filters may be specified using tone value or case-senstive fieldname for a valid dataSource mask, or, a logical filter matrix.']);  
  
  %% Prepare Set Filter
  
  flipping      = false;
  try flipping  = isequal(dataSource.sampling.Flip, true); end  
  
  try
    targetSize    = dataSource.metrics.sampleSize;

    if islogical(setFilter)
      filterSize    = size(setFilter);
      filterRepeat  = targetSize ./ filterSize;
    else
      if validCheck(setFilter, 'double')
        maskID    = ['TV' int2str(setFilter)];
        setFilter = dataSource.sampling.masks.(maskID);
      end
      
      if validCheck('setFilter','char') && ...
          isVerified('all(islogical(dataSource.sampling.masks.(setFilter)))',1)
        setFilter   = dataSource.sampling.masks.(setFilter);
      end
      filterSize    = size(setFilter);
      filterRepeat  = dataSource.sampling.Repeats;
    end
    
    % Create Patch Map
    dataFilter                = repmat(setFilter, filterRepeat);
    
    if flipping, dataFilter   = rot90(dataFilter,2); end
    
    % Filter out pattern
    [dataRows,dataColumns]    = find(dataFilter==1);
    
  catch err
    throw(addCause(filterException, err));
  end
  
  
  %% Process Source Data & Prepare Interpolation Grid
  try
    sheetsLength  = dataSource.length.Sheets;
    sheetsIndex   = dataSource.index.Sheets;
    sheetsRange   = 1:sheetsLength;
    
    setData(sheetsRange) = emptyStruct('refData', 'xyzData', 'labData', 'lData', 'rgbData', 'zData', 'surfData');
    
    % Get Reference Spectra Table & Colorimetry
    sourceRef     = dataSource.tables.spectra;
    
    % Create Meshgrid
    rangeX        = [0 size(sourceRef,2)-1]; %get(gca,'XLim');
    rangeY        = [0 size(sourceRef,3)-1]; %get(gca,'YLim');
    [gridRows,  gridColumns] = meshgrid(rangeX(1):rangeX(2),rangeY(1):rangeY(2));
  catch err
    throw(addCause(sourceException, err));
  end
  
  filterData = varStruct(dataFilter, dataRows, dataColumns, gridRows, gridColumns, maskID, setFilter, targetSize, filterSize, filterRepeat);
    
  %% Process Source Colorimetry
  try  % colorimetry = dataSource.colorimetry;
    refCMF        = dataSource.colorimetry.refCMF;
    refIll        = dataSource.colorimetry.refIll;
    XYZn          = dataSource.colorimetry.XYZn;   
  catch err
    throw(addCause(colorException, err));
  end
  
  
  %% Calculate and Interpolate Sheet Data
  try
    s = 0;
    for s = sheetsRange;
      % Extract reflectance
      sheetData   = squeeze(sourceRef(s,:,:,:));
      refData     = reshape(sheetData, [], size(sheetData,3));
      
      if flipping
        refData   = flipud(refData);
      end
      
      % Calculate Colorimetry
      xyzData     = ref2XYZ(refData', refCMF, refIll);
      
      % Calculate CIE-Lab
      labData     = XYZ2Lab(xyzData, XYZn);
      lData       = labData(1,:);
      
      % Calculate RGB
      rgbData    = XYZ2sRGB(xyzData);
      %iRGB      = reshapeToImage(RGB);
      
      % Fill dataSource & Clear Zero Values
      zData       = lData(dataFilter==1);
      zNan        = zData==0;
      zData(zNan) = NaN; %mean(xZ(xZ>0));
      
      % Interpolate using meshgrid & griddata
      gridData    = TriScatteredInterp(dataRows(:), dataColumns(:), zData(:),'nearest');
      surfData    = gridData(gridRows,gridColumns);
      
      setData(s) = struct( ...
        'refData',  [], ...
        'xyzData',  [],       'labData',  [], ...
        'lData',    [],       'rgbData',  [], ...
        'zData',    zData,    'surfData', surfData);
      
    end
    
  catch err
    warning('Grasppe:UniPrint:InterpUPDataSet:OperationInterrupted', ...
      'Interpolation was interrupted at sheet %d.', s);
    throw(addCause(tablesException, err));
  end  
end

