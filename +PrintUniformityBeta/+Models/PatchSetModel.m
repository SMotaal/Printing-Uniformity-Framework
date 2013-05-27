classdef PatchSetModel < PrintUniformityBeta.Models.AbstractSetModel
  %SETMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  properties(Dependent)
    CaseIDs
    SetIDs
    PatchSets
  end
  
  properties % (SetAccess=protected)
    caseIDs
    setIDs
  end
  
  methods
    function obj = PatchSetModel(varargin)
      
      invalidArguments      = false;
      
      caseIDs               = {};
      setIDs                = [];
      
      if nargin==0
        options             = {'KeyType', 'char', 'ValueType', 'any'};
      elseif nargin==3
        options             = {}; % varargin;
        
        caseIDs             = varargin{1};
        setIDs              = varargin{2};
        setEntries          = varargin{3};
        
        invalidArguments    = invalidArguments || ~iscellstr(caseIDs);
        invalidArguments    = invalidArguments || ~ismatrix(setIDs);
        invalidArguments    = invalidArguments || ~iscell(setEntries);
        invalidArguments    = invalidArguments || ~isequal(numel(caseIDs), size(setEntries,1));
        invalidArguments    = invalidArguments || ~isequal(numel(setIDs), size(setEntries,2));
      else
        invalidArguments    = true;
      end
      
      assert(~invalidArguments, 'Arguments to PatchSetModel constructor need to be a cellstr array with case names, a matrix with patch tone values and equal sized cell array with the PatchSets');
      
      setEntries            = setEntries(:);
      
      if isempty(options)
        setNames            = cell(size(setEntries));
        
        for m = 1:numel(setEntries)
          caseID            = setEntries{m}.CaseID;
          setID             = setEntries{m}.ID;
          setNames{m}       = sprintf('%s:%d', caseID, setID);%obj.getPatchSetKey(, setEntries{m}.ID);
          
          if ~isa(setEntries{m}, 'PrintUniformityBeta.Models.SetData')
            setEntries{m}   = PrintUniformityBeta.Models.SetData(setEntries{m});
          end
          
        end
        
        options             = {setNames(:), setEntries(:)}; % varargin(3)];
      end
      
      obj                   = obj@PrintUniformityBeta.Models.AbstractSetModel(options{:});
      
      obj.caseIDs           = caseIDs;
      obj.setIDs            = setIDs;
    end
    
    function caseIDs = get.CaseIDs(obj)
      caseIDs               = obj.caseIDs;
    end
    
    function setIDs = get.SetIDs(obj)
      setIDs                = obj.setIDs;
    end
    
    function patchSets = get.PatchSets(obj)
      patchSets             = [];
      try patchSets         = cell2array(obj.values); end
    end
    
    function patchSetKey = getPatchSetKey(obj, caseID, setID)
      % patchSetKey           = sprintf('%s:%d', caseID, setID);
    end
    
    function patchSet = getPatchSet(obj, caseID, setID)
      
      patchSet              = [];
      
      try
        patchSetKey         = sprintf('%s:%d', caseID, setID); % obj.getPatchSetKey(caseID, setID);
        patchSet            = cell2array(values(obj, {patchSetKey})); %subsref(values(obj, {patchSetKey}),substruct('{}', {1})); %cell2mat(values(obj, {patchSetKey})); %eval(['obj(''' patchSetKey ''')']);
      catch err
        try
          if ~isempty(setID) && ~isempty(caseID)
            try debugStamp(err.message, 1); catch, debugStamp(); end; rethrow(err);
          end
        end
      end
      
      %       patchSets             = obj.PatchSets;
      %
      %       if isempty(patchSets), return; end;
      %
      %       if exist('caseID', 'var') && ~isempty(caseID)
      %         setFilter           = strcmp(caseID, {patchSets(:).CaseID});
      %       else
      %         setFilter           = true(size(patchSets));
      %       end
      %
      %       if exist('setID', 'var') && ~isempty(setID)
      %         setFilter           = setFilter & (setID==[patchSets(:).ID]);
      %       end
      %
      %       patchSet              = patchSets(setFilter);
      
    end
    
    function setPatchSet(obj, caseID, setID, patchSet)
      
      patchSetKey       = sprintf('%s:%d', caseID, setID); % obj.getPatchSetKey(caseID, setID);
      idx               = find(strcmpi(obj.keys, patchSetKey));
      try
        obj(patchSetKey)  = patchSet;
      catch err
        try debugStamp(err.message, 1); catch, debugStamp(); end; rethrow(err);
      end
      % obj.values{idx}   = patchSet;
      
    end
    
    
  end
  
end

