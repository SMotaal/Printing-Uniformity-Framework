x = MultiPlotFigureObject();
x.setVisible(true);

% d     = LocVarUniformityDataSource('CaseID', 'rithp5501');
% d(2)  = LocVarUniformityDataSource('CaseID', 'rithp7k01');

d     = LocVarUniformityDataSource('CaseID', 'ritsm7402a');
d(2)  = LocVarUniformityDataSource('CaseID', 'ritsm7402b');
d(3)  = LocVarUniformityDataSource('CaseID', 'ritsm7402c');

for i = 1:numel(d)
  p(i)  = x.getPlotAxes(i);
  s(i)  = UniformitySurfaceObject.Create(p(i), 'DataSource', d(i));
  
  
%   xp(i) = FigureObject('WindowTitle', [d(i).CaseID ' Properties'], ...
%     'WindowStyle', 'normal', 'Menubar', 'none', 'Toolbar', 'none');
%   
%   tp(i) = PropertiesTableObject.Create(xp(i));
%   
%   try tp(i).attachProperty(s(i), 'DataSource');   end
%   try tp(i).attachProperty(d(i), 'CaseID');     end
%   try tp(i).attachProperty(d(i), 'SetID');        end
%   try tp(i).attachProperty(d(i), 'SheetID');     end
%   try tp(i).attachProperty(d(i), 'ZLim');         end
%   try tp(i).attachProperty(d(i), 'CLim');         end
%   try tp(i).attachProperty(p(i), 'View');         end
%   
%   xp(i).setVisible(true);
end

cb    = ColorBarObject.Create(x.getPlotAxes(1));




% xp = FigureObject('WindowStyle', 'normal', 'Menubar', 'none', 'Toolbar', 'none'); 
% 
% tp = PropertiesTableObject.Create(xp); ...
%   tp.attachProperty(x,'WindowStyle'); tp.attachProperty(x,'Color'); ...
%   tp.attachProperty(x,'IsVisible');
% 
% xp.setVisible(true); pause(0.5);

% commandwindow;


% x = PlotFigureObject('WindowStyle', 'docked'); x.setVisible(true); p =
% x.PlotAxes; d=RegionsUniformityDataSource(); s =
% UniformitySurfaceObject.Create(x.PlotAxes, 'DataSource', d); b =
% ColorBarObject.Create(p); commandwindow;
