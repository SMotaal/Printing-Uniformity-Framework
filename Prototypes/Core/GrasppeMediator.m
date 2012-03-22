classdef GrasppeMediator < GrasppePrototype & GrasppeComponent
  %GRASPPEMEDIATOR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    MediationProperties
    Colleagues
    SettingProperty = '';
    GettingProperty = '';
  end
  
  methods
    function obj = GrasppeMediator()
      obj = obj@GrasppePrototype;
    end
    
    function attachMediatorProperty(obj, subject, property, alias)
      %% Determine mediator-alias for target property
      
      [validSubject]  = deal(false);
      
      mediatorMeta    = [];
      nativeMeta      = [];
      
      subjectID       = subject.ID;
      mediatorID      = obj.ID;
      
      try
        % Get component metaproperty / value
        subjectMeta   = subject.MetaProperties.(property);
        subjectValue  = subject.(property);
        validSubject  = isa(subject.MetaProperties.(property), 'GrasppeMetaProperty');
                
        % Look for mediator metaproperty
        if ~exists('alias'), alias = [subjectID '_' subjectMeta.Name]; end
        nativeMeta    = obj.findprop(alias); %metaProperty(obj.ClassName, alias);
        
        % Add mediator property if not found or amend components if found
        if isempty(nativeMeta)
          obj.addprop(alias);
          
          nativeMeta        = obj.findprop(alias);
          
          mediationMeta     = GrasppeMetaProperty.CreateDuplicate(subjectMeta, 'Grouping', mediatorID);
          
          mediatorProperty  = GrasppeMediatedProperty(obj, subject, subjectMeta, mediationMeta);
          
          % Attach Mediator Listeners
          
          nativeMeta.GetObservable = true; ...
            nativeMeta.SetObservable = true;
          
          addlistener(obj,  alias,   'PreGet',   @obj.mediatorPreGet);  ...  % Pull
            addlistener(obj,  alias,   'PreSet',   @obj.mediatorPreSet);  ...
            addlistener(obj,  alias,   'PostGet',  @obj.mediatorPostGet); ...
            addlistener(obj,  alias,   'PostSet',  @obj.mediatorPostSet);   % Push
          
          nativeMeta.AbortSet = true;
          
          nativeMeta.SetMethod = @mediationSet;
          
          obj.MediationProperties.(alias) = mediatorProperty;
          
        else
          error('Grasppe:Mediator:PredefinedPropertyAlias', 'Could not define the alias %s for the property %s since it is already defined.', alias, property);
        end
        
        % Attach Subject Listeners
%         subjectMeta.NativeMeta.GetObservable = true; ...
%           subjectMeta.NativeMeta.SetObservable = true; end
        
        addlistener(subject,  property,   'PreGet',   @obj.subjectPreGet);  ...  % Pull
          addlistener(subject,  property,   'PreSet',   @obj.subjectPreSet);  ...
          addlistener(subject,  property,   'PostGet',  @obj.subjectPostGet); ...
          addlistener(subject,  property,   'PostSet',  @obj.subjectPostSet);   % Push
      catch err
        disp(err.message);
        keyboard;
      end
      
    end
    
    function mediatorPreGet(obj, source, event)
      mediationID       = source.Name;
      
      mediationProperty = obj.MediationProperties.(mediationID);
      
      subjectName       = mediationProperty.SubjectMeta.Name;
      subjectValue      = mediationProperty.Subject.(subjectName);
      
      mediationProperty.Value = mediationProperty.Subject.(subjectName);
      
      obj.(mediationID) = mediationProperty.Value;

      return;
    end
    
    function mediatorPreSet(obj, source, event)
      if isempty(obj.SettingProperty)
        obj.SettingProperty = source.Name;
      else
        alreadySetting = {obj.SettingProperty, source.Name};
      end
      return;
    end
    
    function mediationSet(obj, value)
      mediationID = obj.SettingProperty;
      mediationProperty = obj.MediationProperties.(mediationID);
      try
        if ~isequal(mediationProperty, value)
          mediationProperty.Value = value;
        end
        if ~isequal(obj.(mediationID), value)
          obj.(mediationID) = value;
        end
      end
    end
    
    function mediatorPostSet(obj, source, event)
      obj.SettingProperty = '';
      return;
    end    
    
    function mediatorPostGet(obj, source, event)
      return;
    end
    
    function subjectPreGet(obj, source, event)
      return;
    end
    
    function subjectPreSet(obj, source, event)
      return;
    end
    
    function subjectPostGet(obj, source, event)
      return;
    end
    
    function subjectPostSet(obj, source, event)
      return;
    end
    
    function pullProperty(obj, alias)
      return;
    end
    
    function pushProperty(obj, alias)
      return;
    end
    
  end
end
  
