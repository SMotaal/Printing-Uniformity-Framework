function exportVideos( forced, sources, fValues, fViews, fSets )
  %EXPORTVIDEOS Summary of this function goes here
  %   Detailed explanation goes here
  
  default forced false;
  default sources '';
  default fValues [100 75 50 25 0];
  default fViews [1 2];
  default fSets '';
  
  cleanupFcn = onCleanup(@cleanUp);
  
  DS.PersistentSources('load', 'UniPrintAlpha');
  DS.PersistentSources('readonly');
  
  if isempty(sources)
    sources = {'ritsm7402a', 'ritsm7402b', 'ritsm7402c', 'rithp7k01', 'rithp5501'};
  end
  
  if isempty(fSets)
    fSets = {'u2','u3','u4','u'};
  end
  
  allData = Alpha.InterpData(forced);
  
  exportingPath = fullfile(cd, 'output',['supVideo-' datestr(now, 'yymmdd')]);
  
  for source = sources
    sourceName  = char(source);
    sourceData  = allData.(sourceName);
    
    nValues = numel(fValues);
    nSets   = numel(fSets);
    nViews  = numel(fViews);
    
    nRends  = nValues * nSets * nViews;
    sRends  = [numel(fValues), numel(fSets), numel(fViews)];
    
    % sub2ind([numel(fValues), numel(fSets), numel(fViews)])
    
    parfor i = 1:nRends
      
      [p, f, v] = ind2sub(sRends, i);
      
      fValue  = fValues(p);
      fSet    = fSets{f};
      fView   = v;
      
      setID = ['DataSetTV' int2str(fValue)];
      
      SourceData = sourceData;
      SourceSet  = SourceData.(setID);
      
      VideoSourceData = struct(...
        'CMS',      SourceData.CMS,       'Data',     SourceData.Data', ...
        'Filename', SourceData.Filename,  'FilePath', SourceData.FilePath', ...
        'PlotData', SourceSet.PlotData,   'Sample',   SourceSet.Sample, ...
        'Sheet',    1);
      
      exportingName = lower([sourceName '-' upper(fSet) '-' int2str(fView) '-' int2str(fValue)]);
      exportingFile = fullfile(exportingPath, exportingName);
      
      if exist(exportingPath, 'dir') == 0
        mkdir(exportingPath);
      end
      
      Alpha.supVideo(VideoSourceData, fView,  exportingFile, fSet);
      
      %         end
      %       end
      %     end
      
    end
    
  end
  
  
end

function cleanUp()
  disp('Cleanup!');
  UI.setStatus();
end
