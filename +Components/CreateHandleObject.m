function [ handle ] = CreateHandleObject (type, tag, parent, varargin)
  
  type = lower(type);
  constructor = type;
  args = varargin;
  
  switch type
    case 'figure'
      args = [args, 'Visible', 'off'];
    case {'axes', 'plot', 'patch', 'surface', 'surf', 'surfc'}
    case {'text'}
    otherwise
      error('Grasppe:CreateHandleObject:UnsupportedGraphicsObject', ...
        'Could not create a handle object of type ''%s''.', type);
  end
  
  if isValidHandle('parent')
    parentArgs = find(strcmpi(args(1:2:end),'parent'));
    if ~isempty(parentArgs)
      args = args(setdiff(1:numel(args), [parentArgs*2 parentArgs*2-1]));
    end
    args = [args, 'Parent', parent];
  end

  if isValid('tag','char')
    args = [args, 'Tag', tag];
  end
  
  disp(['CreateHandleObject:' constructor ' ==> ' toString(args{:})]);
  
  handle = feval(constructor, args{:});
    
end


