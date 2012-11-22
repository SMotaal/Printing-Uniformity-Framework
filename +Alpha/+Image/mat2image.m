function [ image ] = mat2image( mat )
%MAT2IMAGE Reshapes a matrix to an image
%   ...

image = reshape(permute(mat, [2 1]), size(mat,2),1,size(mat,1));

end

