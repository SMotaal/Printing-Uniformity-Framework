classdef GrasppeMetaProperty
  %GRASPPEMETAPROPERTY Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Name            % Interal property name, not necessarily displayed, used as a key to identify the property.
    DisplayName     % A short property name shown in the left column of the property grid.
    Description     % A concise description of the property, shown at the bottom of the property pane, below the grid.
    Type            % The Java type associated with the property, used to invoke the appropriate renderer or editor.
    EditorContext   % An editor context object. If set, both the type and the context are used to look up the renderer or editor to use. This lets, for instance, one flag value to display as a true/false label, while another as a checkbox.
    Category        % A string specifying the property?s category, for grouping purposes.
    Editable        % Specifies whether the property value is modifiable or read-only.
    DefiningClass   % Defining class;
    NativeMeta      % MatLab Meta Property;
  end
  
  methods
  end
  
  methods (Static)
    
    function properties = GetMeta(varargin)
      properties = MetaProperties(varargin{:});
    end
    
    function DefineMeta(Name, DefiningClass, Type, DisplayName, Category, Description, Editable, EditorContext, NativeMeta)
      metaProperty = GrasppeMetaProperty;
      
      metaProperty.Name           = Name;
      metaProperty.DefiningClass  = DefiningClass;
      metaProperty.Type           = Type;
      metaProperty.DisplayName    = DisplayName;
      metaProperty.Category       = Category;
      metaProperty.Description    = Description;
      metaProperty.Editable       = Editable;
      metaProperty.EditorContext  = EditorContext;
      metaProperty.NativeMeta     = NativeMeta;
      
      MetaProperties(metaProperty);
      
    end
    
    function properties = MetaProperties(varargin)
      persistent Properties;
      
      if nargout==0 && nargin>0 % Setting
        if nargin==1 && isa(varargin{1}, 'GrasppeMetaProperty')
          for i = 1:numel(varargin{1})
            property = varargin{1}(i);
            Properties.(property.DefiningClass).(property.Name) = property;
          end
        end
      end
      
      if nargout==1
        properties = Properties;
        
        if nargin==0
          return;
        end
        
        propertyName  = [];
        
        if nargin>0 && ischar(varargin{1})
          className     = varargin{1};
          
          nameArgs      = regexp(className, '[^\.]+', 'match');
          
          if numel(nameArgs)>1
            className     = nameArgs{1};
            propertyName  = nameArgs{2};
          end
        end
        
        if isempty(propertyName) && nargin>1 && ischar(varargin{2})
          propertyName  = varargin{2};
        end
        
        if ~isempty(className)
          if isempty(propertyName)
            properties = properties.(className);
          else
            properties = properties.(className).(propertyName);
          end
        end
        
      end
    end
  end
  
end

end

end

