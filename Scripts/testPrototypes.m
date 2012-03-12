clc; try dbquit all, end;close all; cleardebug;

pi = 1;
clear pInfo;


disp('Cleared Debug Workspace.');

newProfile  = @(varargin) evalin('caller', 'profile on; tId=tic;,'    );
endProfile  = @(varargin) evalin('caller', ['toc(tId); profile off; ' ...
  'pInfo(pi) = profile(''info''); ' 'pi = pi+1; ' ]                   );

rId = tic;

disp('Running Tests...');

newProfile();

% 1   1.096
% *** CreateHandleObject: figure ==> Name, Printing, Uniformity, Plot, Renderer, opengl, ToolBar, none, MenuBar, none, WindowStyle, docked, Color, white, Tag, PlotFigureObject_1, HandleVisibility, on, SelectionHighlight, on, HitTest, on, Visible, on, Selected, off, UserData, [1x1, PlotFigureObject], Visible, off, Parent, [0], Tag, PlotFigureObject_1
% *** CreateHandleObject: axes ==> Box, off, Color, none, Tag, OverlayAxesObject_1, HandleVisibility, on, SelectionHighlight, on, HitTest, off, Visible, off, Selected, off, UserData, [1x1, OverlayAxesObject], Parent, [1], Tag, OverlayAxesObject_1
% *** CreateHandleObject: text ==> String, Title, Tag, TitleTextObject_1, HandleVisibility, on, SelectionHighlight, on, HitTest, off, Visible, on, Selected, off, UserData, [1x1, TitleTextObject], Parent, [0.01708984375], Tag, TitleTextObject_1
% *** CreateHandleObject: axes ==> Box, on, Color, none, Tag, PlotAxesObject_1, HandleVisibility, on, SelectionHighlight, on, HitTest, on, Visible, on, Selected, off, UserData, [1x1, PlotAxesObject], Parent, [1], Tag, PlotAxesObject_1

x = PlotFigureObject('WindowStyle', 'docked');
endProfile(); snapnow(); newProfile();

% 2   1.978
% *** CreateHandleObject: surf ==> LineSmoothing, on, Tag, UniformitySurfaceObject_1, HandleVisibility, on, SelectionHighlight, on, HitTest, on, Visible, on, Selected, off, UserData, [1x1, UniformitySurfaceObject], Parent, [6.01708984375], Tag, UniformitySurfaceObject_1
s = UniformitySurfaceObject.Create(x.PlotAxes);
endProfile(); snapnow(); newProfile();

% 3   0.258
x.setVisible(true);
endProfile(); newProfile();

% 4   0.001
p = x.PlotAxes;
endProfile(); newProfile();

% 5   1.451
% *** CreateHandleObject: surf ==> LineSmoothing, on, Tag, UniformitySurfaceObject_2, HandleVisibility, on, SelectionHighlight, on, HitTest, on, Visible, on, Selected, off, UserData, [1x1, UniformitySurfaceObject], Parent, [6.01708984375], Tag, UniformitySurfaceObject_2
s = UniformitySurfaceObject.Create(x.PlotAxes);
endProfile(); snapnow(); newProfile();

% 6   0.570
d = s.DataSource; b = ColorBarObject.Create(p);
endProfile(); newProfile();

% 7   9.277
for i = 1:d.Samples
  s.setSheet('+1');
  drawnow();
end
endProfile(); snapnow(); newProfile();

% 8   0.021
delete(x);
endProfile(); newProfile();

% 9   0.879
% *** CreateHandleObject: figure ==> Name, Printing, Uniformity, Plot, Renderer, opengl, ToolBar, none, MenuBar, none, WindowStyle, docked, Color, white, Tag, MultiPlotFigureObject_1, HandleVisibility, on, SelectionHighlight, on, HitTest, on, Visible, on, Selected, off, UserData, [1x1, MultiPlotFigureObject], Visible, off, Parent, [0], Tag, MultiPlotFigureObject_1
% *** CreateHandleObject: axes ==> Box, off, Color, none, Tag, OverlayAxesObject_2, HandleVisibility, on, SelectionHighlight, on, HitTest, off, Visible, off, Selected, off, UserData, [1x1, OverlayAxesObject], Parent, [1], Tag, OverlayAxesObject_2
% *** CreateHandleObject: text ==> String, Title, Tag, TitleTextObject_2, HandleVisibility, on, SelectionHighlight, on, HitTest, off, Visible, on, Selected, off, UserData, [1x1, TitleTextObject], Parent, [0.024658203125], Tag, TitleTextObject_2
% *** CreateHandleObject: axes ==> Box, on, Color, none, Tag, PlotAxesObject_2, HandleVisibility, on, SelectionHighlight, on, HitTest, on, Visible, on, Selected, off, UserData, [1x1, PlotAxesObject], Parent, [1], Tag, PlotAxesObject_2
x = MultiPlotFigureObject('WindowStyle', 'docked'); x.setVisible(1);
endProfile(); snapnow(); newProfile();

