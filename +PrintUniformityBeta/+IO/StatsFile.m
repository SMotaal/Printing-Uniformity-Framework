classdef StatsFile < GrasppeAlpha.Data.Models.SimpleDataModel
  %STATSFILEMODEL Summary of this class goes here
  %   Detailed explanation goes here
  
  properties(Hidden)
    matFile                 = [];
    filePath                = '';
  end
  
  properties(Dependent)
    % Data                    = [];
  end
  
  methods
    function obj = StatsFile(filepath)
      obj.filePath          = filepath;
    end
  end
  
  methods(Hidden)
    
    function preDataGet(obj)
      if isempty(obj.matFile) || ~isa(obj.matFile, 'matlab.io.MatFile') || ~isvalid(obj.matFile) % && exist(obj.filePath, 'file')==2
        obj.matFile         = matfile(obj.filePath);
        obj.DATA            = obj.matFile;
      end
    end
    
    function delete(obj)
      try delete(obj.matFile); end
    end
    
  end
  
end

