% source='rithp5501';%'ritsm7402b';
close all;

pause(0.5);
% exportFun = @(fh,sz,md) imresize( print2array(fh, 1.25)   , sz, md);

if(exist('source','var'))
  supLoad(datadir('uniprint',source));
  newPatchValue = 100;
  %   fSource = source;
  clear source;
end
% if (~exist('fSource','var'))
%   fSource = 100;
% end
if exist('newPatchValue','var')
  clear supPatchSet;
end
if ~exist('supPatchSet','var')
  if ~exist('newPatchValue', 'var')
    newPatchValue = 100;
  end
  supPatchValue = newPatchValue;
  supPatchSet = supData.patchMap == supPatchValue;
  clear newPatchValue;
  clear supPlotData;
end
if ~exist('supPlotData','var')
  supInterp;
  clear supStatPlots;
end
if ~exist('supStatPlots','var')
  supStatPlots = supPlotStats(supPlotData);
end

hfig =  figure('Name', 'Spatial-Temporal Stats Plot', 'units','pixels', ...
  'Color', 'w', 'Toolbar', 'none', ... %'WindowStyle', 'modal', ...
  'MenuBar', 'none', 'Renderer', 'OpenGL');

pause(0.5);

defUnits      = 'normalized';

defLineStyle    = '-';
defLineWidth    = 1;

defGridColor    = [1,1,1].*0.5;

defTextFont   = 'Helvetica'; %'Gill Sans';
defBoldFont   = 'Helvetica Bold'; %defTextFont;
defBoldWeight = 'bold';
defTextColor  = 'k';

mTextFont     = {'FontName',   defTextFont};
mTextColor    = {'Color', defTextColor};
mBoldFont     = {'FontName',   defBoldFont}; %[mTextFont ' Bold']; %'Helvetica Bold'
mBoldWeight   = {'FontWeight', defBoldWeight};
mLabelAlignment = {'HorizontalAlignment','center','VerticalAlignment','middle'};

mTitleStyle   = {mBoldFont{:}, 'FontSize', 12, mBoldWeight{:}, mTextColor{:}};
mLabelStyle   = {mLabelAlignment{:}, mBoldFont{:}, 'FontSize', 11, mBoldWeight{:}, mTextColor{:}}; %...

mBarStyle     = {mBoldFont{:}, 'FontSize', 10, mBoldWeight{:}};
mGridStyle    = {'GridLineStyle', '-', 'MinorGridLineStyle','-', ...
  'XColor',defGridColor, 'YColor',defGridColor, 'ZColor',defGridColor};
mAxesStyle    = {mBoldFont{:}, 'FontSize', 12, mBoldWeight{:}, mGridStyle{:}};
mGlobalStyle  = {'LineSmoothing','on'};
mZoneStyle    = {'LineStyle',':', 'FaceColor', 'none', 'LineWidth', 0.25};


jFrame = get(handle(gcf),'JavaFrame');
jFrame.setMaximized(true);

pause(0.5);

plotType = 'region';
% r=supStatPlots.('bandSurfs'); masks=[6:8];
statPlots=supStatPlots.([plotType 'Surfs']); masks=[];
statMasks=supStatPlots.([plotType 'Masks']);

fields = {'UpperLimit', 'LowerLimit', 'Mean', 'DeltaLimit'};


runName = supMat.sourceTicket.folder.name; %supMat.sourceTicket.testrun.press.name;
%'LowerLimit', ... 'Mean', ... 'UpperLimit'};

clear zData*

%daspect([100 100 15]); view([35  35]);

dint = 1.5;

amin(1:numel(fields)) = 100;
amax(1:numel(fields)) = 0;

