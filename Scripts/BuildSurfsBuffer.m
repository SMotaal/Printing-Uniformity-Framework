function [ output_args ] = BuildSurfsBuffer( input_args )
  %BUILDSURFSBUFFER Summary of this function goes here
  %   Detailed explanation goes here
  
  clc; try dbquit all, end; close all; cleardebug; cleardebug; dbstop if error;
  
  surfCollections = { ...
    ... % 'ritsm7402a',  'sections', 'zones', 'zonebands';
    ... % 'ritsm7402b',  'sections', 'zones', 'zonebands';
    ... % 'ritsm7402c',  'sections', 'zones', 'zonebands';
    'ritsm7401',   'sections', 'zones', 'zonebands';
    ... % 'rithp7k01', 'sections', '', '';
    ... % 'rithp5501', 'sections', '', '';
    };
  
  surfStats = {'mean', 'std', 'sixsigma', 'peaklimits'}; %, 'upperlimit', 'lowerlimit'};
  
  patchSets = [0 25 50 75 100];
  
  output_args = [];
  
  for c = 1:size(surfCollections, 1)
    
    surfCollection  = surfCollections(c, :);
    surfSets        = surfCollection(2:end);
    
    caseID  = surfCollection{1};
    
    for v = 1:numel(surfSets)
      
      variableID = surfSets{v};
      
      if isempty(variableID), continue; end
      
      Data.dataSources('clear');
      Data.dataSources([], 'verbose', true, 'sizeLimit', 1024);
            
      parfor p = 1:numel(patchSets)
        
        patchValue = patchSets(p);
        
        
        d1 = PrintUniformityBeta.Data.RegionStatsDataSource(... 
        'CaseID', caseID, 'VariableID', variableID, 'SetID', patchValue);
        
        for s = 1:numel(surfStats)
          
          statsMode = surfStats{s};
          if isempty(statsMode), continue; end
          
          d1.StatsMode = statsMode;
          
          try
            for m = 1:size(d1.SetData.data,2)
              try d1.setSheet('+1'); end
            end
          end
          
        end
        
        delete(d1);
        
      end
      
      evalin('base', 'GrasppeAlpha.Core.Prototype.ClearPrototypes');
      
    end
    
  end
  
end

