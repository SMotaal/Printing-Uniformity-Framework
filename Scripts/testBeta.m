x = Grasppe.PrintUniformity.Graphics.UniformityPlotFigure('PlotAxesLength', 3, 'WindowStyle', 'docked');

d1 = Grasppe.PrintUniformity.Data.RawUniformityDataSource('CaseID', 'rithp5501'); a1 = x.PlotAxes{1};
p1 = Grasppe.PrintUniformity.Graphics.UniformitySurf(a1, d1);

d2 = Grasppe.PrintUniformity.Data.UniformitySurfaceDataSource('CaseID', 'rithp5501'); a2 = x.PlotAxes{2};
p2 = Grasppe.PrintUniformity.Graphics.UniformitySurf(a2, d2);

d3 = Grasppe.PrintUniformity.Data.LocalVariabilityDataSource('CaseID', 'rithp5501'); a3 = x.PlotAxes{3};
p3 = Grasppe.PrintUniformity.Graphics.UniformitySurf(a3, d3);

x.prepareMediator;
x.PlotMediator.createControls(x);
