function [ report ] = outputAnalysisReport( tally )
  %OUTPUTANALYSISREPORT Summary of this function goes here
  %   Detailed explanation goes here
  
  outputFolder            = fullfile('Output', 'Stats');
  
  statGroups              = {'Run', 'Around', 'Across', 'Region', 'Sheet', 'Zone'};
  
  report                  = struct;
  
  %% Specifications
  aimpoint                = 1.5;
  tolerance               = 0.1;
  
  %% Functions
  
  % PUAccruacyValue         = @(x) x.
  
  PUAccuracyScore         = @(x) x.Value / (tolerance / 2);
  PUPrecisionScore        = @(x) x.Value*6 / tolerance;
  
  PUDirectionality        = @(x) x.Across/x.Around;
  
  %% Inaccuracy Scores
  
  report.Run.Accuracy.Value;
  report.Run.Accuracy.Score           = PUAccuracyScore(report.Run.Accuracy);

  %% Inaccuracy Directionality
  
  report.Run.Accuracy.Around;
  report.Run.Accuracy.Across;
  
  report.Run.Accuracy.Directionality  = PUDirectionality(report.Run.Accuracy);
  
  %% Inaccuracy Proportions
  
  %% Imprecision Scores

  %% Imprecision Directionality
  
  %% Imprecision Proportions
  
  %% Unevenness Factors
  
  %% Unrepeatability Factors
  
  %% Output Report
  
  %% Return Report
  if nargout<1, clear report; end
  
end

