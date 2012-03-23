classdef UniformityPatchSetComparePlotMediator < GrasppeMediator
  %UNIFORMITYPATCHSETCOMPAREPLOTMEDIATOR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    PlotFigures
    DataSources
  end
  
  methods(Static)
    function CreatePlotsForSourceID(sourceID)
      patchValues = [0 50 100];
      dataSources = [];
      for i = patchValues
        dataSource = LocVarUniformityDataSource('CaseID', 'ritsm7402a');
        dataSource.setPatchValue = i;
        if isempty(dataSources)
          dataSources = dataSource
        else
          dataSources(end+1) = dataSource;
        end
      end 
    end
  end
  
  methods (Access=protected, Hidden=false)
    function createComponent(obj, type, varargin)
      
      return;
    end
  end

  
  methods(Static, Hidden)
    function options  = DefaultOptions()
      options = [];
    end
    
  end
  
end

