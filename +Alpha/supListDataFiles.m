function [ fileList nSections nSamples iSamples output_args ] = supListDataFiles( folder,  extension )
%SUPDATAFILES checks files data folder and returns a list
%   Detailed explanation goes here

%% Check that folder is set
  folder  = datadir('UniPrintRaw', folder);
  assert(exist(folder,'dir')==7,'Data folder is not found.')

  
  if ~exist('extension','var')
    extension  = 'sref.txt';
  end

%% List and sort all .sden.txt files
% 
files = dir(fullfile(folder,['*.' extension ]));

fileCount = max(size(files));

[fileNames{1:fileCount,1}] = deal(files.name);

sortedNames = sort(fileNames);

%% Parse name components
% Returns char uniquePrefix, cell uniqueSuffix, cell unqiueSheets
%

nameParts = cellfun(@(x) regexpi(x,['(?<prefix>^[a-z]*)\D*' ...
                                    '(?<number>\d{3})[^\w\.]*' ...
                                    '(?<suffix>[a-z]*)'],'names','emptymatch'),sortedNames,'UniformOutput',true);
%nameCode = @(x) regexpi(x,[ '(?<prefix>^([a-z]*)).*(?<number>\d{3}|\.).*'],'names');
% '(<?<filename>.+)' ...
%nameParts = cellfun(nameCode,sortedNames,'UniformOutput',true);

%samplePrefix = cellfun(@(x) regexpi(x,'^[a-z]*','match'),sortedNames,'UniformOutput',true)

%sampleNumber = cellfun(@(x) regexpi(x,'\d{3}'),sortedNames,'UniformOutput',false)

[nameParts(1:end).filename] = deal(sortedNames{1:end});

% Check consistency of prefix
[samplePrefix{1:fileCount,1}] = deal(nameParts.prefix);
uniquePrefix = unique(samplePrefix);
assert(numel(uniquePrefix)==1,  ['Folder contains more than one datasets {' ...
                                sprintf(' %c', char(uniquePrefix)) ...
                                ' }. Each set must be moved into a separate folder']);

% Split groups by suffix
[sampleSuffix{1:fileCount,1}] = deal(nameParts.suffix);
uniqueSuffix = sort(unique(sampleSuffix));

sampleNumbers = cell(numel(uniqueSuffix),1);

% Select suffix
if numel(uniqueSuffix) > 1
  idn = 0;
  for m = 1:numel(uniqueSuffix)
    grp = uniqueSuffix{m};
    idx = unique(strcmpi(sampleSuffix,grp)'.*[1:numel(sampleSuffix)]);
    idx = idx(idx>0);
    
    if numel(idx > 0)
      for n = 1:numel(idx)
        sid = idx(n);
        sortedParts(m,n) = nameParts(sid);
      end
      
      if m > 1
        gNumbers = horzcat(sortedParts(1,:).number);
        mNumbers = horzcat(sortedParts(m,:).number);
        cNumbers = min(numel(gNumbers), numel(mNumbers));
        gNumbers(1:cNumbers) == mNumbers(1:cNumbers);
        assert(strcmp(gNumbers,mNumbers), ...
          'Sample groups do not match sequentially.');
      end      
    end
  end
  fileList = sortedParts;
  nSamples = numel(idx);
  [iSamples{1:nSamples}] = sortedParts(1,:).number;
else
  fileList = nameParts;
  nSamples = numel(fileList);
  [iSamples{1:nSamples}] = fileList(:).number;
  iSamples=unique(iSamples);
end

nSections = numel(uniqueSuffix);



return

%% Return variable struct
%
% output_args.files = files;
% output_args.fileNames = fileNames;
% output_args.sortedNames = sortedNames;
% output_args.nameParts = nameParts;
% output_args.fileList = fileList;

end

