function [ output_args ] = runlog( text, command )
%RUNLOG Summary of this function goes here
%   Detailed explanation goes here

persistent logFile fid buffer;

default('logFile', '');
default('buffer', '');

if exists('command')
  if strcmpi(command, 'open') && ~isempty(text)
    logFile = text;
  elseif strcmpi(command, 'close') && ~isempty(logFile)
    logFile = '';
  end
else
  fprintf(text);
  if (~isempty(logFile))
    buffer = sprintf(backspace([buffer text]));
    if strfind(text,'\n')
      try
        fid = fopen(logFile, 'a');
        fprintf(fid, buffer);
        fclose(fid);
        clear buffer fid;
%       catch err
%         rethrow err;
      end
    end
  end
  
end
end

% function [result] = backspace(text)
% result = text;
% while (~isempty(strfind(result,'\b')))
%   i=strfind(result,'\b');
%   try
%     result = [result(1:i(1)-2) result(i(1)+2:end)];
%   end
% end
% end
