classdef UniformityPlotFigure < Grasppe.Graphics.MultiPlotFigure
  %UNIFORMITYPLOTFIGURE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    PlotMediator
  end
  
  methods
    
    function obj = UniformityPlotFigure(varargin)
      obj = obj@Grasppe.Graphics.MultiPlotFigure(varargin{:});
    end
    
    function prepareMediator(obj)
      plotAxes      = obj.PlotAxes;
      
      plotMediator  = Grasppe.Core.Mediator;

      dataProperties = {'CaseID', 'SetID', 'SheetID'};
      axesProperties = {'View', 'Projection', 'Color'};
      
      properties = axesProperties;
      for m = 1:numel(plotAxes)
        thisAxes = plotAxes{m};
        if isa(thisAxes, 'Grasppe.Graphics.PlotAxes')
          for n = 1:numel(properties)
            property = properties{n};
%             if ischar(property)
            plotMediator.attachMediatorProperty(thisAxes, property);
          end
        end
      end
      
      obj.PlotMediator = plotMediator;
    end
    
  end
  
end

