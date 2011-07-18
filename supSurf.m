function [ f, j ] = supSurf( fig, fview, cl, input_args )
%SUPSURF plots supSample as a surf
%   Detailed explanation goes here

%% Plot Design (To be implemented)
% Layers:
%   Print Area: entire printing plane, origin at lead-operator (mm)
%     Press Size (mm, to spec)
%   Print Zones: sub-divisions for the printing plane
%     Zone Count X/Y
%   Target Area: entire target plane, off-origin (mm)
%     Patch Count X/Y (to spec)
%     Patch Width X/Y (mm, to spec)
%     Patch Offset X/Y (mm, calculated)
%       Sheet Size X/Y (mm, to spec)
%       Patch Origin X/Y (mm, calculated)
%   Data Area: entire data plane, off-origin (mm)

% Define the plane
lX = [0 52]; %get(gca,'XLim');
lY = [0 76]; %get(gca,'YLim');

gX = [0 52]; 
gY = [-4*1 4*20];

if ~exist('fig','var')
  fig = figure('Name', 'Spatial-Temporal Plot', 'units','pixels', ...
    'Color', 'w', 'Renderer', 'zbuffer'); %OpenGL
    %'Toolbar', 'none', 'WindowStyle', 'modal', 'MenuBar', 'none',  ...
else
    assignin('base', 'supCA', gca);
end

if ~exist('fview','var'), fview = 1; end

% Load supSample values
%supMatrix = evalin('base','supMatrix');
supData = evalin('base','supData');
supSample = evalin('base','supSample');
cms = evalin('base','cms');
supPatchSet = evalin('base','supPatchSet');
supSheet = evalin('base','supSheet');
%supPatchValue = evalin('base','supPatchValue');

% Update supSample fields
%xS    = supSample.sheetData;
%xF    = supSample.dataFilter;
xZ    = supSample.lstar;
%xN    = supSample.lstarN;
xR    = supSample.lstarR - 0.5;
xC    = supSample.lstarC - 0.5;
%xRef  = supSample.spectra;
%xXYZ  = supSample.XYZ;
%xLab  = supSample.Lab;
%xRGB  = supSample.RGB;
%xRGBi = supSample.imageRGB;



% Interpolate using meshgrid & griddata
[r,c]     = meshgrid(lX(1):lX(2),lY(1):lY(2));
V         = TriScatteredInterp(xR(:), xC(:), xZ(:));
u         = V(r,c);
uM        = (u-min(u(:)))./(max(u(:))-min(u(:)));    

% Plot using surf with contour 
%surf(r,c,u,u);


%assignin('base','supZData', u);
%assignin('base','supZDataPoints', xZ);

%colorData = repmat(interp1([0:1:100],[0:1:100],[0:1:numel(u)] )',1,3)
zu = u(u >0);
zm = mean(zu);
%[zmin, zmax] = range(zu)
zr = [min(zu) max(zu)];
zrb = zr(2) - zr(1);

zp = (u - zr(1))./(zrb*100);

%min(zp), max(zp), 

% size(zp), size(u),

%colorData = repmat(zp,1,3);

%surf(r,c,u,u,'ZDataSource','supZData', 'CDataMapping', 'scaled', ...
%  'EdgeColor', 'none');

%contour3(r,c,u)
%contourf(r,c,u,'ZDataSource','supZData');
%, 'CDataMapping', 'scaled', ...
%  'EdgeColor', 'none');

hold on;

%colormap(jet);    
daspect([1,1,0.125]);

%zr = get(gca, 'ZLim');
zb = max(abs([20 16] - 18));
zs = 3; %max(2.5, zb + 0.5);
zf = 2;
if ~exist('zl', 'var') 
  zl = [mean(zm)-zs mean(zm)+zs];
  
  if ~exist('cl','var')
    cl = zl + [1 -1];
    set(gca,'CLim', cl);
    set(gca,'CLimMode', 'Manual');   
  end
  %caxis(cl);
  j = cl;
  
  zl = round(zl./zf).*zf;
end
%zl = round([mean(zr)-5 mean(zr)+5]./3).*3
xlim(gX);
ylim(gY);
zlim(zl);

lRX = (lX(2)-lX(1))/5;
lRY = 4;
lRZ = 1; %0.25;

