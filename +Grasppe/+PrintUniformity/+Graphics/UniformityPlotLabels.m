classdef UniformityPlotLabels < Grasppe.Core.Component
  %UNIFORMITYPLOTLABELS Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    LabelObjects    = {};
    LabelValues     = [];
    LabelRegions    = [];
    LabelPositions  = [];
    LabelActivePositions  = [];
    LabelAreas      = [];
    LabelElevation  = 100;
    SubPlotObjects  = cell(0,2);
    SubPlotMarkers  = {};
    SubPlotBoxes    = {};
    SubPlotData     = {};
    MarkerPositions = {};
    MarkerIndex     = 1;
    PlotObject
    ComponentType   = '';
    FontSize        = 6;
  end
  
  methods
    
    function obj = UniformityPlotLabels()
      obj = obj@Grasppe.Core.Component();
    end
    
    function set.PlotObject(obj, plotObject)
      try obj.deleteLabels; end
      
      obj.PlotObject = plotObject;
    end
    
    function attachPlot(obj, plotObject)
      
      obj.PlotObject = plotObject;
      
      %% Elevation
      zReverse = false;
      try zReverse = isequal(lower(plotObject.ZDir), 'reverse'); end
      
      z = 100;
      
      try
        if zReverse
          z = min(plotObject.HandleObject.ZLim) - 3;
        else
          z = max(plotObject.HandleObject.ZLim) + 3;
        end
      end
      
      obj.LabelElevation = z;
    end
    
    function clearLabels(obj)
      for m = 1:numel(obj.LabelObjects)
        obj.LabelObjects{m}.Text = '';
      end
    end
    
    function deleteLabels(obj)
      
      try
        for m = 1:numel(obj.SubPlotBoxes)
          try delete(obj.SubPlotBoxes{m}); end
          obj.SubPlotBoxes{m} = [];
        end        
      end
      
      try
        for m = 1:numel(obj.SubPlotMarkers)
          try delete(obj.SubPlotMarkers{m}); end
          obj.SubPlotMarkers{m} = [];
        end        
      end

      try
        for m = 1:numel(obj.SubPlotObjects)
          try delete(obj.SubPlotObjects{m}); end
          obj.SubPlotObjects{m} = [];
        end        
      end
      try
        for m = 1:numel(obj.LabelObjects)
          try delete(obj.LabelObjects{m}); end
          obj.LabelObjects{m} = [];
        end
      end
      try
        for m = 1:numel(obj.LabelObjects)
          try if isempty(obj.LabelObjects{m}), continue; end; end
          return;
        end
      end
      try
        obj.LabelObjects    = {};
        obj.LabelValues     = [];
        obj.LabelRegions    = [];
        obj.LabelPositions  = [];
      end
    end
    
    function defineLabels(obj, regions, values)
      %obj.deleteLabels;
      obj.LabelRegions    = regions;
      obj.LabelValues     = values;
      obj.LabelPositions  = [];
    end
    
    function createLabels(obj)
      try
        values  = obj.LabelValues;
        regions = obj.LabelRegions;
        
        
        for m = 1:numel(obj.LabelValues)
          try
            region = eval(['regions(m' repmat(',:',1,ndims(regions)-1)  ')']);
            obj.createLabel(m, squeeze(region), values(m));
          end
        end
      catch err
        %disp(err);
      end
      
    end   
    
    function createLabel(obj, index, region, value)
      try
        if ~isa(obj.PlotObject, 'Grasppe.Graphics.PlotComponent') || ...
            ~isa(obj.PlotObject.ParentAxes, 'Grasppe.Graphics.PlotAxes')
          return;
        end
      catch err
        return;
      end
      
      try
        
        %% Index
        if isempty(index)
          index = numel(obj.LabelObjects)+1;
        else
          label = [];
          try label = obj.LabelObjects{index}; end
        end
        
        %% Label
        if isempty(label) % Create Label
          try
            label = Grasppe.Graphics.TextObject(obj.PlotObject.ParentAxes, 'Text', int2str(index));
            label.HandleObject.HorizontalAlignment  = 'center';
            label.HandleObject.VerticalAlignment    = 'middle';
            % label.FontSize    = 5;
            label.IsClickable = false;
          catch err
            warning('Plot must be attached before creating labels');
            return;
          end
          obj.registerHandle(label);
          obj.LabelObjects{index} = label;
        end
        
        try label.FontSize = obj.FontSize; end
        
        %% Region (xmin ymin width height)
        if isequal(size(region), [1 4])
          % no change
        elseif isequal(size(region), [1 2])
          region  = [region 0 0];
        else % is a mask
          y       = nanmax(region, [], 2);
          y1      = find(y>0, 1, 'first');
          y2      = find(y>0, 1, 'last');
          
          x       = nanmax(region, [], 1);
          x1      = find(x>0, 1, 'first');
          x2      = find(x>0, 1, 'last');
          
          region  = [x1 y1 x2-x1 y2-y1];
        end
        
        dimension = region([3 4]);
        
        %% Position (centering)
        position  = region([1 2]) + dimension/2;
        
        
        try
          if all(dimension>7) %&& ~isempty([obj.SubPlotObjects{:}])  % && dimension>7
            position = position + [0 1];
          end
        end
        
        
        obj.LabelRegions(index, 1:4)    = region;
        obj.LabelPositions(index, 1:2)  = position;
        obj.LabelAreas(index, 1:2)      = dimension;
        
        %% Value
        if nargin < 3, value = []; end
        
        try if isempty(value), value = obj.LabelValues(index); end; end
        
        obj.LabelValues(index) = value;
        
        obj.updateLabel(index);
        
        %% Sub Plots
        try
