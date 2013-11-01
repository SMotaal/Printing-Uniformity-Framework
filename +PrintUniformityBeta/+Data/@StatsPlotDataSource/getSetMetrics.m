function setMetrics = getSetMetrics(obj, setData)
  %PREPAREPLOTREGIONS Populated Set PlotRegions
  %   Detailed explanation goes here
  
  persistent SetMetrics SourcePath;
  
  version                   = MX.stackRev;

  setMetrics                = [];
  
  
  if ~exist('setData', 'var') || isempty(setData)
    setData                 = obj.Reader.getSetData();
  end
  
  caseData                  = obj.Reader.getCaseData();
  
  sourcePath                = obj.Reader.SourcePath;
  
  if isempty(setData), return; end % isempty(caseData)
  
  try
    obj.Tasks.GetMetrics    = obj.ProcessProgress.addAllocatedTask('Processing Metrics', 100, 14);
    TASK                    = obj.Tasks.GetMetrics;
    obj.ProcessProgress.activateTask(TASK);
  end
  
  try TASK.CHECK(); end                               % CHECK ProcessMetrics 1
  
  caseID                    = setData.CaseID;
  setID                     = setData.ID;
  
  
  %% Set Metrics Cache
  if isempty(SetMetrics), SetMetrics = containers.Map(); end
  
  setKey                    = [caseID ':' int2str(setID)];
  
  if SetMetrics.isKey(setKey) && isequal(SourcePath, sourcePath)
    try TASK.CHECK(); end                             % CHECK ProcessMetrics 2
    setMetrics              = SetMetrics(setKey);
  else
    
    setMetrics              = [];
    
    sourceSpace             = regexprep(regexpi(obj.Reader.SourcePath, '[\w-]+$', 'match', 'once'), '\W', '');
    sourceID                = regexprep([caseID 'SetMetrics' int2str(setID)], '\W', '');
    sourceStruct            = DS.dataSources(sourceID, sourceSpace);
    try if isequal(version, sourceStruct.Version), setMetrics = sourceStruct.Data; end; end
    
    if isempty(setMetrics)
    
      sheetIndex              = caseData.Index.Sheets;
      sheetCount              = caseData.Length.Sheets;
      sheetIDs                = 1:sheetCount;
      
      aroundCount             = caseData.Length.Rows;
      acrossCount             = caseData.Length.Columns;
      regionCount             = aroundCount*acrossCount;
      
      if isfield(setData.Regions, 'Regions');
        setRegions            = setData.Regions.Regions;
      else
        setRegions            = setData.Regions;
      end
      
      runData                 = setRegions.Run;    % sheetData= setData.Regions.Regions.Sheet;
      try TASK.CHECK(); end                             % CHECK ProcessMetrics 2
      
      aroundData              = setRegions.Around;
      try TASK.CHECK(); end                             % CHECK ProcessMetrics 3
      
      acrossData              = setRegions.Across;
      try TASK.CHECK(); end                             % CHECK ProcessMetrics 4
      
      regionData              = setRegions.Region;
      try TASK.CHECK(); end                             % CHECK ProcessMetrics 5
      
      
      % Region Naming
      for m = 1:aroundCount,  aroundData(m).Name  = num2str(m, 'C%d'); end
      try TASK.CHECK(); end                             % CHECK ProcessMetrics 6
      
      for m = 1:acrossCount,  acrossData(m).Name  = num2str(m, 'A%d'); end
      try TASK.CHECK(); end                             % CHECK ProcessMetrics 7
      
      for m = 1:regionCount,  regionData(m).Name  = num2str(m, 'R%d'); end
      try TASK.CHECK(); end                             % CHECK ProcessMetrics 8
      
      
      %% Metrics
      metricsTable                = {
        'Inaccuracy.Score',                   'Inaccuracy Score',           'InaccuracyScore';
        'Inaccuracy.Value',                   'Inaccuracy Value',           [];
        'Proportions.Inaccuracy',             'Inaccuracy Proportion',      'InaccuracyProportion';
        'Ranks.Inaccuracy',                   'Inaccuracy Rank',            [];
        'Sequences.Inaccuracy',               'Inaccuracy Sequence',        [];
        {'Directionality.Inaccuracy.Around', ...
        'Directionality.Inaccuracy.Across'},  'Inaccuracy Directionality',  'InaccuracyDirectionality';
        
        'Imprecision.Score',                  'Imprecision Score',          'ImprecisionScore';
        'Imprecision.Value',                  'Imprecision Value',          [];
        'Proportions.Imprecision',            'Imprecision Proportion',     'ImprecisionProportion';
        'Ranks.Imprecision',                  'Imprecision Rank',           [];
        'Ranks.Imprecision',                  'Imprecision Sequence',       [];
        {'Directionality.Imprecision.Around', ...
        'Directionality.Imprecision.Across'}, 'Imprecision Directionality',  'ImprecisionDirectionality';
        {'Factors.Unevenness.Factor', ...
        'Factors.Unrepeatability.Factor'},    'Imprecision Factors',        'ImprecisionFactors';
        
        'Factors.Unevenness.Factor',          'Unevenness Factor',          [];
        'Factors.Unevenness.Value',           'Unevenness Value',           [];
        'Proportions.Imprecision',            'Unevenness Proportion',      []; % Imprecision Proportion
        'Ranks.Unevenness',                   'Unevenness Rank',            [];
        'Ranks.Unevenness',                   'Unevenness Sequence',        [];
        
        'Factors.Unrepeatability.Factor',     'Unrepeatability Factor',     [];
        'Factors.Unrepeatability.Value',      'Unrepeatability Value',      [];
        'Proportions.Imprecision',            'Unrepeatability Proportion', []; % Imprecision Proportion
        'Ranks.Unrepeatability',              'Unrepeatability Rank',       [];
        'Ranks.Unrepeatability',              'Unrepeatability Sequence',   [];
        };
      
      runMetrics              = obj.getRegionMetrics(metricsTable, runData,     1,            1           );
      try TASK.CHECK(); end                             % CHECK ProcessMetrics 9
      
      aroundMetrics           = obj.getRegionMetrics(metricsTable, aroundData,  aroundCount,  1           );
      try TASK.CHECK(); end                             % CHECK ProcessMetrics 10
      
      acrossMetrics           = obj.getRegionMetrics(metricsTable, acrossData,  1,            acrossCount );
      try TASK.CHECK(); end                             % CHECK ProcessMetrics 11
      
      regionMetrics           = obj.getRegionMetrics(metricsTable, regionData,  aroundCount,  acrossCount );
      try TASK.CHECK(); end                             % CHECK ProcessMetrics 12
      
      %% Region Trimming
      % try aroundData          = rmfield(aroundData, 'Patch'); end
      % try acrossData          = rmfield(acrossData, 'Patch'); end
      % try regionData          = rmfield(regionData, 'Patch'); end
      %
      % setData                 = struct( ...
      %   'Run',        {runData        },  ...
      %   'Around',     {aroundData     },  ...
      %   'Across',     {acrossData     },  ...
      %   'Region',     {regionData     });
      
      setMetrics              = struct( ...
        'Table',      {metricsTable   },  ...
        'Run',        {runMetrics     },  ...
        'Around',     {aroundMetrics  },  ...
        'Across',     {acrossMetrics  },  ...
        'Region',     {regionMetrics  }   ... %'Data',       {setData        },  ...
        );
            
      try TASK.CHECK(); end                             % CHECK ProcessMetrics 13      
      
      try DS.dataSources(sourceID, struct('Version', version, 'Data', setMetrics), false, sourceSpace); end
    end
    
    SetMetrics(setKey)      = setMetrics;
    SourcePath              = sourcePath;
    
  end
  
  try TASK.SEAL(); end                                % SEAL ProcessMetrics
  
end
