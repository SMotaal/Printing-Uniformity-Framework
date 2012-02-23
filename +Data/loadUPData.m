function [ data ] = loadUPData( source )
  %LOADDATA Load Print Uniformity Data
  %   Detailed explanation goes here
  
  %   import Color.*;
  
  
  if ischar(source)
    data              = emptyStruct('name', 'path', ...
      'metadata', 'index', 'range', 'length', 'metrics', 'tables', ...
      'sampling', 'colorimetry');
    
    source            = loadSource(source);
    
    data.name         = source.name;
    data.path         = source.path;
    
    data              = prepareData(source, data);
    data.sampling     = processPatchSampling(data);
    data.colorimetry  = processColorimetry(data);
    
    data              = Metrics.processUPMetrics(data);
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
  
  sampling.Repeats  = data.metrics.targetSize ./ size(sampling.PatchMap);
  
  sampling.masks.Slur     = sampling.PatchMap  ==   -1;
  sampling.masks.TV100    = sampling.PatchMap  ==  100;
  sampling.masks.TV75     = sampling.PatchMap  ==   75;
  sampling.masks.TV50     = sampling.PatchMap  ==   50;
  sampling.masks.TV25     = sampling.PatchMap  ==   25;
  sampling.masks.TV0      = sampling.PatchMap  ==    0;
  
  sampling.masks.Columns  = linearMask(data.length.Columns, data.index.Columns);
  sampling.masks.Rows     = linearMask(data.length.Rows, data.index.Rows);
  
  sampling.masks.Target   = sampling.masks.Rows*sampling.masks.Columns';
end

function [mask] = linearMask(length, index)
  mask = zeros(length,1);
  mask(unique(index(:))) = 1;
end

function [ sourceStruct ] = loadSource( source )
  if ischar(source)
    
    sourceID      = source; %Data.generateUPID(source,[],[]);
    
    sourceStruct  = Data.dataSources(sourceID);
    
    if (isempty(sourceStruct))
      %       sourceStruct = Data.dataSources(source);
      %     else
      
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
      
      %       sourceID      = Data.generateUPID(sourceName);
      Data.dataSources(sourceID, sourceStruct);
      
      %     source = struct('name', sourceName, 'path', sourcePath, );
    end
    
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
    
    ticket  = source.sourceTicket;
    index   = source.sparseIndex;
    
    data.metadata = ticket;
    
    data.index.Columns          = index.spreadColumns';
    data.index.Rows             = index.spreadRows';
    data.index.Sheets           = index.spreadSheets(:);
    data.index.Spectra          = index.bandIndex;
    
    data.metrics.patchWidth     = millimeters(ticket.testform.iSis.patchwidth);
    data.metrics.patchLength    = millimeters(ticket.testform.iSis.patchheight);
    
    data.metrics.pressWidth     = millimeters(ticket.testform.press.printwidth);
    data.metrics.pressLength    = millimeters(ticket.testform.press.printlength);
    
    data.metrics.printOffset    = millimeters(ticket.testform.press.printoffset);
    
    data.metrics.paperWidth     = millimeters(ticket.testrun.substrate.sheetsize{1});
    data.metrics.paperLength    = millimeters(ticket.testrun.substrate.sheetsize{2});
    
    % Reduntant with data.length.Rows & data.length.Columns
    data.metrics.targetRows     = 1+nanmax(data.index.Rows(:))    - nanmin(data.index.Rows(:));
    data.metrics.targetColumns  = 1+nanmax(data.index.Columns(:)) - nanmin(data.index.Columns(:));
    
    data.metrics.targetSize     = [data.metrics.targetRows data.metrics.targetColumns];
    
    data.metrics.targetOffset   = millimeters(ticket.testform.target.offset);
    data.metrics.targetShift    = millimeters(ticket.testform.target.shift);
    
    try
      inkZones                  = ticket.testform.press.inkzones;
      data.metrics.zoneRange    = inkZones.range;
      data.metrics.zoneWidth    = inkZones.width;
      data.metrics.zoneSteps    = inkZones.patches;
      
      data.index.SampleZones    = inkZones.targetrange;
      data.index.PressZones     = inkZones.range;
    end
    
    data.tables.spectra(:,:, data.index.Columns,:) = source.sparseData.oldRef;
    
    [data.range.Columns data.length.Columns]  = dataRange(data.index.Columns);
    [data.range.Rows    data.length.Rows]     = dataRange(data.index.Rows);
    
    data.range.Sheets       = stepRange(data.index.Sheets);
    data.length.Sheets      = numel(data.index.Sheets);
    
    data.range.Spectra      = stepRange(data.index.Spectra);
    data.length.Spectra     = numel(data.index.Spectra);
    
    
    try
      data.range.PressZones   = dataRange(data.index.PressZones);
      data.length.PressZones  = numel(data.index.PressZones);
      
      data.range.SampleZones  = dataRange(data.index.SampleZones);
      data.length.SampleZones = numel(data.index.SampleZones);
    end
    
  end
  
  %   data.metrics.target.Sets  = supData.targetSize ./ size(supData.patchMap);
  
  
end

function [ colorimetry ] = processColorimetry( data )
  
  import Color.*;
  
  colorimetry = Color.getCieStruct;
  
  reInterpCMS = 1;
  try
    reInterpCMS = all(colorimetry.refRange == data.spectralRange) == 1;
  end
  
  if reInterpCMS
    colorimetry.refRange  = data.index.Spectra;
    colorimetry.refIll    = interp1(colorimetry.lambda, colorimetry.illD65, colorimetry.refRange,'pchip')';
    colorimetry.refCMF    = interp1(colorimetry.lambda, colorimetry.cmf2deg,colorimetry.refRange ,'pchip');
    colorimetry.XYZn      = ref2XYZ(ones(length(colorimetry.refRange),1),colorimetry.refCMF,colorimetry.refIll);
  end
end

