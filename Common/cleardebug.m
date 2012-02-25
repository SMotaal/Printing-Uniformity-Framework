function [ output_args ] = dbclear( input_args )
  %DBCLEAR Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent dbstate;
  
  mlock
  dbstate = evalin('base', 'dbstatus(''-completenames'')');
  evalin('base', 'clear all;');
  assignin('base', 'dbstate', dbstate);
  evalin('base', 'dbstop(dbstate)');
  evalin('base', 'clear dbstate;');
  munlock;
  
end

