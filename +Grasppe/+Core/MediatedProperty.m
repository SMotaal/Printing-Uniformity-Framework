classdef MediatedProperty < Grasppe.Core.Prototype & Grasppe.Core.Property
  %MEDIATEDPROPERTY Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
%     Mediator
    
    Subject
    SubjectMeta
    
    Subjects    = {};
  end
  
  properties (Dependent)
  end
  
  methods
    function obj = MediatedProperty(mediator, subject, propertyMeta, alias)
      obj = obj@Grasppe.Core.Prototype();
      obj = obj@Grasppe.Core.Property(mediator, [], []);
      
%       obj.Mediator    = mediator;
      
      obj.Subject     = subject;
      obj.SubjectMeta = propertyMeta;
      
      propertyName    = propertyMeta.Name;
      propertyValue   = subject.(propertyName);
      
      if isa(alias, 'Grasppe.Core.MetaProperty')
        obj.MetaProperty  = alias;
        
        obj.Value         = propertyValue;
        
      elseif isa(alias,'char')
        name              = propertyMeta.Name;
        displayName       = propertyMeta.DisplayName;
        category          = propertyMeta.Category;
        mode              = propertyMeta.Mode;
        description       = propertyMeta.Description;
        
        obj.MetaProperty  = Grasppe.Core.MetaProperty.Declare( ...
          alias, class(obj), displayName, category, mode, description);
        
        obj.Value         = propertyValue;
      else
        error('Grasppe:MediatedProperty:MissingMeta', 'Unable to construct a Grasppe.Core.MediatedProperty without a valid MediatorMeta.');
      end
    end
    
    function components = get.Subjects(obj)
      subject = {obj.Subject};
      components = {subject{:}, obj.Subjects{:}};
      %if isempty(obj.Components), components = obj.Component; end
    end
    
    function addSubject(obj, subject)
      subjects = obj.Subjects;
      for i = 1:numel(subjects)
        s = subjects{i};
        if isequal(s, subject), return; end
      end
      obj.Subjects = {subjects{:}, subject};
    end
    
    function [value changed] = newValue(obj, value, currentValue)
      [value changed] = obj.newValue@Grasppe.Core.Property(value, currentValue);
      if changed
        subject         = obj.Subject;
        propertyName    = obj.SubjectMeta.Name;
        obj.Subject.(propertyName) = value;
      end
    end

  end
    
end

