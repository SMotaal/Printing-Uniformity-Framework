classdef PrintUniformityBeta
  %UPBETA Printing Uniformity Research (Beta)
  %   Using GrasppeAlpha.Core.Prototypes
  
  properties
  end
  
  methods (Static)
    exportRegionPlots;
    % demoViewerRegions;
    % demoViewerMultiPlots;
    demoSurfs;
    demoRegions;
    tally   = tallyRegionStats;
    outputRegionStats(tally);
    % tallyRegionStats1;
  end
  
end

