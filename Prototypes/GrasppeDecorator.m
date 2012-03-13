classdef GrasppeDecorator < GrasppeHandle
  %HANDLEDECORATOR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Component;
    ComponentDecorations;
    DecorationProperties;
  end
  
  methods
    
    function obj = GrasppeDecorator(component)
      obj.Component = component;
      component.decorate(obj);
    end
    
    function decorations = get.ComponentDecorations(obj)
      decorations = obj.ComponentDecorations;
      if isempty(decorations) || ~iscell(decorations)
        decorations = {};
        try
          decorations = obj.DecoratingProperties;
        end
      end
    end
    
    function properties = get.DecorationProperties(obj)
      if ~isstruct(obj.DecorationProperties)
        obj.DecorationProperties = struct();
      end
      properties = obj.DecorationProperties;
    end
    
    function obj = set.DecorationProperties(obj, properties)
      if isstruct(properties)
        obj.DecorationProperties = properties;
      end
    end    
    
    function setDecoratorProperty(obj, source, event)
      
      propertyName  = source.Name;
      
      handleValue   = obj.Component.handleGet(propertyName);
      
      try currentValue  = obj.(propertyName);
      catch err, currentValue  = []; end
      
%       try componentValue  = obj.Component.(propertyName);
%       catch err, currentValue  = []; end      
      
%       if ~isequal(currentValue, handleValue) || ~isequal(handleValue, componentValue)
        obj.Component.handleSet(propertyName, currentValue); %obj.Component.(propertyName));
%       end     
      
      obj.DecorationProperties.(propertyName) = currentValue;
%       obj.(propertyName) = obj.DecorationProperties.(propertyName);

    end
    
    function getDecoratorProperty(obj, source, event)
      
      propertyName  = source.Name;
      
      handleValue   = obj.Component.handleGet(propertyName);
      
      try currentValue  = obj.DecorationProperties.(propertyName); 
      catch err, currentValue  = []; end
      
      if ~isequal(currentValue, handleValue)
        obj.DecorationProperties.(propertyName) = currentValue;        
        obj.Component.(propertyName) = handleValue;
      end
      
%       obj.setDecoratorProperty(source, event);
      
    end
  end
  
  methods(Static, Hidden)
%     function UpdateDecoratorProperty(source, event, decorator, dsource, devent, t)
%       toc(t);
%       stop(source); delete(source);    
%       decorator.setDecoratorProperty(dsource, devent);
%     end     
    function preSetDecoratorProperty(source, event)
      obj = event.AffectedObject;
    
      currentValue = obj.(source.Name);
      
      % try disp(['PreSet: ' source.Name ' = ' toString(currentValue)]); end
      
      if GrasppeDecorator.checkInheritence(obj) && isvalid(obj)
        for i = 1:numel(obj.Decorators)
          try
            decorator = obj.Decorators(i);
            decorator.(source.Name) = currentValue;
          end
        end
      end

    end
    
    function postSetDecoratorProperty(source, event)
      obj = event.AffectedObject;
    
      currentValue = obj.(source.Name);
      
      % try disp(['PostSet: ' source.Name ' = ' toString(currentValue)]); end
      
      if GrasppeDecorator.checkInheritence(obj) && isvalid(obj)
        for i = 1:numel(obj.Decorators)
          try
            decorator = obj.Decorators(i);
            decorator.setDecoratorProperty(source, event);
          end
        end
      end

      
    end    

    function GetDecoratorProperty(source, event)
      obj = event.AffectedObject;
      if GrasppeDecorator.checkInheritence(obj) && isvalid(obj)
        for i = 1:numel(obj.Decorators)
          try
            decorator = obj.Decorators(i);
            if stropt(source.Name, decorator.ComponentDecorations)
              decorator.getDecoratorProperty(source, event);
              return;
            end
          end
        end
      end
    end
    
  end
  
end

