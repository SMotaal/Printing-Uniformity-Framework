function [ g ] = listobj( input_args )
  %LISTOBJ Summary of this function goes here
  %   Detailed explanation goes here
  
  hAll=sort(findall(0));
  
  for i = 1:numel(hAll)
    h=hAll(i); p=get(h,{'Tag', 'Type', 'Parent', 'handle'}); 
    g(i,:) = {num2str(h,'% 3.0f'),p{:}};
  end
  g = cellfun(@(x)toString(x),g, 'UniformOutput', false);
  disp(g);
%     disp(sprintf('%s\t%s\t%s\t%s\t%s',  g{:})); %toString(g));
end

