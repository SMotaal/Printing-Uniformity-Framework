function [ output_args ] = dbclear( input_args )
  %DBCLEAR Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent dbstate;
  
  warning('off');
  
  mlock
  dbstate = evalin('base', 'dbstatus(''-completenames'')');
  evalin('base', 'clear all;');
  try
    delete(findobj(findall(0),'type','figure'));
  end
  delete(timerfindall);
  assignin('base', 'dbstate', dbstate);
  evalin('base', 'dbstop(dbstate)');
  evalin('base', 'clear dbstate;');
  munlock;
  
  warning('on');
  
end

