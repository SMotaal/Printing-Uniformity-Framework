function [ output_args ] = BuildSurfsBuffer( input_args )
  %BUILDSURFSBUFFER Summary of this function goes here
  %   Detailed explanation goes here
  
  clc; try dbquit all, end; close all; cleardebug; cleardebug; dbstop if error;
  
  surfCollection = { ...
    {'ritsm7402a',  'sections', 'zones', 'zonebands'}, ...
    {'ritsm7402b',  'sections', 'zones', 'zonebands'}, ...
    {'ritsm7402c',  'sections', 'zones', 'zonebands'}, ...
    {'ritsm7401',   'sections', 'zones', 'zonebands'}, ...
    {'ritsmhp7k01', 'sections'}, ...
    {'ritsmhp5501', 'sections'}, ...
    };
  
  surfStats = {'mean', 'std', 'sixsigma', 'peaklimits'}; %, 'upperlimit', 'lowerlimit'};
  
  d1 = Grasppe.PrintUniformity.Data.RegionStatsDataSource('CaseID', surfCollection{1}{1});
  
  for c = 1:numel(surfCollection)
    d1.CaseID = char(surfCollection{c}{1});
    surfSets  = surfCollection{c}(2:end);
    
    for v = 1:numel(surfSets)
      
      d1.VariableID=char(surfSets{v});
      
      for p = [0 25 50 75 100]
        d1.SetID = p;
        
        for s = 1:numel(surfStats)
          
          d1.StatsMode = char(surfStats{s});
          
          for m = 1:size(d1.SetData.data,2)
            d1.setSheet('+1');
          end
          
        end
        
      end
      
    end
  end
  
end

