function [ mat ] = image2mat( image )
%IMAGE2MAT reshapes an image to a matrix
%   ...

mat = ipermute(squeeze(image), [2 1]);

end

