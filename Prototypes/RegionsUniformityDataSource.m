classdef RegionsUniformityDataSource < UniformityDataSource
  %SURFACEUNIFORMITYDATASOURCE Raw printing uniformity data source
  %   Detailed explanation goes here
  
  properties
    DataGroup   = 'surfs';
    RegionGroup = 'sections';
    StatsGroup  = 'Mean';
  end
  
  methods (Hidden)
    function obj = RegionsUniformityDataSource(varargin)
      obj = obj@UniformityDataSource(varargin{:});
    end
    
    
    function processPlotData(obj)
      try debugStamp(obj.ID); catch, debugStamp(); end;
      sourceData = [];
      try
        obj.retrieveSourceData; %end
        
        sourceData = obj.SourceData;
        
        rows      = sourceData.metrics.sampleSize(1);
        columns   = sourceData.metrics.sampleSize(2);
        sheet     = obj.SampleID;
        
      catch err
        return;
      end
      
      if isempty(sourceData), return; end;
      
      %       try
      setData = obj.SetData;
      sheetData = reshape(setData.(obj.DataGroup).(obj.RegionGroup).(obj.StatsGroup)(sheet,1,:), rows, columns);
      %         sheetData = setData.(obj.DataGroup).(obj.RegionGroup).(obj.StatsGroup); %setData.data(sheet).surfData;
      
      [X Y Z]   = meshgrid(1:columns, 1:rows, 1);
      
      targetFilter  = sourceData.sampling.masks.Target;
      
      Z = sheetData;
      Z(targetFilter~=1) = NaN;
      
      obj.setPlotData(X, Y, Z);
      
      %       catch err
      %         dealwith(err);
      %       end
      
    end
    
  end
  
  methods (Static, Hidden)
    function options  = DefaultOptions()
      SourceID        = 'ritsm7402a';
      
      options = WorkspaceVariables(true);
    end
  end
  
  methods (Static)
    function obj = Create(varargin)
      obj = RegionsUniformityDataSource(varargin{:});
    end
  end
  
  
end

