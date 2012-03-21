classdef GrasppeMediatedProperty < GrasppePrototype & GrasppeProperty
  %MEDIATEDPROPERTY Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Component
    Mediator
    
    Alias
    
    MetaProperty
    MetaMediation
  end
  
  properties (Dependent)
  end
  
  methods
    function obj = GrasppeMediatedProperty (Component, Name, Alias, DisplayName, Description, Type, EditorContext, Category, Editable, Value, MetaProperty, MetaMediation)
      NativeMeta = MetaProperty;
      metaProperty = GrasppeMetaProperty.Define(Name, DefiningClass, Type, DisplayName, Category, Description, Editable, EditorContext, NativeMeta);
    end
  end
    
  methods (Static)
    function obj = DefineByStruct(metaStruct, Component, Name, Alias, DisplayName, Description, Type, EditorContext, Category, Editable, Value, MetaProperty, MetaMediation)
      if ~isempty(metaStruct) && isstruct(metaStruct)
        [Component, Name, Alias, DisplayName, Description, Type, EditorContext, Category, Editable, Value, MetaProperty, MetaMediation] = deal([]);
        structVars(metaStruct);
      end
      obj = GrasppeMediatedProperty(Component, Name, Alias, DisplayName, Description, Type, EditorContext, Category, Editable, Value, MetaProperty, MetaMediation);
    end
  end
  
end

