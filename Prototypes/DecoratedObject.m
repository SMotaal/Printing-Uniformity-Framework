classdef DecoratedObject < GrasppeHandle
  %DECORATEDOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Decorators
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
        if stropt(decorator.ClassName, {decorators(:).ClassName})
          return;
        end
      end
      
      for i = 1:nDecorations
        obj.attachDecoratorProperty(decorator, decorations{i});
        decorator.(decorations{i}) = obj.(decorations{i});
      end
      
      if isempty(decorators)
        obj.Decorators = decorator;
      else
        obj.Decorators(end+1) = decorator;
      end
      
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
      
      obj.(decoration) = obj.(decoration);
      
    end
    
    
    
    
  end
  
end

