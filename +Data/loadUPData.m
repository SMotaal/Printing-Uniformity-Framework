function [ data ] = loadUPData( source )
  %LOADDATA Load Print Uniformity Data
  %   Detailed explanation goes here
  
%   import Color.*;

 
  if ischar(source)
    data              = emptyStruct(...
      'index', 'range', 'metrics', 'tables', ...
      'sampling', 'colorimetry');
    
    source            = loadSource(source);
    
    data              = prepareData(source, data);
    data.sampling     = processPatchSampling(data);
    data.colorimetry  = processColorimetry(data);
  else
    data = source;
  end
  
end

function [ sampling ] = processPatchSampling( data )
  sampling.PatchMap   = [  ...
    100    -1   100    75;
     25   100    50   100;
    100    75   100     0;
     50   100    25   100;  ];
  
  sampling.Repeats  = data.metrics.target.Size ./ size(sampling.PatchMap);
  
  sampling.masks.Slur  = sampling.PatchMap  ==   -1;
  sampling.masks.TV100 = sampling.PatchMap  ==  100;
  sampling.masks.TV75  = sampling.PatchMap  ==   75;
  sampling.masks.TV50  = sampling.PatchMap  ==   50;
  sampling.masks.TV25  = sampling.PatchMap  ==   25;
  sampling.masks.TV0   = sampling.PatchMap  ==    0;
  
  sampling.masks.Columns = setdiff(data.range.Columns, data.index.Columns);
    
end

function [ sourceStruct ] = loadSource( source )
  if ischar(source)
    
    sourcePath = source;
    
    try
      sourceContents = whos('-file', sourcePath);
    catch err
      try
        sourcePath = datadir('uniprint',  source);
        sourceContents = whos('-file', sourcePath);
      catch err
        error('UniPrint:Stats:Load:SourceNotFound', 'Source %s is not found.', sourcePath);
      end
    end
    
    try
      sourcePath = strtrim(ls([sourcePath '.*']));
    catch err
      error('UniPrint:Stats:Load:SourceNotFound', 'Source %s is not found.', sourcePath);      
    end

%     sourcePath = which(sourcePath);
    
    isSolo = all(size(sourceContents) == [1 1]);
    
    assert(isSolo,[sourcePath ...
      ' contains more than one variable. Uniformity data structures must be stored seperately.']);
    
    sourceName = sourceContents.name;
%     sourceData = load(sourcePath); %, sourceName);
%     source = sourceData.(sourceName);
    sourceData = getfield(load(sourcePath), sourceName);
    
    
    sourceFields = fieldnames(sourceData)';
    
    sourceStruct = emptyStruct('name', 'path', sourceFields{:});
    
    sourceStruct.('name') = sourceName;
    sourceStruct.('path') = sourcePath;
    
    for field = sourceFields
      sourceStruct.(char(field)) = sourceData.(char(field));
    end
    
%     source = struct('name', sourceName, 'path', sourcePath, );

  else
    sourceStruct = source;
  end  
end

function [ data ] = prepareData ( source, data )

    %% Process oldschool/newer supMatrix structure
%   try
%     isSupData   = isVerified isstruct(source) && ...
%       strcmpi(source.sourceTicket.subject, 'Print Uniformity Research Data');
%     isSupForme  = isstruct(source) && ...
%       strfind(lower(source.sourceTicket.testform.id), 'sup-');
%     
%   catch
%     Warning('The structure of the data matrix does not conform to a known style.');
%   end
  
  newerStructure = (isVerified('source.sourceTicket.subject', 'Print Uniformity Research Data') && ...
    isVerified('strcmpi(lower(source.sourceTicket.testform.id), ''sup-'')'));
  
  olderStructure = ~newerStructure && iscell(source) && ...
    all(size(source) == [1 2]) && strcmp(source{1,2}{1,2},'sheetNumber');
  
  %% Update Structures
  if newerStructure

    data.index.Columns  = reshape(source.sparseIndex.spreadColumns',1,[]);
    data.index.Sheets   = source.sparseIndex.spreadSheets(:);
    data.index.Spectra = source.sparseIndex.bandIndex;    
       
    data.metrics.patch.Width  = source.sourceTicket.testform.iSis.patchwidth;
    data.metrics.patch.Length = source.sourceTicket.testform.iSis.patchheight;
    
    data.metrics.print.Width  = source.sourceTicket.testform.press.printwidth;
    data.metrics.print.Length = source.sourceTicket.testform.press.printlength;
    data.metrics.print.Offset = source.sourceTicket.testform.press.leadoffset;
    data.metrics.print.Shift  = source.sourceTicket.testform.press.axialshift;
    
    try
        inkZones   = source.sourceTicket.testform.press.inkzones;
        zoneMetrics.Range = inkZones.range;
        zoneMetrics.Width = inkZones.width;
        zoneMetrics.Steps = inkZones.patches;
        
        data.index.Zones = inkZones.targetrange;
        data.range.Zones = inkZones.range;
        data.metrics.zone = zoneMetrics;
    end
    
    data.tables.spectra(:,:, data.index.Columns,:) = source.sparseData.oldRef;
    
    
  elseif olderStructure
    
    data.index.Columns   = source{1,2}{3,1};
    data.index.Sheets    = source{1,2}{1,1};    
    data.index.Spectra = source{1,2}{4,1};
    
    data.tables.spectra(:,:, data.index.Columns,:) = source{1,1};

  end
  
    data.range.Columns  = 1:numel(data.index.Columns);
    data.range.Sheets   = 1:numel(data.index.Sheets);    
    data.range.Spectra   = 1:numel(data.index.Spectra);  
  
  data.metrics.target.Size = [size(data.tables.spectra,2) size(data.tables.spectra,3)];

end

function [ colorimetry ] = processColorimetry( data )
  
  import Color.*;
  
  colorimetry = Color.getCieStruct;

  reInterpCMS = 1;
  try
    reInterpCMS = all(colorimetry.refRange == data.spectralRange) == 1;
  end
  
  if reInterpCMS
    colorimetry.refRange  = data.range.Spectra;
    colorimetry.refIll    = interp1(colorimetry.lambda, colorimetry.illD65, colorimetry.refRange,'pchip')';
    colorimetry.refCMF    = interp1(colorimetry.lambda, colorimetry.cmf2deg,colorimetry.refRange ,'pchip');
    colorimetry.XYZn      = ref2XYZ(ones(length(colorimetry.refRange),1),colorimetry.refCMF,colorimetry.refIll);
  end  
end

