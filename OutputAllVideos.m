%% TODO
% 1 - L* color scale not mirrored! (L-scale not DL-Scale
% 2 - views 3/4 running means and bounds not color scales!
% 3 - Gridlines to solid gray (not dotted cause it's clunky)
% 4 - 

%fullfile('uniprint',sid)

clear all;
  tic; supLoad(datadir('uniprint','rithp5501'));   OutputVideos; clear all; toc;
  tic; supLoad(datadir('uniprint','ritsm7401'));   OutputVideos; clear all; toc;
  tic; supLoad(datadir('uniprint','ritsm7402a'));  OutputVideos; clear all; toc;
  tic; supLoad(datadir('uniprint','ritsm7402b'));  OutputVideos; clear all; toc;
  tic; supLoad(datadir('uniprint','rithp7k01'));   OutputVideos; clear all; toc;
  tic; supLoad(datadir('uniprint','ritsm7402c'));  OutputVideos; clear all; toc;
