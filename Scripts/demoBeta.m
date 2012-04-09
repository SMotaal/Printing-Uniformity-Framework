x = Grasppe.PrintUniformity.Graphics.UniformityPlotFigure('PlotAxesLength', 3); 

mPos = get(0,'MonitorPositions');
set(x.Handle, 'Position', [mPos(1,1) mPos(4) mPos(3) 550]);

a1 = x.PlotAxes{1}; a2 = x.PlotAxes{2}; a3 = x.PlotAxes{3};

d1 = Grasppe.PrintUniformity.Data.RawUniformityDataSource('CaseID', 'rithp5501');

p1 = Grasppe.PrintUniformity.Graphics.UniformitySurf(a1, d1);

d2 = Grasppe.PrintUniformity.Data.UniformitySurfaceDataSource('CaseID', 'rithp5501'); 

p2 = Grasppe.PrintUniformity.Graphics.UniformitySurf(a2, d2);

d3 = Grasppe.PrintUniformity.Data.LocalVariabilityDataSource('CaseID', 'rithp5501');

p3 = Grasppe.PrintUniformity.Graphics.UniformitySurf(a3, d3);

x.prepareMediator;
