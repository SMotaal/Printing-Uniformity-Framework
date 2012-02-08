function [ value ] = default( var, varargin) % , flag, space)
%DEFAULT Sets specified variable to a default value if not already defined

space = 'caller';

if evalin(space,['~exist(''' var ''', ''var'') || isempty(' var ')'])
  let('value', varargin{:});
  assignin(space, var, value);
end

end

