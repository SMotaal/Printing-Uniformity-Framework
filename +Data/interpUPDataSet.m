function [ setData ] = interpUPDataSet( data, setFilter )
%SUPINTERP Summary of this function goes here
%   Detailed explanation goes here

import Color.*;

%% Define common functions
% Common.supFun;

% Load supSample values
% supData = evalin('base','supData');

% data.colorimetry = data.colorimetry; %evalin('base','data.colorimetry');
% supPatchSet = evalin('base','supPatchSet');
targetSize    = data.metrics.target.Size;

filterSize    = size(setFilter);
filterRepeat  = data.sampling.Repeats;

sheetsLength  = data.length.Sheets;
sheetsIndex   = data.index.Sheets;

dataLength    = sheetsLength;
dataRange     = 1:dataLength;


% Get Reference Spectra Table & Colorimetry
sourceRef     = data.tables.spectra;

colorimetry   = data.colorimetry;
refCMF        = colorimetry.refCMF;
refIll        = colorimetry.refIll;
XYZn          = colorimetry.XYZn;

% Create Patch Map
dataFilter    = repmat(setFilter, filterRepeat);

% Filter out pattern
[dataRows,dataColumns]   = find(dataFilter==1);

% Create Meshgrid
rangeX        = [0 size(sourceRef,2)-1]; %get(gca,'XLim');
rangeY        = [0 size(sourceRef,3)-1]; %get(gca,'YLim');
[gridRows,  gridColumns] = meshgrid(rangeX(1):rangeX(2),rangeY(1):rangeY(2));

setData(dataRange) = emptyStruct('refData', 'xyzData', 'labData', 'lData', 'rgbData', 'zData', 'surfData');

%% For each sheet
for s = dataRange;
  % Extract Sample Data
  sheetData   = squeeze(sourceRef(s,:,:,:));

  % Calculate Colorimetry
  refData     = reshape(sheetData, [], size(sheetData,3));
  xyzData     = ref2XYZ(refData', refCMF, refIll);

  % Calculate CIE-Lab
  labData     = XYZ2Lab(xyzData, XYZn);
  lData       = labData(1,:);

  % Calculate RGB
  %RGB       = XYZ2sRGB(XYZ);
  %iRGB      = reshapeToImage(RGB);

  % Fill Data & Clear Zero Values
  zData       = lData(dataFilter==1);
  zNan        = zData==0;
  zData(zNan) = NaN; %mean(xZ(xZ>0));
  
  % Interpolate using meshgrid & griddata
  gridData    = TriScatteredInterp(dataRows(:), dataColumns(:), zData(:),'nearest');
  surfData    = gridData(gridRows,gridColumns);
  
%   plotData(sheet).u  = surfD;
%   plotData(sheet).z = zData;
  setData(s) = struct( ... 
    'refData',  [], ... 
    'xyzData',  [],     'labData',  [], ...
    'lData',    [],     'rgbData',  [], ...
    'zData',    zData,  'surfData', surfData);  
end

% Update supSample fields
% supSample.sheetData = sheetData;
% supSample.dataFilter = dataFilter;
% supSample.lstar = zData;
% %supSample.lstarN = xN;
% supSample.lstarR = dataRows;
% supSample.lstarC = dataColumns;
% supSample.spectra = sheetRef;
% supSample.XYZ = xyzData;
% supSample.Lab = labData;
%supSample.RGB = RGB;
%supSample.imageRGB = iRGB;

end

