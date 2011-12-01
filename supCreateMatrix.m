function [ output_args ] = supCreateMatrix( folder )
%SUPCREATEMATRIX reads in a folder of spectral readings X##-SSS.sref.txt
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
    folder  = 'ritsm7401'; %testing
  end
  
  ticketFile = fullfile(datadir,'uniprint',[folder '.ticket.m']);

  [fileList sampleSections sampleCount sampleIndex] = supListDataFiles(folder);
  folder  = fullfile(datadir, 'uniprint', folder);
  
  t = parseTicket(ticketFile);
  
%% Sample Matrix Creation
% The matrix will be structed as Sheet, Row, Column, Wavelength.
% The order is Gripper First, Operator First.

%% Sheet Indexing
sampleIndex   = str2num(char(sampleIndex'))';   % Numbering from filenames
sampleCount   = numel(sampleIndex);

sheetIndex    = t.testdata.samples.sequence;    % Numbering from actual run
sheetCount    = numel(sheetIndex);

assert((sampleCount==sheetCount),'File numbering did not match with the ticket file.');

%% Block Indexing (Multiple-up of same target)
blockIndex    = t.testform.charts.id; % ascending
blockCount    = t.testform.iSis.sheetblocks;    % Two blocks per sheet
blockOrder    = t.testform.charts.order;
blockRows     = t.testform.iSis.blockrows;
blockColumns  = t.testform.iSis.blockcolumns;

%% Patch Data Indexing
bandIndex     = t.testdata.spectral.range;
bandCount     = numel(bandIndex);

%% Sparse Block Indexing
rowIndex      = t.testdata.samples.rows;
rowCount      = numel(rowIndex);
rowRepeats    = blockCount/size(rowIndex,1);

columnIndex   = t.testdata.samples.columns;
columnCount   = numel(columnIndex);
columnRepeats = blockCount/size(columnIndex,1);

sparseSheets  = 1:sheetCount;
sparseRows    = reshape (1:rowCount,    blockRows,        []  )';
sparseColumns = reshape (1:columnCount, blockColumns,     []  )';
sparseBands   = 1:bandCount;

sparseRows    = repmat  (sparseRows,    rowRepeats,       1   );
spreadRows    = repmat  (rowIndex,      rowRepeats,       1   );

sparseColumns = repmat  (sparseColumns, columnRepeats,    1   );
spreadColumns = repmat  (columnIndex,   columnRepeats,    1   );

[spreadSheets sheetOrder] = sort(sheetIndex);

sparseIndex.sparseRows = sparseRows;
sparseIndex.sparseColumns = sparseColumns;
sparseIndex.sparseSheets = sparseSheets;
sparseIndex.sparseBands = sparseBands;

sparseIndex.spreadRows = spreadRows;
sparseIndex.spreadColumns = spreadColumns;
sparseIndex.spreadSheets = spreadSheets;

sparseIndex.sampleIndex = sampleIndex;
sparseIndex.sheetIndex = sheetIndex;
sparseIndex.sheetOrder = sheetOrder;
sparseIndex.rowIndex = rowIndex;
sparseIndex.columnIndex = columnIndex;
sparseIndex.bandIndex = bandIndex;

% rowMap        = reshape(sparseRows, blockRows, [])'
% columnMap     = reshape(sparseColumns, blockColumns, [])'

% return;
% 
% rowRep        = size(columnIndex,1);
% columnRep     = size(rowIndex,1);
% 
% rowMap        = repmat(rowMap,    size(columnIndex,1)  , 1)
% columnMap     = repmat(columnMap, size(rowIndex,1)     , 1)

sheetMatrix(rowIndex,columnIndex,1:3) = NaN;

% = zeros(  min(rowIndex):max(rowIndex) , ...
%                         min(columnIndex):max(columnIndex) );
                      

%% Create Sparse Matrix
sparseMatrix.SpectralReflectance = zeros([sheetCount rowCount columnCount bandCount]);
sparseMatrix.XYZ = zeros([sheetCount rowCount columnCount 3]);
sparseMatrix.LAB = zeros([sheetCount rowCount columnCount 3]);
sparseMatrix.sRGB = zeros([sheetCount rowCount columnCount 3]);

%% Prepare Colorimetery
cie = Color.getCieStruct;

%stdIll = Color.cieIllD(5000, cie);
stdIll = cie.illD65;
refIll = interp1(cie.lambda, stdIll,  bandIndex,'pchip')';
refCMF = interp1(cie.lambda, cie.cmf2deg, bandIndex ,'pchip');

XYZn = Color.ref2XYZ((bandIndex./bandIndex)',refCMF,refIll);

permuteToImage   = @ (mat) ...
  reshape(permute(mat, [2 1]), size(mat,2),1,size(mat,1));
permuteFromImage = @ (image) ...
  ipermute(squeeze(image), [2 1]);
reshapeToImage     = @ (image, rows, columns) ...
  permute(reshape(image,columns,rows,[]),[2 1 3]);

%% Read-Data

for sample = sort(sheetOrder)
  %file  = sheetOrder(sheetOrder);
  sheet   = spreadSheets(sample);
  fileNum = sheetOrder(sample);
  
%   return;
  
  % Read in the data
  for block = blockOrder
    rows      = sparseRows(block,:);
    columns   = sparseColumns(block,:);
    
    if blockOrder == 1
      fileName  = fileList(fileNum).filename;
      disp(sprintf(['Reading sheet %d of %2d\tprint %2d\t' ...
                    'row %2d:%2d\tcol %2d:%2d\t\tfile ''%s'''], ...
                     sample, sampleCount, sheet, ...
                     min(rows), max(rows), min(columns), max(columns), ...
                     fileName));
    else
      fileName  = fileList(blockOrder(block), fileNum).filename;      
      blockName = blockIndex{blockOrder(block)};
      disp(sprintf(['Reading sheet %d of %2d\tprint %2d.%d %s\t' ...
                    'row %2d:%2d\tcol %2d:%2d\t\tfile ''%s'''], ...
                     sample, sampleCount, sheet, block, blockName, ...
                     min(rows), max(rows), min(columns), max(columns), ...
                     fileName));

    end
    
    refData   = load(fullfile(folder,fileName))';
    
    xyzData   = Color.ref2XYZ(refData, refCMF, refIll);
    labData   = Color.XYZ2Lab(xyzData, XYZn);
    rgbData   = Color.XYZ2sRGB(xyzData);
        
    sparseRef = reshape(refData, blockRows, blockColumns, bandCount);
    
    oldRef = zeros(blockRows,blockColumns,bandCount);
    refData2   = refData';
    
    for r = rows
      % data files are row first?

      rdStart   = ((r-1)*blockColumns)+1;
      rdEnd     = rdStart+blockColumns-1;
      rdRange   = rdStart:rdEnd;
      
      oldRef(r,1:blockColumns,sparseBands) = refData2(rdRange, sparseBands); %rowData;

    end
    
    sparseXYZ = reshapeToImage(permuteToImage(xyzData), blockRows, blockColumns);
    sparseLAB = reshapeToImage(permuteToImage(labData), blockRows, blockColumns);
    sparseRGB = reshapeToImage(permuteToImage(rgbData), blockRows, blockColumns);
  
    sparseMatrix.SpectralReflectance(sample,rows,columns,:) = sparseRef;
    sparseMatrix.XYZ(sample,rows,columns,:)                 = sparseXYZ;
    sparseMatrix.LAB(sample,rows,columns,:)                 = sparseLAB;
    sparseMatrix.RGB(sample,rows,columns,:)                 = sparseRGB;
    sparseMatrix.oldRef(sample,rows,columns,:)              = oldRef;
    
    sheetRows     = spreadRows(block,:);
    sheetColumns  = spreadColumns(block,:);
    
    sheetMatrix(sheetRows(1,:),sheetColumns,:) = sparseRGB; %squeeze(sparseMatrix.RGB(sheet,:,:,:));
    
    %Image.imshowfit(sheetMatrix);
    %drawnow();
  end
  
  %Image.imshowfit(sheetMatrix);
  %drawnow();
  
end

output.sparseData   = sparseMatrix;
output.sparseIndex  = sparseIndex;
output.sourceTicket = t;
% output.

output_args = output;

% nR = t.testform.iSis.blockrows; %52;
% nC = t.testform.iSis.blockcolumns;
% 
% %cellstr(sampleIndex')
% 
% sampleNumbers = str2num(char(sampleIndex'))'
% 
% sheetNumbers  = t.testdata.samples.sequence
% sheetCount    = numel(sheetNumbers);
% sheetRange    = 1:sheetCount;
% 
% 
% 
% zoneRange     = [3:11; 13:21];
% zoneSize      = 4; % in number of patches
% 
% targetRepeats = [1 2];
% targetColumns = nC;
% targetRows    = nR;
% 
% rowCount      = targetRows * targetRepeats(1);
% rowRange      = 1:rowCount;
% 
% columnCount   = targetColumns * targetRepeats(2);
% columnRange   = 1:columnCount;
% subRange      = reshape(columnRange,[],targetRepeats(2));
% 
% rowIndex      = t.testdata.samples.rows;
% columnsIndex      = t.testdata.samples.columns;
% 
% % if size(targetRepeats,2) == 2
% %   % MakeShift Solution to map column to position
% %   %patchWidth    = (targetColumns+targetPadX) * targetRepeats(2) - targetPadX;
% %   %   blockY        = combine(ones(targetRows,1), zeros(targetPad,1));
% %   %   blockY        = combine(repmat(blockX,1, targetRepeats(2)-1),ones(targetColumns,1));
% %   %   columnIndex   = find(blockX==1)'
% %   
% % else
% %   rowIndex      = 1:targetRows;
% % end
% % if size(targetRepeats,2) == 2
% %   % MakeShift Solution to map column to position
% %   %patchWidth    = (targetColumns+targetPadX) * targetRepeats(2) - targetPadX;
% %   blockX        = combine(ones(targetColumns,1), zeros(targetPadX,1));
% %   blockX        = combine(repmat(blockX,1, targetRepeats(2)-1),ones(targetColumns,1));
% %   columnIndex   = find(blockX==1)'
% % else
% %   columnIndex = 1:targetColumns;
% % end
% 
% % subRange      = [targetRows targetColumns] * targetRepeats;
% 
% spectralBands = 380:10:730;
% spectralCount = numel(spectralBands);
% spectralRange = 1:spectralCount;
% 
% maxCount      = max([sheetCount, rowCount, columnCount, spectralCount]);
% supMatrix     = zeros(sheetCount, rowCount, columnCount, spectralCount);
% supIndex      = cell(4,2);
% 
% supIndex{1,2} = 'sheetIndex';
% supIndex{1,1} = sheetNumbers; %+offset;
% supIndex{2,2} = 'rowIndex';
% supIndex{2,1} = rowIndex;
% supIndex{3,2} = 'columnIndex';
% supIndex{3,1} = columnsIndex;
% supIndex{4,2} = 'spectralWavelength';
% supIndex{4,1} = spectralBands;
% 
% sectionIndex  = t.testform.layout.sections;
% sectionOrder  = t.testform.layout.sectionOrder; 
% 
% for s = sheetRange
%   sampleIndex = s;
%   sheetIndex = sheetNumbers(s);
%   
%   for x = 1:prod(targetRepeats)
%     fileName = fileList(x).filename;
%     fileData{s,x} = load(fullfile(folder,fileName));
%   end
%   
% %     for r = rowRange
% %       for c = columnRange
% %       end
% %     end    
%   
% end

% for s = sheetRange;
%   
%   sheetID = sheetIDs(s);
%     
%   fileSig     = [filePrefix num2str(sheetID,['%0.' int2str(filePad) 'i']   )]
% 
%   oprFile     = strcat(folder, filesep, fileSig, '-OPR.sref.txt');
%   drvFile     = strcat(folder, filesep, fileSig, '-DRV.sref.txt');
% 
%   oprData     = load(oprFile);
%   drvData     = load(drvFile);
%   
%   for r = rowRange
%     % data files are row first?
% 
%     rdStart   = ((r-1)*targetColumns)+1;
%     rdEnd     = rdStart+targetColumns-1;
%     rdRange   = rdStart:rdEnd;
%     
%     rowData   = zeros(columnCount, spectralCount);
%     
%     rowData(subRange(:, 1), spectralRange) = oprData(rdRange, spectralRange);
%     rowData(subRange(:, 2), spectralRange) = drvData(rdRange, spectralRange);
%     
%     supMatrix(s,r,columnRange,spectralRange) = rowData;
% 
%   end
%   
% end

%x(:,:,columnInset,:) = supMatrix;
%supMartixDensity = 1/max(supMatrix,[],4);
%imshow((squeeze(supMartixDensity(1,:,:)))');
%supMartixDensity = max(x,[],4);
%imshow((squeeze(supMartixDensity(1,:,:)))');
%output_args = {supMatrix, supIndex};

end
