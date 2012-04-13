function [ output_args ] = cleardebug( input_args )
  %DBCLEAR Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent dbstate;
  
  warning('off');
  
  evalin('base', 'Grasppe.Core.Prototype.ClearPrototypes');
%   
%   evalin('base', 'clear');
  
  mlock;
  try
    if feature('IsDebugMode'), dbquit all; end
    dbstate = evalin('base', 'dbstatus(''-completenames'')');
    evalin('base', 'clear all;');
    evalin('base', 'clear classes;');
    evalin('base', 'delete(timerfindall());');  
    try delete(findobj(findall(0),'type','figure')); catch err, end
    delete(timerfindall);
    assignin('base', 'dbstate', dbstate);
    evalin('base', 'dbstop(dbstate)');
    evalin('base', 'clear dbstate;');
  end
  munlock;
  evalin('base', 'clear cleardebug');
  
  warning('on');
  
end

