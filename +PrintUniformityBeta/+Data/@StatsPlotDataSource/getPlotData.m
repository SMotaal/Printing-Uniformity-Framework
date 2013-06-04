function plotData = getPlotData(obj, setData)
  %GETPLOTMODEL Summary of this function goes here
  %   Detailed explanation goes here
  
      plotData                   = [];
  
      plotDataClass              = 'PrintUniformityBeta.Models.Visualizer.StatsPlotDataModel';
      
      if ~exist('setData', 'var'), setData = obj.SetData; end
      
      metricIDs                   = struct();
      
      switch lower(obj.variableID)
        case 'inaccuracy'
          obj.variableID            = 'Inaccuracy';
          
          metricIDs.Run.Value       = 'Inaccuracy Score';
          metricIDs.Run.Series      = 'Inaccuracy Score';
          metricIDs.Run.Rank        = '';
          metricIDs.Run.Ratio       = 'Inaccuracy Directionality';
          metricIDs.Run.Factors     = '';
          
          metricIDs.Region.Value    = 'Inaccuracy Score';
          metricIDs.Region.Series   = 'Inaccuracy Score';
          metricIDs.Region.Rank     = 'Inaccuracy Rank';
          metricIDs.Region.Ratio    = 'Inaccuracy Directionality';
          metricIDs.Region.Factors  = '';
        case 'imprecision'
          obj.variableID            = 'Imprecision';
          
          metricIDs.Run.Value       = 'Imprecision Score';
          metricIDs.Run.Series      = 'Imprecision Score';
          metricIDs.Run.Rank        = '';
          metricIDs.Run.Ratio       = 'Imprecision Directionality';
          metricIDs.Run.Factors     = 'Imprecision Factors';
          
          metricIDs.Region.Value    = 'Imprecision Score';
          metricIDs.Region.Series   = 'Imprecision Score';
          metricIDs.Region.Rank     = 'Imprecision Rank';
          metricIDs.Region.Ratio    = 'Imprecision Directionality';
          metricIDs.Region.Factors  = 'Imprecision Factors';      
        otherwise
          %plotData                  = feval([plotDataClass '.empty()']);
          return;
      end
      
      %% Prepare PlotModel
      
      if ~isa(obj.PlotDataMap, 'containers.Map') || ~isvalid(obj.PlotDataMap)
        obj.PlotDataMap = containers.Map();
      end
      
      plotData               = feval(plotDataClass);
      
      plotData.CaseID        = setData.CaseID;
      plotData.SetID         = setData.ID;
      plotData.VariableID    = obj.variableID;
      
      plotDataKey            = [plotData.CaseID ':' plotData.VariableID ':TV'  int2str(plotData.SetID)];
      
      if obj.PlotDataMap.isKey(plotDataKey) && isobject(obj.PlotDataMap(plotDataKey)) && isvalid(obj.PlotDataMap(plotDataKey))
        plotData             = obj.PlotDataMap(plotDataKey);
      else
        metricFields            = {'Value', 'Series', 'Rank', 'Ratio', 'Factors'};
        
        runData                 = struct();
        regionData              = struct();
        aroundData              = struct();
        acrossData              = struct();
        
        
        for m = 1:numel(metricFields)
          try
            fieldID                   = metricFields{m};
            runMetricID               = metricIDs.Run.(fieldID);
            regionMetricID            = metricIDs.Region.(fieldID);
            aroundMetricID            = metricIDs.Region.(fieldID);
            acrossMetricID            = metricIDs.Region.(fieldID);
            try runData.(fieldID)     = setData.Metrics.Run(runMetricID); end
            try regionData.(fieldID)  = setData.Metrics.Region(regionMetricID); end
            try aroundData.(fieldID)  = setData.Metrics.Around(aroundMetricID); end
            try acrossData.(fieldID)  = setData.Metrics.Across(acrossMetricID); end
            
            if strcmpi(fieldID, 'Series')
              runSamples              = runData.(fieldID).Samples.Values;
              regionSamples           = regionData.(fieldID).Samples.Values;
              aroundSamples           = aroundData.(fieldID).Samples.Values;
              acrossSamples           = acrossData.(fieldID).Samples.Values;
              runSeries               = reshape([runSamples{:}    ],  size(runSamples   )); % NaN(size(runSamples));
              regionSeries            = reshape([regionSamples{:} ],  size(regionSamples));
              aroundSeries            = reshape([aroundSamples{:} ],  size(aroundSamples));
              acrossSeries            = reshape([acrossSamples{:} ],  size(acrossSamples));  
              
              
              switch lower(obj.variableID)
                % case 'inaccuracy'
                %   runData.(fieldID)       = runSeries; % -min(runSeries(:));
                %   regionData.(fieldID)    = regionSeries-repmat(runSeries, size(regionSeries, 1), size(regionSeries, 2));
                %   aroundData.(fieldID)    = aroundSeries-repmat(runSeries, size(aroundSeries, 1), size(aroundSeries, 2));
                %   acrossData.(fieldID)    = acrossSeries-repmat(runSeries, size(acrossSeries, 1), size(acrossSeries, 2));
                case {'inaccuracy'}
                  seriesBase              = floor(min(abs([runSeries(:)' regionSeries(:)' aroundSeries(:)' acrossSeries(:)']))*2)/2;
                  runData.(fieldID)       = abs(runSeries   ) - seriesBase; % -min(runSeries(:));
                  regionData.(fieldID)    = abs(regionSeries) - seriesBase; % -repmat(runSeries, size(regionSeries, 1), size(regionSeries, 2));
                  aroundData.(fieldID)    = abs(aroundSeries) - seriesBase; %-repmat(runSeries, size(aroundSeries, 1), size(aroundSeries, 2));
                  acrossData.(fieldID)    = abs(acrossSeries) - seriesBase; %-repmat(runSeries, size(acrossSeries, 1), size(acrossSeries, 2));
                case {'imprecision'}
                  seriesBase              = floor(min([runSeries(:)' regionSeries(:)' aroundSeries(:)' acrossSeries(:)'])*2)/2;
                  runData.(fieldID)       = runSeries     - seriesBase; % -min(runSeries(:));
                  regionData.(fieldID)    = regionSeries  - seriesBase; % -repmat(runSeries, size(regionSeries, 1), size(regionSeries, 2));
                  aroundData.(fieldID)    = aroundSeries  - seriesBase; %-repmat(runSeries, size(aroundSeries, 1), size(aroundSeries, 2));
                  acrossData.(fieldID)    = acrossSeries  - seriesBase; %-repmat(runSeries, size(acrossSeries, 1), size(acrossSeries, 2));                                  
                otherwise
                  runData.(fieldID)       = runSeries; % -min(runSeries(:));
                  regionData.(fieldID)    = regionSeries; % -repmat(runSeries, size(regionSeries, 1), size(regionSeries, 2));
                  aroundData.(fieldID)    = aroundSeries; %-repmat(runSeries, size(aroundSeries, 1), size(aroundSeries, 2));
                  acrossData.(fieldID)    = acrossSeries; %-repmat(runSeries, size(acrossSeries, 1), size(acrossSeries, 2));
              end
                
            end
          catch err
            % switch err.identifier
            %   case {'MATLAB:noSuchMethodOrField'}
            %   otherwise
            %     debugStamp(err);
            % end
          end
        end
        
        plotData.RunData             = runData;
        plotData.RegionData          = regionData;
        plotData.AroundData          = aroundData;
        plotData.AcrossData          = acrossData;
        
        obj.PlotDataMap(plotDataKey)  = plotData;
        
      end
  
end

