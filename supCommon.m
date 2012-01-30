%global cms supMatrix supData supPatchSet supSheet supSample

import Color.*;

%% Define data set
% if ~exist('supRITSM74', 'var')
%   load('supRITSM74001')
% end
% 
% if ~exist('supMatrix', 'var')
%   supMatrix     = supRITSM74;
%   spectralRange = supMatrix{1,2}{4,1};
% end

%% Define selected sample
if ~exist('supPatchSet','var')
   supPatchSet   = [];
end

if ~exist('supSheet','var')
  supSheet      = 1;
end

if ~exist('supPatchValue', 'var')
  supPatchValue = 100; % 100, 75, 50, 25, 0 , -1 (slur)
end

if ~exist ('supData','var')
  supData = struct();
end

if ~exist ('supSample','var')
  supSample = struct();
end

%% Define color workspace
cms.cie       = getCieStruct;


%% Define common functions
supFun;
