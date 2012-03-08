classdef ColorBarObject < AxesObject
  %COLORBAROBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    ComponentType = 'colorbar';
    ComponentProperties = { 'Location' };
    ComponentEvents = { };
  end
  
  properties
    PeerAxes
  end
  
  properties (SetObservable)
    Location
  end
  
  properties (Dependent)
    PeerHandle
  end
  
  
  methods (Access=protected, Hidden)
    function obj = ColorBarObject(peerAxes, varargin)
      parentFigure = peerAxes.ParentFigure;
           
      obj = obj@AxesObject(varargin{:}, 'PeerAxes', peerAxes ,'ParentFigure', parentFigure);
      
      try
        colorbarHandle = parentFigure.ColorBarHandle;
        if ~isempty(parentFigure.ColorBar)
          try delete(parentFigure.ColorBar); end;
          parentFigure.ColorBar = [];
        end
        if ishandle(colorbarHandle)
          try delete(colorbarHandle); end;
        end
      end
      
      parentFigure.ColorBar = obj;
      parentFigure.registerWindowEventHandler(obj);
    end
    
    function createComponent(obj, type)
      peer = obj.PeerHandle;
      
      obj.createComponent@GrasppeComponent(type,'peer', peer);
      
      obj.Location = 'North';
      
      obj.resizeComponent();

    end
    
  end
  
  
  methods
    function peer = get.PeerHandle(obj)
      peer = [];
      try peer = obj.PeerAxes.Handle; end
    end
    
    function resizeComponent(obj)
      obj.resizeToFigure;
%       parentPosition  = pixelPosition(obj.ParentFigure.Handle);
%       peerPosition    = pixelPosition(obj.PeerAxes.Handle);
%       
%       size      = [peerPosition(3), 10];
%       position  = [peerPosition(1) peerPosition(2)+peerPosition(4) size];
%       
%       obj.handleSet('Units', 'pixels', 'position', position);
    end    
    
    function resizeToFigure(obj)
      parentPosition  = pixelPosition(obj.ParentFigure.Handle);
      peerPosition    = pixelPosition(obj.PeerAxes.Handle);
      
      size      = [min(parentPosition(3)/4, 400), 10];
      position  = [([parentPosition(3)-10 parentPosition(4)-10])-size size];
      
      obj.handleSet('Units', 'pixels', 'position', position);
      
    end
    
    function resizeToAxes(obj)
      parentPosition  = pixelPosition(obj.ParentFigure.Handle);
      peerPosition    = pixelPosition(obj.PeerAxes.Handle);
      
      size      = [peerPosition(3), 10];
      position  = [peerPosition(1) peerPosition(2)+peerPosition(4) size];
      
      obj.handleSet('Units', 'pixels', 'position', position);
    end      
    
  end
  
  
  methods (Static, Hidden)
    function options  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = true;
      
      options = WorkspaceVariables(true);
    end
    
  end
  
  methods (Static)
    function obj = Create(peerAxes, varargin)
      obj = ColorBarObject(peerAxes, varargin{:});
    end
  end
  
  
end

