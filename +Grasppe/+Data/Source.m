classdef Source  < Grasppe.Core.Component
  %SOURCE Abstract Data Reader
  %   Detailed explanation goes here
  
  properties (GetAccess=public, SetAccess=protected)
    Reader
  end
  
  properties (Dependent)
    IsReady
  end
    
  properties (Access=protected)
    reader
    readerListeners
  end
  
  
  methods
    
    function obj = Source(varargin)      
      obj = obj@Grasppe.Core.Component(varargin{:});
    end
        
    
    function readerValid = get.IsReady(obj)
      readerValid   = Grasppe.Data.Source.ValidateReader(obj.reader);
    end
    
%     function set.Reader(obj, reader)
%       
%     end
    
    function reader = get.Reader(obj)
      reader    = obj.reader;
      if ~isscalar(reader) || ~isa(reader, 'Grasppe.Data.Reader') || ~isvalid(reader)
        try delete(reader); end
        obj.GetNewReader(obj);
        reader    = obj.reader;
      end

    end
    
  end
  
  methods (Access=protected)
    
    function createComponent(obj)
      obj.reader            = [];
      obj.readerListeners   = event.listener.empty;      
      obj.createComponent@Grasppe.Core.Component;
    end
    
    function tf = attachReader(obj, reader)
      
      tf  = false;
      
      if Grasppe.Data.Source.ValidateReader(obj.reader), return; end
      
      if ~Grasppe.Data.Source.ValidateReader(reader), return; end;
      
      %disp(isequal(reader, obj.reader));
      
      try if ~isequal(reader, obj.reader)
          obj.detachReader; end; end
      tf  = obj.attachReaderListeners(reader);
      
      obj.reader    = reader;
      
    end
    
    function detachReader(obj)
      
      try delete(obj.reader); end
            
      obj.reader    = [];      
      
      if ~isempty(obj.readerListeners)
        try delete(obj.readerListeners); end
      end
      
    end
    
    function fireReaderEvent(obj, source, eventData)
      % Notify datasource listeners of event triggered initially by reader
      try notify(obj, eventData.EventName, eventData); end
    end
    
  end
  
  methods (Static)
    function tf = ValidateReader(reader)
      tf = isscalar(reader) && isa(reader, 'Grasppe.Data.Reader') && isvalid(reader);
    end
  end
  
  
  methods (Abstract, Access=protected)
    tf      = attachReaderListeners(obj, reader)
  end
  
  methods (Abstract, Static)
    reader  = GetNewReader(dataSource);
  end
  
  
end

