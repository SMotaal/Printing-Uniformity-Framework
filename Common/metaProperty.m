function [ propertyMeta ] = metaProperty( className, propertyName )
  %Return METAPROPERTY object associated with named property for the named class
  
  if ischar(className)
    metaClass   = meta.class.fromName(className);
  elseif isobject(className)
    metaClass   = metaclass(className);
  end
  propertyNames    = {metaClass.PropertyList.Name};
  propertyIndex = find(strcmp(propertyName, propertyNames));
  propertyMeta  = metaClass.PropertyList(propertyIndex);
end

