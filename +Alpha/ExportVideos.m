function [ output_args ] = ExportVideos( forced, sources, patchvalues, views, sets )
  %EXPORTVIDEOS Summary of this function goes here
  %   Detailed explanation goes here
  
  default forced false;
  default sources '';
  default patchvalues [100 75 50 25 0];
  default views [1 2];
  default sets '';
  
  if isempty(sources)
    sources = {'ritsm7402a', 'ritsm7402b', 'ritsm7402c', 'rithp7k01', 'rithp5501'};
  end
  
  if isempty(sets)
    sets = {'u2','u3','u4','u'};
  end
  
  allData = Alpha.InterpData(forced);
  
  exportingPath = fullfile(cd, 'output',['supVideo-' datestr(now, 'yymmdd')]);
  
  
  
  for source = sources
    sourceName  = char(source);
    sourceData  = allData.(sourceName);
    
    parfor i = 1:numel(patchvalues)
      
      for fset = sets
        fSet = char(fset);
        
        for fView = views %1:4
          
          
          fValue = patchvalues(i);
          
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
          
        end
        
      end
    end
    
  end
  
  
end
