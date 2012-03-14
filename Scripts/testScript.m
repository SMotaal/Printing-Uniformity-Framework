x = MultiPlotFigureObject();
x.setVisible(true);

d = RegionsUniformityDataSource(); 

% s = UniformitySurfaceObject.Create(x.getPlotAxes(1), 'DataSource', d);

for i = 1:4
  s(i) = UniformitySurfaceObject.Create(x.getPlotAxes(i), 'DataSource', d);
end

ColorBarObject.Create(x.getPlotAxes(1));

commandwindow;


% x = PlotFigureObject('WindowStyle', 'docked'); x.setVisible(true); p =
% x.PlotAxes; d=RegionsUniformityDataSource(); s =
% UniformitySurfaceObject.Create(x.PlotAxes, 'DataSource', d); b =
% ColorBarObject.Create(p); commandwindow;
