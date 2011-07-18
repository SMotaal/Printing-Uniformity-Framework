function [ output_args ] = supLoad( supMatrix )
%SUPLOAD Loads the workspace for sup plotting
%   Detailed explanation goes here

evalin('base', 'supCommon');

supMatrix = evalin('base','supMatrix');
supData = evalin('base','supData');
cms = evalin('base','cms');
supPatchSet = evalin('base','supPatchSet');
supSheet = evalin('base','supSheet');
supPatchValue = evalin('base','supPatchValue');


supData.columnInset   = supMatrix{1,2}{3,1};
supData.columnRange   = 1:numel(supData.columnInset);
supData.spectralRange = supMatrix{1,2}{4,1};

supData.sheetIndex    = supMatrix{1,2}{1,1};

supData.data(:,:, supData.columnInset,:) = supMatrix{1,1};

supData.dataPeak         = max(supData.data,[],ndims(supData.data));
supData.dataMaxPeak      = max(max(max(supData.dataPeak)));

supData.dataMean         = mean(supData.data,ndims(supData.data));

supData.dataDen          = (supData.dataPeak+supData.dataMaxPeak/5) ./ (supData.dataMaxPeak/5*6);

supData.targetSize    = [size(supData.data,2) size(supData.data,3)];

supData.patchMap      = [  100  -1 100  75;
                            25 100  50 100;
                           100  75 100   0;
                            50 100  25 100;  ];

supData.patchSetReps  = supData.targetSize ./ size(supData.patchMap);

supData.subSetSlur         = supData.patchMap  ==   -1;
supData.subSet100          = supData.patchMap  ==  100;
supData.subSet75           = supData.patchMap  ==   75;
supData.subSet50           = supData.patchMap  ==   50;
supData.subSet25           = supData.patchMap  ==   25;
supData.subSet0            = supData.patchMap  ==    0;

%if ~exist('supPatchSet','var')
supPatchSet   = supData.patchMap == supPatchValue;
assignin('base', 'supPatchSet', supPatchSet);
%end

supData.gapMap        = setdiff(supData.columnRange,supData.columnInset);

assignin('base','supData',supData);

end

