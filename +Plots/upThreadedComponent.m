classdef upThreadedComponent
  %UNTITLED Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    
%     function response = requestAuthorization(operation, state, callback)
%       
%       persistent change states
%       
%       default state true;
%       default callback [];
%       
%       if isempty(change)
%         change.sourcedata;
%         change.setdata;
%         change.sheetdata;        
%         change.userdata;
%       end
% 
%     end

  
  
    
  methods (Static)
%     function state = updateState(states, state)
%       
%       persistent stateNames;
%       
%       if ~isValid('states','struct')
%         states = emptyStruct('initializing', 'idling', ...
%           'active', 'waiting', 'buffering', 'retrieving', 'updating', ...
%           'rendering', 'exporting');
%       end
%       
%       default stateNames = fieldnames(states);
%       
%       if (isValid('state', 'char') && stropt(state, stateNames))
%         %% Change Request
%         
%         %% Change State
%         switch (newState)
%           case 'initializing'   % Constructing Object
%             prestate      = [];
%             constraints   = {};
%             
% 
%           case 'retrieving'     % Retrieving source data
%             constraints   = {'initializing', 'exporting'};
%             
% 
%           case 'rendering'      % Painting source data
%             constraints   = {'initializing', 'retrieving'};
%             
% 
%           case 'refreshing'     % Refreshing plot data            
%             constraints   = {'initializing', 'retrieving', 'rendering'};
%             
% 
%           case 'exporting'      % Saving plot series
%             prestate      = false;
%             constraints   = {'initializing', 'retrieving', 'rendering', 'exporting'};
%             
% 
% %           case 'idling'         % Awaiting activation (Ready)
% %             constraints   = {'initializing', 'retrieving', 'rendering', 'refreshing'};
% %           case 'active'         % Accepting input
% %             precondition  = {'initializing=false'};
% % 
% %           case 'waiting'        % Awaiting input
% %             precondition  = {'initializing=false'};
% % 
% %           case 'animating'      % Running plot series (Play / Pause)
% %             precondition  = {'initializing=false'};
%       end
%       
%     end    
  end
  
end

