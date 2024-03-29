classdef InFigureComponent < GrasppeAlpha.Graphics.HandleGraphicsComponent ... % & GrasppeAlpha.Core.DecoratedComponent & GrasppeAlpha.Core.EventHandler
    & GrasppeAlpha.Core.MouseEventHandler
  %NEWFIGUREOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    InFigureComponentHandleProperties = {'Position', 'Units'};
    
    InFigureComponentHandleFunctions = {{'MouseDownFunction', 'ButtonDownFcn'}};
    
  end
  
  
  properties (SetObservable, GetObservable, AbortSet)
    ParentFigure
    
    Position
    Units
    
    Padding       = [20 20 20 20]
  end
  
  
  methods
    function obj = InFigureComponent(varargin)
      obj = obj@GrasppeAlpha.Graphics.HandleGraphicsComponent(varargin{:});
    end
    
    
%     function triggerMouseEvent(obj, source, event, eventName)
%       disp(WorkspaceVariables);
%       %disp(event.Sou);
%     end
    
    
    function set.ParentFigure(obj, parentFigure)
      try
        if isempty(parentFigure), return; end
        if ~GrasppeAlpha.Graphics.Figure.checkInheritence(parentFigure)
          error('Grasppe:ParentFigure:NotFigure', 'Attempt to set parent figure to a non-figure object.');
        end
        obj.ParentFigure = parentFigure;
        obj.Parent = parentFigure.Handle;
      catch err
        if obj.VerboseDebugging, try debugStamp(obj.ID); end; end
        try debugStamp(err, 1, obj); catch, debugStamp(); end;
        obj.ParentFigure = [];
      end
      
    end
    
    
    function value = get.Padding(obj)
      value = obj.Padding;
    end
    
    function set.Padding(obj, value)
      obj.Padding = changeSet(obj.Padding, value);
      try obj.resizeComponent; end
    end
    
  end
  
  methods(Static, Hidden=true)
    function OPTIONS  = DefaultOptions()
      GrasppeAlpha.Utilities.DeclareOptions;
    end
  end
  
  %   methods(Abstract, Static, Hidden)
  %     options  = DefaultOptions()
  %     obj = Create()
  %   end
  
  
end