%           subPlot = [];
%           try subPlot = obj.SubPlotObjects{index}; end
%           
%           if ishandle(label.ParentAxes.Handle) && (isempty(subPlot) || ~ishandle(subPlot)) % Create Label
%             
%             
%             xd = 0; yd = 0; zd = 0;
%             try
%               larea = dimension; % obj.LabelAreas(index, :);
%               lpos  = position; %obj.LabelPositions(index, :);
%               
%               xl    = lpos(1) + [-larea(1) larea(1)] /2;
%               yl    = lpos(2) + [-larea(2) larea(2)] /2;
%               
%               yv    = obj.SubPlotData{index};
%               
%               ys    = numel(yv);
%               xs    = (max(xl)-min(xl))/(ys-1);
%               
%               xd    = [min(xl) min(xl)+(1:ys-1)/(ys-1)*(max(xl) - min(xl))]; %min(xl):xs:max(xl);
%               yd    = min(yl) + (yv);
%               
%               zd    = ones(size(xd))*200;
%             end
%             
%             hold(label.ParentAxes.Handle, 'on');
%             subPlot = line(xd, yd, zd, 'Parent', label.ParentAxes.Handle);
%             
%             obj.SubPlotObjects{index} = subPlot;
%           end
        catch err
          disp(err);
        end
        
        
      catch err
        disp(err);
      end
      
      
    end
    
    function updateLabel(obj, index)
      try
        value = [];
        
        try value = obj.LabelValues(index); end
        
        if isa(value, 'double'), value = num2str(value, '%3.1f');
          %else, value = '';
        end
        
        try obj.LabelObjects{index}.Text = toString(value); end
        
        %try obj.LabelObjects{index}.handleSet('BackgroundColor', 'w'); end
        
        position = [-100 -100];
        try 
          position = obj.LabelPositions(index, :); 
          
          try
            extent = obj.LabelObjects{index}.HandleObject.Extent;
            region = obj.LabelAreas(index, :);
            
            if extent(3)*0.8 > region(1)
              position(2) = position(2) + (rem(index,2)*2-1)*1.5;
            end
            
            if extent(4)*0.8 > region(2)
              position(1) = position(1) + (rem(index,2)*2-1)*1.5;
            end
          end
        end
        
        try obj.LabelObjects{index}.Position = [position 200]; end %obj.LabelElevation]; end
        
        try
          %subPlot = obj.SubPlotObjects{index,1};
          marker  = obj.SubPlotMarkers{index};
          
          xi      = obj.MarkerIndex;
          
          if isempty(xi),xi = 1; end;
          
%           if isempty(xi)
%             %xi = 1;
%             set(marker, 'Visible', 'off');
%           else
            xd      = obj.MarkerPositions{index};
            set(marker, 'XData', [xd(xi) xd(xi)]); % 'Visible', 'on');
%           end
        catch err
          %disp(err);
        end
        
        
