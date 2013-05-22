function a = cell2array(c)
  try
    a                       = [c{:}];
  catch err
    err.throwAsCaller;
  end
end
