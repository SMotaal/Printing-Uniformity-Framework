test          = 'supPatchMap2' %'supMatrixOrder'

if ~exist('supRITSM74', 'var')
  load('supRITSM74')
end

supMatrix     = supRITSM74;

reshapeToImage = @ (mat) ...
    reshape(permute(mat, [2 1]), size(mat,2),1,size(mat,1));

reshapeToMat = @ (image) ...
    ipermute(squeeze(image), [2 1]);

columnInset   = supMatrix{1,2}{3,1};
columnRange   = 1:numel(columnInset);
spectralRange = supMatrix{1,2}{4,1};

sheetIndex    = supMatrix{1,2}{1,1};

x(:,:,columnInset,:) = supMatrix{1,1};

xPeak         = max(x,[],ndims(x));
xMaxPeak      = max(max(max(xPeak)));

xMean         = mean(x,ndims(x));

xDen          = (xPeak+xMaxPeak/5) ./ (xMaxPeak/5*6);

targetSize    = [size(x,2) size(x,3)];

patchSet      = [  100  -1 100  75;
                    25 100  50 100;
                   100  75 100   0;
                    50 100  25 100;  ];
                  
patchSetReps  = targetSize ./ size(patchSet);

pSlur         = patchSet  ==   -1;
p100          = patchSet  ==  100;
p75           = patchSet  ==   75;
p50           = patchSet  ==   50;
p25           = patchSet  ==   25;
p0            = patchSet  ==    0;

