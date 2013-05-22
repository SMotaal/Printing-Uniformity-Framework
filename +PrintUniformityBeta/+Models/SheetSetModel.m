classdef SheetSetModel < PrintUniformityBeta.Models.AbstractSetModel
  %SHEETSETMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Sheets
  end
  
  methods
    function obj = SheetSetModel(varargin)
      
      invalidArguments      = false;
      
      if nargin==0
        options             = {'KeyType', 'char', 'ValueType', 'any'};
      elseif nargin==2
        options             = {}; % varargin;
        
        invalidArguments    = invalidArguments || (~iscellstr(varargin{1}) && ~isnumeric(varargin{1}));
        invalidArguments    = invalidArguments || ~iscell(varargin{2});
        invalidArguments    = invalidArguments || ~isequal(size(varargin{1}), size(varargin{2}));
      else
        invalidArguments    = true;
      end
      
      assert(~invalidArguments, 'Arguments to SheetSetModel constructor need to be a matrix with sheet numbers and equal sized cell array with the Sheets');
      
      if isempty(options)
        sheetEntries        = varargin{2};
        
        if isnumeric(varargin{1})
          sheetIDs          = num2cell(varargin{1});
          sheetNames        = cellfun(@(x) num2str(x, '#%d'), sheetIDs, 'UniformOutput', false);
        else
          sheetNames        = varargin{1};
        end
        
        options             = {sheetNames, sheetEntries};
      end
      
      obj                   = obj@PrintUniformityBeta.Models.AbstractSetModel(options{:});
    end
    
    function sheet = getSheet(obj, sheetKey)
      
      sheet                 = [];
      
      if isnumeric(sheetKey)     % Converting from serial number to sequential key
        idx                 = find(cellfun(@(x)isequal(x.Sequence, sheetKey), obj.values),1,'first');
        sheetKey            = obj.keys(idx);
      end
        
      try sheet             = cell2array(values(obj, {sheetKey})); end
      
      % patchSet              = [];
      %
      % try
      %   patchSetKey         = sprintf('%s:%d', caseID, setID); % obj.getPatchSetKey(caseID, setID);
      %   patchSet            = cell2array(values(obj, {patchSetKey})); %subsref(values(obj, {patchSetKey}),substruct('{}', {1})); %cell2mat(values(obj, {patchSetKey})); %eval(['obj(''' patchSetKey ''')']);
      % catch err
      %   try debugStamp(err.message, 1); catch, debugStamp(); end; rethrow(err);
      % end
    end    
    
  end
  
end

