classdef PUAnalyzer < GrasppeAlpha.Core.App
  %PUANALYZER Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
        obj = main(varargin);
  end
  
  methods
    function obj = PUAnalyzer(varargin)
      obj = obj@GrasppeAlpha.Core.App(varargin{:});
    end
    
    function Main(varargin)
      msgbox('PU Main');
    end
  end
  
end

