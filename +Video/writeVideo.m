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
    open(mVideoWriter); % runlog(['.']);
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
    avifile = fullfile(mVideoWriter.Path, mVideoWriter.Filename);
    if (Video.encodeMov(avifile)==0)
      trashpath=fullfile(getenv('HOME'),'.Trash');
      movefile(avifile,[trashpath filesep]);
    end
  end

end

%   stepTimer = tic; runlog([TABS 'Exporting ']); % int2str(nSheets) ' sheets / ' int2str(numel(M)) ' frames to ' exporting.aviName ' ']);

%   mVideoWriter = Video.writeVideo(exporting.file, M);
%
%   runlog([int2str(nSheets) ' sheets / ' int2str(numel(M)) ' frames to ' exporting.name ' ']);
%
%
%   runlog([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
%
%   if (ismac)
%     stepTimer = tic; runlog([TABS 'Encoding QuickTime Movie ...']);
%     avifile = fullfile(mVideoWriter.Path, mVideoWriter.Filename);
%     if (Video.encodeMov(avifile)==0)
%       trashpath=fullfile(getenv('HOME'),'.Trash');
%       movefile(avifile,[trashpath filesep]);
%     end
%     runlog([' OK \t\t' num2str(toc(stepTimer)) '\t seconds\n']);
%   end