%         try 
%           
%           label = obj.LabelObjects{index};
%           
%           larea = obj.LabelAreas(index, :);
%           lpos  = obj.LabelPositions(index, :);
%           
%           xl    = lpos(1) + [-larea(1)+3 larea(1)-2] /2;
%           yl    = lpos(2) + [-larea(2) larea(2)] /2;
%           
%           yv    = obj.SubPlotData{index};
%           
%           ys    = numel(yv);
%           xs    = (max(xl)-min(xl))/(ys-1);
%           
%           xd    = [min(xl) min(xl)+(1:ys-1)/(ys-1)*(max(xl) - min(xl))]; %min(xl):xs:max(xl);
%           yd    = min(yl) + 0.125*(max(yl)-min(yl))*(((yv-min(yv))/(max(yv)-min(yv)))+0.225);
%           
%           zd    = ones(size(xd))*200;
%           
%           try delete(obj.SubPlotObjects{index}); end
%           
%           if (max(xd)-min(xd))>5
%             hold(label.ParentAxes.Handle, 'on');
%             
%             subPlot = line(xd, yd, zd, 'Parent', label.ParentAxes.Handle, 'color', 'k', 'linesmoothing', 'on');
%             
%             obj.SubPlotObjects{index} = subPlot;
%           end
%           
%           %set(label.ParentAxes.Handle, 'Clipping', 'off');
%           %drawnow expose update;
%         end
      catch err
        disp(err);
      end
    end
    
    function updateSubPlots(obj)
      
      try debugStamp(obj.ID, 1); catch, debugStamp(); end;
      
      % disp(obj.SubPlotData);
      
      data = cell2mat(obj.SubPlotData);
      
      try
        %ys    = numel(obj.SubPlotData);
        %yvs    = zeros(1:numel(ys), numel(obj.LabelObjects));
        %         for n = 1:ys
        %           yvs(n,:) = [obj.SubPlotData{n}(:)];
        %         end        
        
        yvs   = data';
        ys    = obj.PlotObject.DataSource.getSheetCount; %size(yvs, 1);
        yn    = size(yvs, 2);
        
        ymean = mean(yvs,2);
        ymin  = min(yvs(:));
        ymax  = max(yvs(:));
        ylen  = ymax-ymin;
      end
      
        try 
          for m = 1:numel(obj.LabelObjects)
            
            label = obj.LabelObjects{m};
            
            larea = obj.LabelAreas(m, :);
            lpos  = obj.LabelPositions(m, :);
            
            xl    = lpos(1)- 1 + [-larea(1)+0 larea(1)+2] /2;
            xdist = max(xl)-min(xl);
            yl    = lpos(2) + [-larea(2) larea(2)] /2;
            ydist = max(yl)-min(yl);
            
            yofs  = 0.5;
            yscl  = 1.5/4;
            
            ys    = numel(obj.SubPlotData);
            yv    = zeros(1,1:numel(ys));
            
            for n = 1:ys
             yv(n) = obj.SubPlotData{n}(m);
            end
            
            yv    = yvs(:,m)' - ymin;
            yv2   = abs(yvs(:,m)-mean(ymean(:)))';
            yv3   = abs(ymean(:)-mean(ymean(:)))';
            
            yv    = (yv )/ylen*ydist*yscl - yofs;    %(yv-min(yv)); %*0.75; %((yv-min(yv))/(max(yv)-min(yv)));
            yv2   = (yv2)/ylen*ydist*yscl - yofs;    %(yv2  - ymin)/ylen*ydist*yscl - yofs;
            yv3   = (yv3)/ylen*ydist*yscl - yofs;
            
            yv3a  = max(yv3, yv3 + yv2);
            %yv3b  = min(yv3, yv3 - yv2);
            
            ys    = numel(yv);
            xs    = (max(xl)-min(xl))/(ys-1);
            
            xd    = [min(xl) min(xl)+(1:ys-1)/(ys-1)*(max(xl) - min(xl))]; %min(xl):xs:max(xl);
            yd    = min(yl) + yv;    %*(yv+0.225); %(0.125*(max(yl)-min(yl))) + + (max(yl)-min(yl)) 
            yd3a  = min(yl) + yv3;
            yd3b  = min(yl) - yv3;
            ydma  = min(yl) + yv3a; % + 0.5; % max(yv3, yv3 + yv2) + 0.5;
            ydmb  = min(yl) - yv3a; % - 0.5;  % min(yv3, yv3 - yv2) - 0.5;
            
            % ydm   = min(yl) + max(yv3, yv3 + yv2) + 0.5; %yv3a + 0.5; % max(yv3, yv3 + yv2) + 0.5;
            % ydm2  = min(yl) + min(yv3, yv3 - yv2) - 0.5; %yv3b -0.5;  % min(yv3, yv3 - yv2) - 0.5;
            
            px = [xd(1) xd(end)] + [-0.1 0.1];
            py = min(yl) + [0 1]*ydist*yscl - yofs; %min(yl)+[-0.1 2.1];
            pz = 200;
            
            zd    = ones(size(xd))*pz;
            
            xi    = obj.MarkerIndex;
            
            if isempty(xi),xi = 1; end;
            
            
            try delete(obj.SubPlotObjects{m,1}); end
            try delete(obj.SubPlotObjects{m,2}); end
            try delete(obj.SubPlotObjects{m,3}); end
            try delete(obj.SubPlotMarkers{m}); end
            try delete(obj.SubPlotBoxes{m}); end 
            
            
            yofs = 0.5*ydist*yscl - yofs; %ydist*0.15;
            
            if (max(xl)-min(xl))>7 && (max(yl)-min(yl))>7

              %hold(label.ParentAxes.Handle, 'on');              
              %plotbox = patch(px([1 2 2 1]), py([1 1 2 2]), 'w', 'ZData', [1 1 1 1] * pz-1, 'Parent', label.ParentAxes.Handle, 'linewidth', 1, 'LineStyle', '-', 'EdgeColor', 'w', 'EdgeAlpha', 0.25, 'FaceColor', 'none', 'FaceAlpha', 0.25, 'linesmoothing', 'on');
              %obj.SubPlotBoxes{m} = plotbox;                  
              
              hold(label.ParentAxes.Handle, 'on');
              marker  = line([xd(xi) xd(xi)]- 1, py, [1 1] * pz-1, 'Parent', label.ParentAxes.Handle, 'color', [0.5 0.75 0.75], 'linewidth', 0.25, 'LineStyle', '-', 'Tag', '@Screen');
              obj.SubPlotMarkers{m} = marker;
              
              hold(label.ParentAxes.Handle, 'on');
              %subPlot1 = line(xd, ydm, zd, 'Parent', label.ParentAxes.Handle, 'color', [0.25 0.5 0.5], 'linewidth', 0.25);  % 'linesmoothing', 'on', %, 'linesmoothing', 'on'
              %subPlot1 = fill3([xd xd(end) xd(1)], [ydm min(yl)-1 min(yl)-1], [zd zd(1) zd(1)], 0.5+[0.25 0.0 0.0], 'Parent', label.ParentAxes.Handle, 'EdgeColor', 'none');
              xdmf = [xd   fliplr(xd)];
              ydmf = [ydma  fliplr(ydmb)];
              zdmf = ones(size(xdmf))*pz;
              subPlot1 = fill3(xdmf, ydmf + yofs, zdmf, [0.35 0.0 0.0], 'Parent', label.ParentAxes.Handle, 'EdgeColor', 'k', 'linewidth', 0.125);
              obj.SubPlotObjects{m,2} = subPlot1;

              xd3f = xdmf;
              yd3f = [yd3a  fliplr(yd3b)];
              zd3f = zdmf;
              
              hold(label.ParentAxes.Handle, 'on');
              %subPlot3 = line(xd, yd3a + yofs, zd, 'Parent', label.ParentAxes.Handle, 'color', [0.35 0.0 0.0], 'linewidth', 1.5);  % 'linesmoothing', 'on', %, 'linesmoothing', 'on'
              subPlot3 = fill3(xd3f, yd3f + yofs, zd3f, 'w' , 'Parent', label.ParentAxes.Handle, 'EdgeColor', 'k', 'linewidth', 0.125);
              obj.SubPlotObjects{m,3} = subPlot3;
              
