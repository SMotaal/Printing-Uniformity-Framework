function ProgressUpdate(progress, varargin)
  %SETSTATU Summary of this function goes here
  %   Detailed explanation goes here
  
  persistent hProgress mProgress;
  
  if ~exist('progress', 'var') || isempty(progress)
    try
      if ~isempty(varargin)
        if isempty(mProgress), mProgress = 0; end
        progress            = mProgress;
      else
        set(hProgress, 'Visible', 'off');
        return;
      end
    catch err
      try delete(hProgress); end
      hProgress             = [];
      return;
    end
  end
  
  if isempty(hProgress) || ~ishandle(hProgress)
    hProgress               = waitbar(progress, varargin{:}, 'Units', 'pixels', 'Position', [25 75 365 75]);
    set(hProgress, 'Units', 'normalized');
  else
    waitbar(progress, hProgress, varargin{:});
  end
  
  mProgress                 = progress;
  
  set(hProgress, 'Visible', 'on');
  
  
  jProgress = get(handle(hProgress),'JavaFrame');

  try
    jProgress.fFigureClient.getWindow().setAlwaysOnTop(true);
  catch err
    jProgress.fHG1Client.getWindow().setAlwaysOnTop(true);
  end
  % try  end
  
  titleHandle               = get(findobj(hProgress,'Type','axes'),'Title');
  set(titleHandle,'FontSize', 8, 'FontWeight', 'bold');
end

