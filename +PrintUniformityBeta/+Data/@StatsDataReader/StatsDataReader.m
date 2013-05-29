classdef StatsDataReader < PrintUniformityBeta.Data.DataReader
  %READER Printing Uniformity Data Reader
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    
    ProcessSheetRegions       = false;
    ProcessRegionModes        = false;
    
    %% HandleComponent
    % HandleProperties = {};
    % HandleEvents = {};
    % ComponentType = 'PrintingUniformityTallyDataReader';
    % ComponentProperties = '';
    
    %% Mediator-Controlled Properties
    % DataProperties    = PrintUniformityBeta.Data.DataReader.GetDataParameters; %%{'CaseID', 'SetID', 'VariableID', 'SheetID'};
    
    %% Prototype Meta Properties
    StatsDataReaderProperties  = {
      'CaseID',     'Case ID',          'Data',      'string',   '';   ...
      'SetID',      'Set ID',           'Data',      'int',      '';   ...
      'SheetID',    'Sheet ID',         'Data',      'int',      '';   ...
      'VariableID', 'Variable ID',      'Data',      'string',   '';   ...
      'RegionMode', 'Region Mode',      'Data',      'string',   '';   ...
      };
    
    % DataModels = struct( ...
    %   'Data',       'PrintUniformityBeta.Models.UniformityData', ...
    %   'Parameters', 'PrintUniformityBeta.Models.DataParameters' ...
    %   )
  end
  
  properties (AbortSet, Dependent, SetObservable, GetObservable)
    SourcePath
    SourceMetadata
    
    Cases
    PatchSets
    RegionSets
    Sheets
    
    CaseKey                       = '';
    SetKey                        = '';
    SheetKey                      = '';
    VariableKey                   = '';
    RegionKey                     = '';
    
    % CaseIndex                     = [];
    % SetIndex                      = [];
    % SheetIndex                    = [];
    % VariableIndex                 = [];
    % RegionIndex                   = [];
    
    % CaseID                      = '';
    % SetID                       = 100;
    % SheetID                     = 0;
    
  end
  
  properties (Dependent)
    RegionMode
    % CaseData
    % SetData
    % SheetData
    
    % CaseName
    % SetName
    % SheetName
  end
  
  properties
    % GetCaseDataFunction         = [];
    % GetSetDataFunction          = [];
    % GetSheetDataFunction        = [];
  end
  
  properties (GetAccess=public, SetAccess=protected, Hidden)
    sourcePath                  = fullfile('Output', 'UniPrint-Stats-130526');
    cases                       = [];
    patchSets                   = [];
    sheets                      = [];
    regionSets                  = [];
    sourceMetadata              = [];
    
    regionMode                  = 'Regions';
    regionModes                 = {};
    regionModeRules             = {
      'Regions',  {'Region',    'Around',   'Across'  },  'Region-to-Region'
      'Zones',    {'Zone',                            },  'Zone-to-Zone'
      'Patches',  {'Patch',                           },  'Patch-to-Patch'
      'Sheets',   {'Sheet'                            },  'Sheet-to-Sheet'
      };
    
    regionIDs                   = {};
    setIDs                      = [];
  end
  
  properties (GetAccess=public, SetAccess=protected, Hidden)
    
    statics                     = evaluateStruct({
      'Metadata.File.Name'            'Metadata.mat'
      'Metadata.Field'                'Metadata'
      'Analysis.Fields.Reference'     'Standard'
      'Analysis.Fields.Tolerance'     'Tolerance'
      'Analysis.Fields.Unit'          'Unit'
      'Analysis.Fields.Method'        'SumsMethod'
      'Analysis.Fields.Version'       'Version'
      'Analysis.Fields.Revision'      'Revision'    
    });
  
  end
  
  
  methods %(Access=protected)
    % [ caseData                ] = getCaseData     (obj, caseID);
    % [ setData                 ] = getSetData      (obj, setID);
    % [ sheetData               ] = getSheetData    (obj, sheetID);
  end
  
  %% Prototype Methods
  methods
    function obj = StatsDataReader(varargin)
      obj                       = obj@PrintUniformityBeta.Data.DataReader(varargin{:});
    end
    
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      % obj.CaseID                  = '';
      % obj.SetID                     = 100;
      % obj.SheetID                   = 1;
      
      %   if ~any(strcmpi(obj.ComponentOptions, 'SetID'))
      %     obj.ComponentOptions        = [obj.ComponentOptions, 'SetID', 100];
      %   end
      %
      %   if ~any(strcmpi(obj.ComponentOptions, 'SheetID'))
      %     obj.ComponentOptions        = [obj.ComponentOptions, 'SheetID', 1];
      %   end
      
      try obj.prepareSource(); end
      
      obj.setDefaultComponentOption('SetID', 100);
      obj.setDefaultComponentOption('SheetID', 1);
      
      obj.createComponent@PrintUniformityBeta.Data.DataReader;
    end
    
  end
  
  %% Getters / Setters Parameters CaseID, SetID, VariableID, SheetID
  methods
    
    prepareSource(obj, sourcePath);
    prepareCases(obj);    
    preparePatchSets(obj);
        
    function set.SourcePath(obj, sourcePath)
      if ~isequal(sourcePath, obj.sourcePath) || isempty(sourcePath)
        obj.clearSource;
        obj.prepareSource(sourcePath);
      end
    end
    
    function clearingSource = clearSource(obj)
      clearingSource              = false;
      clearingSource              = clearingSource || ~isempty(obj.sourcePath);
      clearingSource              = clearingSource || ~isempty(obj.cases);
      clearingSource              = clearingSource || ~isempty(obj.patchSets);
      clearingSource              = clearingSource || ~isempty(obj.regionSets);
      clearingSource              = clearingSource || ~isempty(obj.sheets);
      clearingSource              = clearingSource || ~isempty(obj.sourceMetadata);
      
      if clearingSource
        obj.sourcePath            = '';
        obj.cases                 = [];
        obj.patchSet              = [];
        obj.regionSets             = [];
        obj.sheets                = [];
        obj.sourceMetadata        = [];
        
        obj.clearCaseData;
      end
    end
    
    function clearing = clearCaseData(obj)
      clearing                    = true;
      try clearing                = ~isempty(obj.caseData); end
      
      if ~isempty(obj.CaseID), obj.CaseID = []; end      
      if clearing, obj.Data.CaseData      = []; end
      
      clearing                    = clearing || obj.clearSetData();  
    end
    
    function clearing = clearSetData(obj)
      clearing                    = true;
      try clearing                = ~isempty(obj.setData); end
      
      if ~isempty(obj.SetID), obj.SetID = []; end
      if clearing, obj.Data.SetData     = []; end
      
      clearing                    = clearing || obj.clearSheetData();
    end
    
    function clearing = clearSheetData(obj)
      clearing                    = true;
      try clearing                = ~isempty(obj.sheetData); end
      
      if ~isempty(obj.SheetID), obj.SheetID = []; end     
      if clearing, obj.Data.SheetData       = []; end
      
    end
        
    function loading = loadSource(obj, sourcePath)
      
      loading                   = false;
      
      if nargin==1
        sourcePath              = obj.sourcePath;
      end
      
      if isempty(sourcePath), return; end
      
      metadataPath              = fullfile(sourcePath, obj.statics.Metadata.File.Name);
      
      readStruct                = load(metadataPath, obj.statics.Metadata.Field);
      sourceMetadata            = readStruct.(obj.statics.Metadata.Field);
      
      loading                   = true;
      
      obj.sourcePath            = sourcePath;
      obj.sourceMetadata        = sourceMetadata;
    end
    
    prepareRegionSets(obj);
