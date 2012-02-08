function [ source ] = supStats( source, varargin )
  %SUPSTATS Summary of this function goes here
  %   Detailed explanation goes here
  
  
  parser = inputParser;
  
  %% Print Uniformity Data Source
  parser.addRequired('source', @(x) ischar(x) | isstruct(x));
  
  parser.parse(source, varargin{:});
  
  source = loadSource( source );
  
end


function [ source name ] = loadSource( source )
  if (ischar(source))
    
    if (exist(source, 'file')>0)
      source = source;
    else
      source = datadir('uniprint',source);
    end
    
    try
      contents = whos('-file', source);
    catch err
      error('UniPrint:Stats:Load:SourceNotFound', 'Source %s is not found.', source);
    end
    
    assert(isValid('source.sourceTicket.subject', 'Print Uniformity Research Data'), ...
      'UniPrint:Stats:InvalidSourceStructure', 'Source structure is invalid.');
    
    try
      name = contents.name;
      
    catch err
    end
    
    % %     assert( exist(source,'file')>0, ...
    % %       'UniPrint:Stats:Load:SourceNotFound', 'Source %s is not found.', source);
    %
    %     runName = whos('-file', supFilePath);
    %     runName = runName.name;
    %     stepTimer = tic; runlog(['Loading ' runName ' uniformity data ...']);
    %     supLoad(supFilePath); click roundActions;
    %     runlog(['\n', structTree(supMat.sourceTicket,2), '\n']);
    %     runlog([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
    %     newPatchValue = 100;
    %     clear source;
  end
  
  
end

