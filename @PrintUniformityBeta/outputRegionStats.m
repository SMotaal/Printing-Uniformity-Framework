function outputRegionStats(tally)
  
  statsLabel  = 'Summary';  statGroups  = {'Run', 'Around', 'Across', 'Region', 'Sheet', 'Zone'};
  % statsLabel  = 'Sheets';   statGroups  = {'Run', 'Sheet'};
  % statsLabel  = 'Regions';  statGroups  =  {'Run', 'Around', 'Across', 'Region', 'Zone'};
  
  if nargin==0
    tally = load(fullfile('Output', 'tallyStats.mat'));
  end
  
  %% Prepare Output
  outputFolder                = fullfile('Output', ['Stats-' datestr(now, 'yymmdd')]);
  FS.mkDir(outputFolder);
  
  %   outputFolder            = fullfile('Output', 'Stats');
  
  for m = 1:size(tally.Stats, 1)
    
    caseID                = tally.Metadata.Cases.IDs{m};
    caseMetadata          = tally.Metadata.Cases.Metadata{m};
    
    caseFolder            = fullfile(outputFolder, caseID);
    masksFolder           = fullfile(caseFolder, 'Masks');
    
    caseMasks             = tally.Masks(m);
    caseFlip              = false; %tally.Metadata.CaseFlip(m);
    
    maskStruct            = struct();
    
    % %% Fix Orientation (HPs)
    % % Trail-Edge-Down / Operator-Side-Right
    %
    %
    % %% Flip Orientation
    % % Trail-Edge-Up / Operator-Side-Left
    
    %% Output Region Mask Images
    FS.mkDir(masksFolder);
    for p = 1:numel(caseMasks)
      
      maskGroups          = fieldnames(caseMasks);
      groupCount          = numel(maskGroups);
      
      % Sheet Mask
      mask                = squeeze(ones(size(caseMasks.region(1, :, :))));
      maskFilename        = 'sheet.png';
      maskPath            = fullfile(masksFolder, maskFilename);
      maskStruct.run      = struct( ...
        'ID', 'run', 'Path', maskPath, 'Filename', maskFilename, 'Image', mask);
      maskStruct.sheet    = struct( ...
        'ID', 'sheet', 'Path', maskPath, 'Filename', maskFilename, 'Image', mask);      
      
      [maskImage maskAlpha] = renderMask(mask);
      imwrite(maskImage, maskPath, 'png', 'Alpha', maskAlpha );
      
      % Regional Masks
      for q = 1:numel(maskGroups)
        maskGroup         = maskGroups{q};
        
        masks             = caseMasks.(maskGroup);
        maskCount         = size(masks, 1);
        
        for u = 1:maskCount
          maskID          = [caseID '-' maskGroup '-' int2str(u)];
          mask            = squeeze(masks(u, :, :)); %fliplr
                    
          maskFilename    = [maskID '.png'];
          maskPath        = fullfile(masksFolder, maskFilename);
          
          try
            maskStruct.(maskGroup)(u)         = struct( ...
              'ID', maskID, 'Path', maskPath, 'Filename', maskFilename, 'Image', mask);
          catch err
            debugStamp(err, 1);
            % beep;
            rethrow(err);
          end

          [maskImage maskAlpha] = renderMask(mask);
          imwrite(maskImage, maskPath, 'png', 'Alpha', maskAlpha );
        end
        
      end
    end
    
    caseSummaryTable      = {};
    
    sheetIndex            = tally.Metadata.Sheets.Index{m};
    
    %% Output Summaries
    for n = 1:size(tally.Stats, 2)
      
      setID               = tally.Metadata.Sets.IDs(n);
      
      setName             = tally.Metadata.Sets.Names{m, n};
      % setData             = tally.Metadata.SetData{m, n};
      % setStats            = tally.Metadata.SetStats{m, n};
      
      setFile             = [caseID '-' num2str(setID, '%03.0f')];
      
      setPath             = fullfile(caseFolder, setFile);
      
      stats               = tally.Stats(m, n);
      
      [row htmlRow]       = getSummaryRow(setFile);
      
      summaryTable        = row;
      
      htmlTable           = { ...
        '<html>'
        '<head>'
        '<meta charset="UTF-16" />'
        '<style>'
        '   body    {font-family: Sans-Serif; font-size: 12px;}'
        '   img     {height: 20px; border: #000 1px none;}'        
        '   th      {font-weight: normal; background-color: #000; color: #fff; text-align: center; white-space: nowrap; border: none;}'
        '   tr      {border-top: 1pt solid #ccc;}'        
        '   td      {min-width: 25px; font-size: smaller; text-align: center; white-space: nowrap; border: none;}'        
        '   td:nth-of-type(even)                        {background-color: #f6f6f6;} '
        '   tr:nth-of-type(odd)                         {background-color: #e6e6e6;} '
        '   tr:nth-of-type(odd)   td:nth-of-type(even)  {background-color: #d6d6d6;} '        
        '   tr:nth-of-type(odd)   td:nth-of-type(2)     {background-color: #e6e6e6;} '
        '   tr:nth-of-type(even)  td:nth-of-type(2)     {background-color: #ffffff;} '
        '   caption {font-family: Sans-Serif; font-size: 18px; font-weight: bold; padding: 5px;}'
        '   html *  {text-align: center; white-space: nowrap;}'
        '   table   {width: 100%; border-collapse: collapse; border: none;}'
        '</style></head>'
        '<body>'  %['<h1>' setName '</h1>']
        ['<table><caption>' setName '</caption>']
        ['<thead>' htmlRow '</thead>']
        '<tbody>' ...
        };
      
      for p = 1:numel(statGroups)
        
        statGroup         = statGroups{p};
        
        if ~isfield(stats, statGroup), continue; end
        
        groupStats        = stats.(statGroup);
        groupMasks        = [];
        
        groupFlip         = false;
        
        try
          switch(lower(statGroup))
            case {'region', 'regions'};
              groupMasks  = maskStruct.region;
              groupFlip   = caseFlip;
            case {'around', 'circumferential'};
              groupMasks  = maskStruct.around;
              groupFlip   = caseFlip;
            case {'across', 'axial'};
              groupMasks  = maskStruct.across;
              groupFlip   = caseFlip;
            otherwise
              groupMasks  = maskStruct.(lower(statGroup));
          end
        catch err
          debugStamp(err, 1);
        end
        

        
        
        for q = 1:numel(groupStats)
          
          try
            rowID                   = statGroup;
            
            if strcmpi(statGroup, 'sheet')
              rowNumber             = int2str(sheetIndex(q));
            else
              rowNumber             = int2str(q);
            end
            
            if numel(groupStats)> 1, rowID  = [rowID '-' rowNumber]; end
            
            maskPath                = '';
            
            try 
              if numel(groupMasks)>1
                maskPath          = fullfile('Masks', groupMasks(q).Filename);
              else
                maskPath          = fullfile('Masks', groupMasks.Filename);
              end
            end
            
            rowStats              = groupStats(q);
            
            %rowStats                = groupStats(q);
            
            [row htmlRow]           = getSummaryRow(rowID, rowStats, maskPath);
            
            htmlTable{end+1}        = htmlRow;
            
            summaryTable(end+1, :)  = row;
            
          catch err
            debugStamp(err, 1);
            % beep;
            rethrow(err);
          end
        end
        
      end
      
      htmlTable{end+1}              = '</tbody></table></body></html>';
      
      %       %% Run Summary
      %       runSummary          = getSummaryRow('Run', stats.Run);
      %
      %       %% Around Summary
      %       regionGroup         = 'Around';
      %       for p = 1:size(stats.Around)
      %         regionID          =
      %         regionSummary     = getSummaryRow(
      %       end
      %
      %cell2csv([setPath '-Summary.html'], htmlTable, '\n');
      
      fileID                        = fopen([setPath '-' statsLabel '.html'], 'w', 'n', 'UTF-8');
      fprintf(fileID, '%s\n', htmlTable{:});
      fclose(fileID);
      
      cell2csv([setPath '-' statsLabel '.csv'], summaryTable); %, '\');
      
      % if isempty(caseSummaryTable)
      %   caseSummaryTable            = summaryTable;
      % else
      caseSummaryTable              = [caseSummaryTable summaryTable];
      % end
      
    end
    
    cell2csv(fullfile(caseFolder,[caseID '-' statsLabel '.csv']), caseSummaryTable); %,
  end
end

function [row tr] = getSummaryRow(id, stat, maskPath)
  
%   headers           = { ...
%     'ID',                         'Mask',  ...
%     'Inaccuracy Score',           'Imprecision Score', ...
%     'Inaccuracy Proportion',...
%     'Imprecision Proportion', ...    
%     'Unevenness Factor',          'Unrepeatability Factor', ...    
%     'Mean',                       'Sigma', ...
%     'Reference',                  'Tolerance', ...
%     'Inaccuracy Value',           'Imprecision Value', ...
%     'Unevenness Value',           'Unrepeatability Value', ...
%     'Unevenness Samples',         'Unrepeatability Samples', ...
%     'Samples',                    'Outliers', ...    
%     'Size' };
%   
  headers           = { ...
    'ID',                         'Mask',  ...
    'Inaccuracy Score',           'Imprecision Score', ...
    'Inaccuracy Around',...
    'Imprecision Around', ...    
    'Unevenness',          'Unrepeatability', ...    
    'Mean',                       'Sigma', ...
    'Reference',                  'Tolerance', ...
    'Inaccuracy Value',           'Imprecision Value', ...
    'Unevenness Value',           'Unrepeatability Value', ...
    'Inaccuracy Rank',            'Imprecision Rank', ...
    'Unevenness Rank',            'Unrepeatability Rank', ...
    'Unevenness Samples',         'Unrepeatability Samples', ...    
    'Samples',                    'Outliers', ...    
    'Size' };

  symbols           = { ...
    '#',                          'idx',  ...
    'Inaccuracy.Score',           'Imprecision.Score', ...
    'Inaccuracy.Around',...
    'Imprecision.Around', ...    
    'Unevenness.Factor',          'Unrepeatability.Factor', ...    
    {'Mean.Symbol', 2},            {'Sigma.Symbol', 2}, ...
    'Reference.Symbol',           'Tolerance.Symbol', ...
    'Inaccuracy.Value',           'Imprecision.Value', ...
    'Unevenness.Value',           'Unrepeatability.Value', ...
    'Inaccuracy.Rank',            'Imprecision.Rank', ...    
    'Unevenness.Rank',            'Unrepeatability.Rank', ...
    'Unevenness.Samples',         'Unrepeatability.Samples', ...
    'Samples.Symbol',             'Outliers.Symbol', ...    
    'dim' };
  
  fields            = { ...
    'ID',                         'Mask', ... % Computed Fields
    'Inaccuracy.Score',           'Imprecision.Score', ...
    {'Proportions.Inaccuracy',    'Directionality.Inaccuracy.Around'}, ...
    {'Proportions.Imprecision',   'Directionality.Imprecision.Around'}, ...
    'Factors.Unevenness.Factor',  'Factors.Unrepeatability.Factor', ...
    'Mean',                       'Sigma', ...    
    'Inaccuracy.Reference',       'Imprecision.Tolerance', ...    
    'Inaccuracy.Value',           'Imprecision.Value', ...
    'Factors.Unevenness.Value',   'Factors.Unrepeatability.Value', ...    
    'Ranks.Inaccuracy',           'Ranks.Imprecision', ...
    'Ranks.Unevenness',           'Ranks.Unrepeatability', ...    
    'Factors.Unevenness.Samples', 'Factors.Unrepeatability.Samples', ...
    'Samples',                    'Outliers', ...
    'Size' };
  
  htmlFields        = [1:9 17:25];
  
  if nargin==0 || nargin==1
    
    row             = headers;
    
    if nargin==1, row{1} = id; end
    
    tr              = '<tr>';
    
    for f = htmlFields %1:numel(row)
      symbolID      = symbols{f};
      if ~iscell(symbolID), symbolID = {symbolID}; end
      htmlCode      = metricSymbol(symbolID{:});
      tr            = [tr '<th>' htmlCode '</th>'];
    end
    
    tr              = [tr '</tr>'];

    return;

  end
    
  row               = cell(1, numel(headers));
  row{1}            = id;
  
  row{2}            = maskPath;
  
  try row{end}      = regexprep(sprintf('%d x ', stat.Size), '\sx\s*$', ''); end
  
  
  tr                = '<tr>';
  tr                = [tr '<td>' row{1} '</td>'];  
  
  if ~isempty(row{2})
    tr              = [tr '<td><img src="' row{2} '" /></td>'];  
  else
    tr              = [tr '<td>&nbsp;</td>'];  
  end  

  %tr                = [tr '<td>' row{2} '</td>'];
  
  for f = 3:numel(headers)-1
    
    try % if isfield(s, headers{f})
      
      row{f}                = [];
      
      columnHead            = headers{f};
      columnField           = fields{f};
      
      columnValue           = [];
      
      if ischar(columnField), columnField = {columnField}; end;
      
      for g = 1:numel(columnField)
        try
          columnValue       = eval(['stat.' columnField{g}]);
          break;
        end
      end
      
      row{f}                = columnValue;
      
      if ~any(htmlFields==f), continue; end
      
      tr              = [tr '<td>'];
      
      if ischar(row{f})
        tr          = [tr row{f}];
      elseif isnumeric(row{f})
        if isequal(round(row{f}), row{f})
          tr        = [tr int2str(row{f})];
        else
          tr        = [tr num2str(row{f}, '%1.3f')];
        end
      else
        tr          = [tr toString(row{f})];
      end
      
      tr              = [tr '</td>'];
      
    catch err
      tr            = [tr '<td>&nbsp;</td>'];
    end
  end
  
  tr                = [tr '<td>' row{end} '</td>'];
  
  tr                = [tr '</tr>'];
  
  if nargout < 2, clear tr; end
  
end


function [maskImage maskAlpha] = renderMask(mask)
           
  maskGap                       = 8;
  padValue                      = 0;
  
  maskImage                     = fliplr(mask);
  maskImage                     = 1-maskImage;
  
  markLength                    = ceil(min(size(maskImage,2), size(maskImage,1)/3));
  
  maskImage                     = padarray(maskImage', 1, 0);
  maskImage                     = padarray(maskImage', 1, 0);
  
  maskLead                      = repmat(1, 1, maskGap) .* -1;
  
  maskImage                     = [repmat(maskLead', 1, size(maskImage,2)); maskImage];
  maskImage                     = [repmat(maskLead,  size(maskImage,1), 1), maskImage];
  
  maskImage(1:3, 1:markLength)  = padValue;
  maskImage(1:markLength, 1:3)  = padValue;
  
  % maskImage                     = rot90(maskImage,2);
  
  maskAlpha                     = 0+(maskImage~=-1);
  
  maskImage(maskImage==-1)      = 1;
end

function symbolCode = metricSymbol(symbolID, symbolCase)
  
  symbolCode                = symbolID;
  
  persistent symbolTable;
  
  try
  
  if isempty(symbolTable)
    symbolFile              = fullfile('.', 'resources', 'MetricsTable.txt');
    
    fileID                  = fopen(symbolFile,'r','n','UTF-8');
    symbolPage              = fscanf(fileID,'%c');
    fclose(fileID);
    
    symbolRows              = textscan(symbolPage,'%[^\n\r]');
    symbolRows              = cellfun(@(x)textscan(x,'%[^\t]'),symbolRows{1});
    
    rowCount                = size(symbolRows,1);
    
    symbolTable             = cell(rowCount, 3);
    
    for m=2:rowCount
      rowCells              = symbolRows{m};
      for n=1:numel(rowCells)
        symbolTable(m,n)    = rowCells(n);
      end
    end
    
  end
  
  catch err
    debugStamp(err);
  end

  
  symbolIndex               = find(strcmpi(symbolID, symbolTable(:,1)),1,'First');
  
  if isempty(symbolIndex), return; end
  
  symbolVarients            = reshape(symbolTable(symbolIndex,2:end),1,[]);
  
  if ~exist('symbolCase', 'var') || isempty(symbolCase), symbolCase = 1; end
  
  symbolCode                = symbolVarients{symbolCase};
  
  % disp({symbolID, symbolCase, symbolIndex, symbolCode})
  
  if isempty(symbolCode), symbolCode = symbolID; end
  
end
