classdef TableObject < InFigureObject & DecoratedObject & TableEventHandler
  %TABLEOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    
    ComponentType = 'uitable';
    
    CommonProperties = { ...
      'ColumnFormat', 'ColumnEditable', 'ColumnName', 'ColumnWidth', 'RowName', ...
      'RearrangeableColumns', 'RowStriping', ...
      'Data', ...
      'Extent', 'Position', ...
      'TooltipString', 'Units' ...
      };
    
    ComponentEvents  = {'CellEditCallback', 'CellSelectionCallback'};
    
  end
  
  properties (SetObservable, GetObservable)
    ColumnFormat, ColumnEditable, ColumnName, ColumnWidth, RowName
    
    RearrangeableColumns, RowStriping
    
    Data
    
    Extent, Position
    
    CellEditCallback, CellSelectionCallback
    
    TooltipString
    
    Units
  end
  
  methods
    function obj = TableObject(varargin)
      obj = obj@DecoratedObject();
      obj = obj@InFigureObject(varargin{:});
      
      FontDecorator(obj);
    end
  end
  
  methods (Access=protected)
    function createComponent(obj, type)
      obj.createComponent@InFigureObject(type);
    end
  end
  
  methods(Abstract, Static, Hidden)
    options  = DefaultOptions()
    obj = Create()
  end
  
  
end

