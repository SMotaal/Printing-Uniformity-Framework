function outputRegionStats(tally)
  outputFolder            = fullfile('Output', 'Stats');
  
  statGroups              = {'Run', 'Around', 'Across', 'Region', 'Sheet', 'Zone'};
  
  if nargin==0
    tally = load(fullfile('Output', 'tallyStats.mat'));
  end
  
  for m = 1:size(tally.Stats, 1)
    
    caseID                = tally.Metadata.CaseIDs{m};
    caseMetadata          = tally.Metadata.CaseMetadata{m};
    
    caseFolder            = fullfile(outputFolder, caseID);
    masksFolder           = fullfile(caseFolder, 'Masks');
    
    caseMasks             = tally.Masks(m);
    caseFlip              = tally.Metadata.CaseFlip(m);
    
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
      
      for q = 1:numel(maskGroups)
        maskGroup         = maskGroups{q};
        
        masks             = caseMasks.(maskGroup);
        maskCount         = size(masks, 1);
        
        for u = 1:maskCount
          maskID          = [caseID '-' maskGroup '-' int2str(u)];
          mask            = squeeze(masks(u, :, :)); %fliplr
          
          maskImage       = fliplr(mask);
          
          maskFilename    = [maskID '.png'];
          maskPath        = fullfile(masksFolder, maskFilename);
          
          try
            
            % maskStruct.(maskGroup).Masks     = caseMasks.(maskGroup);
            maskStruct.(maskGroup)(u)         = struct( ...
              'ID', maskID, 'Path', maskPath, ...
              'Filename', maskFilename, 'Image', mask ...
              );
            
            %             maskStruct.(maskGroup).ID(u)      = maskID;
            %             maskStruct.(maskGroup).Path(u)    = maskPath;
            %             maskStruct.(maskGroup).Filename   = maskFilename;
            %             maskStruct.(maskGroup).Image(u)   = mask;
            
          catch err
            debugStamp(err, 1);
            % beep;
            rethrow(err);
          end
          
          % maskImage(maskImage==0) = 0;
          maskImage = 1-maskImage;
          
          maskGap   = 8;          
          
          padValue  = 0;
          
          markLength = ceil(min(size(maskImage,2), size(maskImage,1)/3));
          
          maskImage = padarray(maskImage', 1, 0);
          maskImage = padarray(maskImage', 1, 0);
          
          maskLead  = repmat(1, 1, maskGap) .* 1;
          
          maskImage = [repmat(maskLead', 1, size(maskImage,2)); maskImage];
          
          maskImage = [repmat(maskLead,  size(maskImage,1), 1), maskImage];
          
          maskImage(1:3, 1:markLength) = padValue;
          maskImage(1:markLength, 1:3) = padValue;
          
          maskImage = rot90(maskImage,2);
          
          maskAlpha = 0+(maskImage~=1);
          
          imwrite(maskImage, maskPath, 'png', 'Alpha', maskAlpha);
        end
        
      end
    end
    
    %% Output Summaries
    for n = 1:size(tally.Stats, 2)
      
      setID               = tally.Metadata.SetIDs(n);
      
      setName             = tally.Metadata.SetNames{m, n};
      % setData             = tally.Metadata.SetData{m, n};
      % setStats            = tally.Metadata.SetStats{m, n};
      
      setFile             = [caseID '-' num2str(setID, '%03.0f')];
      
      setPath             = fullfile(caseFolder, setFile);
      
      stats               = tally.Stats(m, n);
      
      [row htmlRow]       = getSummaryRow(setFile);
      
      summaryTable        = row;
      
      htmlTable           = { ...
        '<html>'
        '<head><style>'
        '   body    {font-family: Sans-Serif; font-size: 12px;}'
        '   img     {height: 20px; border: #000 1px none;}'        
        '   th      {background-color: #000; color: #fff; text-align: center; white-space: nowrap; border: none;}'
        '   td      {min-width: 100px; text-align: center; white-space: nowrap; border: none;}'        
        '   td:nth-of-type(odd)  {background-color: #eee;} '
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
            
            if numel(groupStats)> 1, rowID  = [rowID '-' int2str(q)]; end
            
            maskPath                = '';
            
            try maskPath            = fullfile('Masks', groupMasks(q).Filename); end
            
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
      cell2csv([setPath '-Summary.html'], htmlTable, '\n');      
      cell2csv([setPath '-Summary.csv'], summaryTable); %, '\');
      
    end
  end
end

function [row tr] = getSummaryRow(id, stat, maskPath)
  
  headers           = {'ID', 'Mask',  ...
    'Accuracy', 'Precision', 'Evenness', 'Repeatability', ...
    'Samples', 'Outliers',  ...
    'Mean', 'Sigma', 'EvennessN', 'RepeatabilityN', 'Size', ... % 'Norm', 
    };
  
  if nargin==0 || nargin==1
    
    row             = headers;
    
    if nargin==1, row{1} = id; end
    
    tr              = '<tr>';
    
    for f = 1:numel(row)
      tr            = [tr '<th>' row{f} '</th>'];
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
    tr              = [tr '<td>'];
    
    try % if isfield(s, headers{f})
      row{f}        = stat.(headers{f});
      
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
    catch err
      tr            = [tr '&nbsp;'];
    end
    tr              = [tr '</td>'];
  end
  
  tr                = [tr '<td>' row{end} '</td>'];
  
  tr                = [tr '</tr>'];
  
  if nargout < 2, clear tr; end
  
end
