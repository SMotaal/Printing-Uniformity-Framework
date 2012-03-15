classdef DecoratedObject < GrasppeHandle
  %DECORATEDOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Decorators = {};
    DecoratorNames = {};
    Decorations
  end
  
  methods
    
    function decorate(obj, decorator)
      
      if ~(GrasppeDecorator.checkInheritence(decorator) && isvalid(decorator))
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
      
      obj.Decorators = {obj.Decorators{:}, decorator};
      obj.DecoratorNames = {obj.DecoratorNames{:}, decorator.ClassName};
      
    end
    
    function attachDecoratorProperty(obj, decorator, decoration)
      %% Attach a property by meta class
      componentProperties = obj.MetaClass.PropertyList;
      
      if ~stropt(decoration, {componentProperties.Name})
        obj.addprop(decoration);
      end
      
      metaProperty = obj.findprop(decoration);
      
      metaProperty.GetObservable = true;
      metaProperty.SetObservable = true;
      
      %       mb1.SetMethod = {@setView, ;
      
      addlistener(obj, decoration, 'PreGet', @GrasppeDecorator.GetDecoratorProperty);
      addlistener(obj, decoration, 'PreSet', @GrasppeDecorator.preSetDecoratorProperty);
      addlistener(obj, decoration, 'PostSet', @GrasppeDecorator.postSetDecoratorProperty);
      
      try
        defaultValue      = obj.Defaults.(decoration);
        %         obj.(decoration)  = defaultValue;
        set(obj.Handle, decoration, defaultValue);
        %         obj.handleSet(decoration, obj.(decoration));
        disp(sprintf('\t%s.%s(%s) = %s', obj.ID, decoration, class(defaultValue), toString(defaultValue)));
      end
      
      %       obj.(decoration) = obj.(decoration);
      
    end
    
    
    
    
  end
  
end

