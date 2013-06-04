q =   {}; 

n   = 1000;

clf;

  
S = warning('off', 'MATLAB:polyfit:RepeatedPointsOrRescale');

for m = 1:35
  xStd  = 0;
  %while xStd<m/5 && xStd>m/2%xStd<4 % || xStd>5
  x0 = repmat(n, 1, round(rand()*n));
  n0 = numel(x0);
  
  % x  = [1:550];
  % x1=round(rand(1, n-n0)*(rand()*n));
  % x = [n-x1 x0 n+x1];
  x = [];
  while numel(x)<22 || (xStd<550 || xStd>555) % && (numel(x)<500 | numel(x)>1000)
    x1 = round(rand(1, n-n0)*n);
    xO = n*0.5*rand;
    x1(x1>(xO+n/10+rand()*n*0.75) & x1<(xO-n/10-rand()*n*0.5))   = NaN;
    x1 = x1.*fliplr([0.75+rand*0.5]*(1 + log((1+[1:numel(x1)]*rand)/numel(x1)) ) );
    x1(x1<(nanmin(x1)+nanstd(x1)/20)) = NaN;
    x = [n-x1 n+x1];
    %x(x==n) = NaN;
    xStd = round(nanstd(x)); % *100)/100;
  end
  
  %end
  xMean = round(nanmean(x)*10)/10;
  q(end+1, 1:3)   = {xMean, xStd, x};
  ax1               = subplot(5,7,m, 'align');
  ax2               = axes('Position', get(ax1, 'Position'));

  hold on;
  [hY hX]           = hist(x, 123); %, 'Parent', ax1, 'FaceColor',[1 1 1]*0.5,'EdgeColor','w');
  
  bar(hX, hY, 'Parent', ax1, 'FaceColor',[1 1 1]*0.5, 'EdgeColor','none');
  
  %hist(x, 75, 'Parent', ax1, 'FaceColor',[1 1 1]*0.5,'EdgeColor','w');
  
  yLims             = [0 n/3];
  xLims             = [-n/4 n*2+n/4];
  
  set(ax1, 'xtick', [], 'ytick', [], 'xlim', xLims, 'box', 'off'); %, 'ylim', yLims);
  
  hold on;
  
  tX                = [0:n*2];
  tP                = polyfit(hX, hY, 16); %spline(hX, hY, tX);
  tY                = polyval(tP,tX);
  
  yLims             = get(ax1, 'ylim');
  
  plot(tX, tY, 'Parent', ax2, 'Color', 'k', 'Linewidth', 1); % , 'Linesmoothing', 'on');
  
  set(ax2, 'xtick', [], 'ytick', [], 'xlim', xLims,  'box', 'off', 'ylim', yLims, 'Color', 'none', ...
     'visible', 'off')
   
  title(sprintf('Std: %1.2f\tN: %d', xStd, sum(~isnan(x))), 'FontSize', 8, 'Parent', ax1);
  
  drawnow();
  
  %title(sprintf('Mean: %1.1f\tStd:%1.2f', xMean, xStd));
end; 
q

  
warning(S);
