% supDataSets = {'ritsm7401', 'ritsm7402a', 'ritsm7402c'}; %'ritsm7402b',
% 
% for k = 2:numel(supDataSets)
%   
%   

  if exist('output','dir')==0
    mkdir('output');
  end
  if exist('supPatchRange','var') == 0
    supPatchRange = [100 75 50 25 0];
  end
  close all;
  for supPatchValue = eval('supPatchRange')
    %%%
    % Set the patch value
    supPatchSet = supData.patchMap == supPatchValue; supInterp;
    for xView = [1 2] %1:4
      %%%
      % Compose the filename
      for fSet = {'u2','u3','u4','u'};
        thisFile = [supFileName '-' int2str(xView) '-'  int2str(supPatchValue) '-' char(fSet) '.avi'];
        thisTemp = fullfile('output', thisFile);
        supVideo(xView, thisFile, char(fSet));
      end
      %%%
      % Move from output folder? No
%       thisDest = fullfile(supFileName, thisFile)      
%       try
%         movefile( thisTemp,thisDest)
%       catch
%         warning('Could not find appropriate video folder, using ''output'' folder instead');        
%       end
    end
  end
  
  clear supPatchRange;
%   try
%     %movefile('output',supMatrix.sourceTicket.folder.name);
%     movefile('output', supFileName);
%   catch
%     warning('Could not find data folder name, using ''output'' folder instead');
%   end

% end

%   supPatchValue = 75; supPatchSet   = supData.patchMap == supPatchValue; supInterp; supVideo(xView, 'supVideo - ' int2str(xView) ' - 075.avi');
%   supPatchValue = 50; supPatchSet   = supData.patchMap == supPatchValue; supInterp; supVideo(xView, 'supVideo - ' int2str(xView) ' - 050.avi');
%   supPatchValue = 25; supPatchSet   = supData.patchMap == supPatchValue; supInterp; supVideo(xView, 'supVideo - ' int2str(xView) ' - 025.avi');
%   supPatchValue = 0; supPatchSet   = supData.patchMap == supPatchValue; supInterp; supVideo(xView, 'supVideo - ' int2str(xView) ' - 000.avi');

