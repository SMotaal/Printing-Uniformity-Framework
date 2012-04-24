classdef UniformityPlotLabels < Grasppe.Core.Component
  %UNIFORMITYPLOTLABELS Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    LabelObjects    = {};
    LabelValues     = [];
    LabelRegions    = [];
    LabelPositions  = [];
    LabelElevation  = 100;
    PlotObject
  end
  
  methods
    
    function attachPlot(obj, plotObject)
      %% Elevation
      
      obj.LabelElevation = 0;
    end
    
    function detachPlot(obj)
      obj.deleteLabels;
    end
    
    function deleteLabels(obj)
      try
        for m = 1:numel(obj.LabelObjects)
          try delete(obj.LabelObjects{m}); end
          obj.LabelObjects{m} = [];
        end
      end
      try
        for m = 1:numel(obj.LabelObjects)
          try if isempty(obj.LabelObjects{m}), continue; end; end
          return;
        end
        obj.LabelObjects    = {};
        obj.LabelValues     = [];
        obj.LabelRegions    = [];
        obj.LabelPositions  = [];
      end
    end
    
    function defineLabels(obj, regions, values)
      obj.deleteLabels;
      obj.LabelRegions  = regions;
      obj.LabelValues   = values;
    end
    
    function createLabels(obj)
      values  = obj.LabelValues;
      regions = obj.LabelRegions;
      
      for m = 1:numel(obj.LabelValues)
        obj.createLabel(m, values(m), regions(m,:));
      end      
    end
    
    function createLabel(obj, index, region, value)
      
      %% Index        
      if isempty(index)
        index = numel(obj.LabelObjects)+1;
      else
        label = [];
        try label = obj.LabelObjects{index}; end
      end
      
      %% Label
      if isempty(label) % Create Label
        try 
          label = Grasppe.Graphics.TextObject(obj.PlotObject.ParentAxes);
        catch err
          warning('Plot must be attached before creating labels');
          return;
        end
        obj.registerHandle(label);
        obj.LabelObj{index} = label;
      end
      
      %% Region (xmin ymin width height)
      if size(region)==[1 4]
        % no change
      elseif size(region)==[1 2]
        region  = [region 0 0];
      else % is a mask
        y       = nanmax(region, [], 1);
        y1      = find(y>0, 1, 'first');
        y2      = find(y>0, 1, 'last');
        
        x       = nanmax(region, [], 2);
        x1      = find(x>0, 1, 'first');
        x2      = find(x>0, 1, 'last');
        
        region  = [x1 y1 x2-x1 y2-y1];
      end
      
      dimension = region([3 4]);
      
      %% Position (centering)
      position  = region([1 2]) + dimension/2;
      
      
      obj.LabelRegions(index, 1:4) = region;
      obj.LabelPositions(index, 1:2) = position;
      
      %% Value
      if nargin < 3, value = []; end
      
      try if isempty(value), value = obj.LabelValues(index); end; end
      
      obj.LabelValues(index) = value;
      
      obj.updateLabel(index);
      
    end
    
    function updateLabel(obj, index)
      value = [];
      try value = toString(obj.LabelValues(index)); end
      try obj.LabelObjects{index}.Text = value; end
      
      position = [-100 -100];
      try position = obj.LabelPositions(index, :); end
      try obj.LabelObjects{index}.Position([1 2]) = [position obj.LabelElevation]; end
    end
    
    function updateLabels(obj)
      for m = 1:numel(obj.LabelObjects)
        obj.updateLabel(m);
      end
    end
  end
  
end

