function [ sourceData ] = supInterp( source, forcebuild, forcesave, forceclear, patchvalues )
  %SUPINTERP Summary of this function goes here
  %   Detailed explanation goes here
  
  import Alpha.*;
  
  default forcebuild  false;
  default forcesave   = forcebuild;
  default forceclear  false;
  default patchvalues [100 75 50 25 0];
  
  if isempty(patchvalues)
  end
  
  if forceclear
    PersistentSources('clear');
  end
  
  if isstruct(source)
    sourcename = source.Filename;
  else
    sourcename = source;
  end
  
  %% Get Buffer
  t=tic;
  if ischar(source) && forcebuild
    statusUpdate(['Loading ' sourcename '... '], 1);
    sourceData  = supLoad(source);
    modified    = true;
    statusUpdate();    
  else
    statusUpdate(['Restoring ' sourcename ' from persistent store... '], 2);
    sourceData  = supDataBuffer(source);
    if isempty(sourceData)
      statusUpdate(['Could not restore: Loading ' sourcename '... '], 1);
      sourceData  = supLoad(source);
      modified    = true;
      statusUpdate();
    end
    modified    = false;
    statusUpdate();
  end
  toc(t);
  
  if forcebuild
    PatchValues = patchvalues;
  else
    PatchValues = [];
    for PatchValue  = patchvalues
      setID = ['DataSetTV' int2str(PatchValue)];
      if ~(stropt(setID, fieldnames(sourceData)))
        PatchValues   = [PatchValues PatchValue];
      end
    end
  end
  
  if isempty(PatchValues)
    fprintf(2, '\nUsing interpolated data from persistent store... ');
    fprintf(1, 'No interpolation required or forced!\n');
  end
  
  for PatchValue = PatchValues
    t=tic;
    setID = ['DataSetTV' int2str(PatchValue)];
    
    statusUpdate(['Interpolating ' sourcename '.' setID '... '], 1);
    
    %   if (incomplete && stropt(setID, fieldnames(sourceData)))
    sourceData.(setID)  = interpSet(sourceData, PatchValue);
    modified = true;
    %   end
    
    statusUpdate();
    toc(t);
  end
  
  if modified
    Alpha.supDataBuffer(sourceData);
  end
  
  if forcesave
    PersistentSources('readonly save');
  end  
  
end

function [interpData] = interpSet(sourceData, PatchValue)
  
  import Color.*;
  
  supData   = sourceData.Data; %evalin('base','supData');
  CMS       = sourceData.CMS; %evalin('base','cms');
  
  PatchSet  = sourceData.Data.patchMap == PatchValue;
  
  psSize = size(PatchSet);
  
  % Create Patch Map
  xF        = repmat(PatchSet, supData.patchSetReps);
  
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
    XYZ       = ref2XYZ(refObj', CMS.refCMF, CMS.refIll);
    
    % Calculate CIE-Lab
    Lab       = XYZ2Lab(XYZ, CMS.XYZn);
    L         = Lab(1,:);
    
    % Calculate RGB
    %RGB       = XYZ2sRGB(XYZ);
    %iRGB      = reshapeToImage(RGB);
    
    % Fill Data & Clear Zero Values
    xZ        = L(xF==1);
    xZ(xZ==0) = NaN; %mean(xZ(xZ>0));
    
    % Interpolate using meshgrid & griddata
    V         = TriScatteredInterp(xR(:), xC(:), xZ(:),'nearest');
    u         = V(r,c);
    
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
        pZ(psR, psC) = nanmean(nanmean(V(mpR,mpC)));
        V2(mpR, mpC) = pZ(psR, psC);
        
        if psR == 1
          [mpR mpC] = meshgrid(pR2,pC);
          V3(mpR, mpC) = nanmean(nanmean(V(mpR,mpC)));
        end
      end
      
    end
    
    
    supPlotData(s).u  = u;
    supPlotData(s).u2 = V2';
    supPlotData(s).u3 = V3';
    supPlotData(s).u4 = V4';
    
    supPlotData(s).z = xZ;
    
  end
  
  supSample.dataFilter = xF;
  supSample.lstar = xZ;
  supSample.lstarR = xR;
  supSample.lstarC = xC;

  
  interpData.PlotData   = supPlotData;
  interpData.Sample     = supSample;
  
end

