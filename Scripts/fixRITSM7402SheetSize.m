function [result] = fixRITSM7402SheetSize(runList)
  
  if ~isClass('runList','cellstr')
    clear runList
  end
  
  default runList {'ritsm7402a', 'ritsm7402b', 'ritsm7402c'};
  
  fField  = 'sourceTicket.testrun.substrate.sheetsize';
  fValue  = '482.6635.0';
  pValue  = {'19.00 in', '25.00 in'};

  fCheck  = @(x) all(strcmpi(eval(['x.' fField]), fValue));
%   fPatch  = @(x, v) eval(['x.' fField '=v']), x = x;

  for run = runList
    runName = char(run);
    
    try
      
      sourcePath = FS.dataDir('uniprint2',runName);
      sourcePath = strtrim(ls([sourcePath '.*']));
      [folder name ext] = fileparts(sourcePath);

      load(sourcePath);
      
      if (  ~isVerified([runName '.sourceTicket.revision'], 1) || ...
            ~isVerified([runName '.sourceTicket.standard'], 'S-MATIC-1') || ...
            ~isVerified([runName '.sourceTicket.subject'],  'Print Uniformity Research Data'));
        error('Grasppe:UniformPrinting:InvalidDataSignature', 'Could not verify the structure of the data and the revision.');
      end
      
      suf = ['.0' ext]; idx = 0;
      while (exist(fullfile(folder,['~' name suf]),'file')~=0)  % copyfile(sourcePath, fullfile(folder, ['~' name suf])))
        idx = idx+1;
        suf = ['.' int2str(idx) ext];
%         if idx > 10
%           error('Grasppe:Files:CreateBackup', 'Could not create backup due to copies limit or other error.');%           break;
%         end
      end
      
      copyfile(sourcePath, fullfile(folder, ['~' name suf]));
      
      eval([runName '.' fField '=pValue;']);
      
      eval([runName '.' fField]);
      
      save(sourcePath, runName);

    catch err
      disp(err);
    end

  end

end
