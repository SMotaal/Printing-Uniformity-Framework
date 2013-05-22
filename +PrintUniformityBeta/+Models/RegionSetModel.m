classdef RegionSetModel < PrintUniformityBeta.Models.AbstractSetModel
  %SHEETSETMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Regions
    RegionsMap
    CaseMap
  end
  
  methods
    function obj = RegionSetModel(varargin)
      
      invalidArguments      = false;
      
      if nargin==0
        options             = {'KeyType', 'char', 'ValueType', 'any'};
      elseif nargin==1
        options             = {}; % varargin;
        
        invalidArguments    = ~isstruct(varargin{1});
        
        % invalidArguments    = invalidArguments || (~iscellstr(varargin{1}) && ~isnumeric(varargin{1}));
        % invalidArguments    = invalidArguments || ~iscell(varargin{2});
        % invalidArguments    = invalidArguments || ~isequal(size(varargin{1}), size(varargin{2}));
      else
        invalidArguments    = true;
      end
      
      assert(~invalidArguments, 'Arguments to RegionSetModel constructor need to be a struct with Regions/Case subfields');
      
      if isempty(options)
        
        regionStruct        = varargin{1};
        
        regionModes         = fieldnames(regionStruct);
        regionNames         = {};
        regionEntries       = {};
        
        regionModeCount     = numel(regionModes);
        
        for m = 1:regionModeCount
          regionMode        = regionModes{m};
          caseEntries       = regionStruct.(regionMode);
          caseIDs           = fieldnames(caseEntries);
          caseCount         = numel(caseIDs);
          
          for n = 1:caseCount
            regionEntry     = caseEntries.(caseIDs{n});
            regionNames     = [regionNames,     regionEntry.Key];
            regionEntries   = [regionEntries,   regionEntry];
          end
        end
        
        options             = {regionNames, regionEntries};
      end
      
      obj                   = obj@PrintUniformityBeta.Models.AbstractSetModel(options{:});
    end
    
    function regionEntries = getRegionsByMode(obj, regionMode)
      regionKeys            = obj.keys;
      regionEntries         = obj.values;
      
      regionFilter          = cellfun(@isscalar, regexpi(regionKeys, [':' regionMode '$'], 'once'));
      
      regionEntries         = regionEntries(regionFilter);
    end
    
    function regionEntries = getRegionsByCase(obj, caseID)
      regionKeys            = obj.keys;
      regionEntries         = obj.values;
      
      regionFilter          = cellfun(@isscalar, regexpi(regionKeys, ['^' caseID ':'], 'once'));
      
      regionEntries         = regionEntries(regionFilter);
    end
    
    function caseIDs = getCaseIDs(obj, regionMode)
      regionKeys            = obj.keys;
      regionEntries         = obj.values;
      
      caseIDs               = regexpi(regionKeys, ['^[^:](?=:' regionMode ')$'], 'match', 'once');
    end
    
    function regionModes = getRegionModes(obj, caseID)
      regionKeys            = obj.keys;
      regionEntries         = obj.values;
      
      regionModes           = regexpi(regionKeys, ['(?<=^' caseID ':)(.*?)$'], 'match', 'once');   
    end
    
  end
  
end

