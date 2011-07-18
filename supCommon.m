%global cms supMatrix supData supPatchSet supSheet supSample

%% Define data set
if ~exist('supRITSM74', 'var')
  load('supRITSM74001')
end

if ~exist('supMatrix', 'var')
  supMatrix     = supRITSM74;
  spectralRange = supMatrix{1,2}{4,1};
end

%% Define selected sample
if ~exist('supPatchSet','var')
   supPatchSet   = [];
end

if ~exist('supSheet','var')
  supSheet      = 1;
end

if ~exist('supPatchValue', 'var')
  supPatchValue = 75; % 100, 75, 50, 25, 0 , -1 (slur)
end

if ~exist ('supData','var')
  supData = struct();
end

if ~exist ('supSample','var')
  supSample = struct();
end

%% Define color workspace
if ~exist('cms','var')
  cms.cie       = getCieStruct;
  cms.refRange  = spectralRange;

  cms.refIll    = interp1(cms.cie.lambda, cms.cie.illD65, cms.refRange,'pchip')';
  %refIll    = interp1(cie.lambda, cieIllD(5000,cie), refRange,'pchip')'
  cms.refCMF    = interp1(cms.cie.lambda, cms.cie.cmf2deg,cms.refRange ,'pchip');
  cms.XYZn      = ref2XYZ(ones(length(cms.refRange),1),cms.refCMF,cms.refIll);
end


%% Define common functions
supFun;