%       
%       %% Construct proxy structres for region modes avialble for each case
%       % 1. Define region modes rules
%       % 2. Each case: figure out available regions by IDs
%       % 3. Each case:
%       
%       if isempty(obj.cases), obj.prepareCases; end
%       
%       regionModeRules           = obj.regionModeRules;
%       regionModeIDs             = regionModeRules(:,1);
%       regionModeConstraints     = regionModeRules(:,2);
%       regionModeNames           = regionModeRules(:,3);
%       regionModeCount           = numel(regionModeIDs);
%       
%       cases                     = obj.cases;      
%       caseIDs                   = cases.keys;
%       caseCount                 = cases.length;
%       
%       %regionEntries             = cell(1, regionModeCount);
%       
%       regionStruct              = struct();
%       regionNames               = {}; % cell(1, regionModeCount*caseCount);
%       regionEntries             = {}; % cell(1, regionModeCount*caseCount);
%       
%       for m = 1:caseCount
%         caseID                  = caseIDs{m};
%         caseData                = cases(caseID);
%         caseFiles               = caseData.Files;
%         caseMasksFile           = caseFiles.Masks;
%         caseStatsFiles          = caseFiles.Stats;
%         caseRegionFields        = fieldnames(caseStatsFiles);
%         
%         caseRegionIDs           = caseData.Index.Regions;
%         
%         caseRegionModes         = {};
%         caseRegionModeRegionIDs = {};
%         caseRegionModeNames     = {};
%         
%         for n = 1:regionModeCount
%           if stropt(regionModeRules{n,2}, caseRegionIDs)
%             caseRegionModes         = [caseRegionModes regionModeRules{n,1}];
%             caseRegionModeRegionIDs = [caseRegionModeRegionIDs {regionModeRules{n,2}}];
%             caseRegionModeNames     = [caseRegionModeNames regionModeRules{n,3}];
%           end
%         end
%         
%         for n = 1:numel(caseRegionModes)
%           regionMode            = caseRegionModes{n};
%           regionIDs             = caseRegionModeRegionIDs{n};
%           regionModeName        = caseRegionModeNames{n};
%           
%           entry                 = struct();
%           
%           entry.RegionMode      = regionMode;
%           entry.RegionName      = regionModeName;
%           entry.CaseID          = caseID;
%           entry.Key             = [caseID ':' regionMode];
%           entry.RegionIDs       = regionIDs;
%           
%           entry.Files           = struct(...
%             'CaseID',   caseID,           'RegionMode',  regionMode, ...
%             'Path',     caseFiles.Path,   'Masks',  caseMasksFile, ...
%             'Stats',    rmfield(caseStatsFiles, setdiff(caseRegionFields, regionIDs)));
%           
%           regionStruct.(regionMode).(caseID) = entry;
%           regionNames           = [regionNames, entry.Key];
%           regionEntries         = [regionEntries, entry];
%           
%         end
%         
%       end
%       
%       regionSets                = PrintUniformityBeta.Models.RegionSetModel(regionStruct); % regionNames, regionEntries);
%       
%       obj.regionSets            = regionSets;
%       
%         % regionIDs                 = {};
%         %
%         % for m = 1:numel(obj.cases.values)
%         %   caseData                = obj.cases{m};
%         %   caseRegionIDs           = caseData.Index.RegionIDs;
%         %   regionIDs               = unqiue(regionIDs, caseRegionIDs, 'stable');
%         % end
%         %
%         % regionIDs                 = setdiff(unique(['Sheet'; regionIDs], 'Stable'), 'Run', 'Stable');
%         %
%         % %% Update source metadata (transient)
%         % if ~isfield(obj.SourceMetadata, 'RegionIDs') || ~isequal(regionIDs, obj.SourceMetadata.RegionIDs)
%         %   obj.SourceMetadata.RegionIDs  = regionIDs;
%         % end
%         %
%         % obj.regionIDs             = regionIDs; %unqiue([regionIDs, {'Sheet'}], 'stable');
% 
%     end
    
    function updateSheets(obj)
      %% Adding Sheets to SetData Struct
      
      % updatingSetData           = isstruct(obj.SetData)
      
      processModes                    = isequal(obj.ProcessRegionModes, true);
      setData                         = obj.Data.SetData; % getSetData();      
      
      updatingSheetSet                = true;
      updatingSheetSet                = isempty(setData) || ...
        ~isa(setData, 'PrintUniformityBeta.Models.SetData') || ...
        ~isfield(setData, 'Sheets') || ...
        ~isa(setData.Sheets, 'PrintUniformityBeta.Models.SheetSetModel');
      
      if ~updatingSheetSet, return; end;
      
      if isempty(obj.sourceMetadata), obj.prepareSource(); end
      
      if isempty(obj.CaseData), return; end;
      
      setID                           = obj.SetID;
      caseID                          = obj.CaseID;
      
      sheetIDs                        = [];
      sheetEntries                    = {};
      
      sheetsFile                      = obj.getCaseFile(obj.CaseData.ID, setID, 'Sheet'); % obj.getSourceFile(
      dataStruct                      = load(sheetsFile, 'Sheet');
      sheetsStats                     = dataStruct.Sheet;
      
      sheetIDs                        = 1:numel(sheetsStats);
      sheetEntries                    = cell(size(sheetIDs));
      
      caseData                        = obj.Data.CaseData; % getCaseData();
      
      if isequal(obj.ProcessSheetRegions, true)
        regionStats                   = struct();

        if isfield(setData, 'Regions')
          if processModes % ~isfield(setData.Regions, 'Modes');
            regionModes               = fieldnames(setData.Regions);
          else
            regionModes               = {'Full'};
          end

          for n = 1:numel(regionModes)
            if processModes, 
              regionSet               = setData.Regions.(regionModes{n});
            else
              regionSet               = setData.Regions;
            end
            
            regionIDs                 = fieldnames(regionSet);
            for p = 1:numel(regionIDs)
              if ~isfield(regionStats, regionIDs{p})
                regionEntry           = regionSet.(regionIDs{p});
                if isfield(regionEntry, 'Sheet')
                  regionStats.(regionIDs{p})  = reshape([regionEntry(:).Sheet], numel(regionEntry), []);
                else
                  regionStats.(regionIDs{p})  = regionEntry;
                end
              end
            end
          end

        end

        regionIDs                     = fieldnames(regionStats);
      end
      
      for m = sheetIDs
        sheetEntries{m}.ID            = m;
        sheetEntries{m}.Sequence      = caseData.Index.Sheets(m);
        sheetEntries{m}.Name          = num2str(sheetEntries{m}.Sequence, '#%d');    
        sheetEntries{m}.SetID         = setID;
        sheetEntries{m}.CaseID        = caseID;
        % sheetEntries{m}.RegionID  = 'Sheet';        
        sheetEntries{m}.Stats.Sheet   = sheetsStats(m);
        
        % Get Region Stats
        if isequal(obj.ProcessSheetRegions, true)
          for p = 1:numel(regionIDs)
            sheetEntries{m}.Stats.(regionIDs{p})  = regionStats.(regionIDs{p})(:, m);
            %if ~isfield(regionStats, regionIDs{p})
            %  regionEntry       = regionSet.(regionIDs{p});
            %  regionStats.(regionIDs{p})  = regionEntry;
            %end
          end
        end
        % sheetEntries{m}.Regions   = struct();
      end      
      
      if isempty(sheetIDs)
        sheetSet                = PrintUniformityBeta.Models.SheetSetModel();
      else
        sheetSet                = PrintUniformityBeta.Models.SheetSetModel(sheetIDs, sheetEntries);
      end
      
      try delete(obj.sheets);   end;
      try obj.sheets            = sheetSet; end

      % if isfield(setData, 'Sheets') && isobject(setData.Sheets)
      try delete(setData.Sheets);   end
      % end
      
      setData.Sheets            = sheetSet;
      
      obj.PatchSets(setData.Key)  = setData;
      
      return;
      
    end
    
    % function updateRegions(obj)
    %   updatingRegionSets         = true;
    %
    %   setID                     = obj.SetID;
    %   caseID                    = obj.CaseID;
    %   regionID                  = obj.RegionID;
    %
    %   try updatingRegionSets      = ...
    %       ~isa(obj.Data.SetData.(regionID), 'PrintUniformityBeta.Models.RegionSetsModel') || ...
    %       isempty(obj.Data.SetData.(regionID)); end
    %
    %   if ~updatingRegionSets, return; end;
    %
    %   regionIDs                 = [];
    %   regionEntries             = {};
    %
    %   regionsFile               = obj.getCaseFile(obj.CaseData.ID, setID, regionID); % obj.getSourceFile(
    %   dataStruct                = load(regionsFile, regionID);
    %   regionStats               = dataStruct.(regionID);
    %
    %   regionIDs                 = 1:numel(regionStats);
    %   regionEntries             = cell(size(regionIDs));
    %
    %   caseData                  = obj.getCaseData();
    %
    %   for m = regionIDs
    %     regionEntries{m}.ID        = m;
    %     % regionEntries{m}.Sequence  = caseData.Index.Sheets(m);
    %     % regionEntries{m}.Name      = num2str(regionEntries{m}.Sequence, '#%d');
    %     regionEntries{m}.SetID     = setID;
    %     regionEntries{m}.CaseID    = caseID;
    %     regionEntries{m}.RegionID  = regionID;
    %     regionEntries{m}.Stats     = regionStats(m);
    %   end
    %
    %   if isempty(regionIDs)
    %     regionModes                = PrintUniformityBeta.Models.RegionSetsModel();
    %   else
    %     regionModes                = PrintUniformityBeta.Models.RegionSetsModel(regionIDs, regionEntries);
    %   end
    %
    %   % try delete(obj.Data.SetData.Sheets); end
    %
    %   setData                   = obj.Data.SetData.DATA;
    %   setData.(regionID)        = regionModes;
    %
    %   patchSetKey               = sprintf('%s:%d', caseID, setID);
    %
    %   %obj.PatchSets.setPatchSet(caseID, setID, setData);
    %   obj.PatchSets(patchSetKey) = setData;
    %
    %   obj.Data.SetData          = obj.PatchSets.getPatchSet(caseID, setID);
    %
    %   % obj.PatchSets.setPatchSet(caseID, setID, setData);
    %
    %   % obj.Data.SetData.Sheets   = sheetSet;
    %
    %   return;
    % end
    
    function sourceFile = getCaseFile(obj, caseID, setID, regionID)
      
      sourceFile                = caseID;
      
      try
        try if isnumeric(setID), setID = int2str(setID); end; end
        
        sourceFile  = [sourceFile, '-', setID];
        
        try if ~isempty(regionID),  sourceFile  = [sourceFile, '-', regionID]; end; end
        
        sourceFile              = obj.getSourceFile(sourceFile);
      end      
    end
    
    function sourceFile = getSourceFile(obj, filename)
      sourceFile = fullfile(obj.sourcePath, filename);
    end
    
    
    function caseName = GetCaseName(obj, caseID)
      try if nargin<2, caseID   = obj.Parameters.CaseID; end; end
      
      caseName                  = '';
      
      try caseName              = obj.CaseData.Symbol;  end
      
      try
        if isempty(obj.CaseData.Name)
          pressName                 = '';
          try pressName             = obj.CaseData.Metadata.testrun.press.name; end
          
          runCode                   = '';
          try runCode               = obj.CaseData.ID; end
          try runCode               = sprintf('#%s', char(regexpi(runCode, '[0-9]{2}[a-z]?$', 'match'))); end
          
          caseName                  = '';
          try 
            caseName                = strtrim([pressName ' ' runCode]); 
            obj.CaseData.Name       = caseName;
          end
        else
          obj.CaseData.Name       = caseName;
        end
      end
    end
    
    function caseTag = GetCaseTag(obj, caseID)
      try if nargin<2, caseID   = obj.Parameters.CaseID; end; end
      
      caseTag                   = '';
      try caseTag               = obj.CaseData.Symbol;  end
      
    end
    
    function setName = GetSetName(obj, setID)
      try if nargin<2, setID    = obj.Parameters.SetID; end; end
      
      setName                   = '';
      try setName               = [int2str(setID) '%']; end
    end
    
    function sheetName  = GetSheetName(obj, sheetID)
      try if nargin<2, sheetID  = obj.Parameters.SheetID; end; end
      
      sheetName                 = '';
      
      if isequal(sheetID,0)
        sheetName               = 'Run';
      else
        try sheetName           = ['#' int2str(obj.CaseData.Index.Sheets(sheetID))]; end
      end
    end
    
    
    function sourcePath = get.SourcePath(obj)
      sourcePath              = obj.sourcePath;
    end
    
    function sourceMetadata = get.SourceMetadata(obj)
      sourceMetadata          = obj.sourceMetadata;
    end
    
    function cases = get.Cases(obj)
      cases                   = obj.cases;
    end
    
    function patchSets = get.PatchSets(obj)
      patchSets               = obj.patchSets;
    end
    
    function regionSets = get.RegionSets(obj)
      regionSets              = obj.regionSets;
    end
    
    function sheets = get.Sheets(obj)
      sheets                  = obj.sheets;
    end
    
    function regionMode = get.RegionMode(obj)
      regionMode              = obj.regionMode;
    end
    
    function set.RegionMode(obj, regionMode)
      if ~isequal(regionMode, obj.regionMode)
        obj.regionMode        = regionMode;
        
        setID                 = obj.SetID;
        
        obj.clearSetData(); % obj.Data.SetData      = [];
        
        obj.SetID             = setID;   % obj.getSetData();
      end
      
    end
    
    
    % function regionID = get.RegionID(obj)
    %   regionID                = obj.regionID;
    % end
    %
    % function caseIndex = get.CaseIndex(obj)
    %   caseIndex               = [];
    %   try caseIndex           = find(strcmp(obj.CaseID, obj.Cases.keys)); end
    % end
    %
    % function setIndex = get.SetIndex(obj)
    %   setIndex                = [];
    %   % try caseIndex           = find(strcmp(obj.SetID, obj.Cases.keys)); end
    % end
    
    
  end
  
  %% Getters / Setters Parameters CaseID, SetID, VariableID, SheetID
  methods
    
    
    
    function setCaseID(obj, caseID)
      
      if isempty(obj.Cases), obj.prepareCases(); end
      % obj.setCaseID@PrintUniformityBeta.Data.DataReader(caseID);
      
      obj.Parameters.CaseID     = caseID;

      try obj.Data.CaseData     = obj.getCaseData(caseID); end
      
      if isempty(obj.SetID)
        try obj.Data.SetData    = []; end
      else
        obj.setSetID(obj.SetID);
      end
      
    end
    
    function setSetID(obj, setID)
      % obj.setSetID@PrintUniformityBeta.Data.DataReader(setID);
      
      obj.Parameters.SetID      = setID;
      
      try obj.Data.SetData      = obj.getSetData(setID); end
      
      if isempty(obj.SheetID)
        try obj.Data.SheetData  = []; end
      else
        obj.setSheetID(obj.SheetID);
      end
      
    end
    
    function setSheetID(obj, sheetID)
      % obj.setSheetID@PrintUniformityBeta.Data.DataReader(sheetID);
      obj.Parameters.SheetID    = sheetID;
      
      try obj.Data.SheetData    = obj.getSheetData(sheetID); end
    end
  end  
  
  methods(Hidden)
    results = testPerformance(obj);
  end
  
  
  methods(Static, Hidden)
    function options  = DefaultOptions()
      options                   = [];
    end
  end
  
  methods(Static)
    % [ dataSource regions  ] = ProcessRegions(dataSource)
    [ dataSource          ] = ProcessDataMetrics(dataSource)
    % [ dataSource stats    ] = ProcessStatistics(dataSource, dataSet, regions)
    % [ strID               ] = GenerateCacheID(dataSource, dataSet, dataClass)
    
    function parameters = GetDataParameters()
      parameters            = {'CaseID', 'SetID', 'SheetID'}; % Variable ID
    end
    
  end
  
  
  
end



    
    % function [ setData ] = getSetData(obj, setID, caseID, regionMode) %, parameters)
    %   setData                   = obj.SetData;
    %
    %   if nargin<2, setID        = obj.SetID;    end
    %   if nargin<3, caseID       = obj.CaseID;   end
    %   if nargin<4, regionID     = obj.RegionMode; end
    %
    %   if (isempty(caseID) || ~ischar(caseID)) || ...
    %       (~isscalar(setID) && ~isnumeric(setID)) || ...
    %       (isempty(regionID) || ~ischar(regionID)), return; end
    %
    %   settingSetData            = ...
    %     isempty(setData) || ( ...
    %     ( isfield(setData, 'CaseID') &&  strcmpi(setData.CaseID, caseID)) && ...
    %     ( isfield(setData, 'ID') &&  strcmpi(setData.ID, setID)) ...
    %     );
    %
    %   if ~settingSetData, return; end
    %
    %   caseData                  = obj.getCaseData(caseID);
    %
    %   %% Setting Set Data
    %
    %   setData                   = obj.PatchSets.getPatchSet(caseID, setID);
    %   obj.SetData               = setData; % if nargin<2, obj.SetData  = setData; end
    %
    %   %% Clear Sheet Data
    %   obj.SheetData             = [];
    %
    %   obj.updateSheets();
    %
    %   % Get Sheet Data
    %   if nargout==0
    %     obj.getSheetData();
    %   else
    %     setData                 = obj.PatchSets.getPatchSet(caseID, setID);
    %   end
    % end
    
    % function [ caseData ] = getCaseData(obj, caseID) %, parameters)
    %   caseData                  = obj.CaseData;
    %
    %   if nargin<2, caseID       = obj.CaseID; end
    %   if (isempty(caseID) || ~ischar(caseID)), return; end
    %
    %   settingCaseData           = ...
    %     isempty(caseData) || ...
    %     ( isfield(caseData, 'ID') &&  strcmpi(caseData.ID, caseID)) || ...
    %     ( isfield(caseData, 'Symbol') &&  strcmpi(caseData.Symbol, caseID));
    %
    %   if ~settingCaseData, return; end
    %
    %   caseData                  = obj.cases(caseID);
    %
    %   obj.CaseData              = caseData; % if nargin<2, obj.CaseData = caseData; end
    %
    %   %% Update IDs
    %   longID                    = caseData.ID;
    %   regionIDs                 = obj.CaseData.Index.Regions;
    %   setIDs                    = obj.CaseData.Index.PatchSets;
    %
    %   try obj.regionIDs         = setdiff(unique(['Sheet'; regionIDs], 'Stable'), 'Run', 'Stable'); end
    %   try obj.setIDs            = sort(setIDs); end
    %
    %   dispf('\t%s:\t%s\n\t\tSetIDs: [%s]\n\t\tRegionIDs: {%s}', caseID, upper(longID),  toString(obj.setIDs), toString(obj.regionIDs{:}));
    %
    %   %% Clear Set & Sheet Data
    %   obj.SheetData             = [];
    %   obj.SetData               = [];
    %
    %   % Get Set Data
    %   if nargout==0, obj.getSetData(); end
    % end
