function [ output_args ] = supSelect( supData, supPatchSet, supSheet, supSample)
%SUPSELECT Prepares sample data for sup plotting
%   Detailed explanation goes here

%% Define common functions
supFun;

supData = evalin('base','supData');
cms = evalin('base','cms');
supPatchSet = evalin('base','supPatchSet');
supSheet = evalin('base','supSheet');

% Create Patch Map
%xF        = supData.patMap(supPatchSet);
xF         = repmat(supPatchSet, supData.patchSetReps);

% Extract Sample Data
xS        = squeeze(supData.data(supSheet,:,:,:));

% Calculate Colorimetry
refObj    = reshape(xS, [], size(xS,3));
XYZ       = ref2XYZ(refObj', cms.refCMF, cms.refIll);

% Calculate CIE-Lab
Lab       = XYZ2Lab(XYZ, cms.XYZn);
L         = Lab(1,:);

% Calculate RGB
RGB       = XYZ2sRGB(XYZ);
iRGB      = reshapeToImage(RGB);

% Filter out pattern, clear Zero Values and gapMap
xZ        = L(xF==1);
xZ(xZ==0) = NaN; %mean(xZ(xZ>0));
xN        = numel(xZ);
[xR,xC]   = find(xF==1);

% Update supSample fields
supSample.sheetData = xS;
supSample.dataFilter = xF;
supSample.lstar = xZ;
supSample.lstarN = xN;
supSample.lstarR = xR;
supSample.lstarC = xC;
supSample.spectra = refObj;
supSample.XYZ = XYZ;
supSample.Lab = Lab;
supSample.RGB = RGB;
supSample.imageRGB = iRGB;

assignin('base','supSample',supSample);

end

