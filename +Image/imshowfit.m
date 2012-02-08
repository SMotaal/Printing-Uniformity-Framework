function h = imshowfit( varargin )
%IMSHOWFIT Displays images with the initial magnification set to fit
%   Arguments are directed to imshow so refer to imshow for more details.
%   The arguments 'InitialMagnification','fit' are appended at the end of
%   the list of arguments when calling imshow.

h = imshow(varargin{:}, 'InitialMagnification','fit');
end

