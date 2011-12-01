%% Load L* data for sheet from supInterp output
%supImg = supPlotData(1,1).u;

runName = supMat.sourceTicket.folder.name;

if ~exist('fSheet','var') || ~isnumeric(fSheet)
  fSheet  = 1;
end

if ~exist('fSet','var') || ~isstr(fSet)
  fSet   = 'u';
end

if ~exist('useCurrentFrame','var') || useCurrentFrame ~= true
  figure;
end

supImg = evalin('base',['supPlotData(1,' int2str(fSheet) ').' fSet]);

imgName = [runName '-' sprintf('%03d',fSheet) '-' fSet];

%% Squeeze range of data to image
% imean = nanmean(supImg(:));
% imin = nanmin(supImg(:));
% imax = nanmax(supImg(:));
% irange = imax-imin;


%% Squeeze range of data based on supPlot data
irange = 6;
imean = round(nanmean(reshape(eval(['supPlotData(:).' fSet]),[],1,1,1)));
imin = imean - irange / 2;
imax = imean - irange / 2;

% supImg(isnan(supImg)) = 0;

img = (supImg - floor(imin)) / ceil(irange);



img(isnan(img)) = 0.5;


subplot(2,3,1);
imshow(img');

%% Trim to even dimensions for FFT operations
[N1 M1] = size(img);

N = N1 - mod(N1,2);
M = M1 - mod(M1,2);

% N1 = N1 - 1;  % Logic testing passed
% M1 = M1 - 1;

if ~(N==N1 && M==M1)
  img = img(1:N, 1:M);
  [N M] = size(img);
  disp('Image was cropped to next even dimension!');
end

hPreviewFig = subplot(2,3,1);
imshow(img');

img = abs(img-0.5).*2;

subplot(2,3,2);
imshow(img');

%% FFT Analysis
F = fft2(img, N , M);
Fc = fftshift(F);

S = gscale(log(1+abs(Fc)));

subplot(2,3,3);
imshow(S');


%% Spatial Frequency Analysis w/ Gaussian-Band Mean

% These variables are common to spatial analysis
rho = 50; %max(N,M)/2;
%rhoMicrons = rho/imgMPD;
%rhoMin = 2;

rR = rho;
rV = zeros(1,rR);
rV2 = zeros(1,rR);

%clear dbg

for r = 1:rR
  Hr = bandfilter('gaussian', 'pass', N, M, r, 1);
  Gr = F.*Hr; %.*(max(Hr(:))>0)
  if (max(Hr(:))>0)
    Gs = tofloat(abs(Gr));
    rV(r) = sum(Gs(:))/sum(Hr(:));%*max(Gs(:)));
  else
    rV(r) = 0;
  end 

  
  rV2(r) = mean(Gs(:));
  
  %dbg(r,:) = real([max(Gr(:)) max(Hr(:)) max(Gs(:)) sum(Hr(:)) sum(Gs(:)) rV(r)]);
end

% close all;
subplot(2,3,4:6);
% plot(rV);
% return;
% plot(log(rV));
% plot(log(rV));
% grid(gca,'minor');

% xlabel('Spatial Pitch');

% ylabel('Log Frequency');
% axis([ 0 rho -10 0]);
% 
% % ylabel('Frequency');
% % axis([ 0 rho 0 0.3]);
% 
% set(gca,'XMinorTick',  'on');
% set(gca,'XMinorGrid',  'on');
% set(gca,'xtick',0:2:rho)
% set(gca,'YScale',      'log');
% set(gca,'YMinorTick',  'on');
% set(gca,'YMinorGrid',  'on');


%% Plot
mPlotData = rV; %.*irange;       % log(rV);
mYScale   = 'linear'; % 'log';

mYLim     = 50; %irange*1.5; %3*std(mPlotData);

mYLim     = [0 mYLim]; %irange]; %3*std(mPlotData)] %[0 0.25*irange];    % [-10 0];
mMinorGridColor = [1 1 1] .* 0.75;
mPlotAxis = [ 0 rho mYLim];
set(gca, 'XGrid','on', 'XTick',0:rho,  'XTickLabel', '', ...
         'YGrid','on', 'YScale', mYScale, ...
         'XColor', [0 0 0],'YColor', [0 0 0],'GridLineStyle',':');
axis(mPlotAxis);
ylim(mYLim); %ylim([-10 0]);
ylabel('L* Deviation');
title(imgName);
mPlotAxis2 = axes('Position',get(gca,'Position'),'Color','none','box','on','YScale',mYScale, ...
      'GridLineStyle','-','XGrid','on', 'YTick',[]);
hold on;

% pV = log(rV);
plot(mPlotData);

% r = 6; plot(rV); hold on; rQ=upsample(decimate(rV,r),r); bar(rQ); hold off

rF = 2;
rQ=upsample(decimate(mPlotData,rF),rF);
bar(rQ, 'FaceColor', 'none');

% ylim([-10 0]);
ylim(mYLim);
axis(mPlotAxis);
xlabel('Spatial Frquency');



hold off;

% return;

if ~exist('useCurrentFrame','var') || useCurrentFrame ~= true
  jFrame = getjframe;
  jFrame.setExtendedState(6);
end

useCurrentFrame = false;

%% Output Plot
drawnow();

epsExt = '.png'; % '.eps';

epsDir = '';
for epsPath = {'output', ['supFFT-' datestr(now,'yymmdd')], [runName '-' fSet]}
  epsDir = fullfile(epsDir,char(epsPath));
  if ~exist(epsDir ,'dir')>0,  mkdir(epsDir); end
end

% epsDir = 'output';
% if ~exist(epsDir ,'dir')>0,  mkdir(epsDir); end
% 
% epsDir = fullfile(epsDir,'supFFT');
% if ~exist(epsDir ,'dir')>0,  mkdir(epsDir); end
% 
% epsDir = fullfile(epsDir, [runName '-' fSet]);
% if ~exist(epsDir ,'dir')>0,  mkdir(epsDir); end
mOverride = false;

epsNumber = 0;

while true
  if epsNumber > 0
    epsName = ['sup-' datestr(now,'yymmdd') '-' imgName '-' sprintf('%02d',epsNumber) epsExt];
  else
    epsName = ['sup-' datestr(now,'yymmdd') '-' imgName epsExt];
  end
  if (mOverride == false) && (exist(fullfile(epsDir,epsName),'file')>0)
    epsNumber = epsNumber+1;
  else
    break
  end
end  

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'inches');
%set(gcf, 'PaperType', 'usletter');
set(gcf, 'PaperSize', [11 8.5]);
set(gcf, 'PaperOrientation','portrait');
set(gcf, 'PaperPosition',[0 0 11 8.5]);
set(gcf, 'InvertHardcopy', 'off');
bgcolor = get(gcf, 'Color');
set(gcf, 'Color', 'white');
%print('-depsc2',fullfile(epsDir ,epsName));
saveas(gcf,fullfile(epsDir ,epsName));
%plot2svg(fullfile(epsDir ,epsName));
set(gcf, 'Color', bgcolor);

