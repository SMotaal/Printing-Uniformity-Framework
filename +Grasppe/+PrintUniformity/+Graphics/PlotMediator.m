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
  
  properties
    MediatorControls = struct('Component', [], 'Handle', [],  'Object', []);
  end
  
  methods
    function obj = PlotMediator()
      obj = obj@Grasppe.Core.Mediator;
      
      %obj.createControls
    end
    
    function value = get.CASEID(obj)
      value = [];
      try value = obj.CaseID; end
    end
    
    function set.CASEID(obj, value)
      try obj.CaseID = value; end
    end
    
    function value = get.SETID(obj)
      value = [];
      try value = obj.SetID; end
    end
    
    function set.SETID(obj, value)
      try obj.SetID = value; end
    end
    
    function value = get.SHEETID(obj)
      value = [];
      try value = obj.SheetID; end
    end
    
    function set.SHEETID(obj, value)
      try obj.SheetID = value; end
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

    
    function createControls(obj, parentFigure)
           
      cases     = {'ritsm7402a', 'ritsm7402b', 'ritsm7402c', 'rithp7k01', 'rithp5501'};
      sets      = int8([100, 75, 50, 25, 0]);
      
      hFigure   = parentFigure.Handle;
      
      hToolbar  = uitoolbar(hFigure);
      
      jToolbar = get(get(hToolbar,'JavaContainer'),'ComponentPeer');     
      
      caseID = obj.CaseID;
      selectedCase = find(strcmpi(caseID, cases));
      jCaseMenu = obj.createDropDown(hFigure, cases, selectedCase, ...
        @obj.selectCaseID, 0, [], 150);
      
      setID = obj.SetID;
      selectedSet = find(sets==setID);
      jSetMenu = obj.createDropDown(hFigure, sets, selectedSet, ...
        @obj.selectSetID, 175, [], 75);      
      
      
      if ~isempty(jToolbar)
        jToolbar(1).add(jCaseMenu,1);
        jToolbar(1).add(jSetMenu,1);
        jToolbar(1).repaint;
        jToolbar(1).revalidate;
      end      
      
      
%       obj.createDropDown(hFigure, ...
%         {100, 75, 50, 25, 0}, ...
%         @obj.selectCaseID, 175, [], 100);      
    end
    
    function selectCaseID(obj, source, event)
      % disp(source);
      try obj.CaseID = source.getSelectedItem; end
    end
    
    function selectSetID(obj, source, event)
      % disp(source);
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
      try if ~isempty(left),    p(1) = left; end; end
      try if ~isempty(bottom),  p(2) = bottom; end; end
      try if ~isempty(width),   p(3) = width; end; end
      try if ~isempty(height),  p(4) = height; end; end
      set(hCombo, 'Position', p);
      
      try if ~isempty(selection), jCombo.setSelectedIndex(selection-1); end; end
      
      obj.registerControl(jCombo, hCombo, combo);
      
    end
    
    function registerControl(obj, c, h, j)
      entry = struct('Component', c, 'Handle', h, 'Object', j);
      
      obj.MediatorControls(end) = entry;
    end
    
  end
  
end