quote         = @(x) ['''',x,''''];

gapMap        = setdiff(columnRange,columnInset);

patMap        = @(x) repmat(x, patchSetReps);
impIndex      = @(x) find(sheetIndex==x);
impNumber     = @(x) sheetIndex(x);

if ~exist('p','var')
  p         = p75;
end

if ~exist('s','var')
  s         = 1;
end

switch test
  case 'supMatrixOrder';
    %% supMatrix Order Test
   
    xD        = squeeze(xDen(1,:,:,:));
    
    xD(patMap(pSlur)) = 0;
    
    xD(:, gapMap) = 0;
    
    imshow(xD);
    
  case 'supPatchRefMap'
    % Squeeze 4-D matrix to remove bandwith dimension (single value)
    xP        = squeeze(xPeak(5,:,:,:));

    % Create X,Y,Z ==> x(R,C,V)
    xF        = patMap(p);
    xV        = xP.*xF;
    
    xZ        = xV(xV>0);
    
    [xR,xC]   = find(xV>0);
    [r,c]     = meshgrid(1:52,1:76);
    u         = griddata(xR,xC,xZ,r,c,'cubic');
    
    %mesh(r,c,u)
    
    surfc(r,c,u)
    colormap hsv
    
  case 'supPatchMap'
    % Create Patch Map
    %xP        = squeeze(xPeak(5,:,:,:));
    xF        = patMap(p);
    %xV        = xP.*xF;

    % Calculate RGB for actual patches
    xS        = squeeze(x(s,:,:,:));

    cie       = getCieStruct;
    
    refRange  = spectralRange;
    
    refIll    = interp1(cie.lambda, cie.illD65, refRange,'pchip')';
    %refIll    = interp1(cie.lambda, cieIllD(5000,cie), refRange,'pchip')'
    refCMF    = interp1(cie.lambda, cie.cmf2deg,refRange ,'pchip');
    XYZn      = ref2XYZ(ones(length(refRange),1),refCMF,refIll);
    
    refObj    = reshape(xS, [], size(xS,3));
    XYZ       = ref2XYZ(refObj',refCMF,refIll);
    
    Lab       = XYZ2Lab(XYZ, XYZn);
    L         = Lab(1,:);
    
    RGB       = XYZ2sRGB(XYZ);
    iRGB      = reshapeToImage(RGB);
    %size(iRGB)
    %imshowfit(permute(reshape(iRGB,76,52,3),[2 1 3]));
    
    % Filter out pattern, clear Zero Values and gapMap
    xZ        = L(xF==1);
    xZ(xZ==0) = NaN; %mean(xZ(xZ>0));
    xN        = numel(xZ);
    [xR,xC]   = find(xF==1);
%    xM        = (xZ(:)-min(xZ(:)))./(max(xZ(:))-min(xZ(:)));
    
    % Get rest of data
    %uZ        = L(xF==0);
    %uZ(uZ==0) = NaN;    
    %uN        = numel(uZ);
    %[uR,uC]   = find(xF==0);

    % Interpolate using meshgrid & griddata
    [r,c]     = meshgrid(1:52,1:76);
    V         = TriScatteredInterp(xR(:), xC(:), xZ(:));
    u         = V(r,c);
    uM        = (u-min(u(:)))./(max(u(:))-min(u(:)));    
    %u         = griddata(xR,xC,xZ,r,c,'cubic');    

%     size(r), size(c), size(u)
%    scatter3(xR(:),xC(:),xZ(:),25,repmat(xZ(:),1,3)./100); hold on; %,'filled');
%    %scatter3(xR(:),xC(:),ones(xN,1).*100,25,repmat(xZ(:),1,3)./100,'filled');
    
    
    %scatter3(xR(:),xC(:),xZ(:)./10+xMax,xZ(:)./5,xZ(:), 'filled');
    %scatter3(uR(:),uC(:),uZ(:),25,repmat(uZ(:),1,3)./100, 'filled'); hold on;
    
    % Plot using surf with contour  
    %surf(r,c,u,u,'FaceAlpha',0.5);  hold on;
    surf(r,c,u,u);  hold on;
    colormap(jet);    
    daspect([1,1,0.25]);
    
    %zr = get(gca, 'ZLim');
    zr = mean(u(u >0));
    if ~exist('zl', 'var') 
      zl = round([mean(zr)-10 mean(zr)+10]./2).*2;
    end
    %zl = round([mean(zr)-5 mean(zr)+5]./3).*3
    zlim(zl);
    
    view(-80, 25);
    set(gca,'Projection','perspective')
    s=find(sheetSequance>=i,1,'first');
    title(['Sample #' num2str(s)]);
    xlabel('Circumferential'); 
    ylabel('Axial');
    zlabel('L*');

    hold off

  case 'supPatchMap2'
    % Create Patch Map
    %xP        = squeeze(xPeak(5,:,:,:));
    xF        = patMap(p);
    %xV        = xP.*xF;

    % Calculate RGB for actual patches
    xS        = squeeze(x(s,:,:,:));

    cie       = getCieStruct;
    
    refRange  = spectralRange;
    
    refIll    = interp1(cie.lambda, cie.illD65, refRange,'pchip')';
    %refIll    = interp1(cie.lambda, cieIllD(5000,cie), refRange,'pchip')'
    refCMF    = interp1(cie.lambda, cie.cmf2deg,refRange ,'pchip');
    XYZn      = ref2XYZ(ones(length(refRange),1),refCMF,refIll);
    
    refObj    = reshape(xS, [], size(xS,3));
    XYZ       = ref2XYZ(refObj',refCMF,refIll);
    
    Lab       = XYZ2Lab(XYZ, XYZn);
    L         = Lab(1,:);
    
    RGB       = XYZ2sRGB(XYZ);
    iRGB      = reshapeToImage(RGB);
    %size(iRGB)
    %imshowfit(permute(reshape(iRGB,76,52,3),[2 1 3]));
    
    % Filter out pattern, clear Zero Values and gapMap
    xZ        = L(xF==1);
    xZ(xZ==0) = NaN; %mean(xZ(xZ>0));
    xN        = numel(xZ);
    [xR,xC]   = find(xF==1);
%    xM        = (xZ(:)-min(xZ(:)))./(max(xZ(:))-min(xZ(:)));
    
    % Get rest of data
    %uZ        = L(xF==0);
    %uZ(uZ==0) = NaN;    
    %uN        = numel(uZ);
    %[uR,uC]   = find(xF==0);

    % Interpolate using meshgrid & griddata
    [r,c]     = meshgrid(1:52,1:76);
    %V         = TriScatteredInterp(xR(:), xC(:), xZ(:));
    %u         = V(r,c);
    %uM        = (u-min(u(:)))./(max(u(:))-min(u(:)));    
    %u         = griddata(xR,xC,xZ,r,c,'cubic');    

%     size(r), size(c), size(u)
    scatter3(xR(:),xC(:),xZ(:),25,repmat(xZ(:),1,3)./100); hold on; %,'filled');
%    %scatter3(xR(:),xC(:),ones(xN,1).*100,25,repmat(xZ(:),1,3)./100,'filled');
    
    
    %scatter3(xR(:),xC(:),xZ(:)./10+xMax,xZ(:)./5,xZ(:), 'filled');
    %scatter3(uR(:),uC(:),uZ(:),25,repmat(uZ(:),1,3)./100, 'filled'); hold on;
    
    % Plot using surf with contour  
    %surf(r,c,u,u,'FaceAlpha',0.5);  hold on;
    %surf(r,c,u,u);  hold on;
    colormap(jet);    
    daspect([1,1,0.25]);
    
    %zr = get(gca, 'ZLim');
    zr = mean(L(L >0));
    if ~exist('zl', 'var') 
      zl = round([mean(zr)-10 mean(zr)+10]./2).*2;
    end
    %zl = round([mean(zr)-5 mean(zr)+5]./3).*3
    zlim(zl);
    
    view(-80, 25);
    set(gca,'Projection','perspective')
    %s=find(sheetSequance>=i,1,'first');
    %title(['Sample #' num2str(s)]);
    xlabel('Circumferential'); 
    ylabel('Axial');
    zlabel('L*');

    hold off
    
  otherwise
    %% No Test!
end
    
