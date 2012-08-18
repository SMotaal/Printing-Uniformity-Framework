classdef UniformityData < Grasppe.Data.Models.DataModel
  %UNIFORMITYDATA Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Parameters
    CaseData
    SetData
    SheetData
  end
  
  methods
    function obj = UniformityData(varargin)
      obj = obj@Grasppe.Data.Models.DataModel(varargin{:});
      
      obj.CaseData  = Grasppe.Data.Models.SimpleDataModel;
      obj.SetData   = Grasppe.Data.Models.SimpleDataModel;
      obj.SheetData = Grasppe.Data.Models.SimpleDataModel;
      
      if isempty(obj.Parameters)
        obj.Parameters = Grasppe.PrintUniformity.Models.DataParameters('Creator', obj);
      end
      
    end
    
%     function caseData = get.CaseData(obj)
%       if isempty(obj.CaseData)
%         obj.CaseData = Grasppe.Data.Models.SimpleDataModel;
%       end
%       caseData = obj.CaseData;
%     end
%     
%     function set.CaseData(obj, caseData)
%       data = obj.CaseData;
%       if ~isa(obj.CaseData, 'Grasppe.Data.Models.SimpleDataModel')
%       end
%         
%     end
%     
%     function setData = get.SetData(obj)
%       if isempty(obj.SetData)
%         obj.SetData = Grasppe.Data.Models.SimpleDataModel;
%       end
%       setData = obj.SetData;
%     end
%     
%     function sheetData = get.SheetData(obj)
%       if isempty(obj.CaseData)
%         obj.SheetData = Grasppe.Data.Models.SimpleDataModel;
%       end
%       sheetData = obj.SheetData;
%     end
  end
  
  methods (Access = protected)
    % Override copyElement method:
    function cpObj = copyElement(obj)
      % Make a shallow copy of all shallow properties
      cpObj = copyElement@Grasppe.Data.Models.DataModel(obj);
      
      % Make a deep copy of the deep object
      try cpObj.Parameters = copy(obj.Parameters); end
    end
  end
  
end

