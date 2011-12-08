%% Define common functions
reshapeToImage = @ (mat) ...
    reshape(permute(mat, [2 1]), size(mat,2),1,size(mat,1));

reshapeToMat = @ (image) ...
    ipermute(squeeze(image), [2 1]);

  
quote         = @(x) ['''',x,''''];
