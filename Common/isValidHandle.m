function check = isValidHandle( object )
  %ISVALIDHANDLE   Validate handle and check size

  if isnumeric(object)
    check = isValid(object,'handle');
  elseif ischar(object)
    check = evalin('caller', ['isValid(''' object ''', ''handle'')']);
  end
end

