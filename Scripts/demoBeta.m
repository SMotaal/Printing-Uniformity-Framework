x = PrintUniformityBeta.Graphics.UniformityPlotFigure('PlotAxesLength', 3); 

mPos = get(0,'MonitorPositions');
set(x.Handle, 'Position', [mPos(1,1) mPos(4) mPos(3) 550]);

a1 = x.PlotAxes{1}; a2 = x.PlotAxes{2}; a3 = x.PlotAxes{3};

d1 = PrintUniformityBeta.Data.UniformityPlaneDataSource('CaseID', 'rithp5501');

p1 = PrintUniformityBeta.Graphics.UniformitySurf(a1, d1);

d2 = PrintUniformityBeta.Data.RegionStatsDataSource('CaseID', 'rithp5501'); 

p2 = PrintUniformityBeta.Graphics.UniformitySurf(a2, d2);

d3 = PrintUniformityBeta.Data.LocalVariabilityDataSource('CaseID', 'rithp5501');

p3 = PrintUniformityBeta.Graphics.UniformitySurf(a3, d3);
