function [ result ] = encodeMov( varargin )
%ENCODEMOV Converts Video to MOV using AppleScript

if ischar(varargin)
  avilist = {varargin};
end

if iscellstr(varargin)
  avilist = '';
  for arg = varargin
    
    arg = strtrim(char(arg));
    
    pathItems = regexpi(arg,'(?<=[/|]?)([^/:]*)(?=[/:]?)', 'match');
    pathstr = '';
    for item = pathItems
      pathstr = strcat(pathstr, char(item), ':');
    end
    
    pathstr = pathstr(1:end-1);
    
    %     avilist = strcat(avilist, ', "', pathstr, '"');
    avilist = strcat(avilist, ' "', pathstr, '"');
  end
  %   avilist = ['{' avilist(3:end) '}'];
end

avilist = strtrim(avilist);

[pathstr, name, ext] = fileparts(mfilename('fullpath'));

scriptpath = fullfile(pathstr, 'EncodeMov.scpt');

command = ['osascript ' scriptpath ' ' avilist];

result = system(command);

end

