function [ result ] = runlog( text, command )
%RUNLOG Summary of this function goes here
%   Detailed explanation goes here

persistent logFile buffer;

result = logFile;

if ~exists('command') && ~exists('text')
  return;
end

default('logFile', '');
default('buffer', '');

if exists('command')
  if strcmpi(command, 'new') && ~isempty(text)
    logFile = text;
    return;
  elseif strcmpi(command, 'clear') && ~isempty(text)
    logFile = text;
    try
      warning off MATLAB:DELETE:FileNotFound;
      delete(text);
    end
    return;
  elseif strcmpi(command, 'open') && ~isempty(text)
    if ~(strcmpi(logFile,text))
      runlog(text,'new');
    end
    return;
  elseif strcmpi(command, 'optional') && ~isempty(text)
    if (isempty(logFile))
      runlog(text,'new');
    end
    return;    
  elseif strcmpi(command, 'close') && ~isempty(logFile)
    logFile = '';
    return;
  end
end

if exists('text')
  fprintf(text);
  if (~isempty(logFile))
    buffer = backspace([buffer text]);
    if strfind(text,'\n')
      try
        fid = fopen(logFile, 'a');
        fprintf(fid, buffer);
        fclose(fid);
        clear buffer fid;
      catch err
        disp(err);
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
