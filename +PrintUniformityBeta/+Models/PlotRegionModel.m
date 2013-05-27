classdef PlotRegionModel < GrasppeAlpha.Data.Models.DataModel
  %PLOTREGIONMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Position        = evaluateStruct({'X1', []; 'X2', []; 'Y1', []; 'Y2', []});
    Value           = [];
    Data            = [];
    Text            = [];
    Subtext         = [];
    VariableID      = [];
    SheetID         = [];
    RegionID        = [];
    SetID           = [];
    CaseID          = [];
    Category        = [];
    Series          = [];
  end
  
  methods
    function obj = PlotRegionModel(varargin)
      obj = obj@GrasppeAlpha.Data.Models.DataModel(varargin{:});
    end
  end
  
end

