function [ output_args ] = supInterp( input_args )
%SUPINTERP Summary of this function goes here
%   Detailed explanation goes here

import Color.*;

%% Define common functions
Common.supFun;

% Load supSample values
%supMatrix = evalin('base','supMatrix');
supData = evalin('base','supData');
%supSample = evalin('base','supSample');
cms = evalin('base','cms');
supPatchSet = evalin('base','supPatchSet');
%supSheet = evalin('base','supSheet');
%supPatchValue = evalin('base','supPatchValue');

psSize = size(supPatchSet);

% Create Patch Map
xF         = repmat(supPatchSet, supData.patchSetReps);

% Filter out pattern
[xR,xC]   = find(xF==1);

% Create Meshgrid
%[r,c]     = meshgrid(1:52,1:76);
lX = [0 size(supData.data,2)-1]; %get(gca,'XLim');
lY = [0 size(supData.data,3)-1]; %get(gca,'YLim');
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
  V         = TriScatteredInterp(xR(:), xC(:), xZ(:),'nearest');
  u         = V(r,c);
  %uM        = (u-min(u(:)))./(max(u(:))-min(u(:)));
  
  V2        = zeros(supData.targetSize);
  V3        = V2;
  V4        = V2;  
  
  % Interpolate Mean Patch Blocks
  pR2 = 1:supData.targetSize(1);
  pC2 = 1:supData.targetSize(2);
  for psR = 1:supData.patchSetReps(1)
    pR = (psR-1)*psSize(1);
    pR = pR+1:pR+psSize(1);
    
    [mpR mpC] = meshgrid(pR,pC2);
    V4(mpR, mpC) = nanmean(nanmean(V(mpR,mpC)));    
      
    for psC = 1:supData.patchSetReps(2)
      
      pC = (psC-1)*psSize(1);
      pC = pC+1:pC+psSize(1);
      
      [mpR mpC] = meshgrid(pR,pC);
      pV = V(mpR,mpC);
      spV = sum(isnan(pV(:)));
      tpV = (psSize(1)*psSize(2)/4*3);
%       if spV < tpV
        pZ(psR, psC) = nanmean(nanmean(V(mpR,mpC)));
%       else
%         pZ(psR, psC) = NaN;
%         thisblock = NaN
%       end
      %[mR mC] = meshgrid(pR,pC);
      V2(mpR, mpC) = pZ(psR, psC);
      
      if psR == 1
        [mpR mpC] = meshgrid(pR2,pC);
        V3(mpR, mpC) = nanmean(nanmean(V(mpR,mpC)));
      end
%       vl = mean(mean(V(pR2,pC)));
%       V3(mR, mC)  = vl;
      
    end
    
%     pC2 = 1:supData.targetSize(2);
%     [mR mC] = meshgrid(pR,pC2);
%     V4(mR, mC)  = mean(mean(V(pR,pC2)));
  end

  % Interpolate Mean Axial Blocks
%   V3        = V2;
%   V4        = V2;  
  
% 	rZ = reshape(xZ,supData.patchSetReps(1),[])';
%   [mR,mC]   = meshgrid(1:size(rZ,1),1:size(rZ,2));
%   mR2 = reshape(xR,supData.patchSetReps(1),[])';
%   mZ =mZ;

%mR = reshape(xR,supData.patchSetReps(1),[])';
%mC = reshape(xC,supData.patchSetReps(1),[])';
% [mR,mC]   = meshgrid(1:size(xF,1),1:size(xF,2));

  %mZ  = zeros(size(mR));
  %mZ(:) = NaN;
  %mZ(xR(:),xC(:)) = rZ(1:end,1:end); %xZ(1:2);
%   V         = interp2(mR,mC,rZ,r,c);   
  
  supPlotData(s).u  = u;
  supPlotData(s).u2 = V2';
  supPlotData(s).u3 = V3';
  supPlotData(s).u4 = V4';
  
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

