classdef UniformityPlotFigure < GrasppeAlpha.Graphics.MultiPlotFigure
  %UNIFORMITYPLOTFIGURE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    PlotMediator
    DataSources           = {};
    Animate               = false;
    AnimationTimer        = [];
    LatestSheetSet        = 0;
    LinePlotVisible       = true;
    TitlesFormat          = {'FontSize', 9, 'FontUnit', 'point', 'FontName', 'Gill Sans MT', 'FontWeight', 'Bold'};
  end
  
  events
    LayoutUpdate
  end
  
  methods
    function obj = UniformityPlotFigure(varargin)
      obj = obj@GrasppeAlpha.Graphics.MultiPlotFigure(varargin{:});
      obj.HandleObject.BusyAction = 'cancel';
      refresh(obj.Handle);
    end
    
    function set.Animate(obj, animate)
      t                   = obj.AnimationTimer;
      
      interval            = 0.5;
      try interval        = t.Period; end
      
      running             = false;
      try running         = strcmpi(t.Running, 'on'); end
      
      switch lower(animate)
        case {'off'} % false,
          running         = false;
        case {'on'} % true,
          running         = true;
        case 'toggle'
          % if isequal(running, 'off'), running = on; else running = 'off'; end
          running         = ~running;
        otherwise
          if isnumeric(animate)
            interval      = animate;
          end
      end
      
      if ~isa(t, 'timer') || ~isvalid(t)
        t                 = timer('Period', interval, ... % 'Running', running
          'StartDelay', 1, 'ExecutionMode', 'fixedDelay', 'ObjectVisibility', 'off', ...
          'TimerFcn', @(s, e)obj.nextSheet, 'UserData', obj);
      end
      
      % try if ~isequal(running, t.Running), t.Running = running; end; end
      
      if running && ~strcmpi(t.Running, 'on')
        try
          start(t);
          obj.Animate         = 'on';
        end
      elseif ~running && ~strcmpi(t.Running, 'off')
        try stop(t); end
        obj.Animate         = 'off';
      end
      obj.AnimationTimer  = t;
    end
    
    function nextSheet(obj)
      drawnow;
      obj.setSheet('+1', true);
      % drawnow;
    end
    
    function animate = get.Animate(obj)
      animate             = false;
      try
        t                 = obj.AnimationTimer;
        animate           = isa(t, 'timer') && isvalid(t) && isequal(t.Running, 'on');
      end
      
      if animate, animate = 'on'; else animate = 'off'; end
    end
    
    
    filepath = Export(obj, filepath);
    
    function prepareMediator(obj, dataProperties, axesProperties)
      if isempty(obj.PlotMediator) || ~isa(obj.PlotMediator, 'PrintUniformityBeta.UI.PlotMediator')
        obj.PlotMediator  = PrintUniformityBeta.UI.PlotMediator;
      end
      
      obj.registerHandle(obj.PlotMediator);
      
      obj.attachMediations(obj.PlotAxes, axesProperties);
      
      obj.attachMediations(obj.DataSources, dataProperties);
      
      obj.PlotMediator.createControls(obj);
    end
    
    function OnKeyPress(obj, source, event)
      obj.bless;
      
      shiftKey = stropt('shift', event.Data.Modifier);
      commandKey = stropt('command', event.Data.Modifier) || stropt('control', event.Data.Modifier);
      
      syncSheets = false;
      
      if ~event.Consumed
        
        if commandKey
          if shiftKey
            switch event.Data.Key
              case 'a'
                try obj.Animate   = 'toggle'; end
                event.Consumed  = true;
              case 'r'
                try obj.Animate   = 'off'; end
                try obj.DataSources{1}.setSheet('sum'); syncSheets = true; end
                event.Consumed  = true;
              case 'e'
                try obj.Export; end
                event.Consumed  = true;
              case 'h' % toggle hidden axes
                % hiddenFigure    = obj.HiddenFigure;
                %
                % plotAxes        = [];
                % isHidden        = false;
                %
                % %% Show
                % try
                %   plotAxes      = findobj(hiddenFigure, 'Type', 'axes');
                %   isHidden      = isscalar(plotAxes);
                % end
              case 'b'
                obj.LinePlotVisible     = ~isequal(obj.LinePlotVisible, true);
                obj.notify('LayoutUpdate');
                for m = 1:numel(obj.DataSources)
                  try obj.DataSources{m}.notify('OverlayPlotsDataChange'); end
                end
                
              case 'd' % duplicate plot axes
                try obj.Pointer  = 'watch'; drawnow(); end
                activePlotAxes          = obj.ActivePlotAxes;
                
                dataSourceClass         = 'PrintUniformityBeta.Data.StatsPlotDataSource';
                plotComponentClass      = 'PrintUniformityBeta.Graphics.UniformityRegions';
                
                dataSourceOptions       = {};
                plotComponentOptions    = {};
                
                try
                  activePlotComponent   = getappdata(obj.ActivePlotAxes, 'PlotComponent');
                  activePlotDataSource  = activePlotComponent.DataSource;
                
                  dataSourceClass       = class(activePlotDataSource);
                  plotComponentClass    = class(activePlotComponent);
                                    
                  newOptions            = {};
                  %sourceOptions         = activePlotDataSource.ComponentOptions;
                  % for m = 1:2:numel(sourceOptions)
                  %   try newOptions      = [newOptions sourceOptions(m:m+1)]; end
                  % end
                  
                  dataSourceOptions     = activePlotDataSource.ComponentOptions;
                  dataSourceOptions     = [dataSourceOptions, ...
                    'CaseID',     activePlotDataSource.CaseID, ...
                    'SetID',      activePlotDataSource.SetID, ...
                    'SheetID',    activePlotDataSource.SheetID, ...
                    'VariableID', activePlotDataSource.VariableID];
                  
                  newOptions            = {};
                  sourceOptions         = activePlotComponent.ComponentOptions;
                  for m = 1:2:numel(sourceOptions)
                    if ~strcmpi(sourceOptions{m}, 'ParentAxes')
                      try newOptions    = [newOptions sourceOptions(m:m+1)]; end
                    end
                  end
                  plotComponentOptions  = newOptions;                  
                  
                catch err
                  debugStamp(err, 1, obj);
                end
                
                try
                  newDataSource           = feval(dataSourceClass, dataSourceOptions{:});                  
                  newPlotAxes             = obj.newPlotAxes();
                  newPlotAxes.IsVisible   = false;
                  newPlotComponent        = feval(plotComponentClass, newPlotAxes, newDataSource, plotComponentOptions{:});
                  newPlotAxes.IsVisible   = true;
                  obj.formatPlotAxes;
                  obj.layoutPlotAxes;
                catch err
                  debugStamp(err, 1, obj);
                end
                
                obj.ParentFigure.ColorBar.updateLimits;
                obj.ParentFigure.ColorBar.createLabels;
                obj.ParentFigure.ColorBar.createPatches;                
                
                for m = 1:numel(obj.DataSources)
                  try obj.DataSources{m}.notify('OverlayPlotsDataChange'); end
                end
                
                try obj.Pointer  = 'arrow'; end
              case 'backspace'
                try obj.Pointer  = 'watch'; drawnow(); end
                activePlotAxes          = obj.ActivePlotAxes;  
                activePlotComponent     = getappdata(obj.ActivePlotAxes, 'PlotComponent');
                activePlotDataSource    = activePlotComponent.DataSource;
                
                try
                  delete(activePlotComponent); 
                  delete(activePlotDataSource);
                  delete(activePlotAxes);
                  try 
                    obj.PlotAxes        = obj.PlotAxes(~cellfun(@(c)isequal(c, activePlotAxes) || isempty(c), obj.PlotAxes));
                    obj.PlotAxesLength  = numel(obj.PlotAxes);
                    obj.PlotAxesTargets = obj.PlotAxesTargets(~cellfun(@(v)isequal(v, activePlotAxes),{obj.PlotAxesTargets.object}));
                  end
                  obj.layoutPlotAxes;
                catch err
                  debugStamp(err, 1, obj);
                end
                
                obj.ParentFigure.ColorBar.updateLimits;
                obj.ParentFigure.ColorBar.createLabels;
                obj.ParentFigure.ColorBar.createPatches;                
                
                for m = 1:numel(obj.DataSources)
                  try obj.DataSources{m}.notify('OverlayPlotsDataChange'); end
                end
                try obj.Pointer  = 'arrow'; end
              case 'u'
                try animate = obj.Animate; obj.Animate = 'off'; end
                try obj.Pointer  = 'watch'; drawnow(); end
                obj.notify('LayoutUpdate');
                obj.OnResize();
                % childObjects    = get(get(obj.Handle, 'Children'), 'UserData');
                % childObjects    = childObjects(cellfun(@(c)isa(c, 'GrasppeAlpha.Graphics.PlotAxes'), childObjects));
                obj.ColorBar.updateLimits;
                obj.ColorBar.createLabels;
                obj.ColorBar.createPatches;                
                for m = 1:numel(obj.DataSources)
                  try obj.DataSources{m}.notify('OverlayPlotsDataChange'); end
                end
                try obj.Pointer  = 'arrow'; end
                try obj.Animate       = animate; end
              case 'uparrow'
                try obj.Animate   = 'off'; end
                obj.setSheet('+1', false); % try obj.DataSources{1}.setSheet('+1'); syncSheets = true; end
                event.Consumed  = true;
              case 'downarrow'
                try obj.Animate   = 'off'; end
                obj.setSheet('-1', false); % try obj.DataSources{1}.setSheet('-1'); syncSheets = true; end
                event.Consumed  = true;
              otherwise
                % disp(toString(event.Data.Key));
            end
          else
            switch event.Data.Key
              case 'uparrow'
                % try obj.DataSources{1}.setSheet('+1', true); syncSheets = true; end
                try obj.Animate   = 'off'; end
                obj.setSheet('+1', true);
                event.Consumed = true;
              case 'downarrow'
                try obj.Animate   = 'off'; end
                obj.setSheet('-1', true);
                % try obj.DataSources{1}.setSheet('-1', true); syncSheets = true; end
                event.Consumed = true;
            end
          end
        end
      end
      
      obj.OnKeyPress@GrasppeAlpha.Graphics.MultiPlotFigure(source, event);
    end
    
    function setSheet(obj, varargin)
      
      try
        activePlotComponent     = getappdata(obj.ActivePlotAxes, 'PlotComponent');
        activeDataSource        = activePlotComponent.DataSource;
      catch
        try 
          obj.ActivePlotAxes    = obj.DataSources{1}.PlotObjects(1);
          activeDataSource      = obj.DataSources{1};
        catch err
          return;
        end
      end
      
      if numel(varargin)>1 && isequal(varargin{2}, true)
        if ~isequal(obj.Animate, true) || ... 
            ~isscalar(obj.LatestSheetSet) || obj.LatestSheetSet+0.25<cputime
          obj.LatestSheetSet        = cputime;
          try activeDataSource.setSheet(varargin{:}); syncSheets = true; end
          obj.LatestSheetSet        = cputime;
        end
      else
        try activeDataSource.setSheet(varargin{:}); syncSheets = true; end
        obj.LatestSheetSet        = cputime;
      end
    end
    
    function notifySourceSheetChanged(obj, source, sheetID)
      for m = 1:numel(obj.DataSources)
        if ~isequal(source, obj.DataSources{m})
          try obj.DataSources{m}.setSheet(sheetID, true); end
        end
        try notify(obj.DataSources{m}, 'SheetChange'); end
      end
    end
    
    function OnMouseDoubleClick(obj, source, event)
      %beep();
      obj.CurrentObject = [];
      obj.CurrentObject = get(obj.Handle, 'CurrentObject');
      % h = hittest(obj.Handle);
      obj.OnMouseDoubleClick@GrasppeAlpha.Graphics.MultiPlotFigure(source, event);
    end
    
    
    
    function set.DataSources(obj, dataSources)
      if ~iscell(obj.DataSources), obj.DataSources  = {}; end
      
      if isobject(dataSources) && isscalar(dataSources) && isvalid(dataSources)
        obj.DataSources   = {obj.DataSource, dataSources};
      elseif iscell(dataSources)
        obj.DataSources   = dataSources;
      end
      
      dataSources         = obj.DataSources;
      dataSources         = dataSources(cellfun(@(x) isobject(x) && isvalid(x), dataSources));
      
      % dataSourceIndex     = cellfun(@(x)cellfun(@(y)isequal(x,y),dataSources),dataSources, 'UniformOutput', false);
      % dataSources       = unique(dataSources, 'stable');
      obj.DataSources     = dataSources;
      
      % try dataSources.notify('OverlayPlotsDataChange'); end
      
      for m = 1:numel(obj.DataSources)
        try obj.DataSources{m}.notify('OverlayPlotsDataChange'); end
      end
      
    end
    
    function dataSources = get.DataSources(obj)
      dataSources         = obj.DataSources;
    end
    
    
    
  end
  
  methods(Access=protected)
    
    function createComponent(obj)
      obj.createComponent@GrasppeAlpha.Graphics.MultiPlotFigure();
    end
    
    function [plotAxes idx id] = createPlotAxes(obj, idx, id)
      try
        [plotAxes idx id] = obj.createPlotAxes@GrasppeAlpha.Graphics.MultiPlotFigure(idx, id);
      catch err
        debugStamp(err, 1, obj);
        rethrow(err);
      end
    end
    
    function attachMediations(obj, subjects, properties)
      
      plotMediator  = obj.PlotMediator;
      
      subjects = subjects;
      
      for m = 1:numel(subjects)
        subject = subjects{m};
        for n = 1:numel(properties)
          property = properties{n};
          if isa(property, 'char')
            alias     = property;
          elseif isa(property, 'cell')
            alias     = property{1};
            property  = property{2};
          else
            continue;
          end
          try
            plotMediator.attachMediatorProperty(subject, property, alias);
          catch err
            debugStamp(err, 1, obj);
            continue;
          end
        end
      end
      
      obj.PlotMediator = plotMediator;
      
    end
    
    
    %     function preparePlotAxes(obj)
    %       obj.preparePlotAxes@GrasppeAlpha.Graphics.MultiPlotFigure;
    %     end
  end
  
  %     methods (Static, Hidden)
  %     function OPTIONS  = DefaultOptions()
  %       PlotAxesLength = 1;
  %       GrasppeAlpha.Utilities.DeclareOptions;
  %     end
  %
  %     end
  
  methods(Static, Hidden=true)
    function OPTIONS  = DefaultOptions()
      WindowTitle     = 'Printing Uniformity Plot'; ...
        BaseTitle     = 'Printing Uniformity'; ...
        Color         = 'white'; ...
        Toolbar       = 'none';  ... %Menubar       = 'none'; ...
        WindowStyle   = 'normal'; ...
        Renderer      = 'opengl'; ...
        %#ok<NASGU>
      
      
      GrasppeAlpha.Utilities.DeclareOptions;
      
      %options = WorkspaceVariables(true);
    end
  end
  
  
end

