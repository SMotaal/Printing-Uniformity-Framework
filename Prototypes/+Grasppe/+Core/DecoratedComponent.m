classdef DecoratedComponent < GrasppePrototype & GrasppeHandle
  %DECORATEDOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Decorators = {};
    DecoratorNames = {};
    Decorations
  end
  
  methods
    function obj = DecoratedObject()
      obj = obj@GrasppePrototype;
      obj = obj@GrasppeHandle;
      decorateComponent(obj);
    end
  end
  
  methods (Access=protected, Hidden)
    function decorateComponent(obj)
    end
  end
  
  methods
    function decorate(obj, decorator)
      
      if ~(DecoratedObject.checkInheritence(decorator) && isvalid(decorator))
        return;
      end
      
      decorators          = obj.Decorators;
      decoratorProperties = decorator.MetaClass.PropertyList;
      
      decorations         = decorator.ComponentDecorations;
      nDecorations        = length(decorations);
      
      try
        if stropt(decorator.ClassName, obj.DecoratorNames)
          return;
        end
      end
      
      for i = 1:nDecorations
        obj.attachDecoratorProperty(decorator, decorations{i});
        decorator.(decorations{i}) = obj.(decorations{i});
      end
      
      obj.Decorators      = {obj.Decorators{:}, decorator};
      obj.DecoratorNames  = {obj.DecoratorNames{:}, decorator.ClassName};
      
    end
    
    function attachDecoratorProperty(obj, decorator, decoration)
      %% Attach a property by meta class
      componentProperties = obj.MetaClass.PropertyList;
      
      if ~stropt(decoration, {componentProperties.Name})
        obj.addprop(decoration);
      end
      
      propertyMeta = obj.findprop(decoration);
      
      propertyMeta.GetObservable = true;
      propertyMeta.SetObservable = true;
      
      %       mb1.SetMethod = {@setView, ;
      
      addlistener(obj, decoration, 'PreGet', @GrasppeDecorator.GetDecoratorProperty);
      addlistener(obj, decoration, 'PreSet', @GrasppeDecorator.preSetDecoratorProperty);
      addlistener(obj, decoration, 'PostSet', @GrasppeDecorator.postSetDecoratorProperty);
      
      try
        defaultValue      = obj.Defaults.(decoration);
        %         obj.(decoration)  = defaultValue;
        if ishandle(obj.Handle)
          set(obj.Handle, decoration, defaultValue);
          disp(sprintf('\t%s.%s(%s) = %s', obj.ID, decoration, class(defaultValue), toString(defaultValue)));          
        end
        %         obj.handleSet(decoration, obj.(decoration));
      end
      
      %       obj.(decoration) = obj.(decoration);
      
    end
  end
  
end

