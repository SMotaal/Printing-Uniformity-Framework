classdef StatsPlotMediator < PrintUniformityBeta.UI.PlotMediator
  %UNIFORMITYPLOTMEDIATOR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (SetAccess=private)
    PlotOptions     = {}; % {'CaseID', 'rithp5501'};
    PlotTypes       = {'Stats'}; % , 'Stats'}; % {'Regions'}; %'Surface', 'Regionsurfs', 'Slope'}; %, 'Slope'}; %, 'Regions', 'Slope'}; Regionsurfs
    DataProperties  = {'SheetID'}; % , 'VariableID'}; %'CaseID', 'SetID',
    AxesProperties  = {'View', 'Projection', {'PlotColor', 'Color'}};
    FigureOptions;   %= {'PlotAxesLength', 1}; %3
    ActiveSource    = [];
    CurrentObjectListener = [];
    SelectingSource = false;
  end
  
  properties (GetObservable, SetObservable)
    VARIABLEID; %VariableID
  end
  
  properties (Hidden)
    Variables       = {'Inaccuracy', 'Imprecision'};
    VariableIDControl;
  end
  
  methods
    
    function obj = StatsPlotMediator(plotTypes, plotOptions)
      obj = obj@PrintUniformityBeta.UI.PlotMediator;
      
      if exist('plotTypes', 'var') && ~isempty(plotTypes), ...
          obj.PlotTypes   = plotTypes; end
      if exist('plotOptions', 'var') && ~isempty(plotOptions), ...
          obj.PlotOptions = plotOptions; end
      
      obj.FigureOptions =  {'PlotAxesLength', numel(obj.PlotTypes)};
      
      obj.createFigure(obj.FigureOptions{:}, 'IsVisible', false, 'Renderer', 'opengl');
      
      obj.PlotFigure.PlotMediator = obj;
      try obj.PlotFigure.TitleText.IsVisible = false; end
      
      mPos = get(0,'MonitorPositions');
      fPos = [mPos(1,1) mPos(4) mPos(3) 550];
      
      obj.PlotFigure.handleSet('Position', fPos);
      
      plotTypes   = obj.PlotTypes;
      plotAxes    = obj.PlotFigure.PlotAxes;
      plotOptions = obj.PlotOptions;
      for m = 1:numel(plotTypes)
        obj.createPlot(plotTypes{m}, plotAxes{m}, [], plotOptions{:});
      end
      
      obj.attachMediations;
      
      obj.updateControls;
      
    end
    
    function createControls(obj, parentFigure)
      
      obj.Cases                 = {'L1', 'L2', 'L3', 'X1', 'X2'};
      obj.Sets                  = int8([100, 75, 50, 25, 0]);
      
      variables             = obj.Variables;
      cases                 = obj.Cases;
      sets                  = obj.Sets;
      
      hFigure               = parentFigure.Handle;
      
      selectedVariable      = [];
      try selectedVariable  = find(strcmpi(obj.ActiveSource.CaseID, variables)); end
      jVariableMenu         = obj.createDropDown(hFigure, variables, selectedVariable, ...
        @obj.selectVariable, [], [], 150);
      obj.VariableIDControl = jVariableMenu;
      
      selectedCase          = [];
      try selectedCase      = find(strcmpi(obj.ActiveSource.CaseID, cases)); end
      jCaseMenu             = obj.createDropDown(hFigure, cases, selectedCase, ...
        @obj.selectCase, [], [], 150);
      obj.CaseIDControl     = jCaseMenu;
      
      selectedSet           = [];
      try selectedSet       = find(sets==obj.ActiveSource.CaseID); end
      jSetMenu              = obj.createDropDown(hFigure, sets, selectedSet, ...
        @obj.selectSet, [], [], 75);
      obj.SetIDControl      = jSetMenu;
      
      % jCommandPrompt = obj.createCommandPrompt(hFigure);
      % obj.CommandPromptControl = jCommandPrompt;
      
      hToolbar = findall(allchild(hFigure),'flat','type','uitoolbar');
      
      if isempty(hToolbar), hToolbar  = uitoolbar(hFigure); end
      
      drawnow;
      
      jContainer = get(hToolbar(1),'JavaContainer');
      jToolbar = jContainer.getComponentPeer;
      
      jToolbar.removeAll();
      
      jToolbar.add(jVariableMenu);
      jToolbar.add(jCaseMenu);
      jToolbar.add(jSetMenu);
      % jToolbar.add(jCommandPrompt);
      jToolbar.repaint;
      jToolbar.revalidate;
      
      refresh(hFigure);
      
      % obj.createControls@PrintUniformityBeta.UI.PlotMediator(parentFigure);
      
    end
    
    function activeSource = get.ActiveSource(obj)
      activeSource            = [];
      if ~isscalar(obj.ActiveSource) || ...
          ~isvalid(obj.ActiveSource) || ...
          ~isa(obj.ActiveSource, 'PrintUniformityBeta.Data.DataSource')
        try obj.ActiveSource  = obj.DataSources{1}; end
      end
      activeSource            = obj.ActiveSource;
    end
    
    function updateControls(obj)
      
      disp('Updating Controls');
      if ~isempty(obj.CaseIDControl)
        try
          selectedCase = find(strcmpi(obj.ActiveSource.CaseID, obj.Cases));
          %if ~isempty(selectedCase)
          obj.CaseIDControl.setSelectedIndex(selectedCase-1);
          %end
        end
      end
      
      if ~isempty(obj.SetIDControl)
        try
          selectedSet = find(obj.ActiveSource.SetID == obj.Sets, 1);
          %if ~isempty(selectedSet)
          obj.SetIDControl.setSelectedIndex(selectedSet-1);
          %end
        end
      end
      
      if ~isempty(obj.VariableIDControl)
        try
          selectedVariable = find(strcmpi(obj.ActiveSource.VariableID, obj.Variables));
          % if ~isempty(selectedVariable)
          obj.VariableIDControl.setSelectedIndex(selectedVariable-1);
          %end
        end
      end
      
    end
    
    
    function value = get.VARIABLEID(obj)
      value = [];
      try value = obj.VariableID; end
    end
    
    function set.VARIABLEID(obj, value)
      try obj.VariableID = value; end
      obj.updateControls;
    end
    
    function selectSource(obj, source, event)
      obj.SelectingSource = true;
      try
        if ~isempty(event.AffectedObject.CurrentObject) && ...
            ~isequal(event.AffectedObject.Handle, event.AffectedObject.CurrentObject)
          
          activeSource                = obj.ActiveSource;
          try
            try currentObject         = getappdata(event.AffectedObject.CurrentObject, 'PrototypeHandle'); end
            %currentObject             = get(event.AffectedObject.CurrentObject, 'UserData');
            
            if isa(currentObject, 'GrasppeAlpha.Graphics.InAxesComponent')
              try currentObject       = currentObject.ParentAxes; end
            end
            
            try
              activeSource            = getappdata(currentObject, 'PlotDataSource');
            end
          end
          
          obj.ActiveSource            = activeSource;
          obj.updateControls();
        end
      end
      obj.SelectingSource = false;
    end
    
    function modifier = getCurrentModifier(obj)
      modifier =  {};
      try modifier =  get(obj.PlotFigure.Handle, 'CurrentModifier'); end
    end
    
    
    function selectCase(obj, source, event)
      %try animate = obj.PlotFigure.Animate; obj.PlotFigure.Animate = 'off'; end
      
      %GrasppeKit.Utilities.DelayedCall(@(s, e)obj.updateCase(source.getSelectedItem), 0.5,'start');
      if obj.SelectingSource, return; end
      try obj.PlotFigure.Pointer  = 'watch'; end
      try obj.updateCase(source.getSelectedItem, obj.getCurrentModifier()); end
      try obj.PlotFigure.Pointer  = 'arrow'; end
      %try if source.hasFocus, obj.updateCase(source.getSelectedItem, obj.getCurrentModifier()); end; end
    end
    
    function updateCase(obj, id, modifier, varargin)
      if ~exist('modifier', 'var') || ~iscell(modifier) || isempty(modifier), modifier = obj.getCurrentModifier(); end
      activePlotComponent         =   [];
      try activePlotComponent     = getappdata(obj.PlotFigure.ActivePlotAxes, 'PlotComponent'); end
      try animate = obj.PlotFigure.Animate; obj.PlotFigure.Animate = 'off'; end
      try
        if ~isempty(modifier) &&  all(strcmpi(modifier, 'command'))
          % try cellfun(@(p)cla(p.Handle), obj.PlotFigure.PlotAxes); drawnow update expose; end
          for m = 1:numel(obj.DataSources);
            % try if ~strcmpi(obj.DataSources{m}.CaseID, id), obj.DataSources{m}.CaseID = id; end; end
              try if ~isequal(obj.DataSources{m}.CaseID, id) obj.DataSources{m}.CaseID = id; end; end
          end
          %try cellfun(@(p)p.updateLayout, obj.PlotFigure.PlotAxes); end; % drawnow update expose; end
          try obj.PlotFigure.layoutPlotAxes(); end;  try obj.PlotFigure.layoutOverlay(); end
          try cellfun(@(p)p.updateLayout, obj.PlotFigure.PlotAxes); drawnow update expose; end
        else
          activePlotComponent.DataSource.CaseID  = id;
        end
      end
      drawnow;
      try obj.PlotFigure.Animate = animate; end
    end
    
    function selectSet(obj, source, event)
      % GrasppeKit.Utilities.DelayedCall(@(s, e)obj.updateSet(source.getSelectedItem), 0.5,'start');
      if obj.SelectingSource, return; end
      try obj.PlotFigure.Pointer  = 'watch'; end
      try obj.updateSet(source.getSelectedItem, obj.getCurrentModifier()); end
      try obj.PlotFigure.Pointer  = 'arrow'; end
      %try if source.hasFocus, obj.updateSet(source.getSelectedItem, obj.getCurrentModifier()); end; end;
    end
    
    function updateSet(obj, id, modifier, varargin)
      if ~exist('modifier', 'var') || ~iscell(modifier) || isempty(modifier), modifier = obj.getCurrentModifier(); end
      activePlotComponent         =   [];
      try activePlotComponent     = getappdata(obj.PlotFigure.ActivePlotAxes, 'PlotComponent'); end
      try animate = obj.PlotFigure.Animate; obj.PlotFigure.Animate = 'off'; end
      try
        if ~isempty(modifier) &&  all(strcmpi(modifier, 'command'))
          % try cellfun(@(p)cla(p.Handle), obj.PlotFigure.PlotAxes); drawnow update expose; end
          for m = 1:numel(obj.DataSources);
            try if ~isequal(obj.DataSources{m}.SetID, id) obj.DataSources{m}.SetID = id; end; end
          end
          %try cellfun(@(p)p.updateLayout, obj.PlotFigure.PlotAxes); end; % drawnow update expose; end
          try cellfun(@(p)p.updateLayout, obj.PlotFigure.PlotAxes); end
          try obj.PlotFigure.layoutPlotAxes(); end;  try obj.PlotFigure.layoutOverlay(); end
          drawnow update expose;
        else
          activePlotComponent.DataSource.SetID  = id;
          try obj.PlotFigure.layoutPlotAxes(); end;  try obj.PlotFigure.layoutOverlay(); end
        end
      end
      drawnow;
      try obj.PlotFigure.Animate = animate; end
    end
    
    
    function selectVariable(obj, source, event)
      % GrasppeKit.Utilities.DelayedCall(@(s, e)obj.updateVariable(source.getSelectedItem), 0.5,'start');
      if obj.SelectingSource, return; end
      try obj.PlotFigure.Pointer  = 'watch'; end
      try obj.updateVariable(source.getSelectedItem, obj.getCurrentModifier()); end
      try obj.PlotFigure.Pointer  = 'arrow'; end
      %try if source.hasFocus, obj.updateVariable(source.getSelectedItem, obj.getCurrentModifier()); end; end
    end
    
    function updateVariable(obj, id, modifier, varargin)
      if ~exist('modifier', 'var') || ~iscell(modifier) || isempty(modifier), modifier = obj.getCurrentModifier(); end
      activePlotComponent         =   [];
      try activePlotComponent     = getappdata(obj.PlotFigure.ActivePlotAxes, 'PlotComponent'); end
      try animate = obj.PlotFigure.Animate; obj.PlotFigure.Animate = 'off'; end
      try
        if ~isempty(modifier) &&  all(strcmpi(modifier, 'command'))
          % try cellfun(@(p)cla(p.Handle), obj.PlotFigure.PlotAxes); drawnow update expose; end
          for m = 1:numel(obj.DataSources);
            try if ~isequal(obj.DataSources{m}.VariableID, id) obj.DataSources{m}.VariableID = id; end; end
            % try obj.DataSources{m}.VariableID = id; end
          end
          %try cellfun(@(p)p.updateLayout, obj.PlotFigure.PlotAxes); end; % drawnow update expose; end
          try obj.PlotFigure.layoutPlotAxes(); end;  try obj.PlotFigure.layoutOverlay(); end
          try cellfun(@(p)p.updateLayout, obj.PlotFigure.PlotAxes); drawnow update expose; end
        else
          activePlotComponent.DataSource.VariableID  = id;
        end
      end
      % try cellfun(@(p)p.updateLayout, obj.PlotFigure.PlotAxes); end; % drawnow update expose; end
      % try obj.PlotFigure.layoutPlotAxes(); end;  try obj.PlotFigure.layoutOverlay(); end
      % try cellfun(@(p)p.updateLayout, obj.PlotFigure.PlotAxes); drawnow update expose; end
      drawnow;
      try obj.PlotFigure.Animate = animate; end
    end
    
    
    function showFigure(obj)
      obj.PlotFigure.present; % show;
      
      % for m = 1:numel(obj.DataSources);
      %   dataSource = obj.DataSources{m};
      %   %notify(dataSource.DataReader, 'SetChange');
      %   %try obj.PlotLabels.clearLabels; end
      %   %try dataSource.PlotLabels.clearLabels; end
      %   %dataSource.updatePlotLabels; %end
      %   %try dataSource.PlotLabels.updatePlotLabels; end
      %   %dataSource.PlotLabels.updateSubPlots; %end
      % end
    end
    
    function createFigure(obj, varargin)
      obj.PlotFigure = PrintUniformityBeta.Graphics.UniformityPlotFigure(varargin{:});
      
      %obj.CurrentObjectListener = addlistener(obj.PlotFigure.Handle, 'CurrentObject', 'PostSet', @obj.selectSource);
      obj.CurrentObjectListener = addlistener(obj.PlotFigure, 'CurrentObject', 'PostSet', @obj.selectSource);
      
    end
    
    function createPlot(obj, plotType, plotAxes, dataSource, varargin)
      import PrintUniformityBeta.Data.*;
      
      %return;
      
      createSource = nargin<4 || isempty(dataSource);
      switch lower(plotType)
        
        otherwise % {'Stats'}
          
          if createSource, dataSource  = StatsPlotDataSource(varargin{:}); end
          plotObject    = PrintUniformityBeta.Graphics.UniformityRegions(plotAxes, dataSource);
          try dataSource.ProcessProgress.Window = obj.PlotFigure.Handle; end
          try dataSource.Reader.ProcessProgress.Window = obj.PlotFigure.Handle; end
      end
      
      if createSource
        obj.DataSources = {obj.DataSources{:}, dataSource};
      end
      
      obj.PlotObjects = {obj.PlotObjects{:}, plotObject};
    end
    
    function executeCommand(obj, command)
      try eval(command); end
    end
    
    
    function attachMediations(obj)
      % try
      % obj.PlotFigure.PlotMediator = obj;
      obj.PlotFigure.prepareMediator(obj.DataProperties, obj.AxesProperties);
      % end
    end
  end
  
end

