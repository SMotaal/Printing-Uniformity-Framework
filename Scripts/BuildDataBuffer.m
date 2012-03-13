function [ output_args ] = BuildDataBuffer( input_args )
  %TESTBUFFERING Summary of this function goes here
  warnState = warning ('off', 'backtrace');
  PersistentSources readwrite;
  PersistentSources clear;
  
  Data.dataSources('clear');
  Data.dataSources([], 'verbose', true, 'sizeLimit', 1024);
  
  SourceIDs   = {'rithp7k01','rithp5501','ritsm7402a','ritsm7402b','ritsm7402c'};
  PatchValues = [0 25 50 75 100]; %-1
  
  disp('Buffering Print Uniformity Data');
  fprintf(['SourceIDs:\t' toString(SourceIDs) '\n']);
  fprintf(['PatchValues:\t' toString(PatchValues) '\n']);
  
  rt = tic;
  for source = SourceIDs
    parfor p = 1:numel(PatchValues)
      
      patchValue = PatchValues(p);
      
      t = tic;
      [stats parser params] = Plots.plotUPStats(char(source),patchValue,'complete');
      et = toc(t);
      src = params.dataSourceName;
      rsrc = [src blanks(10-numel(src))];
      tv = params.dataPatchSet;
      dsrc = Data.dataSources;
      names = dsrc.names;
      rnames = strrep(names,'rit','');
      rnames = strrep(rnames,'sm','');
      rnames = strrep(rnames,'hp','');
      elements = dsrc.elements;
      megabytes = dsrc.megabytes;
      fprintf([ '\t' '%s' '\t' '% 4.0f' '\t' '%5.2f' '\t' '%2.0f' '\t' '% 7.2f' '' '\t' '%s' '\n'],rsrc, tv, et, elements, megabytes, rnames);
      
    end
  end
  toc(rt);
  disp('Saving PersistentSources Buffer');  
  PersistentSources force save;
  PersistentSources 'readonly';
  
  Data.dataSources('reset'); % [], 'verbose', 'reset', 'sizeLimit', 'reset');
  warning(warnState);
  
end

