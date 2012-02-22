% tic; dataSource = Data.loadUPData('ritsm7402a'); dataSource2 = Metrics.generateUPRegions(dataSource); dataSet = Data.interpUPDataSet(dataSource2,dataSource2.sampling.masks.TV100); toc;
% tic; dataSet = Data.interpUPDataSet(dataSource2,dataSource2.sampling.masks.TV100); toc;
% tic; dataSource3 = Stats.generateUPStats(dataSource2, dataSet); toc;

pi = 1;
clear pInfo;

Data.dataSources('clear');
disp('Data buffer cleared.');

newProfile  = @(varargin) evalin('caller', 'profile on; tId=tic;,'    );
endProfile  = @(varargin) evalin('caller', ['toc(tId); profile off; ' ...
  'pInfo(pi) = profile(''info''); ' 'pi = pi+1; ' ]                   );

rId = tic;

disp('Running Tests...');

newProfile();

[dataSource params] = Plots.plotUPStats('ritsm7402a');
endProfile(); newProfile();
[dataSource params] = Plots.plotUPStats('ritsm7402a',params);
endProfile(); newProfile();
[dataSource params] = Plots.plotUPStats('ritsm7402c',params);
endProfile(); newProfile();
[dataSource params] = Plots.plotUPStats('ritsm7402c', 50, params);
endProfile(); newProfile();
[dataSource params] = Plots.plotUPStats('ritsm7402c',params);
endProfile(); newProfile();
[dataSource params] = Plots.plotUPStats('ritsm7402a');

endProfile();

fprintf('Tests Complete in %f s.\n', toc(rId));

disp('Saving Test Profiles...');

rID = tic;

for pi = 1:numel(pInfo)
  profileName = ['plotUPStats' int2str(pi)];
  fprintf('Saving %s...\n', profileName);
  profsave( pInfo(pi), fullfile(cd, 'output', 'profile', profileName));
end

fprintf('Saving Profiles Complete in %f s.\n', toc(rId));
