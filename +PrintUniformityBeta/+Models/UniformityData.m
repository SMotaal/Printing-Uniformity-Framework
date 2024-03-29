classdef UniformityData < GrasppeAlpha.Data.Models.DataModel
  %UNIFORMITYDATA Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Parameters
    DataReader
    CaseData
    SetData
    VariableData
    SheetData
  end
  
  properties (Hidden)
    ParametersClass = 'PrintUniformityBeta.Models.DataParameters'
    CaseDataClass   = 'PrintUniformityBeta.Models.CaseData'
    SetDataClass    = 'PrintUniformityBeta.Models.SetData'
  end
  
  methods
    function obj = UniformityData(varargin)
      obj = obj@GrasppeAlpha.Data.Models.DataModel(varargin{:});
                 
      if isempty(obj.Parameters)
        obj.resetParameters;
      else
        obj.resetCaseData;
      end
    end
    
    function resetParameters(obj)
      try delete(obj.Parameters); end
      obj.Parameters = eval(obj.ParametersClass); % ~Component
      obj.resetCaseData;
    end
    
    function resetCaseData(obj)
      try delete(obj.CaseData); end
      obj.CaseData      = [];
      obj.resetSetData;
    end
    
    function resetSetData(obj)
      try delete(obj.SetData); end
      obj.SetData       = [];
      obj.resetVariableData;
    end
    
    function resetVariableData(obj)
      obj.VariableData  = [];
      obj.resetSheetData;
    end    
    
    function resetSheetData(obj)
      obj.SheetData     = [];
    end
    
    function set.CaseData(obj, caseData)
      obj.CaseData  = obj.modelSet(obj.CaseData, caseData, obj.CaseDataClass);
    end
    
    function set.SetData(obj, setData)
      obj.SetData   = obj.modelSet(obj.SetData, setData, obj.SetDataClass);
    end
    
    function model = modelSet(obj, model, value, modelClass)
      oldModel  = model;
      if ~isa(model, modelClass) || ~isvalid(model)
        model   = eval(modelClass); % ~Component
      end
      if isa(value, modelClass)
        model.DATA = value.DATA;
        %return;
      else
        model.DATA = value;
      end
      try if ~isequal(model, oldModel)
          delete(oldModel); end; end
    end
    
  end
  
  methods (Access = protected)
    % Override copyElement method:
    function cpObj = copyElement(obj)
      % Make a shallow copy of all shallow properties
      cpObj = copyElement@GrasppeAlpha.Data.Models.DataModel(obj);
      
      % Make a deep copy of the deep object
      try cpObj.Parameters = copy(obj.Parameters); end
    end
  end
  
end

