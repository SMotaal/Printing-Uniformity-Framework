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
    SettingValue    = false;
  end
  
  properties (GetObservable, SetObservable)
    VARIABLEID; %VariableID
  end
  
  properties (Hidden)
    Variables       = {'Inaccuracy', 'Imprecision'};
    VariableIDControl;
  end
  
  methods
    
    function obj = StatsPlotMediator(plotTypes, plotOptions, varargin)
      obj = obj@PrintUniformityBeta.UI.PlotMediator;
      
      if exist('plotTypes', 'var') && ~isempty(plotTypes), ...
          obj.PlotTypes   = plotTypes; end
      if exist('plotOptions', 'var') && ~isempty(plotOptions), ...
          obj.PlotOptions = plotOptions; end
      
      plotOptions = [{obj.PlotOptions} varargin];
      
      obj.FigureOptions =  {'PlotAxesLength', numel(plotOptions)};
      obj.createFigure(obj.FigureOptions{:}, 'IsVisible', false, 'Renderer', 'opengl');
      
      obj.PlotFigure.PlotMediator = obj;
      try obj.PlotFigure.TitleText.IsVisible = false; end
      
      mPos = get(0,'MonitorPositions');
      fPos = [mPos(1,1) mPos(4) mPos(3) 550];
      
      obj.PlotFigure.handleSet('Position', fPos);
      
      plotTypes   = obj.PlotTypes;
      plotAxes    = obj.PlotFigure.PlotAxes;
      %for m = 1:numel(plotTypes)
      for n = 1:numel(plotOptions)
        obj.createPlot(plotTypes{1}, plotAxes{n}, [], plotOptions{n}{:});
      end
      %end
      
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
      settingSource           = obj.SelectingSource;
      obj.SelectingSource     = true;
      if ~isscalar(obj.ActiveSource) || ...
          ~isvalid(obj.ActiveSource) || ...
          ~isa(obj.ActiveSource, 'PrintUniformityBeta.Data.DataSource')
        try obj.ActiveSource  = obj.DataSources{1}; end
      end
      activeSource            = obj.ActiveSource;
      obj.SelectingSource     = settingSource;
    end
    
    function updateControls(obj)
      
      %disp('Updating Controls');
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
              if isa(currentObject, 'GrasppeAlpha.Graphics.Axes') && ~isequal(obj.PlotFigure.ActivePlotAxes, currentObject)
                obj.PlotFigure.ActivePlotAxes   = currentObject;
              end
            end
            
            try
              activeSource            = getappdata(currentObject, 'PlotDataSource');
            end
          end
          
          oldSource                   = obj.ActiveSource.PlotObjects{1};
          try activeSource.PlotObjects{1}.updatePlotTitle; end
          
          obj.ActiveSource            = activeSource;
          try oldSource.updatePlotTitle; end          
          obj.updateControls();
        end
      end
      obj.SelectingSource = false;
      try obj.PlotFigure.Pointer  = 'arrow'; end
    end
    
    function modifier = getCurrentModifier(obj)
      modifier =  {};
      try modifier =  get(obj.PlotFigure.Handle, 'CurrentModifier'); end
    end
    
    
    function selectCase(obj, source, event)
      %try animate = obj.PlotFigure.Animate; obj.PlotFigure.Animate = 'off'; end
      
      %GrasppeKit.Utilities.DelayedCall(@(s, e)obj.updateCase(source.getSelectedItem), 0.5,'start');
      if obj.SelectingSource, return; end
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
          try obj.PlotFigure.Pointer  = 'watch'; end
          for m = 1:numel(obj.DataSources);
              try if ~isequal(obj.DataSources{m}.CaseID, id) obj.DataSources{m}.CaseID = id; end; end
          end
          try obj.PlotFigure.layoutPlotAxes(); end;  try obj.PlotFigure.layoutOverlay(); end
          try cellfun(@(p)p.updateLayout, obj.PlotFigure.PlotAxes); drawnow update expose; end
          try obj.PlotFigure.Pointer  = 'arrow'; end
        else
          if ~isequal(activePlotComponent.DataSource.CaseID, id)
            try obj.PlotFigure.Pointer  = 'watch'; end
            try activePlotComponent.DataSource.CaseID  = id; end
            try obj.PlotFigure.Pointer  = 'arrow'; end
          end
        end
      end
      drawnow;
      try obj.PlotFigure.Animate = animate; end
    end
    
    function selectSet(obj, source, event)
      % GrasppeKit.Utilities.DelayedCall(@(s, e)obj.updateSet(source.getSelectedItem), 0.5,'start');
      if obj.SelectingSource, return; end
      % try obj.PlotFigure.Pointer  = 'watch'; end
      try obj.updateSet(source.getSelectedItem, obj.getCurrentModifier()); end
      % try obj.PlotFigure.Pointer  = 'arrow'; end
      %try if source.hasFocus, obj.updateSet(source.getSelectedItem, obj.getCurrentModifier()); end; end;
      try obj.PlotFigure.Pointer  = 'arrow'; end
    end
    
    function updateSet(obj, id, modifier, varargin)
      if ~exist('modifier', 'var') || ~iscell(modifier) || isempty(modifier), modifier = obj.getCurrentModifier(); end
      activePlotComponent         =   [];
      try activePlotComponent     = getappdata(obj.PlotFigure.ActivePlotAxes, 'PlotComponent'); end
      try animate = obj.PlotFigure.Animate; obj.PlotFigure.Animate = 'off'; end
      try
        if ~isempty(modifier) &&  all(strcmpi(modifier, 'command'))
          try obj.PlotFigure.Pointer  = 'watch'; end
          for m = 1:numel(obj.DataSources);
            try if ~isequal(obj.DataSources{m}.SetID, id) obj.DataSources{m}.SetID = id; end; end
          end
          try cellfun(@(p)p.updateLayout, obj.PlotFigure.PlotAxes); end
          try obj.PlotFigure.layoutPlotAxes(); end;  try obj.PlotFigure.layoutOverlay(); end
          drawnow update expose;
          try obj.PlotFigure.Pointer  = 'arrow'; end
        else
          if ~isequal(activePlotComponent.DataSource.SetID, id)
            try obj.PlotFigure.Pointer  = 'watch'; end
            try activePlotComponent.DataSource.SetID  = id; end
            try obj.PlotFigure.layoutPlotAxes(); end;  try obj.PlotFigure.layoutOverlay(); end
            try obj.PlotFigure.Pointer  = 'arrow'; end
          end         
        end
      end
      drawnow;
      try obj.PlotFigure.Animate = animate; end
    end
    
    
    function selectVariable(obj, source, event)
      % GrasppeKit.Utilities.DelayedCall(@(s, e)obj.updateVariable(source.getSelectedItem), 0.5,'start');
      if obj.SelectingSource, return; end
      % try obj.PlotFigure.Pointer  = 'watch'; end
      try obj.updateVariable(source.getSelectedItem, obj.getCurrentModifier()); end
      % try obj.PlotFigure.Pointer  = 'arrow'; end
      %try if source.hasFocus, obj.updateVariable(source.getSelectedItem, obj.getCurrentModifier()); end; end
      try obj.PlotFigure.Pointer  = 'arrow'; end
    end
    
    function updateVariable(obj, id, modifier, varargin)
      if ~exist('modifier', 'var') || ~iscell(modifier) || isempty(modifier), modifier = obj.getCurrentModifier(); end
      activePlotComponent         =   [];
      try activePlotComponent     = getappdata(obj.PlotFigure.ActivePlotAxes, 'PlotComponent'); end
      try animate = obj.PlotFigure.Animate; obj.PlotFigure.Animate = 'off'; end
      try
        if ~isempty(modifier) &&  all(strcmpi(modifier, 'command'))
          try obj.PlotFigure.Pointer  = 'watch'; end
          for m = 1:numel(obj.DataSources);
            try if ~isequal(obj.DataSources{m}.VariableID, id) obj.DataSources{m}.VariableID = id; end; end
          end
          try obj.PlotFigure.layoutPlotAxes(); end;  try obj.PlotFigure.layoutOverlay(); end
          try cellfun(@(p)p.updateLayout, obj.PlotFigure.PlotAxes); drawnow update expose; end
          try obj.PlotFigure.Pointer  = 'arrow'; end
        else
          if ~isequal(activePlotComponent.DataSource.VariableID, id)
            try obj.PlotFigure.Pointer  = 'watch'; end
            try activePlotComponent.DataSource.VariableID  = id; end
            try obj.PlotFigure.Pointer  = 'arrow'; end
          end
        end
      end
      % try cellfun(@(p)p.updateLayout, obj.PlotFigure.PlotAxes); end; % drawnow update expose; end
      % try obj.PlotFigure.layoutPlotAxes(); end;  try obj.PlotFigure.layoutOverlay(); end
      % try cellfun(@(p)p.updateLayout, obj.PlotFigure.PlotAxes); drawnow update expose; end
      drawnow;
      try obj.PlotFigure.Animate = animate; end
    end
    
    
    function showFigure(obj)
      try cellfun(@(p)p.updateLayout, obj.PlotFigure.PlotAxes); end
      try obj.PlotFigure.ColorBar.createPatches; end
      try obj.PlotFigure.ColorBar.createLabels; end
      obj.PlotFigure.present; % show;
      try obj.PlotFigure.Pointer  = 'arrow'; end
      %try obj.PlotFigure.layoutPlotAxes(); end;  try obj.PlotFigure.layoutOverlay(); end      
      
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
      % obj.PlotFigure.prepareMediator(obj.DataProperties, obj.AxesProperties);
      obj.createControls(obj.PlotFigure);
      % end
    end
  end
  
end

