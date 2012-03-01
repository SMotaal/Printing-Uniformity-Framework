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
  
  exporting.path = fullfile(cd, 'output',['supVideo-' datestr(now, 'yymmdd')]);
  
  for source = sources
    sourceName  = char(source);
    sourceData  = allData.(sourceName);
    
    videoSourceData.CMS       = sourceData.CMS;
    videoSourceData.Data      = sourceData.Data;
    videoSourceData.Filename  = sourceData.Filename;
    videoSourceData.FilePath  = sourceData.FilePath;
    videoSourceData.Sheet     = 1;
    
    for fView = views %1:4
      for fset = sets
        
        fSet = char(fset);
        
        for fTV = patchvalues
          
          setID = ['DataSetTV' int2str(fTV)];
          
          videoSourceData.PlotData = sourceData.(setID).PlotData;
          videoSourceData.Sample = sourceData.(setID).Sample;

          exporting.name = lower([sourceName '-' upper(fSet) '-' int2str(fView) '-' int2str(fTV)]);
          exporting.file = fullfile(exporting.path, exporting.name);

          if exist(exporting.path, 'dir') == 0
            mkdir(exporting.path);
          end
          

          Alpha.supVideo(videoSourceData, fView,  exporting.file, fSet);
          
        end
        
      end
    end
    
  end
  
  
end
