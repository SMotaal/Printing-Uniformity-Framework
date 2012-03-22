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
    
    function attachMediatorProperty(obj, subject, property, alias)
      %% Determine mediator-alias for target property
      
      [validSubje] = deal(false);
      
      mediatorMeta  = [];
      nativeMeta    = [];
      
      subjectID   = subject.ID;
      mediatorID    = obj.ID;
      
      try
        % Get component metaproperty / value
        subjectMeta  = subject.MetaProperties.(property);
        subjectValue = subject.(property);
        validSubject = isa(subject.MetaProperties.(property), 'GrasppeMetaProperty');
                
        % Look for mediator metaproperty
        if ~exists('alias'), alias = [subjeID '_' subjectMeta.Name]; end
        nativeMeta  = metaProperty(obj.ClassName, alias);
        
        % Add mediator property if not found or amend components if found
        if isempty(nativeMeta)
          obj.addprop(alias);
          
          mediationMeta     = GrasppeMetaProperty.CreateDuplicate(subjectMeta, 'Grouping', mediatorID);
          
          mediatorProperty  = GrasppeMediatedProperty(subject, subjectMeta, mediationMeta);
          
          % Attach Mediator Listeners
          nativeMeta.GetObservable = true; ...
            nativeMeta.SetObservable = true;
          
          addlistener(obj,  property,   'PreGet',   @obj.mediatorPreGet);  ...  % Pull
            addlistener(obj,  property,   'PreSet',   @obj.mediatorPreSet);  ...
            addlistener(obj,  property,   'PostGet',  @obj.mediatorPostGet); ...
            addlistener(obj,  property,   'PostSet',  @obj.mediatorPostSet);   % Push
          
          obj.MediationProperties.(alias) = mediatorProperty;
          
        else
          error('Grasppe:Mediator:PredefinedPropertyAlias', 'Could not define the alias %s for the property %s since it is already defined.', alias, property);
        end
        
        % Attach Subject Listeners
        subjectMeta.GetObservable = true; ...
          subjectMeta.SetObservable = true;
        
        addlistener(subject,  property,   'PreGet',   @obj.subjectPreGet);  ...  % Pull
          addlistener(subject,  property,   'PreSet',   @obj.subjectPreSet);  ...
          addlistener(subject,  property,   'PostGet',  @obj.subjectPostGet); ...
          addlistener(subject,  property,   'PostSet',  @obj.subjectPostSet);   % Push
      catch err
        disp(err);
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
    
    function subjectPreGet(obj, source, event)
    end
    
    function subjectPreSet(obj, source, event)
    end
    
    function subjectPostGet(obj, source, event)
    end
    
    function subjectPostSet(obj, source, event)
    end
    
    function pullProperty(obj, alias)
    end
    
    function pushProperty(obj, alias)
    end
    
  end
end
  
