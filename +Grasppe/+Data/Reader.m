classdef Reader < Grasppe.Core.Component
  %READER Abstract Data Reader
  %   Detailed explanation goes here
  
  properties (GetAccess=public, SetAccess=protected)
    Data
    Parameters
  end

  %% Abstract Data Reader Methods
  methods (Abstract)
    createDataModels(obj);
    deleteDataModels(obj);
  end
  
  %% Data Model Methods
  methods
    function resetDataModels(obj)
      obj.deleteDataModels;
      obj.createDataModels;
    end
  end
  
  
  %% Grasppe Prototype Methods
  methods (Access=protected)
    function createComponent(obj)
      obj.initializeDataModels;
      obj.createComponent@Grasppe.Core.Component;
    end
    
    function createDataModel(obj, field, class, varargin)
      if ~isa(obj.(field), class)
        obj.(field) = feval(class, varargin{:});
      end
    end
    
    function deleteDataModel(obj, field, condition)
      if ~exist('condition', 'var') || condition
        if isobject(obj.(field)), delete(obj.(field)); end
        obj.(field) = [];
      end
    end
  end  
  
end

