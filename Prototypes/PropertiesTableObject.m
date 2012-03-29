classdef PropertiesTableObject < GrasppePrototype & TableObject
  %PROPERTIESTABLEOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    ComponentProperties = { };
    Properties
    IsUpdatingTable = false;
    UpdateTimer = [];
    Timers;
  end
  
  methods
  end
  
  methods (Access=protected, Hidden)
    function obj = PropertiesTableObject(parentFigure, varargin)
      obj = obj@GrasppePrototype;
      obj = obj@TableObject(varargin{:},'ParentFigure', parentFigure );
    end
    
    function createComponent(obj, type)
      obj.createComponent@TableObject(type);
      obj.Units     = 'normalized';
      obj.Position  = [0 0 1 1];
      obj.ColumnEditable = [true false];
      obj.RowName   = '';
      obj.ColumnName = '';
      obj.ColumnWidth = {400};
      
      if ~obj.HasParentFigure
        return;
      end
      obj.ParentFigure.registerWindowEventHandler(obj);
      
      
      obj.Timers.ResizeTimer = timer('TimerFcn',@obj.resizeColumns, ...
        'ExecutionMode', 'fixedDelay', 'Period', 1, 'StartDelay', 1);
      
      try start(obj.Timers.ResizeTimer); end;
      
    end
  end
  
  methods (Static, Hidden)
    function obj = Create(parentFigure, varargin)
      obj = PropertiesTableObject(parentFigure, varargin{:});
    end
    
    function options  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = true;
      
      options = WorkspaceVariables(true);
    end
    
  end
  
  methods
    function attachProperty(obj, target, name)
      value     = target.(name);
      type      = class(value);
      
      property  = struct( ...
        'Target', target, 'Name', name, 'Type', type, 'Value', value);
      
      target.addlistener(name, 'PostSet', @(s,e)obj.pullPropertyValue(s,e));
      
      obj.Properties.(name)=property;
      obj.updatePropertyTable;
    end
    
    function updatePropertyTable(obj)
      
      properties  = obj.Properties;
      names       = fieldnames(properties);
      nProperties = numel(names);
      
      try
        data        = {obj.RowName{:}; obj.Data{:,1}}';
      catch err
        data = {};
      end
      
      nDataRows   = size(data,1);
      % nColumns    = size(data,2);
      
      newData     = cell(nProperties,2);
      
      newData(:,1) = names;
      
      for i = 1:nDataRows
        try
          name    = data{i,1};
          value   = data{i,2};
          row     = find(strcmp(name, names));
          
          newData(row, 2) = value;
        catch err
          disp(err);
        end
      end
      
      for i = 1:nProperties
        try
          name    = names{i};
          value   = properties.(name).Value; % Target.(name);
          row     = i;
          
          switch class(value)
            case {'logical', 'single', 'double', 'int8', 'int16', 'int32', 'int64', 'uint8', 'uint16', 'uint32', 'uint64'}
              value = regexprep(num2str(value), '\s', ' ');
            case {'char'}
            otherwise
              if isobject(value)
                try value = [value.ID ' (' class(value) ')'];
                catch, value = ['(' class(value) ')']; end;
              else
                value = toString(value);
              end
          end
          newData{row, 2} = value;
        catch err
          disp(err);          
        end
      end
      
      obj.RowName = newData(:,1);
      obj.Data    = newData(:,2);
    end
    
    function pullPropertyValue(obj, source, event)
      
      property  = source.Name;
      component = event.AffectedObject;
      
      if isempty(obj.UpdateTimer) || ~isvalid(obj.UpdateTimer)
        obj.UpdateTimer = timer('TimerFcn',{@obj.updatePropertyValue, property}, ...
        'Period', 0.25, 'StartDelay', 0.25);
      end
      
      start(obj.UpdateTimer);
      
      %         obj.updatePropertyValue(property);
      
      %       obj.Properties.(property).Value = component.(property);
      %       obj.updatePropertyTable;
      %obj.Properties.(source.name).Target.(source.name);
    end
    
    function updatePropertyValue(obj, varargin)
      if nargin == 2
        property = varargin{1};
      elseif nargin == 4
        source    = varargin{1};
        event     = varargin{2};
        property  = varargin{3};
      end
      try
        if ~obj.IsUpdatingTable
          try stop(source); end %delete(source); end
          
          try obj.Properties.(property).Value = obj.Properties.(property).Target.(property); end
          try obj.updatePropertyTable; end
        else
          try stop(source); start(source); end
        end
      catch err
        halt(err, obj.ID);
      end
      
    end
    
    function pushPropertyValue(obj, property) %source, event)
      %       property  = source.Name;
      component = obj.Properties.(property).Target;
      value     = obj.Properties.(property).Value;
      type      = obj.Properties.(property).Type;
      
      %       dispf('Setting %s.%s: %s', component.ID, property, toString(value));
      
      %       try component.setOptions(property,value); end
      if ischar(value)
        switch type
          case 'double'
            try value = str2num(value); end
          case 'logical'
            % try value = isOn(value); end
            try value = str2num(value)==1; end
          case 'char'
          otherwise
            return;
        end
      end
      dispf('Setting %s.%s(%s): %s', component.ID, property, type, toString(value));      
      try component.(property) = value; end
    end
    
    function cellSelect(obj, source, event, varargin)
      obj.cellSelect@TableObject(source, event, varargin{:});
      %       try
      %         name = obj.Data(event.Indices(1),1);
      %       end
      %       disp(event);
    end
    
    function cellEdit(obj, source, event, varargin)
      
      obj.cellEdit@TableObject(source, event, varargin{:});
      
      %       if ~obj.IsUpdatingTable
      obj.IsUpdatingTable = true;
      
      try
        name  = obj.RowName{event.Indices(1)};
        value = event.NewData;
        
        try obj.Properties.(name).Value = value; end
        try obj.pushPropertyValue(name); end
      catch err
        disp(err);
      end
      obj.IsUpdatingTable = false;
      %       end
    end
    
    function resizeComponent(obj, varargin)
      obj.resizeColumns;
    end
    
    function resizeColumns(obj, varargin)
      position = getpixelposition(obj.Parent);
      
      obj.handleSet('Units', 'normalized', 'Position', [0 0 1 1]);
      
      obj.handleSet('Units', 'pixels'); %, 'Position', [0 0 position(3) position(4));
      position  = obj.handleGet('Position');
      extent    = obj.handleGet('Extent');
      obj.handleSet('Units', 'normalized');
      
      offset = position(3)-extent(3);
      width = cell2mat(obj.handleGet('ColumnWidth')) + offset;
      
      obj.handleSet('ColumnWidth', {width});
      
    end
    
    function delete(obj)
      try
        timers = obj.Timers;
        timers = struct2cell(timers);
        for t = 1:numel(timers)
          try stop(timers{t}); delete(timers{t}); end
        end
      catch err
        disp(err);
      end
      
      obj.delete@TableObject;
    end
    
    
  end
  
  methods (Static)
    function PullPropertyValue(source, event)
    end
    
    function PushPropertyValue(source, event)
    end
  end
  
  
end

