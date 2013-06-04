function Export(obj)
  
  obj.bless;
  
  S = warning('off', 'all');
  
  %obj.ColorBar.createPatches; obj.ColorBar.createLabels;
  
  obj.layoutPlotAxes;
  
  try
    for m = 1:numel(obj.DataSources)
      try obj.DataSources{m}.PlotOverlay.updateSubPlots; end
    end
  end
  
  try
    
    %% Options
    pageScale   = 150;
    pageSize    = [11 8.5]; %  .* 150;
    
    if ~obj.IsVisible
      obj.Position = [obj.Position(1:2) [800 600]];
    end
    
    screenPPI   = get(0, 'ScreenPixelsPerInch');
    
    set(0, 'ScreenPixelsPerInch', 96);
    
    figureOptions = { ...
      'Visible', 'off', 'Renderer', 'painters', ...
      'Position', floor([0 0 pageSize]), ...
      'Color', 'none', ...
      'Toolbar', 'none', 'Menubar', 'none', ...
      'NumberTitle','off', 'Name', 'Grasppe Ouput', ...
      };
    
    %% Functions
    deleteHandle = @(x) delete(ishandle(x));
    
    %% Setup Output Figure
    try deleteHandle(obj.OutputFigure); end
    
    obj.OutputFigure = figure(figureOptions{:});
    
    %% Duplicate Figure
    hdFigure = obj.Handle;
    hdOutput = obj.OutputFigure;
    
    colormap(hdOutput, colormap(hdFigure));
    
    %% Switch Print/Screen
    set(findobj(hdFigure, '-regexp','Tag','@Screen'), 'Visible', 'off');
    set(findobj(hdFigure, '-regexp','Tag','@Print'), 'Visible', 'on');
    
    %% Duplicate Children
    
    children  = allchild(hdFigure);
    nChildren = numel(children);
    
    hgObjects.Unsupported = cell(0,4);
    
    for m = 1:nChildren
      
      [hdObject, hgObject, clObject, hdInfo] = HG.handleObject(children(m));
      
      try clObject = hgObject.type; end
      
      properties = {};
      
      switch clObject
        case {'axes'}
          properties = {'XLim', 'YLim', 'ZLim', 'CLim', 'LooseInset'};
        otherwise
          %dispf('Not copying handle %d because %s objects are not supported.\t%s', floor(hdObject), clObject, hdInfo);
          hgObjects.Unsupported(end+1,:) = {clObject, hdObject, hgObject, hdInfo};
          continue;
      end
      
      %% Shallow Copying
      hdCopy  = copyobj(hdObject, hdOutput);
      hgCopy  = handle(hdCopy);
      
      %%% Deep Copying
      if ~isempty(properties)
        for n = 1:numel(properties)
          try
            set(hdCopy, properties{n}, get(hdObject, properties{n}));
          catch err
            try debugStamp(err, 1, obj); catch, debugStamp(); end;
          end
        end
      end
      
      %         switch clObject
      %           case {'axes'}
      %             for n = 1:numel(properties)
      %               set(hdCopy, properties{n}, get(hdObject(properties{n})));
      %             end
      %         end
      
      if isfield(hgObjects, clObject)
        hgObjects.(clObject)(end+1) = hgCopy;
      else
        hgObjects.(clObject)        = hgCopy;
      end
      
    end
    
    %% Restore Print/Non-Print
    set(findobj(hdFigure, '-regexp','Tag','@Screen'), 'Visible', 'on');
    set(findobj(hdFigure, '-regexp','Tag','@Print'), 'Visible', 'off');
    
    set(hdOutput, 'Units', 'pixels', 'Position', [0 0 100 100]);
    
    plotRect=[];
    
    %% Gather Decendents
    
    for ax = fliplr(hgObjects.('axes'))
      decendents  = allchild(ax);
      nDecendents = numel(decendents);
      
      
      % if isempty(strfind('ax.Tag', '#PlotAxes'))
      %   continue;
      % end
      
      ax.Units = 'pixels';
      
      tag = ax.Tag;
      
      isPlotAxes  = ~isempty(strfind(ax.Tag, 'PlotAxes'));
      isColorBar  = ~isempty(strfind(ax.Tag, 'ColorBar'));
      isOverlay  = ~isempty(strfind(ax.Tag, 'OverlayAxes'));
      
      if isPlotAxes %~isempty(strfind(ax.Tag, 'PlotAxes'))
        ax.XLim = ax.XLim + [-1 +1];
        ax.YLim = ax.YLim + [-1 +1];
        
        if all(mod(ax.View,90))==0
          %dispf('AX:\t[View: %d %d]', mod(ax.View,90));
          ax.Box  = 'on';
        end
        
        axPad               = [0 0 0 0];
        try axPad           = ax.LooseInset; end
        ax.OuterPosition    = ax.OuterPosition + ...
          [15+axPad(1) 15-axPad(4) 30-axPad(1)-axPad(3) 30-axPad(2)-axPad(4)];
        
        clObject = 'PlotAxes';
        if isfield(hgObjects, clObject)
          hgObjects.(clObject)(end+1) = ax;
        else
          hgObjects.(clObject)        = ax;
        end
        
      elseif isColorBar %~isempty(strfind(ax.Tag, 'ColorBar'))
        %axOffset = 10; %ax.Position(3)/2;
        %ax.OuterPosition  = ax.OuterPosition + [-25 15 0 0];
        ax.Position       = [0 0 175 15]; %.* [1 1 0.75 0.75];
        %ax.Position       = ax.Position .* [0.75 0.75 0.75 0.75];
        ax.Visible  = 'off';
        %colorBars{end+1} = ax;
        clObject = 'ColorBarAxes';
        if isfield(hgObjects, clObject)
          hgObjects.(clObject)(end+1) = ax;
        else
          hgObjects.(clObject)        = ax;
        end
        
        if ax.LineWidth==1, ax.LineWidth = 0.5; end
        set(findobj(decendents, 'Type', 'text'), 'FontSize', 6, 'FontWeight', 'normal');
        
        continue;
      elseif isOverlay
        clObject = 'OverlayAxes';
        if isfield(hgObjects, clObject)
          hgObjects.(clObject)(end+1) = ax;
        else
          hgObjects.(clObject)        = ax;
        end
        continue;
      else
        %ax.OuterPosition = ax.OuterPosition + [15 15 0 0];
        %ax.LineWidth = ax.LineWidth/2;
      end
      
      if isequal(ax.Visible, 'on')
        parentPosition = HG.pixelPosition(hdOutput);
        
        % dispf(['AX:\t[Position: %d %d %d %d \t' ...
        %   'OuterPoisiton: %d %d %d %d\t' ...
        %   'TightInset: %d %d %d %d\t' ...
        %   'LooseInset: %d %d %d %d\t' ...
        %   'Figure: %d %d %d %d' ...
        %   ], ax.Position, ax.OuterPosition, ax.TightInset, ax.LooseInset, ...
        %   parentPosition);
        
        axPosition    = ax.Position;
        axRight       = axPosition(1) + axPosition(3);
        axTop         = axPosition(2) + axPosition(4);
        
        parentWidth   = parentPosition(3);
        parentHeight  = parentPosition(4);
        
        if isPlotAxes && axRight > parentWidth || axTop > parentHeight
          parentPosition  = [parentPosition(1:2) axRight+50 axTop+50];
          parentUnits     = get(hdOutput, 'Units');
          set(hdOutput, 'Units', 'pixels', 'Position', parentPosition);
          set(hdOutput, 'Units', parentUnits);
        end
      end
      
      for o = 1:nDecendents
        
        [hdObject, hgObject, clObject, hdInfo] = HG.handleObject(decendents(o));
        
        try clObject = hgObject.type; end
        
        switch clObject
          case {'text', 'surface', 'line', 'patch'}
            
          otherwise
            %dispf('Not formatting handle %d because %s objects are not supported.\t%s', floor(hdObject), clObject, hdInfo);
            hgObjects.Unsupported(end+1,:) = {clObject, hdObject, hgObject, hdInfo};
            continue;
        end
        
        if isfield(hgObjects, clObject)
          hgObjects.(clObject)(end+1) = hgObject;
        else
          hgObjects.(clObject)        = hgObject;
        end
        
      end
      
      if isequal(ax.Visible, 'on') && all(mod(ax.View,90))==0 && isPlotAxes
        tick2text(ax);
        hx = getappdata(ax, 'XTickText');
        hy = getappdata(ax, 'YTickText');
        hz = getappdata(ax, 'ZTickText');
        hxyz = [hx; hy; hz];
        
        set(hxyz, 'Units', 'data');
        hxPos = get(hx, 'Position');
        hyPos = get(hy, 'Position');
        hzPos = get(hz, 'Position');
        
        set(hx, 'VerticalAlignment', 'Cap', 'HorizontalAlignment', 'Center'); %, 'Units', 'Pixels');
        
        set(hy, 'VerticalAlignment', 'Middle', 'HorizontalAlignment', 'Right'); % ', 'Units', 'Pixels');
        
        set(hxyz, 'Margin', 2, ... %'BackgroundColor', 'g', ...
          'FontUnits', ax.FontUnits, 'FontSize', ax.FontSize);
        
        set(hxyz, 'Units', 'data');
        
        for n = 1:numel(hx)
          hn = handle(hx(n));
          hn.Position = [hxPos{n}(1) min(ax.YLim)-0.5 hxPos{n}(3)];
        end
        
        for n = 1:numel(hy)
          hn = handle(hy(n));
          hn.Position = [min(ax.XLim)-0.5 hyPos{n}(2) hyPos{n}(3)];
        end
        
        for n = 1:numel(hz)
          hn = handle(hz(n));
          hn.Position = hzPos{n};
        end
        %hpos2 = get(hxyz, 'Position');
        
      end
      
    end
    
    %       %set(hdText, 'Margin' , cell2mat(get(hdText, 'Margin')) +1)
    %       for m = 1:numel(hdTexts)
    %         hgText = handle(hdTexts(m));
    %         hgText.Margin = hgText.Margin + 2;
    %         %hgText.BackgroundColor = 'g';
    %       end
    
    %% Fix Surfs
    if ~isfield(hgObjects, 'surface'), hgObjects.surface = []; end
    for hgSurf = hgObjects.('surface')
      if isa(hgSurf.Userdata, 'PrintUniformityBeta.Graphics.UniformityPlotComponent')
        objSurf   = hgSurf.Userdata(1);
        
        hdAx      = hgSurf.Parent;
        
        %           hdTitle   = title(hdAx, obj.Title, 'FontSize', 6, 'FontWeight', 'normal', ...
        %             'Units', 'normalized', 'Position', [0 1], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle'); % 'HorizontalAlignment', 'left');
        %
        %           set(hdTitle,'Units', 'pixels', 'Position', HG.pixelPosition(hdTitle) + [0 15 0]);
        
        try
          dataSource  = objSurf.DataSource;
          
          switch class(dataSource)
            case {'PrintUniformityBeta.Data.RegionStatsDataSource', 'PrintUniformityBeta.Data.RegionPlotDataSource'}
              
              regionMasks = dataSource.PlotRegions;
              regionData  = dataSource.PlotValues;
              regionRects = zeros(size(regionMasks,1), 4);
              
              regionPatch = [];
              regionLine  = [];
              
              regionMean  = nanmean(regionData(:));
              
              for r = 1:size(regionMasks,1)
                region = squeeze(eval(['regionMasks(r' repmat(',:',1,ndims(regionMasks)-1)  ')']));
                
                y       = nanmax(region, [], 2);
                y1      = find(y>0, 1, 'first')-1;
                y2      = find(y>0, 1, 'last');
                
                x       = nanmax(region, [], 1);
                x1      = find(x>0, 1, 'first')-1;
                x2      = find(x>0, 1, 'last');
                
                region  = [x1 y1 x2-x1 y2-y1];
                
                regionRects(r, :) = region;
                
                xl      = [x1 x2];
                yl      = [y1 y2];
                
                zv      = regionData(r);
                
                xd      = xl([1 2 2 1 1])';
                yd      = yl([1 1 2 2 1])';
                zd      = min(get(hdAx, 'ZLim')) .* [1 1 1 1 1]; %regionMean([1 1 1 1 1]);
                cd      = zv([1 1 1 1 1]);
                
                %'ZData',
                regionPatch(end+1)  = patch(xd, yd, zd, cd, 'Parent', hgSurf.Parent, 'FaceColor', 'flat', 'EdgeColor', 'k' , 'LineWidth', 0.125 ); %'EdgeColor', [0.5 0.15 0.15]
                regionLine(end+1)   = line(xd, yd, 210*[1 1 1 1 1], 'Parent', hgSurf.Parent, 'Color', 'k' , 'LineWidth', 0.125 ); %'EdgeColor', [0.5 0.15 0.15]
                
                %uistack(regionLine(end+1), 'bottom');
                %uistack(regionPatch(end+1), 'bottom');
                
                set(hdAx, 'Clipping', 'off');
                
                %, 'ZData', 210*[1 1 1 1 1],
                
                %try delete(hgSurf); end
              end
              
              hgSurf.Visible = 'off';
          end
          
        catch err
          try debugStamp(err, 1, obj); catch, debugStamp(); end;
        end
      end
    end
    
    %% Remove @Screen Objects
    set(findobj(hdOutput, '-regexp','Tag','@Screen'), 'Visible', 'off');
    set(findobj(hdOutput, '-regexp','Tag','@Print'), 'Visible', 'on');
    
    
    %% Determine Active PlotArea
    plotRect      = [];
    outerRect     = [];
    axesMaxArea   = [0 0];
    
    if ~isfield(hgObjects, 'PlotAxes'), hgObjects.PlotAxes = []; end
    for ax = hgObjects.('PlotAxes')
      set(ax, 'Units', 'pixels');
      
      %% Plot Rect
      axPosition    = HG.pixelPosition(ax);
      
      %ht          = text(max(ax.XLim), max(ax.YLim), 'test', 'Parent', ax); % max(ax.ZLim));
      ht            = text('Units', 'normalized', 'Parent', ax, 'String', '.', 'Position', [1 1]);
      htMax         = HG.pixelPosition(ht);
      set(ht, 'Units', 'normalized', 'Position', [0 0]);
      htMin         = HG.pixelPosition(ht);
      try delete(ht); end
      
      htBottomLeft  = axPosition(1:2) + min([htMax(:,1:2); htMin(:,1:2)]);
      htTopRight    = axPosition(1:2) + max([htMax(:,1:2); htMin(:,1:2)]);
      
      axBottomLeft  = htBottomLeft;
      axTopRight    = max([axPosition(1:2)+axPosition(3:4); htTopRight]);
      htDiff        = axPosition(3:4) - (htTopRight - htBottomLeft);
      
      axBottomLeft  = axBottomLeft + htDiff/2;
      axTopRight    = axTopRight - htDiff/2;
      
      if isempty(plotRect)
        plotRect = [axBottomLeft axTopRight];
      else
        plotRect = [ ...
          min([plotRect(1:2); axBottomLeft  ]), ...
          max([plotRect(3:4); axTopRight    ])];
      end
      
      axesMaxArea = max([axesMaxArea; axPosition(3:4)]);
      
      %% Outer Rect
      inset         = ax.LooseInset;
      exBottomLeft  = axBottomLeft - inset(1:2) - 10;
      exTopRight    = axTopRight   + inset(3:4) + 10; %+ inset(1:2);
      
      if isempty(outerRect)
        outerRect = [exBottomLeft exTopRight];
      else
        outerRect = [ ...
          min([outerRect(1:2); exBottomLeft ]), ...
          max([outerRect(3:4); exTopRight   ])];
      end
      
      
    end
    
    plotRect(3:4)     = plotRect(3:4)-plotRect(1:2);
    %outerRect(1:2)    = outerRect(1:2)+[-15 5];
    outerRect(3:4)    = outerRect(3:4)-outerRect(1:2);
    
    %outerRect         = outerRect + [-30 -20 +60 +160];
    outerRect         = plotRect  + [-300 -300 +600 +700];
    
    hax = axes('Parent', hdOutput, 'Units','pixels', 'Position', plotRect , ...
      'Visible', 'on', 'Color', 'none', 'Box', 'off', 'XColor', 'w', 'YColor', 'w');
    hax2 = axes('Parent', hdOutput, 'Units','pixels', 'Position', outerRect , ...
      'Visible', 'on', 'Color', 'none', 'Box', 'off', 'XColor', 'w', 'YColor', 'w');
    
    
    %% Fix Text
    titleFont   = 8;
    smallFont   = 5;
    adjustFont  = 0;
    fontUnits   = 'points';
    
    hdTexts = unique(findall(hdOutput, 'type', 'text'));
    for m = 1:numel(hdTexts)
      hgText = handle(hdTexts(m));
      
      hgText.FontUnits  = fontUnits;
      hgText.FontSize   = hgText.FontSize+adjustFont;
            
      if hgText.FontSize < smallFont
        hgText.FontSize   = smallFont;
      end
      
      try
        str   = hgText.String;
        nstr  = {};
        
        adjustText  = num2str(adjustFont,'%+1.0f');
        smallText   = num2str(smallFont,'%1.0f');
        
        %disp({adjustText, smallText});
        
        for l = 1:size(str,1)
          %nstr = strvcat(nstr, regexprep(strtrim(str(l,:)),'(\\fontsize{)([\d\.]+)(})', ['$1${max(2, ' int2str(smallFont-2) ', str2num($2)+' int2str(adjustFont) ')}$3']));
          nstr{end+1,1} = regexprep(strtrim(str(l,:)), ...
            '(\\fontsize{)([\d]+)(})', ...
            ['$1' '${int2str(max([2 ' smallText ' str2num($2)' adjustText ' ]) )}' '$3']);
        end
        %disp(str);
        %disp(nstr);
        if iscell(nstr) && ~iscellstr(nstr)
          hgText.String = [nstr{:}];
        else
          hgText.String = nstr;
        end
      catch err
        debugStamp(err,1);
      end
      
      if ~strcmpi(hgText.BackgroundColor, 'none') && all(hgText.Extent(3:4)>0)
        hgRect            = rectangle('Position', hgText.Extent, ...
          'FaceColor', hgText.BackgroundColor, 'Parent', hgText.Parent, ...
          'EdgeColor', 'none');
        
        % hgRect            = patch(...
        %   [0 hgText.Extent(3)] + hgText.Extent(1), [0 hgText.Extent(4)] + hgText.Extent(2), [10 10], ... %'Position', hgText.Extent, ...
        %   'FaceColor', hgText.BackgroundColor, 'Parent', hgText.Parent, ...
        %   'EdgeColor', 'none'); % , 'FaceAlpha', 0.5);
        
        uistack(hgRect, 'top');
        
        hgText.BackgroundColor = 'none';
      end
      
      uistack(hgText, 'top');      
      
      %hgText.Margin = hgText.Margin + 2;
      %hgText.BackgroundColor = 'g';
    end
    
    
    %% Fix OverlayAxes
    if ~isfield(hgObjects, 'OverlayAxes'), hgObjects.OverlayAxes = []; end
    for m = 1:numel(hgObjects.('OverlayAxes'))
      ax = hgObjects.('OverlayAxes')(m);
      if m==1
        ax.Position     = plotRect;
        htx = (findobj(ax,'Type', 'text'));
        
        set(htx(1), 'Units', 'normalized', 'Position',[0 1], ...
          'FontUnits', fontUnits, 'FontSize', titleFont, ...
          'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
        
        set(htx(1), 'Units', 'pixels', 'Position', HG.pixelPosition(htx(1)) + [0 +7 0]);
      else
        try delete(ax); end
      end
    end
    
    %% Fix ColorBarAxes
    if ~isfield(hgObjects, 'ColorBarAxes'), hgObjects.ColorBarAxes = []; end
    for m = 1:numel(hgObjects.('ColorBarAxes'))
      ax = hgObjects.('ColorBarAxes')(m);
      if m==1
        ax.ActivePositionProperty  = 'position';
        ax.Units        = 'pixels';
        axPosition      = ax.Position;
        axPosition(3)   = 350; %max(min(350, plotRect(3)/4), 500);
        axPosition(4)   = axPosition(3)/(max(ax.XLim)-min(ax.XLim)-2);
        ax.Clipping     = 'off';
        
        ax.Position     = [outerRect(1)+outerRect(3)-axPosition(3)-1 outerRect(2)+outerRect(4)-100-axPosition(4)-20 axPosition(3:4)];
        
        % ax.Position = [ ...
        %   outerRect(1)+outerRect(3)-axPosition(3) plotRect(4)+plotRect(2)+axPosition(4) axPosition(3:4)]; %
        ax.Visible  = 'off';
      else
        try delete(ax); end
      end
    end
    
    %% Fix Appearances
    uistack(hax2, 'bottom');
    uistack(hax, 'bottom');    
    
    %% Fix Layout
    
    try
      hdOverlays        = unique(findall(hdOutput, 'tag', 'BorderOverlay')); 
      
      for p = 1:numel(hdOverlays)
        uistack(hdOverlays(p), 'top');
      end
    end
    
    try
      hdGillSans        = unique(findall(hdOutput, 'FontName', 'Gill Sans MT'));
      set(hdGillSans, 'FontName', 'Helvetica');
    end
    
    %% Output Results
    assignin('base', 'hgObjects', hgObjects);
    
    %% Export Document
    export_fig(fullfile('Output','export.pdf'), '-painters', hdOutput);
    
    %% Delete Figure
    %try deleteHandle(obj.OutputFigure); end
    
  catch err
    warning(S);
    rethrow(err);
  end
  
  set(0, 'ScreenPixelsPerInch', screenPPI);
  warning(S);
end
