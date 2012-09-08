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
      
      s = warning('off', 'MATLAB:structOnObject');
      
      try if exist('parameters', 'var')
          evt.Parameters      = struct(parameters);     end; end
      try if exist('data',            'var')
          evt.Data            = struct(data);           end; end
      try if exist('oldParameters',   'var')
          evt.OldParameters   = struct(oldParameters);  end; end
      try if exist('oldData',         'var')
          evt.OldData         = struct(oldData);        end; end
      try if exist('sheetChange',     'var')
          evt.SheetChange     = sheetChange;            end; end
      try if exist('variableChange',  'var')
          evt.VariableChange  = variableChange;         end; end
      try if exist('setChange',       'var')
          evt.SetChange       = setChange;              end; end
      try if exist('caseChange',      'var')
          evt.CaseChange      = caseChange;             end; end
      
      warning(s);
    end
    
    function caseID = get.CaseID(evt)
      caseID = '';
      try caseID = evt.Parameters.CaseID; end      
      %if isstruct(evt.Parameters) && isfield(evt.Parameters, 'CaseID')end
    end
    
    function setID = get.SetID(evt)
      setID = [];
      try setID = evt.Parameters.SetID; end
    end
    
    function variableID = get.VariableID(evt)
      variableID = '';
      try variableID = evt.Parameters.VariableID; end
    end
    
    function sheetID = get.SheetID(evt)
      sheetID = [];
      try sheetID = evt.Parameters.SheetID; end
    end
    
    function display(evt)
      
      eventName       = evt.EventName;
      
      sheetChange     = isequal(evt.SheetChange,    true);
      variableChange  = isequal(evt.VariableChange, true);
      setChange       = isequal(evt.SetChange,      true);
      caseChange      = isequal(evt.CaseChange,     true);
      
      change = '';
      if caseChange,      change  = [change ' Case '];            end
      if setChange,       change  = [change ' Set '];             end
      if variableChange,  change  = [change ' Variable '];        end
      if sheetChange,     change  = [change ' Sheet '];           end
      try 
        if ~isempty(strtrim(change))
          change        = ['Change: ' regexprep(strtrim(change), '\s+' , ', ')]; 
        end
      end
      
      
      %% Old Parameters
      caseID = '';      setID = [];     variableID = '';      sheetID = [];
      oldCaseID = '';   oldSetID = [];  oldVariableID = '';   oldSheetID = [];
      sheetData = [];   err = []; errorMsg = '';
      
      try caseID        = evt.Parameters.CaseID;         end
      try setID         = evt.Parameters.SetID;          end
      try variableID    = evt.Parameters.VariableID;     end
      try sheetID       = evt.Parameters.SheetID;        end
      try oldCaseID     = evt.OldParameters.CaseID;      end
      try oldSetID      = evt.OldParameters.SetID;       end
      try oldVariableID = evt.OldParameters.VariableID;  end
      try oldSheetID    = evt.OldParameters.SheetID;     end
      %try sheetData     = evt.Data.SheetData;                 end
      try 
        err             = evt.Exception;                 
        errorMsg        = ['Error: ' err.message];
      end
      
      dispf('\n%s ReaderEvent %s %s',     eventName,      change, errorMsg);
      dispf('\tCase: %s>%s\tSet: %d>%d\tVariable: %s>%s\tSheet: %d>%d', ...
        oldCaseID, caseID, oldSetID, setID, ...
        oldVariableID, variableID, oldSheetID, sheetID);
      
%       dispf('\tCase:     \t%s\t > \t%s',    oldCaseID,      caseID);
%       dispf('\tSet:      \t%d\t > \d%s',    oldSetID,       setID);
%       dispf('\tVariable: \t%s\t > \t%s',    oldVariableID,  variableID);
%       dispf('\tSheet:    \d%s\t > \d%s\n',  oldSheetID,     sheetID);
      
      
      %       dispf('@%s\tCase: %s\tSet: %d\tVariable: %s\tSheet: %d/%d\tDataSize: %d x %d', ...
      %         eventName, ...
      %         caseID, setID, variableID, sheetID, ...
      %         oldSheetID, size(sheetData) ...
      %         );
      
    end
  end
  
  
  % function S = getStruct(obj)
  %   s = warning('off', 'MATLAB:structOnObject');
  %   S = struct(obj);
  %   warning(s);
  % end
  
  
end

