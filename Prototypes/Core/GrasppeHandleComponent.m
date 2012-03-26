classdef GrasppeHandleComponent < GrasppeComponent
  %GRASPPEHANDLECOMPONENT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    HandleProperties
    ObjectPropertyMap   % Object-Handle Map
    HandlePropertyMap   % Handle-Object Map
    
    Handle
  end
  
  methods
    function obj = GrasppeHandleComponent
      obj = obj.GrasppeComponent();
    end
  end
  
  methods (Access=protected)
    function createComponent(obj, type, varargin)
      obj.createComponent@GrasppeComponent();
      obj.createHandlePropertyMap;
    end
    
    function attachHandleProperty(obj, propertyAlias, propertyName)
      
    end
    
    function createHandlePropertyMap(obj)
      
      if isempty(obj.HandlePropertyMap) || isempty(obj.ObjectPropertyMap)
        handlePropertyTable = obj.getRecursiveProperty('HandleProperties');

        handleProperties  = cell(size(handlePropertyTable)); 
        objectProperties  = handleProperties;

        for i = 1:numel(handlePropertyTable);
          property = handlePropertyTable{i};
          
          switch length(property)
            case 1
              % propertyAlias = property(1);
              % propertyName  = property(1);
              property(2) = property(1);
            case 2
          end
          
          objectProperties(end+1) = property(1);
          handleProperties(end+1) = property(2);
          
          obj.attachHandleProperty(property{:});
        end
        
        obj.ObjectPropertyMap = containers.Map(objectProperties, handleProperties);
        obj.HandlePropertyMap = containers.Map(handleProperties, objectProperties);
      end
    end
    
  end
  
  methods
    function h = get.Handle(obj)
      if isa(obj.Handle, 'handle') && isvalid(obj.Handle)
        
      end
    end
  end
    
  
  
  %% Property Update
  methods(Hidden)
    function objectPreSet(obj, source, event)
      return;
    end
    
    function objectPostSet(obj, source, event)
      propertyAlias = source.Name;
      propertyName  = obj.ObjectPropertyMap(propertyAlias);
      
      
      return;
    end
    
    function objectPostGet(obj, source, event)
      return;
    end
    
    function handlePreGet(obj, source, event)
      return;
    end
    
    function handlePreSet(obj, source, event)
      return;
    end
    
    function handlePostGet(obj, source, event)
      return;
    end
    
    function handlePostSet(obj, source, event)
      return;
    end
    
  end
    
  end
  
  
end

