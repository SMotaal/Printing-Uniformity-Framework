function [ output_args ] = supReadIsis( folder )
%SUPREADISIS reads in a folder of spectral readings X##-SSS.sref.txt
%   This function will read in the spectra files of several impressions
%   used for spatial uniformity (SUP) research. 
%
%   The function is designed around the concept that SUP data is a
%   multi-dimensional array by sheet, patch row and column, and spectra,
%   stored sparsely. This means that the matrix dimensions do not
%   necessarily reflect the physical location, i.e. the actual sheet
%   number, but rather a compressed sequence, i.e. sheet 1, 20, 80... etc.
%   in ascending order.
%
%   SUP data as such has two matrices, one for the data and the other is
%   the index matrix. The index matrix is used to define the physical
%   location over the four dimensions. This way, it is easy to identify the
%   sheet, row, and column for a given reading by referencing the index
%   matrix with respective element index for each.


%% File List Preparation
  if ~exist('folder','var')
    folder    = datadir('uniprintraw','ritsm7401');
  end

  files     = dir(fullfile(folder, '*.sref.txt'));
  
  fileCount = max(size(files));
  
  assert( bitand(fileCount,1)==0  , 'Files must be in pairs' );
  
  [fileNames{1:fileCount,1}] = deal(files.name);
  
  sortedNames = cell2mat(sort(fileNames));
  fileDash = find(sortedNames(1,:) =='-', 1);
  filePad = fileDash - 2;
  filePrefix = sortedNames(1,1);
  fileNumbers = str2num(sortedNames(:,2:4));
  [sampleIDs, splitCheck] = unique(fileNumbers);
  
%  assert( (sum(splitCheck==[2:2:fileCount]')==(fileCount/2))  , ...
%    'Files must be in pairs');
  
%% Sample Matrix Creation
% The matrix will be structed as Sheet, Row, Column, Wavelength.
% The order is Gripper First, Operator First.

nR = 52;
nC = 36;
nZ = 19;

sheetIDs      = sampleIDs;
offset        = min(sampleIDs) == 0;

sheetCount    = numel(sheetIDs);
sheetRange    = 1:sheetCount;

zoneRange     = [3:11; 13:21];
zoneSize      = 4; % in number of patches

targetRepeats = [1 2];
targetColumns = size(zoneRange,2) * zoneSize;
targetRows    = nR;
targetPadX    = 4;

rowCount      = targetRows * targetRepeats(1);
rowRange      = 1:rowCount;

columnCount   = targetColumns * targetRepeats(2);
columnRange   = 1:columnCount;
subRange      = reshape(columnRange,[],targetRepeats(2));

% MakeShift Solution to map column to position
%patchWidth    = (targetColumns+targetPadX) * targetRepeats(2) - targetPadX;
blockX        = combine(ones(targetColumns,1), zeros(targetPadX,1));
blockX        = combine(repmat(blockX,1, targetRepeats(2)-1),ones(targetColumns,1));
columnInset   = find(blockX==1)';
   % ...
  %== 1)

%return
%find (interp1( 1:patchWidth+targetPadX, ...
%  repmat(combine(ones(targetColumns,1), zeros(targetPadX,1))',1, targetRepeats(2)), ...
%  1:patchWidth) ==1)



% subRange      = [targetRows targetColumns] * targetRepeats;

spectralBands = 380:10:730;
spectralCount = numel(spectralBands);
spectralRange = 1:spectralCount;

maxCount      = max([sheetCount, rowCount, columnCount, spectralCount]);
supMatrix     = zeros(sheetCount, rowCount, columnCount, spectralCount);
supIndex      = cell(4,2);

supIndex{1,2} = 'sheetNumber';
supIndex{1,1} = sheetIDs+offset;
supIndex{2,2} = 'rowInset';
supIndex{2,1} = rowRange;
supIndex{3,2} = 'columnInset';
supIndex{3,1} = columnInset;
supIndex{4,2} = 'spectralWavelength';
supIndex{4,1} = spectralBands;

for s = sheetRange;
  
  sheetID = sheetIDs(s);
    
  fileSig     = [filePrefix num2str(sheetID,['%0.' int2str(filePad) 'i']   )]

  oprFile     = strcat(folder, filesep, fileSig, '-OPR.sref.txt');
  drvFile     = strcat(folder, filesep, fileSig, '-DRV.sref.txt');

  oprData     = load(oprFile);
  drvData     = load(drvFile);
  
  for r = rowRange
    % data files are row first?

    rdStart   = ((r-1)*targetColumns)+1;
    rdEnd     = rdStart+targetColumns-1;
    rdRange   = rdStart:rdEnd;
    
    rowData   = zeros(columnCount, spectralCount);
    
    rowData(subRange(:, 1), spectralRange) = oprData(rdRange, spectralRange);
    rowData(subRange(:, 2), spectralRange) = drvData(rdRange, spectralRange);
    
    supMatrix(s,r,columnRange,spectralRange) = rowData;

  end
  
end

x(:,:,columnInset,:) = supMatrix;
%supMartixDensity = 1/max(supMatrix,[],4);
%imshow((squeeze(supMartixDensity(1,:,:)))');
%supMartixDensity = max(x,[],4);
%imshow((squeeze(supMartixDensity(1,:,:)))');
output_args = {supMatrix, supIndex};

end
