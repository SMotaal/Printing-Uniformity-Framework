function obj = main(varargin)
  try
    obj.main@Grasppe.Core.App(varargin{:});
  catch err
    obj = Grasppe.PrintUniformity.PUAnalyzer(varargin{:});
  end
end
