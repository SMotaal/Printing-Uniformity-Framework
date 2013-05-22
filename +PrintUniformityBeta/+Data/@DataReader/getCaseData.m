function [ caseData ] = getCaseData(obj, caseID, varargin) %, parameters)
  %GetCaseData Load and Get Case Data
  %   Detailed explanation goes here
  
  caseData                      = [];
  
  if nargin<2, caseID           = obj.CaseID; end
  if isempty(caseID), return; end  
  
  caseData                      = obj.CaseData;
  if ~isempty(caseData), return; end
  
  caseData                      = loadCaseData(caseID);
  caseData.SetData              = containers.Map('KeyType', 'int32', 'ValueType', 'any');
  
  if nargin<2, obj.CaseData     = caseData; end
  
  
  %   %% Data
  %   newData               = obj.Data;
  %   dataReader            = newData.DataReader;
  %
  %   caseData              = newData.CaseData;
  %   sourceData            = [];
  %
  %   %% Get State
  %   customFunction        = false;
  %   caseReady             = false;
  %   caseLoading           = false;
  %
  %   try customFunction    = isa(obj.GetSetDataFunction, 'function_handle'); end
  %   try caseReady         = dataReader.CheckState('CaseReady'); end
  %   try caseLoading       = dataReader.CheckState('CaseLoading'); end
  %
  %   %% Load Data
  %   if ~caseLoading || ~caseReady || isempty(caseData) %|| updatedParameters ~caseLoading ||
  %
  %     try dataReader.PromoteState('CaseLoading', true); end
  %
  %     %% Get Container Data
  %     %if ~exist('sourceData', 'var') ||
  %       sourceData        = loadCaseData(dataReader.Parameters.CaseID); %feval([eval(NS.CLASS) '.LoadSourceData'], dataReader.Parameters.CaseID);
  %     %end
  %
  %     if isempty(sourceData)
  %       error('Grasppe:DataReader:Invalid source', 'Could not load source data.');
  %     end
  %
  %     %% Execute Custom Processing Function
  %     skip                = false;
  %
  %     if isa(obj.GetCaseDataFunction, 'function_handle')
  %       [caseData skip]   = obj.GetCaseDataFunction(newData);
  %     end
  %
  %     %% Execute Default Processing Function
  %     if isequal(skip, false)
  %       caseData          = sourceData;
  %     end
  %
  %     %try dataReader.PromoteState('CaseParsed', true); end
  %
  %     %% Update Data Model
  %     newData.CaseData    = caseData;
  %
  %     newData.Parameters.CaseID = dataReader.Parameters.CaseID;
  %
  %     try dataReader.PromoteState('CaseReady', true); end
  %   end
  %
  %   %% Return
  %   if nargout<1, clear caseData;   end
  %   if nargout<2, clear parameters; end
end

function [ data ] = loadCaseData( source )
  %LOADDATA Load Print Uniformity Data
  %   Detailed explanation goes here 
  
  if ischar(source)
    data                        = emptyStruct(... 
      'name', 'path', ...
      'metadata', 'index', 'range', 'length', 'metrics', 'tables', ...
      'sampling', 'colorimetry');
    
    source                      = loadSource(source);
    
    data.name                   = source.name;
    data.path                   = source.path;
    
    data                        = prepareData(source, data);
    data.sampling               = processPatchSampling(data);
    data.range.Sets             = data.sampling.PatchSets;
    data.length.Sets            = numel(data.range.Sets);
    data.colorimetry            = processColorimetry(data);
    data                        = PrintUniformityBeta.Data.DataReader.ProcessDataMetrics(data);
  else
    data = source;
  end
  
end

function [ sampling ] = processPatchSampling( data )
  sampling.PatchMap             = [  ...
    100    -1   100    75;
    25   100    50   100;
    100    75   100     0;
    50   100    25   100;  ];
  
  sampling.Repeats              = data.metrics.targetSize ./ size(sampling.PatchMap);
  
  sampling.masks.TV100          = sampling.PatchMap  ==  100;
  sampling.masks.TV75           = sampling.PatchMap  ==   75;
  sampling.masks.TV50           = sampling.PatchMap  ==   50;
  sampling.masks.TV25           = sampling.PatchMap  ==   25;
  sampling.masks.TV0            = sampling.PatchMap  ==    0;
  sampling.masks.Slur           = sampling.PatchMap  ==   -1;  
  
  sampling.masks.Columns        = linearMask(data.length.Columns, data.index.Columns);
  sampling.masks.Rows           = linearMask(data.length.Rows, data.index.Rows);
  
  sampling.masks.Target         = sampling.masks.Rows*sampling.masks.Columns';
    
  sampling.Flip                 = false;
  
  sampling.PatchSets            = sort(unique(sampling.PatchMap(sampling.PatchMap>=0)), 'descend');
  
  try sampling.Flip             = isequal(data.metadata.testdata.samples.flipped, true); end
