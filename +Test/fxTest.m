function [ output_args ] = fxTest( input_args )
%FXTEST Summary of this function goes here
%   Detailed explanation goes here

fxData1 = wipeStripes(20,56,72);
fxData2 = 1; %-cornerBoxes(20,56,72);
fxData = fxData1.*fxData2;
fxAnimate(fxData);
close;

end

function out = fxAnimate (data, t)
try
  t=t;
catch
  t=0.25;
end
figure('WindowStyle','docked');
% figure(gcf)
imshow(squeeze(data(1,:,:)));
pause(2);
for i = 1:size(data,1)
  frameData = squeeze(data(i,:,:));
  if (numel(findobj('Type','figure'))==0), break; end
  imshow(frameData,[]);
  pause(t);
end
end


function out = cornerBoxes(f, w, h)
v = 1;
if (f==0), f=max(w,h)/2; end
out = zeros(f, w, h);

for i = 1:f
  newData = zeros(w, h);
  newData(1:i,1:i) = v;
  newData(end-i:end,end-i:end) = v;
  newData(end-i:end,1:i) = v;
  newData(1:i,end-i:end) = v;
  
  out(i,:,:) = newData;
end
end

function out = wipeStripes(f, w, h)
v=1;
if (f==0), f=w/2; end
out = zeros(f, w, h);
newData = zeros(w, h);
for i = 1:f;
  newData(i*2,1:end) = v;
  out(i,:,:) = newData;
end
end

function out = zoomingStripes(f, w, h)
v=1;
if (f==0), f=w/2; end
out = zeros(f, w, h);
newData = zeros(w, h);
for i = 1:f;
  if i>1
    newData = zoomIn(newData,1.01);
  else
    newData(1:2:end,1:end) = v;
  end
  out(i,:,:) = newData;
end
end

function out = zoomIn(data, n)
  try
    n=n;
  catch
    n=2;
  end
  w = size(data,1);
  h = size(data,2);
  w2 = round(w/2);
  h2 = round(h/2);
  newData = data;
  zoomData = interp2(newData,n);
  out = zoomData(w2:w2+w-1,h2:h2+h-1);
end