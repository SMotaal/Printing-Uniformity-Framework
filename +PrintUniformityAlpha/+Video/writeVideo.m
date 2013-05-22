function [ mVideoWriter ] = writeVideo( file, frames, frameindex )
  %WRITEVIDEO Summary of this function goes here
  %   Detailed explanation goes here
  
  nFrames = numel(frames);
  
  default frameindex [];
  
  if isempty(frameindex)
    frameindex = 1:nFrames;
  end
  
  frameindex(end+1) = frameindex(end)+1;
  
  mVideoWriter = VideoWriter(file,'Motion JPEG AVI');
  mVideoWriter.FrameRate = 10;
  mVideoWriter.Quality = 100;
  
  try
    open(mVideoWriter);
    try
      for f = 1:nFrames
        for i = frameindex(f):frameindex(f+1)-1;
          writeVideo(mVideoWriter,frames(f));
        end
      end
    catch err
      dealwith(err);      
    end
    close(mVideoWriter);
  catch err
    dealwith(err);    
  end
     
  if (ismac)
    exportMOV([], [], mVideoWriter);
    % tEncodeMOV = timer('Tag', ['EncodeMOV:' mVideoWriter.Filename], ...
    %   'StartDelay', 1, 'TimerFcn', {@exportMOV, mVideoWriter});
    % start(tEncodeMOV);
  end

end

function exportMOV(source, event, mVideoWriter)
  if (ismac)
    avifile = fullfile(mVideoWriter.Path, mVideoWriter.Filename);
    if (PrintUniformityAlpha.Video.encodeMov(avifile)==0)
      trashpath=fullfile(getenv('HOME'),'.Trash');
      movefile(avifile,[trashpath filesep]);
    end
  end
  
  try stop(source); delete(source); end
end
