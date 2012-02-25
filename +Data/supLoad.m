function [ output_args ] = supLoad( supMatrix )
%SUPLOAD Loads the workspace for sup plotting
%   Detailed explanation goes here

import Color.*;

%% Do we need to load?
if isstr(supMatrix)
  
  supFilePath = supMatrix;
  
  [pathstr, filename, fileext] = fileparts(supFilePath);
    
  if isempty(fileext)
    supFilePath = [supFilePath '.mat'];
  end
  
  if ~isempty(which(supFilePath))
    supFilePath = which(supFilePath);
  end
  
  assert(exist(supFilePath,'file')>0, ['Could not find the data file ' supFilePath]);
  
  evalin('base','clear sup*;');
  assignin('base','supFilePath',supFilePath);
  assignin('base','supFileName',filename);
  
  supFileVars = whos('-file', supFilePath);
  
  isSolo = all(size(supFileVars) == [1 1]);
  
  assert(isSolo,[supFilePath ...
    ' contains more than one variable. Uniformity data structures must be stored seperately.']);
  
  supFileVar = supFileVars.name;
  supFileMatrix = load(supFilePath,supFileVar);
  supMatrix = supFileMatrix.(supFileVar);
  
  assignin('base','supMatrix',supMatrix);
  
end


evalin('base', 'Common.supCommon');

if ~exist('supMatrix','var')  
  supMatrix = evalin('base','supMatrix');
end
  
cms = evalin('base','cms');
supPatchSet = evalin('base','supPatchSet');
supSheet = evalin('base','supSheet');
supPatchValue = evalin('base','supPatchValue');

    
%% Process oldschool/newer supMatrix structure
try
isSupData   = isstruct(supMatrix) && ...
              strcmpi(supMatrix.sourceTicket.subject, 'Print Uniformity Research Data');
isSupForme  = isstruct(supMatrix) && ...
              strfind(lower(supMatrix.sourceTicket.testform.id), 'sup-');
catch
  Warning('The structure of the data matrix does not conform to a known style.');
end

isOldSchool = iscell(supMatrix) && ...
              all(size(supMatrix) == [1 2]) && strcmp(supMatrix{1,2}{1,2},'sheetNumber');

%% Convert newschool to old
if isSupData && isSupForme
  supSparseMatrix = supMatrix;
  assignin('base','supSparseMatrix',supSparseMatrix);

  supData.columnInset   = reshape(supMatrix.sparseIndex.spreadColumns',1,[]);
  supData.columnRange   = 1:numel(supData.columnInset);
  supData.spectralRange = supMatrix.sparseIndex.bandIndex;

  supData.sheetIndex    = supMatrix.sparseIndex.spreadSheets(:);

  supData.data(:,:, supData.columnInset,:) = supMatrix.sparseData.oldRef;
  
  supData.columnPitch   = supMatrix.sourceTicket.testform.iSis.patchwidth;
  supData.rowPitch      = supMatrix.sourceTicket.testform.iSis.patchheight;
  supData.axialShift    = supMatrix.sourceTicket.testform.press.axialshift;
  supData.leadOffset    = supMatrix.sourceTicket.testform.press.leadoffset;
  supData.printWidth    = supMatrix.sourceTicket.testform.press.printwidth;
  supData.printLength   = supMatrix.sourceTicket.testform.press.printlength;
  
  try
    supData.inkZones   = supMatrix.sourceTicket.testform.press.inkzones;
    
  end
  

%% Just pass on the variable to base workstation
elseif isOldSchool

  supData.columnInset   = supMatrix{1,2}{3,1};
  supData.columnRange   = 1:numel(supData.columnInset);
  supData.spectralRange = supMatrix{1,2}{4,1};
  
  supData.sheetIndex    = supMatrix{1,2}{1,1};

  supData.data(:,:, supData.columnInset,:) = supMatrix{1,1};
  
  

end

%% Re-interp Reference Spectra
reInterpCMS = 1;
try
  reInterpCMS = all(cms.refRange == supData.spectralRange) == 1;
end

if reInterpCMS
  cms.refRange  = supData.spectralRange;
  cms.refIll    = interp1(cms.cie.lambda, cms.cie.illD65, cms.refRange,'pchip')';
  cms.refCMF    = interp1(cms.cie.lambda, cms.cie.cmf2deg,cms.refRange ,'pchip');
  cms.XYZn      = ref2XYZ(ones(length(cms.refRange),1),cms.refCMF,cms.refIll);  
  assignin('base','cms',cms);
end

%% Preview

permuteToImage   = @ (mat) ...
  reshape(permute(mat, [2 1]), size(mat,2),1,size(mat,1));
permuteFromImage = @ (image) ...
  ipermute(squeeze(image), [2 1]);


sheetRows     = size(supData.data,2);
sheetColumns  = size(supData.data,3);
bandCount     = numel(supData.spectralRange);

refData   = squeeze(supData.data(1,:,:,:));
refData   = reshape(refData,sheetRows*sheetColumns,bandCount)';
assignin('base','refData',refData);


%% Prepare Data

supData.dataPeak         = max(supData.data,[],ndims(supData.data));
supData.dataMaxPeak      = max(max(max(supData.dataPeak)));

supData.dataMean         = mean(supData.data,ndims(supData.data));

supData.dataDen          = (supData.dataPeak+supData.dataMaxPeak/5) ./ (supData.dataMaxPeak/5*6);

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

supPatchSet   = supData.patchMap == supPatchValue;
assignin('base', 'supPatchSet', supPatchSet);

supData.gapMap        = setdiff(supData.columnRange,supData.columnInset);

evalin('base','supMat = supMatrix;');
evalin('base','clear supMatrix;');

assignin('base','supData',supData);

end
