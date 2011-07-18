function [ output_args ] = supInterp( input_args )
%SUPINTERP Summary of this function goes here
%   Detailed explanation goes here

%% Define common functions
supFun;

% Load supSample values
%supMatrix = evalin('base','supMatrix');
supData = evalin('base','supData');
%supSample = evalin('base','supSample');
cms = evalin('base','cms');
supPatchSet = evalin('base','supPatchSet');
%supSheet = evalin('base','supSheet');
%supPatchValue = evalin('base','supPatchValue');

% Create Patch Map
xF         = repmat(supPatchSet, supData.patchSetReps);
% Filter out pattern
[xR,xC]   = find(xF==1);

% Create Meshgrid
%[r,c]     = meshgrid(1:52,1:76);
lX = [0 52]; %get(gca,'XLim');
lY = [0 76]; %get(gca,'YLim');
[r,c]     = meshgrid(lX(1):lX(2),lY(1):lY(2));

supPlotData(1:numel(supData.sheetIndex)) = struct;

%% For each sheet
for s = 1:numel(supData.sheetIndex);
  % Extract Sample Data
  xS        = squeeze(supData.data(s,:,:,:));

  % Calculate Colorimetry
  refObj    = reshape(xS, [], size(xS,3));
  XYZ       = ref2XYZ(refObj', cms.refCMF, cms.refIll);

  % Calculate CIE-Lab
  Lab       = XYZ2Lab(XYZ, cms.XYZn);
  L         = Lab(1,:);

  % Calculate RGB
  %RGB       = XYZ2sRGB(XYZ);
  %iRGB      = reshapeToImage(RGB);

  % Fill Data & Clear Zero Values
  xZ        = L(xF==1);
  xZ(xZ==0) = NaN; %mean(xZ(xZ>0));
  %xN        = numel(xZ);


  % Interpolate using meshgrid & griddata
  V         = TriScatteredInterp(xR(:), xC(:), xZ(:),'natural');
  u         = V(r,c);
  %uM        = (u-min(u(:)))./(max(u(:))-min(u(:)));
  
  supPlotData(s).u = u;
  %supPlotData(s).r = xR;
  %supPlotData(s).c = xC;
  supPlotData(s).z = xZ;
  
end

% Update supSample fields
supSample.sheetData = xS;
supSample.dataFilter = xF;
supSample.lstar = xZ;
%supSample.lstarN = xN;
supSample.lstarR = xR;
supSample.lstarC = xC;
supSample.spectra = refObj;
supSample.XYZ = XYZ;
supSample.Lab = Lab;
%supSample.RGB = RGB;
%supSample.imageRGB = iRGB;

assignin('base','supPlotData',supPlotData);
assignin('base','supSample',supSample);


end

