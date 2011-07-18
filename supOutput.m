for supPatchValue = [100 75 50 25 0]
  supPatchSet = supData.patchMap == supPatchValue; supInterp;
  for xView = 1:4
    supVideo(xView, ['supVideo' int2str(xView) '-'  int2str(supPatchValue) '.avi']);
  end
end


%   supPatchValue = 75; supPatchSet   = supData.patchMap == supPatchValue; supInterp; supVideo(xView, 'supVideo - ' int2str(xView) ' - 075.avi');
%   supPatchValue = 50; supPatchSet   = supData.patchMap == supPatchValue; supInterp; supVideo(xView, 'supVideo - ' int2str(xView) ' - 050.avi');
%   supPatchValue = 25; supPatchSet   = supData.patchMap == supPatchValue; supInterp; supVideo(xView, 'supVideo - ' int2str(xView) ' - 025.avi');
%   supPatchValue = 0; supPatchSet   = supData.patchMap == supPatchValue; supInterp; supVideo(xView, 'supVideo - ' int2str(xView) ' - 000.avi');

