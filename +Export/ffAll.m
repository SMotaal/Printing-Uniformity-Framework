%ffPath = fullfile('samples', 'slices', 'TIFF'), ffForm = 'conresC3_%02d.tif'

% F = img;

ffXs = [1  1  7  7];
ffYs = [1  7  1  7];
ffBs = [3  3 12 12];
ffSs = 1;
ffRp = 60;
ffRs = 1:1/ffSs:ffRp;
ffRs = ffRs(1:end-1);
ffS = 40;

for q = 1 %1:numel(ffXs)
  ffX = ffXs(q);
  ffY = ffYs(q);
  ffB = ffBs(q);
  
%   ffAngles    = round(360/360); ffNum = ffX*8+ffY, bpF = ffB, ffPlot;

  ffP = 0;

  ffTarget = ['F' int2str(ffX) int2str(ffY)];

  for ffP = 0; %0:3 %:4
    %ffRange = 1+ffP*ffS:(ffP+1)*ffS;
    ffA = 1+ffP*ffS;
    if ffA > ffRp, break; end
    ffRange = ffRs(min(ffA, ffRp-1):min(ffA+ffS-1,ffRp-1));
    xCols = 10;
    xRows = numel(ffRange) / xCols;

    set(gcf,'Position', [20 20 1113 600]); % [20 20 1113 860]);

    for xPlot = 1:numel(ffRange)
      
      xFreq = ffRange(xPlot);

%       xLoc = find(locs(1:min(10, numel(locs))) == xFreq);

      if xFreq ~= 0
        H = bandfilter('gaussian', 'pass', N, M, xFreq, 1);
        G = F.*H;
        img2 = ifft2(G);
        %img2 = im2bw(imadjust(img2,stretchlim(img2,[0.45,0.55]),[]));
      else
        img2 = img;
      end

      h = subplot(xRows,xCols,xPlot);
      p = get(h, 'pos');
      p(3) = p(3) + 0.01;
      set(h, 'pos', p);

      imshow(img2, [] ,'Border','tight');
      %axis off;

%       if xLoc > 0
%         xSub = ['  ' int2str(xLoc)];
%         axis on;
%         set(gca,'XTickLabel',[]);
%         set(gca,'YTickLabel',[]);
%         set(gca,'XTick',[]);
%         set(gca,'YTick',[]);
%         set(gca,'LineWidth',2);
%       else
%         xSub = '';
%         axis off;
%       end

      %ffTitle = [ffTarget '-' num2str(xFreq)
%       title([ffTarget '-' num2str(xFreq,'%3.2f') xSub], 'FontSize', 5);
title(num2str(xFreq,'%3.2f'));
    end

    drawnow;

    print('-depsc2', [ffTarget '-' int2str(ffP+1) '.eps']);

  end
end

