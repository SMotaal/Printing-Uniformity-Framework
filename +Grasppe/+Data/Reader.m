classdef Reader < Grasppe.Core.Component
  %READER Abstract Data Reader
  %   Detailed explanation goes here
  
  properties (GetAccess=public, SetAccess=protected)
    Data
    Parameters
  end
  
  methods
    function ResetDataModels(obj)
      obj.DeleteDataModels;
      obj.CreateDataModels;
    end
  end
  
  %% Grasppe Prototype Methods
  methods
    function obj = Reader(varargin)      
      obj = obj@Grasppe.Core.Component(varargin{:});
    end
    
%     function set.Parameters(obj, parameters) % Protected, called by setParamters only
%       if isempty(parameters) || isa(parameters, 'Grasppe.PrintUniformity.Models.DataParameters')
%         obj.Parameters = parameters;
%       end
%     end
    
  end
  
  methods (Access=protected)
    function createComponent(obj)
      obj.PrepareDataModels;
      obj.createComponent@Grasppe.Core.Component;
    end
    
    function CreateDataModel(obj, field, class, varargin)
      obj.DeleteDataModel(field);
      obj.PrepareDataModel(field, class, varargin{:});
    end
    
    function DeleteDataModel(obj, field, condition)
      if ~exist('condition', 'var') || condition
        if isobject(obj.(field)), delete(obj.(field)); end
        obj.(field) = [];
      end
    end
    
    function PrepareDataModel(obj, field, class, varargin)
      if ~isa(obj.(field), class) || isempty(obj.(field))
        obj.(field) = feval(class, varargin{:});
      end      
    end
    
    function ReplaceDataModel(obj, field, newModel)
      disp(field);
      
      obj.DeleteDataModel(field);
      obj.(field)   = newModel;
    end
    
    function PrepareDataModels(obj)
      if ~isstruct(obj.DataModels) || isempty(fieldnames(obj.DataModels)), return;  end
      modelFields = fieldnames(obj.DataModels);
      for m = 1:numel(modelFields)
        obj.PrepareDataModel(modelFields{m}, obj.DataModels.(modelFields{m}));
      end
    end
    
    function DeleteDataModels(obj)
      if ~isstruct(obj.DataModels) || isempty(fieldnames(obj.DataModels)), return;  end
      modelFields = fieldnames(obj.DataModels);
      for m = 1:numel(modelFields)
        obj.DeleteDataModel(modelFields{m});
      end      
      %if ~iscellstr(obj.DataModels) || size(obj.DataModels,1) < 1 || size(obj.DataModels, 2) < 2%       
%       for m = 1:size(obj.DataModels,1)
%         obj.DeleteDataModel(obj.DataModels{m,1});
%       end
    end
    
    function CreateDataModels(obj)
      if ~isstruct(obj.DataModels) || isempty(fieldnames(obj.DataModels)), return;  end
      modelFields = fieldnames(obj.DataModels);
      for m = 1:numel(modelFields)
        obj.CreateDataModel(modelFields{m}, obj.DataModels.(modelFields{m}));
      end      
%       if ~iscellstr(obj.DataModels) || size(obj.DataModels,1) < 1 || size(obj.DataModels, 2) < 2
%         return;
%       end
%       for m = 1:size(obj.DataModels,1)
%         obj.CreateDataModel(obj.DataModels{m,1}, obj.DataModels{m,2});
%       end
    end
    
  end  
  
end

