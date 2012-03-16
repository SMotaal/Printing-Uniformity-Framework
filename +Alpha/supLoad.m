function [ sourceData ] = supLoad( source, forced )
  %SUPLOAD Loads the workspace for sup plotting
  %   Detailed explanation goes here
  
  import Color.* Alpha.*;
  default forced false;
  
  %% Do we need to load?
  if ~isstr(source)
    error('Spatial uniformity data source must be a valid MAT filename located in the UniPrintAlpha data folder.');
  end
  
  sourceData = supDataBuffer(source);
    
  if ~forced && ~isempty(sourceData)
    sourceData = sourceData;
    return;
  else
    sourceData = supStruct();
  end
  
  supFilename = source;
  [supPath, supFilename, supExt] = fileparts(supFilename);
  sourceData.Filename = supFilename;
  
  sourceSpace     = upper(supFilename);
  
  sourceMatrixID  = [upper(supFilename) 'Alpha'];
  sourceMatrix    = Data.dataSources(sourceMatrixID, sourceMatrixID);  
    
  
  if (forced || isempty(sourceMatrix))
    
    supFilePath = datadir('UniPrintAlpha', [supFilename '.mat']);

    if ~isempty(which(supFilePath))
      supFilePath = which(supFilePath);
    end   
    
    assert(exist(supFilePath,'file')>0, ['Could not find the data file ' supFilePath]);
    
    sourceData.FilePath = supFilePath;
    
    supFileVars = whos('-file', supFilePath);
    
    isSolo = all(size(supFileVars) == [1 1]);
    
    assert(isSolo,[supFilePath ...
      ' contains more than one variable. Uniformity data structures must be stored seperately.']);
    
    supFileVar = supFileVars.name;
    supFileMatrix = load(supFilePath,supFileVar);
    sourceMatrix = supFileMatrix.(supFileVar);
    
    Data.dataSources(sourceMatrixID, sourceMatrix, true, sourceMatrixID);
    
  end
  
  % sourceData.Matrix = sourceMatrix;
  %   assignin('base', 'supMatrix', sourceMatrix);
  
  CMS           = sourceData.CMS;
%   PatchSet      = sourceData.PatchSet;
%   supSheet      = sourceData.Sheet;
%   supPatchValue = sourceData.PatchValue;
  
  
  %% Process oldschool/newer sourceMatrix structure
  try
    isSupData   = isstruct(sourceMatrix) && ...
      strcmpi(sourceMatrix.sourceTicket.subject, 'Print Uniformity Research Data');
    isSupForme  = isstruct(sourceMatrix) && ...
      strfind(lower(sourceMatrix.sourceTicket.testform.id), 'sup-');
  catch
    Warning('The structure of the data matrix does not conform to a known style.');
  end
  
  isOldSchool = iscell(sourceMatrix) && ...
    all(size(sourceMatrix) == [1 2]) && strcmp(sourceMatrix{1,2}{1,2},'sheetNumber');
  
  %% Convert newschool to old
  if isSupData && isSupForme
    
    supData.columnInset   = reshape(sourceMatrix.sparseIndex.spreadColumns',1,[]);
    supData.columnRange   = 1:numel(supData.columnInset);
    supData.spectralRange = sourceMatrix.sparseIndex.bandIndex;
    
    supData.sheetIndex    = sourceMatrix.sparseIndex.spreadSheets(:);
    
    supData.data(:,:, supData.columnInset,:) = sourceMatrix.sparseData.oldRef;
    
    supData.columnPitch   = sourceMatrix.sourceTicket.testform.iSis.patchwidth;
    supData.rowPitch      = sourceMatrix.sourceTicket.testform.iSis.patchheight;
    supData.axialShift    = sourceMatrix.sourceTicket.testform.press.axialshift;
    supData.leadOffset    = sourceMatrix.sourceTicket.testform.press.leadoffset;
    supData.printWidth    = sourceMatrix.sourceTicket.testform.press.printwidth;
    supData.printLength   = sourceMatrix.sourceTicket.testform.press.printlength;
    
    try
      supData.inkZones   = sourceMatrix.sourceTicket.testform.press.inkzones;
    end
    
    
    %% Just pass on the variable to base workstation
  elseif isOldSchool
    
    supData.columnInset   = sourceMatrix{1,2}{3,1};
    supData.columnRange   = 1:numel(supData.columnInset);
    supData.spectralRange = sourceMatrix{1,2}{4,1};
    
    supData.sheetIndex    = sourceMatrix{1,2}{1,1};
    
    supData.data(:,:, supData.columnInset,:) = sourceMatrix{1,1};
    
  end
  
  %% Re-interp Reference Spectra
  reInterpCMS = 1;
  try
    reInterpCMS = all(CMS.refRange == supData.spectralRange) == 1;
  end
  
  if reInterpCMS
    CMS.refRange  = supData.spectralRange;
    CMS.refIll    = interp1(CMS.cie.lambda, CMS.cie.illD65, CMS.refRange,'pchip')';
    CMS.refCMF    = interp1(CMS.cie.lambda, CMS.cie.cmf2deg,CMS.refRange ,'pchip');
    CMS.XYZn      = ref2XYZ(ones(length(CMS.refRange),1),CMS.refCMF,CMS.refIll);
%     sourceData.CMS       = CMS;
  end
  
  %% Preview
  
  
  sheetRows     = size(supData.data,2);
  sheetColumns  = size(supData.data,3);
  bandCount     = numel(supData.spectralRange);
  
%   SpectralData  = squeeze(supData.data(1,:,:,:));
%   SpectralData  = reshape(SpectralData, sheetRows*sheetColumns,bandCount)';
%   
%   sourceData.SpectralData = SpectralData;
  
  %% Prepare Data
  
  supData.dataPeak      = max(supData.data,[],ndims(supData.data));
  supData.dataMaxPeak   = max(max(max(supData.dataPeak)));
  
  supData.dataMean      = mean(supData.data,ndims(supData.data));
  
  supData.dataDen       = (supData.dataPeak+supData.dataMaxPeak/5) ./ (supData.dataMaxPeak/5*6);
  
  supData.targetSize    = [size(supData.data,2) size(supData.data,3)];
  
  supData.patchMap      = [  100  -1 100  75;
    25 100  50 100;
    100  75 100   0;
    50 100  25 100;  ];
  
  supData.patchSetReps  = supData.targetSize ./ size(supData.patchMap);
  
  supData.subSetSlur         = supData.patchMap  ==   -1;
  supData.subSet100          = supData.patchMap  ==  100;
  supData.subSet75           = supData.patchMap  ==   75;
  supData.subSet50           = supData.patchMap  ==   50;
  supData.subSet25           = supData.patchMap  ==   25;
  supData.subSet0            = supData.patchMap  ==    0;
  
%   PatchSet   = supData.patchMap == supPatchValue;
  
  supData.gapMap    = setdiff(supData.columnRange, supData.columnInset);
  
  sourceData.CMS    = CMS;
%   sourceData.PatchSet    = PatchSet;
%   sourceData.Sheet       = supSheet;
%   sourceData.PatchValue  = supPatchValue;  
    
  sourceData.Data   = supData;
%   sourceData.PatchSet  = PatchSet;
  
  supDataBuffer(sourceData);
  
end

