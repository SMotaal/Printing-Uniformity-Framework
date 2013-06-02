function prepareCases(obj)
  %PREPARECASES Populate obj.Cases with CaseSetModel
  %   Detailed explanation goes here
  
  % if isequal(obj.State, GrasppeAlpha.Core.Enumerations.TaskStates.Initializing), return; end
  
  sourceMetadata            = obj.sourceMetadata;
  
  if isempty(obj.sourceMetadata), obj.prepareSource(); end
  
  if isempty(obj.cases)
    % caseMetadata            = sourceMetadata.Cases.Metadata;
    
    caseSymbols             = sourceMetadata.Cases.Symbols;
    caseIDs                 = sourceMetadata.Cases.IDs;
    caseCount               = numel(caseIDs);
    caseEntries             = cell(1, caseCount);
    
    for m = 1:caseCount
      caseMetadata          = sourceMetadata.Cases.Metadata{m};
      
      caseData              = struct(); ...
        caseData.ID         = caseIDs{m}; ...
        caseData.Symbol     = caseSymbols{m}; ...
        caseData.Name       = ''; ...
        caseData.Path       = obj.sourcePath; ...
        caseData.Metadata   = caseMetadata; ...
        caseData.Files      = getCaseFiles(caseData.ID, @obj.getSourceFile);
      
      aroundBandIndex       = [];
      acrossBandIndex       = [];
      zoneIndex             = [];
      
      try
        masksFile           = obj.getSourceFile(caseData.Files.Masks.name); %obj.getCaseFile(obj.CaseData.ID, setKey(3:end), regionID); % obj.getSourceFile(
        dataStruct          = load(masksFile, 'Masks');
        sourceMasks         = dataStruct.Masks;
        maskFields          = fieldnames(sourceMasks);
      end
      
      regionIDs             = fieldnames(caseData.Files.Stats);
      setKeys               = fieldnames(caseData.Files.Stats.Run);
      setIDs                = cellfun(@str2num, regexpi(setKeys, '\d+$', 'match', 'once'));  
      sheetSequence         = sourceMetadata.Sheets.Index{m}; % caseData{m}.testdata.dimensions.samples.sequence;
      
      try
        masks               = cell(2,numel(maskFields));
        
        for n = 1:numel(maskFields)
          masks{1, n}       = regionIDs{strcmpi(maskFields{n}, regionIDs)}; % maskID;
          masks{2, n}       = sourceMasks.(maskFields{n});
        end
        
        masks               = struct(masks{:});
                
        try aroundBandIndex = 1:size(masks.Around,1); end
        try acrossBandIndex = 1:size(masks.Across,1); end
        try zoneIndex       = 1:size(masks.Zone,1);   end
        
        caseData.Masks      = masks;
      end
      
      caseData.Index        = struct( ...
        'Regions',      {regionIDs}, ...
        'PatchSets',    setIDs, ...
        'Sheets',       sheetSequence, ...
        'Rows',         aroundBandIndex, ...
        'Columns',      acrossBandIndex, ...
        'Zones',        zoneIndex);
      
      caseData.Length       = caseData.Index;
      lengthFields          = fieldnames(caseData.Length);
      for n = 1:numel(lengthFields)
        caseData.Length.(lengthFields{n}) = numel(caseData.Length.(lengthFields{n}));
      end
      
      caseEntries{m}        = caseData;
      
    end
    
    cases                     = PrintUniformityBeta.Models.CaseSetModel(caseSymbols, caseEntries);
    
    obj.cases                 = cases;
  end
  
end

function caseFiles = getCaseFiles(caseID, getSourceFile)
  
  sourcePath                = getSourceFile('');
  sourceList                = ls(getSourceFile([caseID '-*.mat']));
  dataFiles                 = regexpi(sourceList, ['(?<CaseID>' caseID ')-(?<SetID>\d+)-(?<RegionID>\w*)\.mat\s?'], 'names', 'lineanchors');
  caseFiles                 = struct();
  caseFiles.CaseID          = caseID;
  caseFiles.Path            = sourcePath;
  caseFiles.Masks           = dir(strtrim(ls(getSourceFile([caseID '-Masks.mat']))));
  statsFiles                = struct('Run', [], 'Sheet', [], 'Patch', [], 'Region', [], 'Across', [], 'Around', []);
  
  for m = 1:numel(dataFiles)
    
    dataFile                = dataFiles(m);
    setID                   = dataFile.SetID;
    regionID                = dataFile.RegionID;
    dataFile.Filename       = [caseID '-' setID '-' regionID '.mat'];
    dataFile.Path           = strtrim(ls(getSourceFile(dataFile.Filename)));
    % dataFile.Fields         = whos('-file', dataFile.Path);
    
    statsFiles.(regionID).(['TV' setID]) = dir(dataFile.Path);
  end
  
  caseFiles.Stats         = statsFiles;
  
end
