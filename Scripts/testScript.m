x = MultiPlotFigureObject();
x.setVisible(1);

d = RegionStatsUniformityDataSource(); 

% s = UniformitySurfaceObject.Create(x.getPlotAxes(1), 'DataSource', d);

for i = 1:4
  s(i) = UniformitySurfaceObject.Create(x.getPlotAxes(i), 'DataSource', d);
end
