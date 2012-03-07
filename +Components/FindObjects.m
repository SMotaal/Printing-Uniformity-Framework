function [ handles ] = FindObjects(tag, type, parent, varargin)
  
  import Components.*;
  
  args = {}; handles = [];
  
  if (isValid('tag', 'char'))
    args = {args{:}, 'Tag', tag};
  end
  
  if (isValid('type', 'char'))
    args = {args{:}, 'Type', type};
  end
  
  if (~isempty(varargin))
    args = [args varargin];
  end
  
  try
    if (isValidHandle('parent'))
      handles = findobj(allchild(parent),args{:});
    else
      handles = findobj(findall(0), args{:});
    end
  end
  
end
