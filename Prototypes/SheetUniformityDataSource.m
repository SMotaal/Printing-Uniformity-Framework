classdef SheetUniformityDataSource < UniformityDataSource
  %SURFACEUNIFORMITYDATASOURCE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods (Hidden)
    function obj = SheetUniformityDataSource(varargin)
      obj = obj@UniformityDataSource(varargin{:});
    end
    
    
    function processPlotData(obj)
      sourceData = [];
      try
%         obj.retrieveSourceData;
        
        sourceData = obj.SourceData;
        
        rows      = sourceData.metrics.sampleSize(1);
        columns   = sourceData.metrics.sampleSize(2);
        sheet     = obj.SampleID;
        
      catch err
        return;
      end
      
      if isempty(sourceData), return; end;
      
      try
        setData = obj.SetData;
        sheetData = setData.data(sheet).surfData;
        
        [X Y Z]   = meshgrid(1:columns, 1:rows, 1);
        
        targetFilter  = sourceData.sampling.masks.Target;
        
        Z = sheetData';
        Z(targetFilter~=1) = NaN;
        
        obj.setPlotData(X, Y, Z);
        
      catch err
        dealwith(err);
      end
      
    end
    
  end
  
  methods (Static, Hidden)
    function options  = DefaultOptions()
      SourceID        = 'ritsm7402a';
      %     DataParameters: []
      %         SourceData: []
      %            SetData: []
      %         SampleData: []
      %           SourceID: []
      %              SetID: []
      %           SampleID: []
      %         SourceName: []
      %            SetName: []
      %               Sets: 0
      %         SampleName: []
      %            Samples: 0
      %                 ID: 'SheetUniformityDataSource_1'
      
      options = WorkspaceVariables(true);
    end
  end
  
  methods (Static)
    function obj = createDataSource(varargin)
      obj = SheetUniformityDataSource(varargin{:});
    end
  end
  
  
end