% 10  1.340
% *** CreateHandleObject: surf ==> LineSmoothing, on, Tag, UniformitySurfaceObject_3, HandleVisibility, on, SelectionHighlight, on, HitTest, on, Visible, on, Selected, off, UserData, [1x1, UniformitySurfaceObject], Parent, [6.024658203125], Tag, UniformitySurfaceObject_3
s(1) = UniformitySurfaceObject.Create(x.getPlotAxes(1));
endProfile(); snapnow(); newProfile();

% 11  1.557
% *** CreateHandleObject: axes ==> Box, on, Color, none, Tag, PlotAxesObject_3, HandleVisibility, on, SelectionHighlight, on, HitTest, on, Visible, on, Selected, off, UserData, [1x1, PlotAxesObject], Parent, [1], Tag, PlotAxesObject_3
% *** CreateHandleObject: surf ==> LineSmoothing, on, Tag, UniformitySurfaceObject_4, HandleVisibility, on, SelectionHighlight, on, HitTest, on, Visible, on, Selected, off, UserData, [1x1, UniformitySurfaceObject], Parent, [11.024658203125], Tag, UniformitySurfaceObject_4
% *** CreateHandleObject: axes ==> Box, on, Color, none, Tag, PlotAxesObject_4, HandleVisibility, on, SelectionHighlight, on, HitTest, on, Visible, on, Selected, off, UserData, [1x1, PlotAxesObject], Parent, [1], Tag, PlotAxesObject_4
% *** CreateHandleObject: surf ==> LineSmoothing, on, Tag, UniformitySurfaceObject_5, HandleVisibility, on, SelectionHighlight, on, HitTest, on, Visible, on, Selected, off, UserData, [1x1, UniformitySurfaceObject], Parent, [16.024658203125], Tag, UniformitySurfaceObject_5
% *** CreateHandleObject: axes ==> Box, on, Color, none, Tag, PlotAxesObject_5, HandleVisibility, on, SelectionHighlight, on, HitTest, on, Visible, on, Selected, off, UserData, [1x1, PlotAxesObject], Parent, [1], Tag, PlotAxesObject_5
% *** CreateHandleObject: surf ==> LineSmoothing, on, Tag, UniformitySurfaceObject_6, HandleVisibility, on, SelectionHighlight, on, HitTest, on, Visible, on, Selected, off, UserData, [1x1, UniformitySurfaceObject], Parent, [21.024658203125], Tag, UniformitySurfaceObject_6
% *** CreateHandleObject: axes ==> Box, on, Color, none, Tag, PlotAxesObject_6, HandleVisibility, on, SelectionHighlight, on, HitTest, on, Visible, on, Selected, off, UserData, [1x1, PlotAxesObject], Parent, [1], Tag, PlotAxesObject_6
% *** CreateHandleObject: surf ==> LineSmoothing, on, Tag, UniformitySurfaceObject_7, HandleVisibility, on, SelectionHighlight, on, HitTest, on, Visible, on, Selected, off, UserData, [1x1, UniformitySurfaceObject], Parent, [26.024658203125], Tag, UniformitySurfaceObject_7
for i = 2:5, s(i) = UniformitySurfaceObject.Create(x.getPlotAxes(i), 'DataSource', s(1).DataSource); end
endProfile(); snapnow(); newProfile();

% 12  1.157
% Warning: figure JavaFrame property will be obsoleted in a future release. For more
% information see the JavaFrame resource on the MathWorks web site. 
% > In testPrototypes at 58 

x.WindowStyle = 'normal';
% jFrame = get(x.Handle,'JavaFrame');
% jFrame.setMaximized(true);
%  1          61        1168         796
set(x.Handle, 'Position', [1 61 1168 796]);
drawnow;
% x.resizeComponent;
endProfile(); 
pause(2);
set(x.Handle, 'Position', [1 61 1168 796]);
pause(2);
snapnow(); 

newProfile();

% 13  14.999
for i = 1:d.Samples
  s(1).setSheet('+1');
  drawnow();
end
endProfile(); snapnow(); newProfile();

% 14  0.013
% close all;
delete(x);

endProfile(); close all;

drawnow();
% 34.809
fprintf('Tests Complete in %f s.\n', toc(rId));

% disp('Saving Test Profiles...');
% 
% rID = tic;
% 
% % Saving Profiles Complete in 721.330361 s.
% for pi = 1:numel(pInfo)
%   profileName = ['Prototypes' int2str(pi)];
%   fprintf('Saving %s...\n', profileName);
%   profsave( pInfo(pi), fullfile(cd, 'output', 'profile', profileName));
% end
% 
% fprintf('Saving Profiles Complete in %f s.\n', toc(rId));
% 
% clear all;
