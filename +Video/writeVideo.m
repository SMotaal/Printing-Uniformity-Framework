function [ mVideoWriter ] = writeVideo( file, frames )
  %WRITEVIDEO Summary of this function goes here
  %   Detailed explanation goes here
   
  mVideoWriter = VideoWriter(file,'Motion JPEG AVI'); 
  mVideoWriter.FrameRate = 10;
  mVideoWriter.Quality = 100;
  
  try
    open(mVideoWriter); % runlog(['.']);
    nFrames = numel(frames);
    for f = 1:nFrames % numel(frames)
      writeVideo(mVideoWriter,frames(f)); %runlog(['.']);      
    end
  catch err
    close(mVideoWriter);
  end  
end

