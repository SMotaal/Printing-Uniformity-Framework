function prepareCases(obj)
  %PREPARECASES Populate obj.Cases with CaseSetModel
  %   Detailed explanation goes here
  
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
      
      regionIDs             = fieldnames(caseData.Files.Stats);
      setKeys               = fieldnames(caseData.Files.Stats.Run);
      setIDs                = cellfun(@str2num, regexpi(setKeys, '\d+$', 'match', 'once'));
      
      sheetSequence         = sourceMetadata.Sheets.Index{m}; % caseData{m}.testdata.dimensions.samples.sequence;
      
      caseData.Index        = struct('Regions', {regionIDs}, 'PatchSets', setIDs, 'Sheets', sheetSequence);
      
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
