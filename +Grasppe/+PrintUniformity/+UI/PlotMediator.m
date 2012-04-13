classdef PlotMediator < Grasppe.Core.Mediator
  %PLOTMEDIATOR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (GetObservable, SetObservable)
    CASEID
    SETID
    SHEETID
    VIEW
    PLOTCOLOR
  end
  
  properties (Hidden)
    Cases = {'ritsm7402a', 'ritsm7402b', 'ritsm7402c', 'rithp7k01', 'rithp5501'};
    Sets  = int8([100, 75, 50, 25, 0]);
    
    CaseIDControl
    SetIDControl
    
    MediatorControls;
  end
  
  methods
    function obj = PlotMediator()
      obj = obj@Grasppe.Core.Mediator;
    end
    
    function value = get.CASEID(obj)
      value = [];
      try value = obj.CaseID; end
    end
    
    function set.CASEID(obj, value)
      try obj.CaseID = value; end
      obj.updateControls;
    end
    
    function value = get.SETID(obj)
      value = [];
      try value = obj.SetID; end
    end
    
    function set.SETID(obj, value)
      try obj.SetID = value; end
      obj.updateControls;
    end
    
    function value = get.SHEETID(obj)
      value = [];
      try value = obj.SheetID; end
    end
    
    function set.SHEETID(obj, value)
      try obj.SheetID = value; end
      % obj.updateControls;
    end
    
    
    function value = get.VIEW(obj)
      value = [];
      try value = obj.View; end
    end
    
    function set.VIEW(obj, value)
      try obj.View = value; end
    end
    
    
    function value = get.PLOTCOLOR(obj)
      value = [];
      try value = obj.PlotColor; end
    end
    
    function set.PLOTCOLOR(obj, value)
      try obj.PlotColor = value; end
    end
    
    %     function delete(obj)
    %       controlEntries  = obj.MediatorControls;
    %       obj.delete@Grasppe.Core.Mediator;
    %     end
    
    function updateControls(obj)
      disp('Updating Controls');
      if ~isempty(obj.CaseIDControl)
        try selectedCase = find(strcmpi(obj.CaseID, obj.Cases));
          if ~isempty(selectedCase)
            obj.CaseIDControl.setSelectedIndex(selectedCase-1);
          end
        end
      end
      
      if ~isempty(obj.SetIDControl)
        try selectedSet = find(obj.SetID == obj.Sets, 1);
          if ~isempty(selectedSet)
            obj.SetIDControl.setSelectedIndex(selectedSet-1);
          end
        end
      end
      
    end
    
    function createControls(obj, parentFigure)
      
      cases     = obj.Cases; sets      = obj.Sets;
      
      hFigure   = parentFigure.Handle;
      
      selectedCase = [];
      try selectedCase = find(strcmpi(obj.CaseID, cases)); end
      jCaseMenu = obj.createDropDown(hFigure, cases, selectedCase, ...
        @obj.selectCaseID, [], [], 150);
      
      obj.CaseIDControl = jCaseMenu;
      
      selectedSet = [];
      try selectedSet = find(sets==obj.SetID); end
      jSetMenu = obj.createDropDown(hFigure, sets, selectedSet, ...
        @obj.selectSetID, [], [], 75);
      
      obj.SetIDControl = jSetMenu;
      
      hToolbar = findall(allchild(hFigure),'flat','type','uitoolbar');
      
      if isempty(hToolbar), hToolbar  = uitoolbar(hFigure); end
      
      drawnow;
      
      jContainer = get(hToolbar(1),'JavaContainer');
      jToolbar = jContainer.getComponentPeer;
      
      jToolbar.add(jCaseMenu);
      jToolbar.add(jSetMenu);
      jToolbar.repaint;
      jToolbar.revalidate;
      
      refresh(hFigure);
      
    end
    
    function selectCaseID(obj, source, event)
      % disp(source); caseID = source.getSelectedItem;
      try obj.CaseID = source.getSelectedItem; end
    end
    
    function selectSetID(obj, source, event)
      % disp(source); setID = source.getSelectedItem;
      try obj.SetID = source.getSelectedItem; end
    end
    
    
    function jCombo = createDropDown(obj, hFigure, options, selection, callback, left, bottom, width, height)
      % options = {'opt #1', 'opt #2', 'opt #3'};
      
      try if isnumeric(options)
          options = num2cell(options);
        end; end;
      
      combo = javax.swing.JComboBox(options);
      % combo.setEditable(1);
      %[jCombo,hCombo] = javacomponent(combo, position);
      [jCombo,hCombo] = javacomponent(combo);
      
      jCombo.ActionPerformedCallback = callback;
      
      p = get(hCombo, 'Position');
      try if ~isempty(left),    p(1) = left;  end; end
      try if ~isempty(bottom),  p(2) = bottom;
        else p(2) = -height-10; end; end
      try if ~isempty(width),   p(3) = width; end; end
      try if ~isempty(height),  p(4) = height; end; end
      set(hCombo, 'Position', p);
      
      
      try
        if ~isempty(width),
          s         = jCombo.getMaximumSize;
          s.width   = width;
          jCombo.setMaximumSize(s);
        end
      end
      
      
      
      try if ~isempty(selection), jCombo.setSelectedIndex(selection-1); end; end
      
      obj.registerControl(jCombo, hCombo, combo);
      
    end
    
    function registerControl(obj, c, h, j)
      entry = struct('Component', c, 'Handle', h, 'Object', j);
      
      if isempty(obj.MediatorControls)
        obj.MediatorControls = entry;
      else
        obj.MediatorControls(end+1) = entry;
      end
      
      try obj.registerHandle(h); end
      try obj.registerHandle(c); end
      try obj.registerHandle(j); end
      
    end
    
  end
  
end

