classdef LocalVariabilityDataSource < Grasppe.PrintUniformity.Data.UniformityDataSource
  %SURFACEUNIFORMITYDATASOURCE Raw printing uniformity data source
  %   Detailed explanation goes here
  
  properties
    LocalVariabilityDataSourceProperties = {
      'TestProperty', 'Test Property', 'Labels', 'string', '';   ...
      };    
    
    TestProperty
  end
  
  methods (Hidden)
    function obj = LocalVariabilityDataSource(varargin)
      obj = obj@Grasppe.PrintUniformity.Data.UniformityDataSource(varargin{:});
    end

    function [X Y Z] = processSheetData(obj, sheetID)

      [X Y Z]   = obj.processSheetData@Grasppe.PrintUniformity.Data.UniformityDataSource(sheetID);
      
      sourceData    = obj.SourceData;
      setData       = obj.SetData;
      sheetData     = setData.data(sheetID).zData;
      
      targetFilter  = sourceData.sampling.masks.Target;
      patchFilter   = setData.filterData.dataFilter;
      
      Z(patchFilter)      = sheetData;
      Z(targetFilter~=1)  = NaN;
      Z(patchFilter~=1)   = NaN;
      
      Z = Grasppe.PrintUniformity.Data.LocalVariabilityDataSource.localVariabilityFilter(Z);
      
      try
        zNaN        = isnan(Z);
        
        X(zNaN) = NaN;
        Y(zNaN) = NaN;
      end

      
      %Z(patchFilter~=1)   = NaN;      
      
    end
    
    function optimizeSetLimits(obj)
      zLim    = [0 10];
      
      obj.ZLim  = zLim;
      obj.CLim  = zLim;
    end
    
    
  end
  
  methods (Static, Hidden)
    function newData = localVariabilityFilter(zData)
      newData = [];
      try
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
    end
    function OPTIONS  = DefaultOptions()      
      Grasppe.Utilities.DeclareOptions;
    end
  end
  
  methods (Static)
    function obj = Create(varargin)
      obj = Grasppe.PrintUniformity.Data.LocalVariabilityDataSource(varargin{:});
    end
  end
  
  
end

