classdef ReaderException < MException
  %READEREXCEPTION Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    CaseID
    SetID
    VariableID
    SheetID
  end
  
  methods(Access=private)
    function err = ReaderException(id, msg, cause, varargin)
      err = err@MException(['Grasppe:DataReader:' id], msg{:});
      
      if exist('cause', 'var') && isscalar(cause) && isa(cause, 'MException')
        err.addCause(cause);
      end
      
      try err.parseArguments(varargin{:}); end
    end
    
    function parseArguments(err, varargin)
      if numel(varargin)==1
        try err.CaseID        = varargin{1}.CaseID;       end
        try err.SetID         = varargin{1}.SetID;        end
        try err.VariableID    = varargin{1}.VariableID;   end
        try err.SheetID       = varargin{1}.SheetID;      end
      elseif numel(varargin)==1+4
        try err.CaseID        = varargin{1};              end
        try err.SetID         = varargin{2};              end
        try err.VariableID    = varargin{3};              end
        try err.SheetID       = varargin{4};              end
      end      
    end
  end
  
  methods(Static)
    function err = GenericError(cause, varargin)
      if exist('cause', 'var')~=1, cause = []; end
      msg = {'Data reader has failed due to some error.'};
      err = feval(eval(NS.CLASS), 'UnknownError', msg, cause, varargin{:});
    end
    
    function err = SheetRangeError(cause, sheetID, parameters)
      if exist('cause', 'var')~=1, cause = []; end
      msg = {'Data reader failed to load sheet %s', toString(sheetID)};
      err = feval(eval(NS.CLASS), 'SheetRangeError', msg, cause, parameters);
    end    
  end
  
end

