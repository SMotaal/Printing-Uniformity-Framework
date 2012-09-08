classdef UniformityPlotFigure < Grasppe.Graphics.MultiPlotFigure
  %UNIFORMITYPLOTFIGURE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    PlotMediator
    DataSources
  end
  
  methods
    function obj = UniformityPlotFigure(varargin)
      obj = obj@Grasppe.Graphics.MultiPlotFigure(varargin{:});
      refresh(obj.Handle);
    end   

    function prepareMediator(obj, dataProperties, axesProperties)
      if isempty(obj.PlotMediator) || ~isa(obj, 'Grasppe.PrintUniformity.UI.PlotMediator')
        obj.PlotMediator  = Grasppe.PrintUniformity.UI.PlotMediator;
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
      
        if commandKey && shiftKey
          switch event.Data.Key
            case 'h'
              try obj.DataSources{1}.setSheet('sum'); syncSheets = true; end
              event.Consumed = true;
            case 'uparrow'
              try obj.DataSources{1}.setSheet('+1'); syncSheets = true; end
              event.Consumed = true;
            case 'downarrow'
              try obj.DataSources{1}.setSheet('-1'); syncSheets = true; end
              event.Consumed = true;
            otherwise
              %disp(toString(event.Data.Key));
          end
        end
      end
      
      if syncSheets
        %if numel(obj.DataSources)>1
          for m = 2:numel(obj.DataSources)
            notify(obj.DataSources{m}, 'SheetChange');
            %try obj.DataSources{m}.SheetID = obj.DataSources{1}.SheetID; end
          end
        %end
      end
      
      obj.OnKeyPress@Grasppe.Graphics.MultiPlotFigure(source, event);
    end
    
    
  end
  
  methods(Access=protected)
    
    function createComponent(obj)
      obj.createComponent@Grasppe.Graphics.MultiPlotFigure();
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
          plotMediator.attachMediatorProperty(subject, property, alias);
        end
      end
      
      obj.PlotMediator = plotMediator;
      
    end
    
    
%     function preparePlotAxes(obj)
%       obj.preparePlotAxes@Grasppe.Graphics.MultiPlotFigure;
%     end
  end
  
  %     methods (Static, Hidden)
  %     function OPTIONS  = DefaultOptions()
  %       PlotAxesLength = 1;
  %       Grasppe.Utilities.DeclareOptions;
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
      
      
      Grasppe.Utilities.DeclareOptions;

      %options = WorkspaceVariables(true);
    end
  end
  
  
end

