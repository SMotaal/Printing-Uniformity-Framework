x = Grasppe.PrintUniformity.Graphics.UniformityPlotFigure('PlotAxesLength', 2, 'WindowStyle', 'docked');

d1 = Grasppe.PrintUniformity.Data.LocalVariabilityDataSource('CaseID', 'rithp5501'); a1 = x.PlotAxes{1};
p = Grasppe.PrintUniformity.Graphics.UniformitySurf(a1, d1);

d2 = Grasppe.PrintUniformity.Data.RawUniformityDataSource('CaseID', 'rithp5501'); a2 = x.PlotAxes{2};
p2 = Grasppe.PrintUniformity.Graphics.UniformitySurf(a2, d2);

x.prepareMediator;
