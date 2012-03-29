function [ handle ] = CreateHandleObject (type, tag, parent, varargin)
  
  type = lower(type);
  constructor = type;
  args = varargin;
  
  switch type
    case 'figure'
      args = [args, 'Visible', 'off'];
    case {'axes', 'colorbar', 'plot', 'patch', 'surface', 'surf', 'surfc'}
    case {'uitable'}
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
  elseif isempty(parent)
    parentArgs = find(strcmpi(args(1:2:end),'parent'));
    if ~isempty(parentArgs)
      args = args(setdiff(1:numel(args), [parentArgs*2 parentArgs*2-1]));
    end    
  end

  if validCheck('tag','char')
    args = [args, 'Tag', tag];
  end
  
  %dispf(['\n*** CreateHandleObject: ' constructor ' ==> ' toString(args{:}) '\n']);
  
%   switch type
%     case 'colorbar'
%       idx   = find(strcmp(args,'peer'));
%       peer  = args{idx+1};
%       args  = args([1:idx-1 idx+2:end]);
%       handle = colorbar('peer', peer);
%     otherwise
      handle = feval(constructor, args{:});
%   end
    
end


