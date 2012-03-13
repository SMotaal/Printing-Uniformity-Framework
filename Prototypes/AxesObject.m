classdef AxesObject < InFigureObject & DecoratedObject
  %AXESOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  properties (Transient, Hidden, Constant)    
    
    CommonProperties = { ...
     'Box', 'Color', 'Units', 'Projection', ... % 'View', ...
     ...
     'FontName', 'FontSize', 'FontAngle', 'FontWeight', 'FontUnits', ...
     ...
     'XScale', 'XDir', 'XColor', 'XLabel', 'XAxisLocation', ...
     'XGrid', 'XMinorGrid', 'XMinorTick', ...
     ...
     'YScale', 'YDir', 'YColor', 'YLabel', 'YAxisLocation', ...
     'YGrid', 'YMinorGrid', 'YMinorTick', ...
     ...
     'ZScale', 'ZDir', 'ZColor', 'ZLabel', ...
     'ZGrid', 'ZMinorGrid', 'ZMinorTick', ...
     };
   
%     ComponentEvents = { };

%     ComponentType = 'axes';
%     
%     ComponentProperties = { ...
%      'Box', 'Color', 'Units', 'Projection', 'View', ...
%      ...
%      'FontName', 'FontSize', 'FontAngle', 'FontWeight', 'FontUnits', ...
%      ...
%      'XScale', 'XDir', 'XColor', 'XLabel', 'XAxisLocation', ...
%      'XGrid', 'XMinorGrid', 'XMinorTick', ...
%      ...
%      'YScale', 'YDir', 'YColor', 'YLabel', 'YAxisLocation', ...
%      'YGrid', 'YMinorGrid', 'YMinorTick', ...
%      ...
%      'ZScale', 'ZDir', 'ZColor', 'ZLabel', ...
%      'ZGrid', 'ZMinorGrid', 'ZMinorTick', ...
%      };
%    
%     ComponentEvents = { };
    
  end
  
  properties
    Color, Units, Box, PositionMode
  end
  
  properties
    %ActivePositionProperty
    Position, OuterPosition,
    
    Projection, % View
    
    FontName, FontSize, FontAngle, FontWeight, FontUnits
    
    XScale, XDir, XColor, XLabel, XAxisLocation
    XGrid, XMinorGrid, XMinorTick
       
    YScale, YDir, YColor, YLabel, YAxisLocation
    YGrid, YMinorGrid, YMinorTick    
    
    ZScale, , ZDir, ZColor, ZLabel
    ZGrid, ZMinorGrid, ZMinorTick
  
  end
  
  properties (Dependent)
    %DataAspectRatioMode
    AspectRatio
    
    %CLimMode   ALimMode
    CLim,       ALim
    
    %XLimMode   XTickMode,  XTickLabelMode    
    XLim,       XTick,      XTickLabel
    
    %YLimMode   YTickMode,  YTickLabelMode
    YLim,       YTick,      YTickLabel
    
    %ZLimMode   ZTickMode,  ZTickLabelMode
    ZLim,       ZTick,      ZTickLabel
  end
  
  methods (Access=protected)
    
    function obj = AxesObject(varargin)
      obj = obj@InFigureObject(varargin{:});
      AxesViewDecorator(obj);
    end
    
  end
  
  methods
        
    function position = get.Position(obj)
      position = obj.handleGet('Position');
    end
    
    function set.Position(obj, value)
      obj.setPosition(value, 'position');
      obj.Position = value;
    end
    
    function set.OuterPosition(obj, value)
      obj.setPosition(value, 'outerposition');
      obj.OuterPosition = value;
    end
    
%     function set.DataAspectRatio(obj, value)
%       if isequal(value &&
%     end

    %DataAspectRatioMode
%     function set.(obj, value)
%     end
%     function =get.(obj)
%     end

    %% AspectRatio / DataAspectRatio
    function set.AspectRatio(obj, value)
      obj.autoSet('DataAspectRatio', value);
    end
    
    function value=get.AspectRatio(obj)
      value = obj.autoGet('DataAspectRatio');
    end

    %% CLim
    function set.CLim(obj, value)
      obj.autoSet('CLim', value);
    end
    
    function value=get.CLim(obj)
      value = obj.autoGet('DataAspectRatio');
    end

    %% ALim
    function set.ALim(obj, value)
      obj.autoSet('ALim', value);
    end
    
    function value=get.ALim(obj)
      value = obj.autoGet('ALim');
    end

    %% XLim
    function set.XLim(obj, value)
      obj.autoSet('XLim', value);
    end
    
    function value=get.XLim(obj)
      value = obj.autoGet('XLim');
    end

    % XTick
    function set.XTick(obj, value)
      obj.autoSet('XTick', value);
    end
    
    function value=get.XTick(obj)
      value = obj.autoGet('XTick');
    end

    % XTickLabel
    function set.XTickLabel(obj, value)
      obj.autoSet('XTickLabel', value);
    end
    
    function value=get.XTickLabel(obj)
      value = obj.autoGet('XTickLabel');
    end

    %% YLim
    function set.YLim(obj, value)
      obj.autoSet('YLim', value);
    end
    
    function value=get.YLim(obj)
      value = obj.autoGet('YLim');
    end

    % YTick
    function set.YTick(obj, value)
      obj.autoSet('YTick', value);
    end
    
    function value=get.YTick(obj)
      value = obj.autoGet('YTick');
    end

    % YTickLabel
    function set.YTickLabel(obj, value)
      obj.autoSet('YTickLabel', value);
    end
    
    function value=get.YTickLabel(obj)
      value = obj.autoGet('YTickLabel');
    end

    %% ZLim
    function set.ZLim(obj, value)
      obj.autoSet('ZLim', value);
    end
    
    function value=get.ZLim(obj)
      value = obj.autoGet('ZLim');
    end

    % ZTick
    function set.ZTick(obj, value)
      obj.autoSet('ZTick', value);
    end
    
    function value=get.ZTick(obj)
      value = obj.autoGet('ZTick');
    end

    % ZTickLabel
    function set.ZTickLabel(obj, value)
      obj.autoSet('ZTickLabel', value);
    end
    
    function value=get.ZTickLabel(obj)
      value = obj.autoGet('ZTickLabel');
    end    
    
  end
  
  methods (Hidden=false)
    
    function setPosition(obj, value, mode)
      
      if ~obj.IsHandled
        return;
      end
      
      if ~exist('mode', 'var')
        if isempty(obj.PositionMode)
          mode = 'outerposition';
        else
          mode = obj.PositionMode;
        end
      end
      
%       obj.set('ActivePositionProperty', mode);
      
      numeric   = isnumeric(value);
      relative  = ~isinteger(value) && numeric && all(value>=0) && all(value<=1);
      integer   = isinteger(value) || isInteger(value);
      double    = numeric && ~relative;
      
      currentUnits = obj.handleGet('Units');
      
      try
        if relative
          obj.handleSet('ActivePositionProperty', mode, 'Units', 'normalized', 'Position', value);
        elseif integer
          obj.handleSet('ActivePositionProperty', mode, 'Units', 'pixels', 'Position', value);
        end
      end
      
      obj.handleSet('Units', currentUnits);
    end
    
  end
  
  
  methods(Abstract, Static, Hidden)
    options  = DefaultOptions()
    obj = Create()
  end

  
end

