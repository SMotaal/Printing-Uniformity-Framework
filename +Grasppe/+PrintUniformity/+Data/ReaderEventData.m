classdef ReaderEventData < Grasppe.Data.ChangeEventData
  %READEREVENTDATA Printing uniformity data event
  %   Detailed explanation goes here
  
  properties
    
  end
  
  methods (Access=protected)
    function evt = ReaderEventData(varargin)
      evt = evt@Grasppe.Data.ChangeEventData(varargin{:});
    end
  end
  
  methods (Static)
    
    function parameters = GetDataParameters()
      parameters  = {'CaseID', 'SetID', 'VariableID', 'SheetID'};
    end
   
    function evt = CreateEventData(parameter, newValue, previousValue, previousData)
      import Grasppe.PrintUniformity.Data.*;
      
      if nargin < 3,  previousValue = []; end
      if nargin < 4,  previousData  = []; end
      
      evt         = ReaderEventData(parameter, newValue, previousValue, previousData);
    end
            
  end
  
end

