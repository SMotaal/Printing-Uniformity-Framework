function [ propertyMeta ] = metaProperty( className, propertyName )
  %Return METAPROPERTY object associated with named property for the named class
  
  if ischar(className)
    metaClass   = meta.class.fromName(className);
  elseif isobject(className)
    metaClass   = metaclass(className);
  end
  properties    = {metaClass.PropertyList.Name};
  propertyIndex = find(strcmp(propertyName, properties));
  propertyMeta  = metaClass.PropertyList(propertyIndex);
end

