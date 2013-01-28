classdef Styles < GrasppeAlpha.Data.Models.SimpleDataModel
  %STYLES Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (Dependent)
    Style
  end
  
  methods (Access=private)
    function obj=Styles(style)
      obj.DATA = style;
    end
  end
  
  methods
    function style = get.Style(obj)
      style = obj.DATA;
    end
  end
  
  methods (Static)
    style = PlotTitle();
    style = DataLabel();
%     function style = PlotTitle()
% 
%       FontSize    = 10;
%       Color       = [0 0 0];
%       Margin      = 0;
%       
%       feval([eval(NS.CLASS) '.DefineStyle']);
%     end
    
%     function style = DataLabel()
%       FontSize    = 10;
%       
%       feval([eval(NS.CLASS) '.DefineStyle']);
%     end
    
    function DefineStyle()
      
      evalin('caller', 'persistent STYLE');
      style = evalin('caller', 'STYLE');
      
%       empty = false;
%       try empty = isempty(fieldnames(style.DATA)); end
      
      if ~isa(style, eval(NS.CLASS))
        style = evalin('caller', 'WorkspaceVariables');
        if isfield(style, 'STYLE'), style = rmfield(style, 'STYLE'); end
        style = feval(eval(NS.CLASS), style);
        assignin('caller', 'STYLE', style);
      end
      
      assignin('caller', 'style', style);
      
    end
  end
  
end

