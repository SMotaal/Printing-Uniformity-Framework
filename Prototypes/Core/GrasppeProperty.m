classdef GrasppeProperty < GrasppePrototype
  %MEDIATEDPROPERTY Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    MetaProperty
    Value
    DefaultValue
    PreviousValue
    Revertable    = false;
    RedundantSet  = false;
  end
  
  properties (Dependent)
    Name            % Interal property name, not necessarily displayed, used as a key to identify the property.
    DisplayName     % A short property name shown in the left column of the property grid.
    Description     % A concise description of the property, shown at the bottom of the property pane, below the grid.
    Type            % The Java type associated with the property, used to invoke the appropriate renderer or editor.
    EditorContext   % An editor context object. If set, both the type and the context are used to look up the renderer or editor to use. This lets, for instance, one flag value to display as a true/false label, while another as a checkbox.
    Category        % A string specifying the property?s category, for grouping purposes.
    Editable        % Specifies whether the property value is modifiable or read-only.
  end
  
  methods
    function obj = GrasppeProperty (Component, Name, DisplayName, Description, Type, EditorContext, Category, Editable, Value)
      MetaClass   = meta.class.fromName(Component);
      NativeMeta = m.PropertyList(find(strcmp(Name, {m.PropertyList.Name})));
      obj = GrasppeMetaProperty.Define(Name, DefiningClass, Type, DisplayName, Category, Description, Editable, EditorContext, NativeMeta);
      obj.Value = Value;
    end
    
    function set.Value(obj, value)
      if obj.RedundantSet || ~isempty(obj.Value, value)
        if obj.Revertable
          obj.PreviousValue = obj.Value;
        else
          obj.PreviousValue = [];
        end;
        
        obj.Value = value;
      end
    end
  end
    
  methods % Meta Getters
    function value = get.Name(obj)
      value = obj.MetaProperty.Name
    end
    
    function value = get.DisplayName(obj)
      value = obj.MetaProperty.Name
    end
    
    function value = get.Description(obj)
      value = obj.MetaProperty.Name
    end
    
    function value = get.EditorContext(obj)
      value = obj.MetaProperty.Name
    end
    
    function value = get.Category(obj)
      value = obj.MetaProperty.Name
    end
    
    function value = get.Editable(obj)
      value = obj.MetaProperty.Name
    end
  end
  
  methods (Static)
    function obj = DefineByStruct(metaStruct, Component, Name, Alias, DisplayName, Description, Type, EditorContext, Category, Editable, Value, MetaProperty, MetaMediation)
      if ~isempty(metaStruct) && isstruct(metaStruct)
        [Component, Name, Alias, DisplayName, Description, Type, EditorContext, Category, Editable, Value, MetaProperty, MetaMediation] = deal([]);
        structVars(metaStruct);
      end
      obj = GrasppeProperty(Component, Name, Alias, DisplayName, Description, Type, EditorContext, Category, Editable, Value, MetaProperty, MetaMediation);
    end
  end
  
  
end

