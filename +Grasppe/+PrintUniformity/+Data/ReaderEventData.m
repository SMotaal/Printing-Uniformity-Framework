classdef ReaderEventData < event.EventData
  %DATAREADEREVENT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties(SetAccess=immutable)
    Parameters
    Data
    OldParameters
    OldData
    CaseChange      = false;
    SetChange       = false;
    VariableChange  = false;
    SheetChange     = false;
  end
  
  properties (Dependent)
    CaseID
    SetID
    VariableID
    SheetID
  end
  
  properties
    Exception
  end
  
  methods
    function evt = ReaderEventData(parameters, data, oldParameters, oldData, ...
        sheetChange, variableChange, setChange, caseChange)
      try
        if exist('parameters',      'var'),	evt.Parameters      = copy(parameters);     end
        if exist('data',            'var'), evt.Data            = copy(data);           end
        if exist('oldParameters',   'var'), evt.OldParameters   = copy(oldParameters);  end
        if exist('oldData',         'var'), evt.OldData         = copy(oldData);        end
        if exist('sheetChange',     'var'), evt.SheetChange     = sheetChange;          end
        if exist('variableChange',  'var'), evt.VariableChange  = variableChange;       end
        if exist('setChange',       'var'), evt.SetChange       = setChange;            end
        if exist('caseChange',      'var'), evt.CaseChange      = caseChange;           end
      end
    end
    
    function caseID = get.CaseID(obj)
      caseID = '';
      if isstruct(obj.Parameters) && isfield(obj.Parameters, 'CaseID')
        caseID = obj.Parameters.CaseID;
      end
    end
    
    function setID = get.SetID(obj)
      setID = [];
      try setID = obj.Parameters.SetID; end
    end
    
    function variableID = get.VariableID(obj)
      variableID = '';
      try variableID = obj.Parameters.VariableID; end
    end
    
    function sheetID = get.SheetID(obj)
      sheetID = [];
      try sheetID = obj.Parameters.SheetID; end
    end    
  end
  
end

