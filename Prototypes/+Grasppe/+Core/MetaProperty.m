classdef MetaProperty < GrasppePrototype
  %GRASPPEMETAPROPERTY Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Name            % Interal property name, not necessarily displayed, used as a key to identify the property.
    DisplayName     % A short property name shown in the left column of the property grid.
    Description     % A concise description of the property, shown at the bottom of the property pane, below the grid.
    %     Class           % The Java type associated with the property, used to invoke the appropriate renderer or editor.
    Mode            % Grasppe property type tag
    %     EditorContext   % An editor context object. If set, both the type and the context are used to look up the renderer or editor to use. This lets, for instance, one flag value to display as a true/false label, while another as a checkbox.
    Category        % A string specifying the property?s category, for grouping purposes.
    Editable        % Specifies whether the property value is modifiable or read-only.
    DefiningClass   % Defining class;
    NativeMeta      % MatLab Meta Property
    Grouping        % Group ID separating
  end
  
  properties (Dependent)
    Class
    EditorContext
  end
  
  methods
  end
  
  methods (Static)
    
    function properties = Get(grouping, varargin)
      properties = GrasppeMetaProperty.MetaPropertiesRecord(grouping, varargin{:});
    end
    
    function propertyMeta = Declare(name, definingClass, displayName, category, mode, description)
      
      nativeMeta    = metaProperty( definingClass, name );
      editable      = isequal(nativeMeta.SetAccess, 'public') && ~nativeMeta.Constant && ~nativeMeta.Abstract;
      
      propertyMeta  = GrasppeMetaProperty.Define( ...
        [], name, definingClass, mode, displayName, category, description, editable, nativeMeta);
      
    end
    
    function propertyMeta = CreateDuplicate(source, varargin)
      
      propertyMeta = GrasppeMetaProperty;
      
      fields = {'Grouping', 'Name', 'DefiningClass', ...
        'Mode', 'DisplayName', 'Category', 'Description', ...
        'Editable', 'NativeMeta'};
      
      [pairs paired args values ] = pairedArgs(varargin{:});
      
      for i = 1:numel(fields)
        field = fields{i};
        narg  = find(strcmpi(field, args));
        
        if narg > 0
          propertyMeta.(field)  = values{narg};
        else
          propertyMeta.(field)  = source.(field);
        end
      end
      
      GrasppeMetaProperty.MetaPropertiesRecord(propertyMeta.Grouping, propertyMeta);
    end
    
    function propertyMeta = Define(grouping, name, definingClass, mode, displayName, category, description, editable, nativeMeta)
      
      propertyMeta = GrasppeMetaProperty;
      
      propertyMeta.Grouping       = grouping;
      propertyMeta.Name           = name;
      propertyMeta.DefiningClass  = definingClass;
      propertyMeta.Mode           = mode;
      propertyMeta.DisplayName    = displayName;
      propertyMeta.Category       = category;
      propertyMeta.Description    = description;
      propertyMeta.Editable       = editable;
      propertyMeta.NativeMeta     = nativeMeta;
      
      GrasppeMetaProperty.MetaPropertiesRecord(propertyMeta.Grouping, propertyMeta);
      
    end
    
    
    function properties = MetaPropertiesRecord(mediatorID, varargin)
      persistent MetaProperties MediatorProperties;
      
      try
        
        if isempty(MetaProperties),     MetaProperties      = struct(); end
        if isempty(MediatorProperties), MediatorProperties  = struct(); end
        
        mediatorMode = false;
        try mediatorMode = ischar(mediatorID); end
        
        nargs = numel(varargin);
        
        if nargout==0 && nargs>0
          if nargs==1 && isa(varargin{1}, 'GrasppeMetaProperty')
            for i = 1:numel(varargin{1})
              property = varargin{1}(i);
              if mediatorMode
                MediatorProperties.(mediatorID).(property.Name) = property;
              else
                MetaProperties.(property.DefiningClass).(property.Name) = property;
              end
            end
          end
        end
        
        if nargout==1
          if mediatorMode
            properties = MediatorProperties;
          else
            properties = MetaProperties;
          end
          
          if nargs==0
            return;
          end
          
          propertyName  = [];
          
          if nargs>0 && ischar(varargin{1})
            groupName     = varargin{1};
            
            nameArgs      = regexp(groupName, '[^\.]+', 'match');
            
            if nargs==1 && numel(nameArgs)>1
              groupName     = nameArgs{1};
              propertyName  = nameArgs{2};
            elseif nargs>1 && ischar(varargin{2}) %isempty(propertyName) &&
              propertyName  = varargin{2};
            end
          end
          
          
          if ~isempty(groupName)
            if isempty(propertyName)
              if mediatorMode
                properties = MediatorProperties.(groupName);
              else
                properties = MetaProperties.(groupName);
              end
            else
              if mediatorMode
                properties = MediatorProperties.(groupName).(propertyName);
              else
                properties = MetaProperties.(groupName).(propertyName);
              end
            end
          end
          
        end
        
        return;
      catch err
        disp(err);
      end
      
    end
    
  end
end