end

function [mask] = linearMask(length, index)
  mask                          = zeros(length,1);
  mask(unique(index(:)))        = 1;
end

function [ sourceStruct ] = loadSource( source )
  
  if ischar(source)
    
    sourceID                    = source;
    sourceSpace                 = sourceID;
    sourceStruct                = DS.dataSources(sourceID, sourceSpace);
    
    if (isempty(sourceStruct))

      sourcePath                = source;
      
      try
        sourceContents          = whos('-file', sourcePath);
      catch err
        try
          sourcePath            = FS.dataDir('uniprint',  source);
          sourceContents        = whos('-file', sourcePath);
        catch err
          error('UniPrint:Stats:Load:SourceNotFound', 'Source %s is not found.', sourcePath);
        end
      end
      
      try
        sourcePath              = strtrim(ls([sourcePath '.*']));
      catch err
        error('UniPrint:Stats:Load:SourceNotFound', 'Source %s is not found.', sourcePath);
      end
      
      isSolo                    = all(size(sourceContents) == [1 1]);
      
      assert(isSolo,[sourcePath ...
        ' contains more than one variable. Uniformity data structures must be stored seperately.']);
      
      sourceName                = sourceContents.name;
      sourceData                = getfield(load(sourcePath), sourceName);
      
      sourceFields              = fieldnames(sourceData)';
      
      sourceStruct              = emptyStruct('name', 'path', sourceFields{:});
      
      sourceStruct.('name')     = sourceName;
      sourceStruct.('path')     = sourcePath;
      
      for field = sourceFields
        sourceStruct.(char(field)) = sourceData.(char(field));
      end
      
      DS.dataSources(sourceID, sourceStruct, true, sourceSpace);

    end
    
  else
    sourceStruct                = source;
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
  
  newerStructure                = ( ...
    isVerified('source.sourceTicket.subject', 'Print Uniformity Research Data') && ...
    isVerified('strcmpi(lower(source.sourceTicket.testform.id), ''sup-'')'));
  
  %% Update Structures
  if newerStructure
    
    ticket                      = source.sourceTicket;
    index                       = source.sparseIndex;
    
    data.metadata               = ticket;
    
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
    
    data.range                  = emptyStruct( ...
      'Rows', 'Columns', 'Sets', 'Sheets', 'Spectra', 'PressZones', 'SampleZones');
    
    data.length                 = emptyStruct( ...
      'Rows', 'Columns', 'Sets', 'Sheets', 'Spectra', 'PressZones', 'SampleZones');    
    
    [data.range.Columns data.length.Columns]  = dataRange(data.index.Columns);
    [data.range.Rows    data.length.Rows]     = dataRange(data.index.Rows);
    
    data.range.Sheets           = stepRange(data.index.Sheets);
    
    data.range.Spectra          = stepRange(data.index.Spectra);
    
    data.range.PressZones       = [];
    try data.range.PressZones   = min(data.index.PressZones):max(data.index.PressZones); end         % if isfield(data.index, 'PressZones')
    
    data.range.SampleZones      = [];
    try data.range.SampleZones  = min(data.index.SampleZones):max(data.index.SampleZones); end        % if isfield(data.index, 'SampleZones')
    
    data.length.Sheets          = numel(data.index.Sheets);  
    data.length.Spectra         = numel(data.index.Spectra);    
    data.length.PressZones      = numel(data.range.PressZones);
    data.length.SampleZones     = numel(data.range.SampleZones);
  end
    
end

function [ colorimetry ] = processColorimetry( data )
  
  colorimetry                   = Color.getCieStruct;
  
  reInterpCMS                   = 1;
  try reInterpCMS               = all(colorimetry.refRange == data.spectralRange) == 1; end
  
  if reInterpCMS
    colorimetry.refRange        = data.index.Spectra;
    colorimetry.refIll          = interp1(colorimetry.lambda, colorimetry.illD65, colorimetry.refRange,'pchip')';
    colorimetry.refCMF          = interp1(colorimetry.lambda, colorimetry.cmf2deg,colorimetry.refRange ,'pchip');
    colorimetry.XYZn            = Color.ref2XYZ(ones(length(colorimetry.refRange),1),colorimetry.refCMF,colorimetry.refIll);
  end
  
end