htext = []; %zeros(supStatPlots.sheets,numel(fields);

iX1 = 0; iX2 = 0; iY1 = 0; iY2 = 0;

M(1:supStatPlots.sheets) = struct('cdata', [], 'colormap', []);

for s = 1:supStatPlots.sheets
  for f = 1:numel(fields) % Field Loop
    field = char(fields(f));
    
    subplot(1,numel(fields),f);
    
    %       subplot(2,2,f);
    
    deltaField = strcmpi(field,'DeltaLimit');
    meanField = strcmpi(field,'Mean');
    labelField = 1; %(deltaField || meanField);
    
    if(~deltaField)
      af=1;
    else
      af=f;
    end
    
    if(s==1)
      %         axes(mAxesStyle{:});
      daspect([100 100 20]); % view([55,20]);
      view([0, 90]);
      hold on;
      colorbar('SouthOutside', mBarStyle {:}); %, 'LineWidth', defLineWidth + 0.5);
      grid on;
      %         title([runName '        '  field  '        ' int2str(s) ' ' int2str(supPatchValue) '%'], mTitleStyle{:});
      xlim([1 supStatPlots.columns]);
      ylim([1 supStatPlots.rows]);
      cmap = 'Jet';
      colormap(cmap);
    end;
    title([runName '     '  field '     ' int2str(supPatchValue) '%'  '     ' int2str(s)], mTitleStyle{:});
    
    
    dlist = reshape(statPlots.(field).Values(:,:,:,:),[],1);
    
    dmean = nanmean(dlist);
    dstd = nanstd(dlist);
    
    %     dmin = min(dlist);
    %     dmax = max(dlist);
    dint = max([dint, dstd*3]); %abs(dmean-dmin), abs(dmean-dmax), dint]);
    dmin  = dmean-dint; %min(dlist);
    dmax  = dmean+dint; %max(dlist);
    
    amin(af) = min([amin(af), dmin]);
    amax(af) = max([amax(af), dmax]);
    
    dlim  = [amin(af) amax(af)];
    clim  = [floor(amin(af)) ceil(amax(af))];
    
    
    
    zlim([dlim(1)-1 dlim(2)+1]);
    caxis(clim);
    
    
    data = squeeze(statPlots.(field).Values(s,:,:,:)); % + (squeeze(r.('Std').Values(s,:,:,:)).*2);
    if(numel(masks)==0)
      masks=1:size(data,1);
      if(s==1 && f==1)
        htext = zeros(numel(fields),numel(masks));
      end
    end
    zData = squeeze(data(masks(1),:,:));
    for m = masks
      
      mask = squeeze(statMasks(m,:,:));
      
      
      if (m==masks(1))
        nData = squeeze(data(m,:,:));
      else
        nData = squeeze(data(m,:,:));
      end
      zIndex = ~isnan(nData);
      zData(zIndex) = nData(zIndex);
      zLabel = ['zData' field int2str(m)];
      %zData(tY,tX) = 0;
      eval([zLabel '=zData;']);
      
      if (labelField)
        tV = int2str(nanmean(nData(:)));
      end
      
      if (s==1)
        %         if (m==masks(end))
        %            %f = 1 % Field Loop
        %
        %           surf(zData, 'ZDataSource',zLabel, 'EdgeColor', 'none', 'FaceAlpha', 0.75);
        %           text(tX,tY,max(dlim),int2str(nanmean(nData(:))));
        %           drawnow;
        %         end
        
        surf(nData, 'ZDataSource',zLabel, 'EdgeColor', 'none'); % 'FaceAlpha', 0.75);
        
        if (labelField)
          [tY1 tX1] = ind2sub(size(mask),find(mask==1, 1, 'first'));
          [tY2 tX2] = ind2sub(size(mask),find(mask==1, 1, 'last'));
          tX = min(tX1,tX2) + round(abs(tX1-tX2)/2);
          tY = min(tY1,tY2) + round(abs(tY1-tY2)/2);
          htext(f,m) = text(tX,tY,max(dlim)+1,'', mLabelStyle{:});
        end
        
        %         if (m==1 && f==1)
        %           jFrame = get(handle(gcf),'JavaFrame');
        %           jFrame.setMaximized(true);
        %         end
      end
      if (labelField)
        set(htext(f,m),'String', tV);
      end
      %       drawnow();
    end;
    
    
    
  end % Field Loop
  refreshdata;
  drawnow;
  cmap = 'Jet';
  colormap(cmap);
  %   F = getframe(gcf);
  %   [I,C] = frame2im(F);
  %   img = imresize(I,1/1.25);
  img = imresize(print2array(hfig, 1.25),1/1.25);
  if (s==1)
    mImg = mean(img,3);
    mIX = mean(mImg,1);
    mIY = mean(mImg,2);
    mBorder = 20;
    %     [iY1 iX1] = ind2sub(size(img),find(mImg~=255, 1, 'first'));
    %     [iY2 iX2] = ind2sub(size(img),find(mImg~=255, 1, 'last'));
    iY1 = find(mIY~=255, 1, 'first');
    iX1 = find(mIX~=255, 1, 'first');
    iY2 = find(mIY~=255, 1, 'last');
    iX2 = find(mIX~=255, 1, 'last');
    iY1 = max(iY1-mBorder,0);
    iX1 = max(iX1-mBorder,0);
    iY2 = min(iY2+mBorder,size(img,1));
    iX2 = min(iX2+mBorder,size(img,2));
    
    % image(F.cdata)
    %     colormap(F.colormap)
  end
  
  img2 = img(iY1:iY2,iX1:iX2,:);
  
  %   [I, C] = rgb2ind(img2,32);
  
  %   M(s) = im2frame(img2,F.colormap);
  M(s) = im2frame(img2); %,C);
  pause(0.001)
end
aviName = fullfile('output','statsVideo',[runName '-' int2str(supPatchValue)]);
mVideoWriter = VideoWriter(aviName,'Motion JPEG AVI');
mVideoWriter.FrameRate = 10.0;
open(mVideoWriter);
writeVideo(mVideoWriter,M);
close(mVideoWriter);
close gcf;

