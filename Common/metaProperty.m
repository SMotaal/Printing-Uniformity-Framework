function [ propertyMeta ] = metaProperty( className, propertyName )
  %Return METAPROPERTY object associated with named property for the named class
  
  metaClass     = meta.class.fromName(className);
  properties    = {metaClass.PropertyList.Name};
  propertyIndex = find(strcmp(propertyName, properties));
  propertyMeta  = metaClass.PropertyList(propertyIndex);
end

