classdef CaseSetModel < PrintUniformityBeta.Models.AbstractSetModel
  %CASESETMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Cases
  end
  
  methods
    function obj = CaseSetModel(varargin)
      
      invalidArguments      = false;
      
      if nargin==0
        options             = {'KeyType', 'char', 'ValueType', 'any'};
      elseif nargin==2
        options             = varargin;
        
        invalidArguments    = invalidArguments || ~iscellstr(varargin{1});
        invalidArguments    = invalidArguments || ~iscell(varargin{2});
        invalidArguments    = invalidArguments || ~isequal(size(varargin{1}), size(varargin{2}));
        
        setEntries          = varargin{2};
        
        for m = 1:numel(setEntries)
          if ~isa(setEntries{m}, 'PrintUniformityBeta.Models.CaseData')
            setEntries{m}   = PrintUniformityBeta.Models.CaseData(setEntries{m});
          end   
        end
        
      else
        invalidArguments    = true;
      end
      
      assert(~invalidArguments, 'Arguments to CaseSetModel constructor need to be a cellstr array with case names and equal sized cell array with the cases');
      
      obj                   = obj@PrintUniformityBeta.Models.AbstractSetModel(options{:});
    end
  end
  
end

