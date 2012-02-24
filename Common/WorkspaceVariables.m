function [ VariableStructure ] = WorkspaceVariables(Clear)
  %WORKSPACEVARIABLES structure containing workspace variables
  
  mpath = fileparts(mfilename);
  tempfile = fullfile(mpath,'~workspace.mat');
  
  evalin('caller', ['save(''' tempfile ''')']);
  
  if isVerified('Clear',true)
    evalin('caller', 'clear');
  end
  
  VariableStructure = load(tempfile);
  
  delete(tempfile);
  
end

