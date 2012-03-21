classdef GrasppeMetaProperty < GrasppePrototype
  %GRASPPEMETAPROPERTY Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Name            % Interal property name, not necessarily displayed, used as a key to identify the property.
    DisplayName     % A short property name shown in the left column of the property grid.
    Description     % A concise description of the property, shown at the bottom of the property pane, below the grid.
    Class            % The Java type associated with the property, used to invoke the appropriate renderer or editor.
    EditorContext   % An editor context object. If set, both the type and the context are used to look up the renderer or editor to use. This lets, for instance, one flag value to display as a true/false label, while another as a checkbox.
    Category        % A string specifying the property?s category, for grouping purposes.
    Editable        % Specifies whether the property value is modifiable or read-only.
    DefiningClass   % Defining class;
    NativeMeta      % MatLab Meta Property;
  end
  
  methods
  end
  
  methods (Static)
    
    function properties = Get(varargin)
      properties = MetaProperties(varargin{:});
    end
    
    function metaProperty = Declare(Name, DefiningClass, DisplayName, Category, Mode, Description)
      % DefiningClass = dbstack('-completenames');
      ClassMeta     = meta.class.fromName(DefiningClass);
      MetaIndex     = find( strcmp( Name, {ClassMeta.PropertyList.Name} ));
      NativeMeta    = ClassMeta.PropertyList(MetaIndex);
      Editable      = isequal(NativeMeta.SetAccess, 'public') && ...
        ~NativeMeta.Constant && ~NativeMeta.Abstract;
      
      switch lower(Mode)
       case {'string', 'char'}
         Class = 'char';
       case {'single', 'double', 'logical', ... 
           'int8', 'int16', 'int32', 'unit8', 'uint16', 'uint32', 'uint64'}
         Class = lower(Mode);
      end
      
      EditorContext = [];
      
      metaProperty  = GrasppeMetaProperty.Define( ...
        Name, DefiningClass, Class, DisplayName, Category, Description, ... 
        Editable, EditorContext, NativeMeta);
    end
    
    function metaProperty = Define(Name, DefiningClass, Class, DisplayName, Category, Description, Editable, EditorContext, NativeMeta)
      metaProperty = GrasppeMetaProperty;
      
      metaProperty.Name           = Name;
      metaProperty.DefiningClass  = DefiningClass;
      metaProperty.Class          = Class;
      metaProperty.DisplayName    = DisplayName;
      metaProperty.Category       = Category;
      metaProperty.Description    = Description;
      metaProperty.Editable       = Editable;
      metaProperty.EditorContext  = EditorContext;
      metaProperty.NativeMeta     = NativeMeta;
      
      GrasppeMetaProperty.MetaPropertiesRecord(metaProperty);
      
    end
    
    function properties = MetaPropertiesRecord(varargin)
      persistent Properties;
      
      if isempty(Properties), Properties = struct(); end
      
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
          
          if nargin==1 && numel(nameArgs)>1
            className     = nameArgs{1};
            propertyName  = nameArgs{2};
          elseif nargin>1 && ischar(varargin{2}) %isempty(propertyName) &&
            propertyName  = varargin{2};
          end
%         elseif nargin>0 && isa(varargin{1}, 'GrasppeMetaProperty')
%           metaProperty = varargin{1};
%           className     = metaProperty.DefiningClass;
%           propertyName  = metaProperty.Name;
        end
        
        
        if ~isempty(className)
          if isempty(propertyName)
            properties = Properties.(className);
          else
            properties = Properties.(className).(propertyName);
          end
        end
        
      end
      
      return;
    end
    
  end
  
end
