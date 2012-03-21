classdef LocVarUniformityDataSource < GrasppePrototype & UniformityDataSource
  %SURFACEUNIFORMITYDATASOURCE Raw printing uniformity data source
  %   Detailed explanation goes here
  
  properties
  end
  
  methods (Hidden)
    function obj = LocVarUniformityDataSource(varargin)
      obj = obj@GrasppePrototype;
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
      sheetData = setData.data(sheet).zData;
      
      [X Y Z]   = meshgrid(1:columns, 1:rows, 1);
      
      targetFilter  = sourceData.sampling.masks.Target;
      patchFilter   = setData.filterData.dataFilter;
      
      Z(patchFilter)      = sheetData;
      Z(targetFilter~=1)  = NaN;
      Z(patchFilter~=1)   = NaN;
            
      Z = LocVarUniformityDataSource.localVariabilityFilter(X, Y, Z);
      
      obj.setPlotData(X, Y, Z);
      
      %       catch err
      %         dealwith(err);
      %       end
      
    end
    
    function optimizePlotLimits(obj)
      if obj.IsRetrieved
        % setData = obj.SetData;
        
        %zData   = [setData.data(:).zData];
%         zMean   = nanmean(zData);
%         zStd    = nanstd(zData,1);
%         zSigma  = [-3 +3] * zStd;
%         
%         
%         zMedian = round(zMean*2)/2;
%         zRange  = [-3 +3];

        zLim    = [0 10];
        
        cLim    = zLim;
        
        obj.ZLim  = zLim;
        obj.CLim  = cLim;
      end
    end
    
    
  end
  
  methods (Static, Hidden)
    function newData = localVariabilityFilter(xData, yData, zData)
      yNan    = find(~isnan(zData(:,1)));
      yStep   = abs(mode(yNan - yNan([2:end 1])));
      
      xNan    = find(~isnan(zData(1,:)));
      xStep   = abs(mode(xNan - xNan([2:end 1])));
      
      ySub    = yStep+1:yStep+size(zData,1);
      xSub    = xStep+1:xStep+size(zData,2);
      
      pSize   = size(zData) + [yStep*2 xStep*2];
      
      pData             = ones(pSize) * nan;
      pData(ySub, xSub) = zData;
      
      dData   = zeros(size(pData));
      
      for x = [-xStep 0 +xStep]
        for y = [-yStep 0 +yStep]
          fData                 = abs(pData-circshift(pData,[y x]));
          fData(isnan(fData))   = 0 ;
          dData                 = dData + fData;
        end
      end
      
      newData   = dData(ySub, xSub);
    end
    function options  = DefaultOptions()
%       SourceID        = 'ritsm7402a';
      
      options = WorkspaceVariables(true);
    end
  end
  
  methods (Static)
    function obj = Create(varargin)
      obj = LocVarUniformityDataSource(varargin{:});
    end
  end
  
  
end

