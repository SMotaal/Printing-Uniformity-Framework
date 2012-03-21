classdef GrasppeMediator < GrasppePrototype & GrasppeComponent
  %GRASPPEMEDIATOR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    MediationProperties
    Colleagues
  end
  
  methods
    function obj = GrasppeMediator()
      obj = obj@GrasppePrototype;
    end
    
    function attachMediatorProperty(obj, component, property, alias)
      %% Determine mediator-alias for target property
      if ~exists('alias'), alias = property;
        
        %% Attach a property by meta class
        mediatorProperties  = obj.MetaClass.PropertyList;
        componentProperties = component.MetaClass.PropertyList;
        
        if ~stropt(alias, {componentProperties.Name})
          error('Grasppe:Mediator:UndefinedComponentProperty', 'Could not find the property %s in the mediated component.', property);
        end
        
        if ~stropt(alias, {mediatorProperties.Name})
          obj.addprop(alias);
        else
          error('Grasppe:Mediator:PredefinedPropertyAlias', 'Could not define the alias %s for the property %s since it is already defined.', alias, property);
        end
                
        metaMediator.GetObservable = true;
        metaMediator.SetObservable = true;
        
        mediatedMeta      = GrasppeMetaProperty(class(component), property);
        mediatedProperty  = GrasppeProperty;
                
        mediatedProperty.Component      = component;
        mediatedProperty.Name           = property;
        mediatedProperty.DisplayName    = '';
        mediatedProperty.Description    = '';
        mediatedProperty.Type           = '';
        mediatedProperty.DisplayName    = '';
        mediatedProperty.EditorContext  = '';
        mediatedProperty.Category       = '';
        mediatedProperty.Editable       = '';
        mediatedProperty.Value          = component.(property);
        mediatedProperty.MetaComponent  = component.findprop(property);
        mediatedProperty.MetaMediator   = obj.findprop(alias);
        
        obj.MediationProperties.(alias) = mediatedProperty;
        
        mediatedProperty.MetaMediator.GetObservable = true;
        mediatedProperty.MetaMediator.SetObservable = true;
        
        addlistener(obj,        alias,      'PreGet',   @obj.mediatorPreGet);   ...   % Pull
          addlistener(obj,        alias,      'PreSet',   @obj.mediatorPreSet);   ...
          addlistener(obj,        alias,      'PostGet',  @obj.mediatorPostGet);  ...
          addlistener(obj,        alias,      'PostSet',  @obj.mediatorPostSet);   % Push
        
        
        mediatedProperty.MetaComponent.GetObservable = true;
        mediatedProperty.MetaComponent.SetObservable = true;
        
        addlistener(component,  property,   'PreGet',   @obj.componentPreGet);  ...  % Pull
          addlistener(component,  property,   'PreSet',   @obj.componentPreSet);  ...
          addlistener(component,  property,   'PostGet',  @obj.componentPostGet); ...
          addlistener(component,  property,   'PostSet',  @obj.componentPostSet);   % Push
        
        % try
        %   defaultValue      = obj.Defaults.(property);
        %   % obj.(decoration)  = defaultValue;
        %   if ishandle(obj.Handle)
        %     set(obj.Handle, decoration, defaultValue);
        %     disp(sprintf('\t%s.%s(%s) = %s', obj.ID, decoration, class(defaultValue), toString(defaultValue)));
        %   end
        % end
        
      end
      
    end
    
    function mediatorPreGet(obj, source, event)
    end
    
    function mediatorPreSet(obj, source, event)
    end
    
    function mediatorPostGet(obj, source, event)
    end
    
    function mediatorPostSet(obj, source, event)
    end
    
    function componentPreGet(obj, source, event)
    end
    
    function componentPreSet(obj, source, event)
    end
    
    function componentPostGet(obj, source, event)
    end
    
    function componentPostSet(obj, source, event)
    end
    
    function pullProperty(obj, alias)
    end
    
    function pushProperty(obj, alias)
    end
    
  end
  
