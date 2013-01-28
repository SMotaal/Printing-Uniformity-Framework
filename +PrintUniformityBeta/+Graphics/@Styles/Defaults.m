function style = Defaults(update)
  
  if update, STYLE = []; end
  
  Font  = fontSpecs;
  Color = colorSpecs;
  
  
  PlotFigure.Color.Color          = Color.Background;   % Background Color
  
  PlotAxes.Font                   = Font.Styles.Label;
  PlotAxes.Color.Color            = Color.Clear;        % Background Color
  
  PlotText.Font                   = Font.Styles.Text;
  PlotText.Color.Color            = Color.Text;         % Text Color  
  PlotText.Color.BackgroundColor  = Color.Clear;
  PlotText.Color.EdgeColor        = Color.Clear;
  
  
  
  feval([eval(NS.CLASS) '.DefineStyle']);
end

function color = colorSpecs()
  color.Background          = [1 1 1];
  color.Clear               = 'none';
  color.Text                = [0 0 0];
  color.Highlight           = [0.8 0.8 0];
  
  color.Max                 = [1 0 0];
  color.Min                 = [1 0.8 0.8];
  
  color.Hot                 = [1 0 0];
  color.Warm                = [1 1 0];
  color.Cool                = [0 1 0];
  color.Cold                = [0 0 1];
end

function font = fontSpecs()
  font.SansSerif            = {'DIN', 'Gill Sans', 'Helvetica', 'Arial'};
  font.SansSerifBold        = font.SansSerif
  font.SansSerifItalic      = font.SansSerif
  font.SansSerifBoldItalic  = font.SansSerif
  
  font.Serif                = {'Georgia', 'Bell MT', 'Palatino', 'Times New Roman'};
  font.SerifBold            = font.Serif
  font.SerifItalic          = font.Serif
  font.SerifBoldItalic      = font.Serif
  
  font.Regular              = 'normal';
  font.Italic               = 'italic';
  font.Bold                 = 'bold';
  
  font.Tiny                 = 6;
  font.Small                = 8;
  font.Medium               = 9;
  font.Large                = 10;
  font.Huge                 = 12;
  
  font.Pixels               = 'pixels';
  font.Points               = 'points';
  font.Relative             = 'normalized';
  
  
  
  font.Styles.Comment       = HG.DefineFont(font.SansSerifBold, 0, font.Tiny);
  font.Styles.Label         = HG.DefineFont(font.SansSerif,     0, font.Small);
  font.Styles.Text          = HG.DefineFont(font.SansSerif,     0, font.Medium);
  font.Styles.Heading       = HG.DefineFont(font.SansSerifBold, 1, font.Large);
  font.Styles.Title         = HG.DefineFont(font.SansSerifBold, 1, font.Huge);  
end

% function c = systemFonts(update)
%   persistent C;
%
%   if isempty(C) || isequal(lower(update), 'update')
%     C = listfonts;
%   end
%
%   c = C;
% end
%
%
% function f = matchFont1(fonts, weight)
%   f = 'Helvetica';
%   c = systemFonts
%
%   if ~iscell(fonts), fonts = {fonts};
%     for m = 1:numel(fonts)
%       s = fonts{m};
%       n = ~cellfun(@isempty, regexpi(s, c)); %strcmpi(fonts{m}, c);
%       if any(n), f = c(n); end
%       return;
%     end
%
%
%
%   end
% end

% function fname = defineFont(familyNames, style, fontSize, fontUnits)
%
%   persistent families
%
%   if ~exist('style',  'var'), style   = 0;            end
%   if ~exist('size',   'var'), fontSize    = 10;       end
%   if ~exist('units',  'var'), fontUnits   = 'pixels'; end
%
%   if ischar(style)
%     bold    = ~isempty(regexpi(style, 'b\w+'));
%     italic  = ~isempty(regexpi(style, 'i\w+'));
%     style   = bold*1 + italic*2;
%   end
%
%   fontWeight  = 'normal';
%   if bold,  fontWeight = 'bold'; end
%
%   fontAngle   = 'normal';
%   if italic,  fontAngle = 'italic'; end
%
%   notBoldFilter     = ('Bold|Demi|Heavy');
%   notItalicFilter   = ('Italic|Oblique');
%   neitherFilter     = [notBoldFilter '|' notItalicFilter];
%
%   filter  = neitherFilter;
%   variant = 'Regular';
%
%   if bold && ~italic
%     filter  = notItalicFilter;
%     variant = 'Bold';
%   elseif ~bold && italic
%     filter = notBoldFilter;
%     variant = 'Italic';
%   elseif bold && italic
%     filter = '';
%     variant = 'BoldItalic';
%   end %else neitherFilter variant = 'Regular';
%
%   fonts = fontFamilies();
%
%   fontName = 'Helvetica';
%
%   if ~iscell(fonts), fonts = {fonts};
%     for m = 1:numel(fonts)
%       fname   = lower(fonts{m});
%
%       if isfield(families, fname) && isfield(families.(fname), variant)
%         fontName = families.(fname).(variant)
%         break;
%       end
%
%       fidx    = ~cellfun(@isempty, regexpi(['^' fname '[-\s]?'], fonts));
%       if any(fsidx)
%         fontName = fonts{find(fsidx,1,'first')}; %fontName = fontName{1};
%         families.(fname).(variant) = fontName;
%         break;
%       end
%
%       if ~isempty(filter)
%         fsidx   = ~cellfun(@isempty, regexpi(['^' fname '[-\s].*?[(' filter ')]'], fonts));
%         if any(fidx)
%           fontName = fonts{find(fidx,1,'first')}; % fontName = fontName{1};
%           families.(fname).(variant) = fontName;
%           break;
%         end
%       end
%     end
%   end
%
%   f.FontAngle   = fontAngle;
%   f.FontName    = fontName;
%   f.FontSize    = fontSize
%   f.FontWeight  = fontWeight;
%   f.FontUnits   = fontUnits;
%
% end
