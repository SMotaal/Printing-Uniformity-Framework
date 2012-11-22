


% supLoad(FS.dataDir('rithp5501')); supInterp;
% close all; fSheet=1; fSet='u2'; supFFT;
testData = zeros(20,56, 76);

for i = 1:20
  newData = zeros(56, 76);
  newData(1:i,1:i) = 50;
  newData(end-i:end,end-i:end) = 50;
  newData(end-i:end,1:i) = 50;
  newData(1:i,end-i:end) = 50;
  imshow(newData,[]);
  pause(1);
end

return;

close all;
figure;
jFrame = getjframe;
jFrame.setExtendedState(6);

% for fRun = {'ritsm7402a', 'ritsm7402b', 'ritsm7402c'}
% for fRun = {'rithp5501', 'rithp7k01', 'ritsm7402a', 'ritsm7402b', 'ritsm7402c'}
%   supLoad(FS.dataDir(fullfile('uniprint',char(fRun))));
%   supInterp;
  for fSet = {'u'}; %, 'u2', 'u3', 'u4'}
    for fSheet = 1:1 %numel(supData.sheetIndex)
      fSet=char(fSet); useCurrentFrame = true; supFFTTests;
    end
  end
% end

close;
