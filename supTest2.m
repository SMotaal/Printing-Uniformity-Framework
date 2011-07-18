sheetRange = 1:sheetIndex(end);

sheetInterp = interp1(sheetIndex,1:numel(sheetIndex),sheetRange,'nearest');

[w,sf,w] = unique(sheetInterp,'first');
sl = [sf(2:end) numel(sheetInterp)];
%[w,sl,w] = unique(sheetInterp,'last');
sd       = sl-sf+1;
%sf       = sl-1;
[sf' sl' sd']
return
cie       = getCieStruct;

refIll    = interp1(cie.lambda, cie.illD65, refRange,'pchip')';
refCMF    = interp1(cie.lambda, cie.cmf2deg,refRange ,'pchip');
XYZn      = ref2XYZ(ones(length(refRange),1),refCMF,refIll);

refRange  = spectralRange;


xF        = patMap(p);
[xR,xC]   = find(xF==1);

%sheetRange = 1:numel(sheetIndex)
sheetRange = 1:sheetIndex(end);

sheetInterp = interp1(sheetIndex,1:numel(sheetIndex),sheetRange,'spline');

[r,c,s]     = meshgrid(1:52,1:76,sheetRange);

for s = sheetRange

  sf        = floor(sheetInterp(sf));
%  sc        =
  
  xS        = squeeze(x(s,:,:,:));
  
  

  refObj    = reshape(xS, [], size(xS,3));
  XYZ       = ref2XYZ(refObj',refCMF,refIll);
  
  Lab       = XYZ2Lab(XYZ, XYZn);
  L         = Lab(1,:);
  
  %RGB       = XYZ2sRGB(XYZ);
  %iRGB      = reshapeToImage(RGB);
  %imshowfit(permute(reshape(iRGB,76,52,3),[2 1 3]));
  
  % Filter out pattern, clear Zero Values and gapMap
  xZ        = L(xF==1);
  xZ(xZ==0) = NaN;
  xN        = numel(xZ);

  % Interpolate using meshgrid & griddata
  [r,c]     = meshgrid(1:52,1:76);
  V         = TriScatteredInterp(xR(:), xC(:), xZ(:));

  u         = V(r,c);
  uM        = (u-min(u(:)))./(max(u(:))-min(u(:)));

end
