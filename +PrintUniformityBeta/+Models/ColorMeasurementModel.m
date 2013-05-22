classdef ColorMeasurementModel
  %ColorMeasurementModel Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    SpectralReflectance
    CIELab
    CIEXYZ
    ISOVisualDensity
    StatusT
    ToneValue
    sRGB
    MeasurementData
    MeasurementModel
  end
  
  properties (SetAccess=immutable, GetAccess=protected)
    measurementData
    measurementModel
  end
  
  methods % (Access=protected)
    function obj = ColorMeasurementModel(data, model)
      obj.measurementData     = data;
      obj.measurementModel    = model;
    end
  end
  
  
  
end

