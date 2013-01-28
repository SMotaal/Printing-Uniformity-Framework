classdef DataParameters < GrasppeAlpha.Core.Model
  %UNIFORMITYSAMPLEDATAPARAMETERS Case, Set, Sample, Variable Details
  %   Detailed explanation goes here
  
  properties (GetObservable, SetObservable, Dependent, AbortSet)
    CaseID
    SetID
    VariableID
    SheetID
  end
  
  properties (SetAccess=protected, GetAccess=protected)
    caseID
    setID
    variableID
    sampleID
  end  
  
  methods    
    
    function obj = DataParameters(varargin)
      obj = obj@GrasppeAlpha.Core.Model(varargin);
    end
    
    function caseID = get.CaseID(model)
      caseID = model.caseID;
    end
    
    function set.CaseID(model, caseID)
      model.caseID = caseID;
    end
    
    function setID = get.SetID(model)
      setID = model.setID;
    end
    
    function set.SetID(model, setID)
      model.setID = setID;
    end
    
    function sheetID = get.SheetID(model)
      sheetID = model.sampleID;
    end
    
    function set.SheetID(model, sheetID)
      model.sampleID = sheetID;
    end
    
    function variableID = get.VariableID(model)
      variableID = model.variableID;
    end
    
    function set.VariableID(model, variableID)
      model.variableID = variableID;
    end
    
  end
  
end


%     function clear(model)
%       
%       fields = {'CaseID', 'SetID', 'SheetID', 'VariableID'}
%       
%       for i = 1:numel(fields)
%         try
%           model.(fields{i}) = model.findprop('CaseID').DefaultValue;
%         catch
%           model.(fields{i}) = [];
%         end
%       end
%       
%     end


%     function model = DataParameters(caseID, setID, sheetID, variableID)
%       model = model@GrasppeAlpha.Data.Models.DataParameters();
%       try model.CaseID      = caseID;     end
%       try model.SetID       = setID;      end
%       try model.SheetID     = sheetID;    end
%       try model.VariableID  = variableID; end
%     end
    
%     function model = duplicate(model, varargin)
%       
%       model = PrintUniformityBeta.Models.DataParameters( ...
%         'CaseID', model.CaseID,   'SetID', model.SetID, ... 
%         'SheetID', model.SheetID, 'VariableID', model.VariableID);
%       
%       [pargin ineven innames invalues] = pairedArgs(varargin{:});
%       for i = 1:pargin
%         model.(innames{i}) = invalues{i};
%       end
%       
%     end
    
%     function obj = DataParameters(varargin)
%       obj = obj@GrasppeAlpha.Data.Models.DataParameters(varargin{:});
%     end

