% supLoad(datadir('rithp5501')); supInterp;
% close all; fSheet=1; fSet='u2'; supFFT;
close all;
figure;
jFrame = getjframe;
jFrame.setExtendedState(6);

% for fRun = {'ritsm7402a', 'ritsm7402b', 'ritsm7402c'}
for fRun = {'rithp5501', 'rithp7k01', 'ritsm7402a', 'ritsm7402b', 'ritsm7402c'}
  supLoad(datadir(fullfile('uniprint',char(fRun))));
  supInterp;
  for fSet = {'u'}; %, 'u2', 'u3', 'u4'}
    for fSheet = 1:numel(supData.sheetIndex)
      fSet=char(fSet); useCurrentFrame = true; supFFT;
    end
  end
end

close;
