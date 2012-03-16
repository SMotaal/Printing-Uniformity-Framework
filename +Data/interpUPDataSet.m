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
  try
    targetSize    = dataSource.metrics.sampleSize;

    if islogical(setFilter)
      filterSize    = size(setFilter);
      filterRepeat  = targetSize ./ filterSize;
    else
      if isValid(setFilter, 'double')
        maskID    = ['TV' int2str(setFilter)];
        setFilter = dataSource.sampling.masks.(maskID);
      end
      
      if isValid('setFilter','char') && ...
          isVerified('all(islogical(dataSource.sampling.masks.(setFilter)))',1)
        setFilter = dataSource.sampling.masks.(setFilter);
      end
      filterSize    = size(setFilter);
      filterRepeat  = dataSource.sampling.Repeats;
    end
    
    % Create Patch Map
    dataFilter    = repmat(setFilter, filterRepeat);
    
    % Filter out pattern
    [dataRows,dataColumns]   = find(dataFilter==1);
    
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
      % Extract Sample dataSource
      sheetData   = squeeze(sourceRef(s,:,:,:));
      
      % Calculate Colorimetry
      refData     = reshape(sheetData, [], size(sheetData,3));
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
            
      %       'refData',  refData, ...
      %       'xyzData',  xyzData,  'labData',  labData, ...
      %       'lData',    lData,    'rgbData',  rgbData, ...
      
      %     'refData',  [], ...
      %     'xyzData',  [],     'labData',  [], ...
      %     'lData',    [],     'rgbData',  [], ...
      
    end
    
  catch err
    warning('Grasppe:UniPrint:InterpUPDataSet:OperationInterrupted', ...
      'Interpolation was interrupted at sheet %d.', s);
    throw(addCause(tablesException, err));
  end  
end

