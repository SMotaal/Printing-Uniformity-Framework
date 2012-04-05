classdef Model < Grasppe.Core.Prototype & matlab.mixin.Copyable
  %MODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    
    function obj = Model(varargin)
      obj = obj@Grasppe.Core.Prototype;
      
      if (nargin > 0), obj.setOptions(varargin{:}); end
    end
  end
  
  methods (Access = protected)
    % Override copyElement method:
    function cpObj = copyElement(obj)
      % Make a shallow copy of all shallow properties
      cpObj = copyElement@matlab.mixin.Copyable(obj);
      
      % Make a deep copy of the deep object
      % cpObj.DeepObj = copy(obj.DeepObj);
    end
    
    function [names values] = setOptions(obj, varargin)
      
      [names values paired pairs] = obj.parseOptions(varargin{:});
      
      if (paired)
        for i=1:numel(names)
          try
            if ~isequal(obj.(names{i}), values{i})
              obj.(names{i}) = values{i};
            end
          catch err
            if ~strcontains(err.identifier, 'noSetMethod')
              try debugStamp(obj.ID, 5); end
              disp(['Could not set ' names{i} ' for ' class(obj) '. ' err.message]);
            end
          end
        end
      end
      
    end
    
    function [names values paired pairs] = parseOptions(obj, varargin)
      
      names        = varargin;
      extraArgs   = {};
      
      %% Parse Lead Structures
      while (~isempty(names) && isstruct(names{1}))
        stArgs    = structArgs(names{1});
        extraArgs = [extraArgs stArgs]; %#ok<*AGROW>
        
        if length(names)>1
          names = names(2:end);
        else
          names = {};
        end
        
      end
      
      names = [extraArgs, names];
      
      [pairs paired names values ] = pairedArgs(names{:});
      
    end
    
  end
  
end

