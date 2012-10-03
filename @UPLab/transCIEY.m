%% TRANSECIEY Testing CIE-Y to L* and D

%% Load sample data 

% function [ output_args ] = transCIEY( input_args )
%   %TRANSCIEY Summary of this function goes here
%   %   Detailed explanation goes here
%   
%   
% end
% 


% Here are the simplified L* and Density equations for print. The threshold for these formulas are L* > 9.1399 and D > 1.9923.

% If	Yn = 100  and  L<7.9996  or  D>2.0528	Absolute White
%     Yn =  93  and  L<8.5872  or  D>2.0212	Type-1 Gloss-Coated, Wood-Free
%     Yn =  92  and  L<8.676   or  D>2.0166	Type-2 Matte-Coated, Wood-Free
%     Yn =  87  and  L<9.1399  or  D>1.9923	Type-3 Gloss-Coated, Web
%   	Yn =  92  and  L<8.676   or  D>2.0166	Type-4 Uncoated, White
%   	Yn =  88  and  L<9.0443  or  D>1.9972	Type-5 Uncoated, Slightly Yellowish

Y2V           = @(Y, Yn)  -log10(Y./Yn);
Y2L           = @(Y, Yn)  (116.*(Y./Yn).^(1./3))-16;

V2Y           = @(D, Yn)  Yn./10.^D;
L2Y           = @(L, Yn)  ((L+16)./116).^3.*Yn;

L2V           = @(L)      -log10(((L+16)./116).^3);
V2L           = @(D)      (116./10.^(D./3))-16;


l             = 0:5:100;
v             = linspace(2, 0, numel(l));
y             = l; % 10:5:100;

ylvL          = [Y2L(y, 100);   l;  V2L(v)];
ylvLab(:,:,1) = ylvL; ylvLab(:,:,2:3) = 0;

imwrite(ylvLab, fullfile('Output', 'YLVScale.tiff'), ...
  'ColorSpace', 'cielab', 'Resolution', 4, 'Compression', 'lzw');


