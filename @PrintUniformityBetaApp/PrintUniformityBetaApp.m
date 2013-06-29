classdef PrintUniformityBetaApp
  %UPBETA Printing Uniformity Research (Beta)
  %   Using GrasppeAlpha.Core.Prototypes
  
  properties
  end
  
  methods (Static)
    exportRegionPlots;
    exportStatsPlots;
    % demoViewerRegions;
    % demoViewerMultiPlots;
    demoSurfs;
    demoRegions;
    tally   = tallyRegionStats;
    outputRegionStats(tally);
    % tallyRegionStats1;
    icDemoPreloader
  end
  
end