% lX = [1 76]; %get(gca,'XLim');
% lY = [1 52]; %get(gca,'YLim');

lX = lX(1):lRX:lX(2);
lY = lY(1):lRY:lY(2);
lZ = ones(numel(lX), numel(lY));

[lX lY] = meshgrid(lX, lY);

%size (lX), size (lY), size (lZ)

% Grid ticks
tRX = 52.0 / 4.0;
tX = gX(1):tRX:gX(2);
set(gca, 'XTick', tX);

tRY = lRY;
tY = gY(1):tRY:gY(2);
%tYl = 2:2:gY(2)-gY(1);
tYl = [1:gY(2)-gY(1)-1 []];
%tYl(1:2:end) = [];
set(gca, 'YTick', tY+2);
set(gca, 'YTickLabel', tYl);
set(gca, 'YGrid', 'off');
%set(gca, 'YMinorGrid', 'off');
set(gca, 'YMinorTick', 'on');
set(gca, 'Clipping', 'off');
%tYlh = get(gca,'YTickLabel');
%gtp = get(tYlh,'Position')
%set(tYlh,'Position',get(tYlh,'Position') + 0.5) 
set(gca,'ZDir','reverse');

lLineStyle = '-';

switch fview
  case 1
    view(-80, 25);  % lead-operator off-axis
    set(gca,'Projection','perspective');
    grid(gca, 'on');
  case 2
    set(gca,'ZDir','normal');
    view(-90, 90);  % top on-axis
    set(gca,'Projection','orthographic');
    lLayers = [floor(zr(1)) ceil(zr(2))];
    grid(gca, 'off');
    xZC = ones(size(xZ)) .* zr(1)-10;
    cba = colorbar('SouthOutside');
    cbp = get(cba, 'Position');
    cbp = [cbp(1) 0.15 cbp(3) 0.025];
    set(cba,'Position', cbp);
  case 3
    view(-180, 0);  % driver on-axis
    set(gca,'Projection','orthographic');
    lLayers = floor(zr(1)):lRZ:ceil(zr(2));
    grid(gca, 'on');
  case 4
    view(-90, 0);  % lead on-axis
    set(gca,'Projection','orthographic');
    lLayers = floor(zr(1)):lRZ:ceil(zr(2));
    set(gca, 'YMinorGrid', 'on');    
    grid(gca, 'on');
end

switch fview
  case 2
    %size xR, size xC, size xZ,
    %contourf(r, c, u, 'ZDataSource','supZData'); %, 'CDataMapping', 'scaled', ...
    %'EdgeColor', 'none');%(xZ>0),xC(xZ>0),xZ(xZ>0)); %,'ZDataSource','supZData');
    %, 'CDataMapping', 'scaled', ...
    %'EdgeColor', 'none',);
    surf(r,c,u,u,'ZDataSource','supZData', 'CDataMapping', 'scaled', ...
    'EdgeColor', 'none', 'CDataSource','supZData' );  
  otherwise
    surf(r,c,u,u,'ZDataSource','supZData', 'CDataMapping', 'scaled', ...
    'EdgeColor', 'none', 'CDataSource','supZData' );
end

if exist('lLayers','var')
  for l = lLayers %[floor(zr(1)) ceil(zr(2))]
    surf(lX, lY, lZ'.* l , ...
       'EdgeAlpha', 1, 'EdgeColor', 0.5 * [1 1 1], ...
       'FaceAlpha', 1, 'FaceColor', 'none', ... %0.25 * [1 1 1], ...
       'LineStyle', lLineStyle, 'LineWidth', 0.5, ...
       'Marker', 'none' );
  end
end

if exist('xZC','var')
  scatter3(xR(xZ>0),xC(xZ>0),xZC(xZ>0),25,[0 0 0], ...
    'LineWidth', 0.25, 'Marker', 's'); %'filled', 
end



%set(gca,'XGrid','off','YGrid','off','ZGrid','on')
%s=find(sheetSequance>=i,1,'first');
s=supData.sheetIndex(supSheet);
title(['Sample #' num2str(s)]);
xlabel('Circumferential'); 
ylabel('Axial');
zlabel('L*');

hold off;

f = fig;

end

