classdef upStyledObject < handle
  %UPSTYLEDOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
  end
  
  properties (Dependent = true)
    Styles
  end

  
  methods
    function [styles] = get.Styles(obj)
      persistent DefinedStyles;
      default DefinedStyles = obj.getStatic('DefaultStyles');
      styles = DefinedStyles;
    end    
  end
  
  methods(Static)
    function styles   = DefaultStyles()
      
      %% Declarations
      Define            = @horzcat;
      
      %% Font Declarations
      Type.Face           = 'FontName';
      Type.Angle          = 'FontAngle';
      Type.Weight         = 'FontWeight';
      Type.Unit           = 'FontUnits';
      Type.Size           = 'FontSize';
      
      Type.SansSerif      = {Type.Face,     'Gill Sans'};  % 'Linotype Syntax Com Medium'
      Type.Serif          = {Type.Face,     'Bell MT'};
      Type.MonoSpaced     = {Type.Face,     'Lucida Sans Typewriter'};
      
      Type.BookWeight     = {Type.Weight,   'Normal'};
      Type.BoldWeight     = {Type.Weight,   'Bold'};
      
      Type.StraightAngle  = {Type.Angle,    'Normal'};
      Type.ObliqueAngle   = {Type.Angle,    'Italic'};
      
      Type.PointSize      = {Type.Unit,     'Point'};
      
      Type.Tiny           = Define(Type.PointSize,    Type.Size,  8       );
      Type.Small          = Define(Type.PointSize,    Type.Size,  10      );
      Type.Medium         = Define(Type.PointSize,    Type.Size,  12      );
      Type.Large          = Define(Type.PointSize,    Type.Size,  14      );
      Type.Huge           = Define(Type.PointSize,    Type.Size,  16      );
      
      Type.Regular        = Define(Type.BookWeight,   Type.StraightAngle  );
      Type.Bold           = Define(Type.BoldWeight,   Type.StraightAngle  );
      Type.Italic         = Define(Type.BoldWeight,   Type.ObliqueAngle   );
      Type.BoldItalic     = Define(Type.BoldWeight,   Type.ObliqueAngle   );
      
      %% Font Styles
      TextFont        = Define(Type.Serif,        Type.Italic,    Type.Medium );
      EmphasisFont    = Define(Type.Serif,        Type.Regular,   Type.Medium );
      LabelFont       = Define(Type.SansSerif,    Type.Regular,   Type.Medium );
      TitleFont       = Define(Type.SansSerif,    Type.Bold,      Type.Huge   );
      HeadingFont     = Define(Type.SansSerif,    Type.Bold,      Type.Large  );
      LegendFont      = Define(Type.SansSerif,    Type.Regular,   Type.Small  );
      OverlayFont     = Define(Type.SansSerif,    Type.Regular,   Type.Tiny   );
      TableFont       = Define(Type.MonoSpaced,   Type.Regular,   Type.Medium );
      CodeFont        = Define(Type.MonoSpaced,   Type.Regular,   Type.Small  );
      
      %% Layout Styles
      Layout.Horizontal   = 'HorizontalAlignment';
      Layout.Vertical     = 'VerticalAlignment';
      
      Layout.Left         = {Layout.Horizontal, 'Left'      };
      Layout.Center       = {Layout.Horizontal, 'Center'    };
      Layout.Right        = {Layout.Horizontal, 'Right'     };
      Layout.Top          = {Layout.Vertical,   'Top'       };
      Layout.Middle       = {Layout.Vertical,   'Middle'    };
      Layout.Bottom       = {Layout.Vertical,   'Bottom'    };
      Layout.Caps         = {Layout.Vertical,   'Cap'       };
      Layout.Baseline     = {Layout.Vertical,   'Baseline'  };
      
      
      
      %% Graphic Styles
      Axes.SmoothLines    = {'LineSmoothing', 'on'};
      
      Axes.Orthographic   = {'Projection', 'Orthographic'};
      Axes.Perspective    = {'Projection', 'Perspective'};
      
      Axes.BoxClipped     = {'Box','on'};
      Axes.Clipped        = {'Box','off', 'Clipping', 'on'};
      Axes.Unclipped      = {'Box','off', 'Clipping', 'off'};
      
      
      Grid.MajorLine      = 'GridLineStyle';
      Grid.MinorLine      = 'MinorGridLineStyle';
      Grid.XColor         = 'XColor';
      Grid.YColor         = 'YColor';
      Grid.ZColor         = 'YColor';
      
      Line.None           = {'LineStyle', 'none'; 'LineWidth', 0.00};
      
      Line.Hairline       = {'LineWidth', 0.25};
      Line.Thin           = {'LineWidth', 0.50};
      Line.Medium         = {'LineWidth', 0.50};
      Line.Thick          = {'LineWidth', 1.50};
      
      Line.Solid          = {'LineStyle', 'none'};
      Line.Dotted         = {'LineStyle', 'none'};
      Line.Dashed         = {'LineStyle', 'none'};
      Line.Mixed          = {'LineStyle', 'none'};
      
      
      %% Defined Styles
      NormalStyle         = Define(TextFont);
      AxesStyle           = Define(LegendFont);
      DataStyle           = Define(OverlayFont);
      TitleStyle          = Define(TitleFont, Layout.Center, Layout.Middle);
      
      clear Define;
      styles              = WorkspaceVariables(true);
      
    end
    
  end
  
end

