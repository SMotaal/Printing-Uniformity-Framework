%% L*-Density Equations
% Here are the simplified L* and Density equations for print. The threshold for these formulas are L* > 9.1399 and D > 1.9923.
% If	Yn = 100  and  L<7.9996  or  D>2.0528	Absolute White
%     Yn =  93  and  L<8.5872  or  D>2.0212	Type-1 Gloss-Coated, Wood-Free
%     Yn =  92  and  L<8.676   or  D>2.0166	Type-2 Matte-Coated, Wood-Free
%     Yn =  87  and  L<9.1399  or  D>1.9923	Type-3 Gloss-Coated, Web
%   	Yn =  92  and  L<8.676   or  D>2.0166	Type-4 Uncoated, White
%   	Yn =  88  and  L<9.0443  or  D>1.9972	Type-5 Uncoated, Slightly Yellowish

%% LD-Limits
%       L   YN                LY                DY
%       ------------------------------------------------------------------------
%       100 1.000000000000000	7.99959199306381  2.05276239212933
%        93 0.829670266308582	9.54085019445322	1.97166791827045
%        92 0.807044159252122	9.77733954810557	1.95965969090943
%        87 0.700063937635820	11.0286667106350	1.89790009856409
%        88 0.720652753290418	10.7687756845712	1.91048844234492
%
% YSET=[];
% L=100; YN=YL(L,1); YSET(end+1,:) = [L YN LY(0.008856,YN) DY(0.008856,YN)];
% L= 93; YN=YL(L,1); YSET(end+1,:) = [L YN LY(0.008856,YN) DY(0.008856,YN)];
% L= 92; YN=YL(L,1); YSET(end+1,:) = [L YN LY(0.008856,YN) DY(0.008856,YN)];
% L= 87; YN=YL(L,1); YSET(end+1,:) = [L YN LY(0.008856,YN) DY(0.008856,YN)];
% L= 88; YN=YL(L,1); YSET(end+1,:) = [L YN LY(0.008856,YN) DY(0.008856,YN)];
%


%% LD-Equations
Y2V = @(Y, Yn)  -log10(Y./Yn);
Y2L = @(Y, Yn)  (116.*(Y./Yn).^(1./3))-16;
V2Y = @(D, Yn)  Yn./10.^D;
L2Y = @(L, Yn)  ((L+16)./116).^3.*Yn;
L2V = @(L)      -log10(((L+16)./116).^3);
V2L = @(D)      (116./10.^(D./3))-16;
