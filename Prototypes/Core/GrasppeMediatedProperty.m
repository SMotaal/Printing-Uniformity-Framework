classdef GrasppeMediatedProperty < GrasppePrototype & GrasppeProperty
  %MEDIATEDPROPERTY Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Mediator
    MediatorMeta
    
    Subject
    SubjectMeta
    
    Subjects    = {};
  end
  
  properties (Dependent)
  end
  
  methods
    function obj = GrasppeMediatedProperty (component, propertyMeta, alias)
      obj = obj@GrasppePrototype();
      obj = obj@GrasppeProperty();
      
      obj.Subject     = component;
      obj.SubjectMeta = propertyMeta;
      
      if isa(alias,'GrasppeMetaProperty')
        obj.MediatorMeta  = alias;
      elseif isa(alias,'char')
        name              = propertyMeta.Name;
        displayName       = propertyMeta.DisplayName;
        category          = propertyMeta.Category;
        mode              = propertyMeta.Mode;
        description       = propertyMeta.Description;

        value             = component.(name);

        obj.MediatorMeta  = GrasppeMetaProperty.Declare( ...
          alias, class(obj), displayName, category, mode, description);
      else
        error('Grasppe:MediatedProperty:MissingMeta', 'Unable to construct a GrasppeMediatedProperty without a valid MediatorMeta.');
      end
    end
    
    function components = get.Subjects(obj)
      components = {{obj.Subject}, obj.Subjects{:}};
      %if isempty(obj.Components), components = obj.Component; end
    end
  end
  
%   methods (Static)
%     function obj = DefineByStruct(metaStruct, component, name, alias, displayName, description, type, editorContext, category, editable, value, metaProperty, metaMediation)
%       if ~isempty(metaStruct) && isstruct(metaStruct)
%         [component, ame, alias, displayName, description, type, editorContext, category, editable, value, metaProperty, metaMediation] = deal([]);
%         structVars(metaStruct);
%       end
%       obj = GrasppeMediatedProperty(component, ame, alias, displayName, description, type, editorContext, category, editable, value, metaProperty, metaMediation);
%     end
%   end
  
end

