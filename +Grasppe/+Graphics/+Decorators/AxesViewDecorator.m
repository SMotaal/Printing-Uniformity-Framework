classdef AxesViewDecorator < Grasppe.Core.Prototype & Grasppe.Core.PropertyDecorator
  %AXESVIEWDECORATOR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    DecoratingProperties = {'View'};
  end
  
  properties (SetObservable, GetObservable)
    View
  end
  
  methods
    function obj = AxesViewDecorator(varargin)
      obj = obj@Grasppe.Core.Prototype;
      obj@Grasppe.Core.PropertyDecorator(varargin{:});
    end
    
    %     function value = getView(obj)
    %     end
    %     function setView(obj, value)
    %       beep;
    %     end
    
    function set.View(obj, value)
      obj.View = value;
%       if obj.Component.HasParentFigure
%         try obj.Component.ParentFigure.StatusText.Text = toString(value); end
%       end
    end
  end
  
  methods(Static, Hidden)
    function OPTIONS  = DefaultOptions()
      Grasppe.Utilities.DeclareOptions;
    end
  end
  
  
end

