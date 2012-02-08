% close all;

pause(0.5);

if(~exist('supData', 'var') && ~exist('source','var'))
  source = 'ritsm7402a';
end

if(exist('source','var'))
  supLoad(datadir('uniprint',source));
  newPatchValue = 100;
  clear source;
end
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
  supStatPlots = supPlotStats(supPlotData, supData);
end

if ~exist('exportVideo', 'var')
  exportVideo = false;
end


if (exportVideo)
  nfig = 'Spatial-Temporal Stats Output Plot';
  hfig = []; % findobj('type','figure','name', nfig);
  if (isempty(hfig))
    hfig =  figure('Name', nfig, 'units','pixels', ...
      'Color', 'w', 'Toolbar', 'none', ... %'WindowStyle', 'modal', ...
      'MenuBar', 'none', 'Renderer', 'OpenGL');
  else
    figure(hfig);
  end
else
  nfig = 'Spatial-Temporal Stats Plot';
  hfig = []; % findobj('type','figure','name', nfig);  
  if (isempty(hfig))
    hfig =  figure('Name', nfig, 'units','pixels', ...
      'Color', 'w', 'Renderer', 'OpenGL');
  else
    figure(hfig);    
  end
end

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

mBarStyle     = {mBoldFont{:}, 'FontSize', 10, mBoldWeight{:}, 'Projection', 'Perspective'};
mGridStyle    = {'GridLineStyle', ':', 'MinorGridLineStyle','-', ...
  'XColor',defGridColor, 'YColor',defGridColor, 'ZColor',defGridColor};
mAxesStyle    = {mBoldFont{:}, 'FontSize', 12, mBoldWeight{:}, mGridStyle{:}};
mGlobalStyle  = {'LineSmoothing','on'};
mZoneStyle    = {'LineStyle',':', 'FaceColor', 'none', 'LineWidth', 0.25};


jFrame = get(handle(gcf),'JavaFrame');
jFrame.setMaximized(true);

fPos = get(hfig,'position');  %[fLeft fBottom fWidth fHeight]

pause(0.5);

if ~exist('plotType', 'var')
  plotType = 'region';  % 'zone';  % 'axial';
end
% r=supStatPlots.('bandSurfs'); masks=[6:8];
try
  statPlots=supStatPlots.([plotType 'Surfs']); masks=[];
  statMasks=supStatPlots.([plotType 'Masks']);
catch err
  return;
end

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
    
    deltaField = numel(field)>=5 && strcmpi(field(1:5),'Delta');
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
      
      
      grid on;
      set(gca,mAxesStyle{:});
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
    
    if(~deltaField)
      amin(af) = min([amin(af), dmin]);
      amax(af) = max([amax(af), dmax]);
      dlim  = [floor(amin(af)) ceil(amax(af))]; % dlim  = [amin(af) amax(af)];
      clim = dlim;
    else
      amin(af) = 0;
      amax(af) = 10;
      dlim  = [floor(amin(af)) ceil(amax(af))]; % dlim  = [amin(af) amax(af)];
      clim = [0 6];
    end
    
    
    
    
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
        
        surf(nData, 'ZDataSource',zLabel, 'EdgeColor', 'none'); % 'FaceAlpha', 0.75);
        
        hcb = colorbar('SouthOutside', mBarStyle {:}); %, 'LineWidth', defLineWidth + 0.5);
        cbUnits = get(hcb,'Units');
        set(hcb,'Units','pixels');
        cbPos = get(hcb,'Position');
        cbPos(2) = cbPos(2) - 40;
        cbPos(4) = 5;
        cbPos(3) = cbPos(3)-2;
        set(hcb,'Position', cbPos);
        cbTicks = get(hcb, 'XTick');
        cbLims = get(hcb, 'XLim');
        cbTicks = floor(min(cbLims)):1:ceil(max(cbLims));
        set(hcb, 'XTick', cbTicks);
        set(hcb, 'Units', cbUnits);

      end
      if (labelField)
        try
          set(htext(f,m),'String', tV);
        catch err
          try
            [tY1 tX1] = ind2sub(size(mask),find(mask==1, 1, 'first'));
            [tY2 tX2] = ind2sub(size(mask),find(mask==1, 1, 'last'));
            tZ = max(dlim)+1;
            tX = min(tX1,tX2) + round(abs(tX1-tX2)/2);
            tY = min(tY1,tY2) + round(abs(tY1-tY2)/2);
            htext(f,m) = text(tX,tY,tZ,'##', mLabelStyle{:});
            
            tEx = num2cell(get(htext(f,m),'Extent')); % [tl, tb, tw, th]
            [tl, tb, tw, th] = deal(tEx{:});
            if (tw*0.5>tX2-tX1)
              if(rem(m,2)==1) % || -1);
                %                 tbo = +5
                set(htext(f,m),'VerticalAlignment','top');
              else
                set(htext(f,m),'VerticalAlignment','bottom');
              end
              %               set(htext(f,m),'Position',[tl tb+tbo tZ]);
            end
            if (th*0.5>tY2-tY1)
              if(rem(m,2)==1) % || -1);
                %                 tbo = +5
                set(htext(f,m),'HorizontalAlignment','left');
              else
                set(htext(f,m),'HorizontalAlignment','right');
              end
              %               set(htext(f,m),'Position',[tl tb+tbo tZ]);
            end
            
            set(htext(f,m),'String', tV);
          catch err
            continue;
            
          end
        end
      end
      %       drawnow();
    end;
    
    
    
  end % Field Loop
  refreshdata;
  drawnow;
  %   cmap = 'Jet';
  %   colormap(cmap);
  
  if (exportVideo)
    img = imresize(print2array(hfig, 1.25),1/1.25);
    if (s==1)
      mImg = mean(img,3);
      mIX = mean(mImg,1);
      mIY = mean(mImg,2);
      mBorder = 20;
      iY1 = find(mIY~=255, 1, 'first');
      iX1 = find(mIX~=255, 1, 'first');
      iY2 = find(mIY~=255, 1, 'last');
      iX2 = find(mIX~=255, 1, 'last');
      iY1 = max(iY1-mBorder,0);
      iX1 = max(iX1-mBorder,0);
      iY2 = min(iY2+mBorder,size(img,1));
      iX2 = min(iX2+mBorder,size(img,2));
    end
    
    img2 = img(iY1:iY2,iX1:iX2,:);
    M(s) = im2frame(img2); %,C);
  end
  pause(0.001)
end

hold off;

if (exportVideo)
  aviName = fullfile('output','statsVideo',lower([runName '-' plotType '-' int2str(supPatchValue)]));
  mVideoWriter = VideoWriter(aviName,'Motion JPEG AVI');
  mVideoWriter.FrameRate = 10.0;
  open(mVideoWriter);
  writeVideo(mVideoWriter,M);
  close(mVideoWriter);
  close gcf;
end


