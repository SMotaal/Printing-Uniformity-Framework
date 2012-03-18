classdef PatchObject < PlotObject
  %SURFACEOBJECT Superclass for patch plot objects
  %   Detailed explanation goes here
  
  properties (Transient, Hidden)
    %  AlphaDataMapping, Annotation, CData, CDataMapping, DisplayName,
    %  FaceVertexAlphaData, FaceVertexCData, EdgeAlpha, EdgeColor, FaceAlpha,
    %  FaceColor, Faces, LineStyle, LineWidth, Marker, MarkerEdgeColor,
    %  MarkerFaceColor, MarkerSize, Vertices, XData, YData, ZData,
    %  FaceLighting, EdgeLighting, BackFaceLighting, AmbientStrength,
    %  DiffuseStrength, SpecularStrength, SpecularExponent,
    %  SpecularColorReflectance, VertexNormals, NormalMode
    
    ComponentType = 'patch';
    
    ComponentProperties = { ...
      'Clipping', ...
      'DisplayName', ...
      'CData', 'CDataMapping', ...
      'XData', 'YData', 'ZData', ...
      {'AntiAliasing' 'LineSmoothing'} ...
      };
    
    ComponentEvents = {};
    
    DataProperties = {'XData', 'YData', 'ZData'}; %, 'SampleID', 'SourceID', 'SetID'};
    
  end
  
  properties (SetObservable, GetObservable)
    Clipping, DisplayName='', CData, CDataMapping, XData, YData, ZData
    AntiAliasing = 'on';
  end
  
  methods (Access=protected)
    function obj = PatchObject(parentAxes, varargin)
      obj = obj@PlotObject(parentAxes, varargin{:});
    end
  end
  
  methods (Static, Hidden)
    function options  = DefaultOptions( )
      
      IsVisible     = true;
      IsClickable   = true;
      
      options = WorkspaceVariables(true);
    end
    
  end
  
end

