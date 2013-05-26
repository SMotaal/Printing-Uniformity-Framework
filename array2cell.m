function c = array2cell(a)
  try
    c                       = arrayfun(@(x)x, a, 'UniformOutput', false);
  catch err
    err.throwAsCaller;
  end
end
