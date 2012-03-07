classdef upSurface < Plots.upAxesObject
  %UPSURFACE Printing Uniformity Surface Object
  
  properties (Constant = true, Transient = true)
    ComponentType = 'surf';
    ComponentProperties = Graphics.Properties.Surface;
  end
  
  properties
    DataSource
    DataSet
    DataParameters
    PlotParameters
    PlotSource
    PlotData
    XData
    YData
    ZData
    CData
    Sheet
    Modified
    RotationMode
  end
  
  methods
    function obj = upSurface(parentFigure, varargin)
      obj = obj@Plots.upAxesObject(parentFigure, varargin{:});
%       obj.createComponent;
      
      obj.ParentFigureObject.registerKeyEventHandler(obj);
      obj.ParentFigureObject.registerMouseEventHandler(obj);
      
      obj.Modified = 1;
    end
    
    function keyPress(obj, event, source)
      if (stropt(event.Modifier, 'control command'))
        switch event.Key
          case 'uparrow'
            obj.stepSheet(+1);
          case 'downarrow'
            obj.stepSheet(-1);
        end
      end
      end
    
      function stepSheet(obj, step)
        %         try
        length    =  obj.PlotSource.length.Sheets;
        sheet     =  obj.Sheet;
        
        obj.Sheet = mod(sheet+step, length);

      end
      
    
    function obj = processPlotData(obj)
      try
        obj.retrieveSourceData;
        rows      = obj.PlotSource.metrics.sampleSize(1);
        columns   = obj.PlotSource.metrics.sampleSize(2);
      catch err
        return;
      end
      
      try
      sheet     = obj.Sheet;
      
      [X Y Z]   = meshgrid(1:columns, 1:rows, 1);
      
      surfs     = obj.PlotData.surfs;
      
      region    = subrange( fieldnames(surfs),           {1});
      field     = subrange( fieldnames(surfs.(region)),  {1});
      
%       setData   = obj.PlotData.surfs.(region).(field);
%       
%       sheetData = squeeze( setData(sheet,:,:,:)  );
%       sheetData = substitute(sheetData, nan, 0);
%       sheetData = sum(sheetData,1);

      targetFilter  = obj.PlotSource.sampling.masks.Target;
%       patchFilter   = obj.PlotData.patchFilter;
%       sheetFilter   = logical( ...
%         repmat(patchFilter,size(targetFilter) ./ size(patchFilter))); %targetFilter * repmat(patchFilter,size(targetFilter)./size(patchFilter))

      sheetData = obj.PlotData.data(sheet).surfData;
      
      Z = sheetData';
      Z(targetFilter~=1) = NaN;
      
      obj.setPlotData(X, Y, Z);
      
      catch err
        dealwith(err);
      end
      
    end
    
    function obj = setPlotData(obj, XData, YData, ZData)
      obj.setOptions('XData', XData, 'YData', YData, 'ZData', ZData);
    end
    
    function obj = refreshPlotData(obj)
      if isValidHandle(obj.Primitive)
        obj.Set('XData', obj.XData, 'YData', obj.YData, 'ZData', obj.ZData);
      end
      drawnow expose;
    end
    
    
    function obj = set.Sheet(obj, value)
      obj.Sheet = value;
      obj.Modified = true;
      try
        obj.ParentFigureObject.appendTitle([' [' int2str(obj.Sheet) ']']);
      end
      if ~(obj.Busy)
        obj.updateComponent;
      end
    end
    
    function obj = set.DataParameters(obj, value)
      obj.DataParameters  = value;
      if ~(obj.Busy)
        obj.updateComponent;
      end
    end
        
    function obj = updateComponent(obj)
      if (obj.Modified)
        obj.processPlotData;
      end
      try
        obj.refreshPlotData;
      catch err
        obj.processPlotData;
        obj.refreshPlotData;
      end
      obj.Modified = false;
      obj.updateComponent@Plots.upViewComponent();
    end
    
    
    function [value] = get.DataParameters(obj)
      obj.Busy = true;
      try
        if isempty(obj.DataParameters)
          obj.DataParameters = {100};
        end
        
        if~iscell(obj.DataParameters)
          obj.DataParameters = {obj.DataParameters};
        end
      catch err
        dealwith(err);
      end
      obj.Busy = false;
      
      value = obj.DataParameters;
    end
    
    function obj = show(obj)
      
      obj.updateComponent;
            
      obj.show@Plots.upViewComponent;
      
      try
        obj.ParentFigureObject.show();
      end
      
      rotate3d(obj.PlotAxes);
      
      obj.ParentFigureObject.attachEvents();
    end
    
    function toggleRotation(obj, mode)
      try
        persistent cbActionPost hRotate releaseTimer
        default mode = ~obj.RotationMode;

        if isempty(cbActionPost)
          cbActionPost = obj.callbackFunction('WindowButtonUpFcn');
        end
        
        if isempty(releaseTimer)
            releaseTimer = timer('Name','ReleaseTimer', 'Period', 0.05, 'StartDelay', 0.05, ...
              'TimerFcn', callbackFunction(obj, 'DisableRotation'));          
        end
        
        switch mode
          case {true,   'on'}
            hRotate = rotate3d(obj.PlotAxes);
            set(hRotate, 'ActionPostCallback', cbActionPost, 'Enable', 'on');
            try stop(releaseTimer); end
          case {false,  'off'}
            try start(releaseTimer); end
          case {'callback'}
            try
              hRotate = rotate3d(obj.PlotAxes);
              set(hRotate,'Enable', 'off');
%               hManager = uigetmodemanager(obj.ParentFigure);
%               set(hManager.WindowListenerHandles,'Enable','off'); % zap the listeners
              obj.ParentFigureObject.attachEvents;
            catch err
              start(releaseTimer);
            end
            obj.ParentFigureObject.attachEvents;
            figure(obj.ParentFigure);
        end

%         if (mode)
%         else
%           hRotate = rotate3d(obj.PlotAxes);
% %           t = timer('Name','DelayTimer', 'Period', 2, 'StartDelay', 2, 'TimerFcn', {@rotate3d,'off'});
% %           rotate3d off;
% %           hRotate = rotate3d(obj.PlotAxes);
% %             if ~isempty(hRotate)
% %             end
% %           set(hRotate, 'Enable', 'off');
% %           rotate3d(obj.PlotAxes, 'Enable', 'off');
% %           obj.ParentFigureObject.attachEvents;
%         end
      catch err
        dealwith(err);
      end
      
    end
    
    function mouseUp(obj, event, source)
      obj.toggleRotation(false);
    end
    
    function mouseDown(obj, event, source)
      obj.toggleRotation(true);
    end
    
    function obj = retrieveSourceData(obj)
      
      args = {};
      
      source = obj.DataSource;
      
      if isValid(source, 'char')
        args = {source, args{:}};
      else
        obj.DataSource = [];
        return;
      end
      
      params = obj.DataParameters;
      
      if isClass(params, 'cell') && ~isempty(params);
        args = {args{:}, params{:}};
      end
      
      [source data params] = Plots.plotUPStats(args{:});
      
      obj.setOptions('DataSource', source.name, 'DataSet', params.dataPatchSet, ...
        'PlotSource', source, 'PlotData', data, 'PlotParameters', params);
      
    end
    
    
    
  end
  
  methods(Static)
    function options  = DefaultOptions()
      Sheet = 1;
      
      options = WorkspaceVariables(true);
    end
  end
  
  
end