%               hold(label.ParentAxes.Handle, 'on');
%               subPlot2 = line(xd, yd3a + yofs, zd, 'Parent', label.ParentAxes.Handle, 'color', 'w' , 'linewidth', 0.5);  % [1 0.75 0.75] 'linesmoothing', 'on', %, 'linesmoothing', 'on'
%               obj.SubPlotObjects{m,1} = subPlot2;              
              
              %hold(label.ParentAxes.Handle, 'on');              
              %plotbox = line(px([1 2 2 1 1]), py([1 1 2 2 1]), [1 1 1 1 1] * pz+1, 'Parent', label.ParentAxes.Handle, 'color', 'w', 'linewidth', 0.25); %, 'linesmoothing', 'on'
              %obj.SubPlotBoxes{m} = plotbox;              

            end
            
            obj.MarkerPositions{m}   = xd;
            
            %obj.LabelPositions(m, 2) = lpos(2)+50;
            
            %obj.SubPlotObjects{end+1} = line([xd(1) xd(1)], yd, zd, 'Parent', label.ParentAxes.Handle, 'color', 'k', 'linesmoothing', 'on', 'linewidth', 0.25);
            
            %set(label.ParentAxes.Handle, 'Clipping', 'off');
            drawnow expose update;
          end
          
        catch err
          disp(err);
        end
      
    end
    
    function updateLabels(obj)
      for m = 1:numel(obj.LabelObjects)
        obj.updateLabel(m);
      end
            
    end
  end
  
  methods (Access=protected)
    %     function createComponent(obj)
    %
    %       try
    %         componentType = obj.ComponentType;
    %       catch err
    %         error('Grasppe:Component:MissingType', ...
    %           'Unable to determine the component type to create the component.');
    %       end
    %
    %       obj.intializeComponentOptions;
    %
    %       obj.Initialized = true;
    %
    %     end
  end
  
  methods (Static)
    
    function OPTIONS  = DefaultOptions()
      Grasppe.Utilities.DeclareOptions;
    end
  end
  
  
end

