function obj = main(varargin)
  try
    obj.main@GrasppeAlpha.Core.App(varargin{:});
  catch err
    obj = PrintUniformityBeta.PUAnalyzer(varargin{:});
  end
end
