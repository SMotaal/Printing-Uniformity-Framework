classdef PlotRegionModel < GrasppeAlpha.Data.Models.DataModel
  %PLOTREGIONMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Value           = [];
    Values          = [];
    Data            = [];
    
    Text            = [];
    Subtext         = [];
    
    Position        = evaluateStruct({'X1', []; 'X2', []; 'Y1', []; 'Y2', []});    
    Row             = [];
    Column          = [];
    
    CaseID          = [];
    SetID           = [];
    SheetID         = [];
    RegionID        = [];
    VariableID      = [];
    
    
    Category        = [];
    Series          = [];
  end
  
  methods
    function obj = PlotRegionModel(varargin)
      obj = obj@GrasppeAlpha.Data.Models.DataModel(varargin{:});
    end
  end
  
end

