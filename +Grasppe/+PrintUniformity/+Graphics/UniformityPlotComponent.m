classdef UniformityPlotComponent < Grasppe.Core.Prototype
  %UNIFORMITYPLOTOBJECT Co-superclass for printing uniformity plot objects
  %   Detailed explanation goes here
  
  properties (SetObservable, GetObservable)
    DataSource
    LinkedProperties
  end
  
  properties (Dependent)
    %     IsLinked;
  end
  
  methods
    function obj = UniformityPlotComponent(dataSource, varargin)
      obj = obj@Grasppe.Core.Prototype; %Component(varargin{:}, 'DataSource', dataSource);
      obj.DataSource = dataSource;
    end
  end
  
  methods (Access=protected)
    
    %     function createComponent(obj, type)
    % %       if ~UniformityPlotObject.checkInheritence(obj.DataSource, 'UniformityDataSource')
    % %         obj.DataSource = RawUniformityDataSource.Create(obj);
    % %       end
    % %
    %
    %     end
    
    function attachDataSource(obj)
      obj.DataSource.attachPlotObject(obj);
    end
  end
  
  methods
    function set.DataSource(obj, value)
      try obj.DataSource = value; end
      value.attachPlotObject(obj);
      %       try value.attachPlotObject(obj); end
    end
    
    function OnMouseScroll(obj, source, event)
%       if ~isequal(obj.Handle, hittest)
%         consumed = false;
%         return;
%       end
      
      if ~event.Data.Scrolling.Momentum
        % disp(toString(event));
        % plotAxes = get(obj.handleGet('CurrentAxes'), 'UserData');
        if event.Data.Scrolling.Vertical(1) > 0
          obj.setSheet('+1');
        elseif event.Data.Scrolling.Vertical(1) < 0
          obj.setSheet('-1');
        end
      end    
    end
    
    function setSheet(obj, varargin)
      try obj.DataSource.setSheet(varargin{:}); end
    end
    
  end
  
end

