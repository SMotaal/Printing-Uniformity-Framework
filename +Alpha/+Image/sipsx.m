function [ profile ] = sipsx( filename )
%SIPSX Wrapper function to extract profiles from images using Mac OS sips
%   sipsx generates a Mac OS X call to the Scriptable Image Processing
%   System (sips) to extract and load embedded icc profiles from images.
%   Two opertions are carried out. First, the system command 'sips -x ...'
%   is called to export the icc profile with the same filename as the input
%   image adding the .icc suffix. Finally, an iccread is then called on the
%   extracted icc profile file and returned.

if exist(filename,'file')
    [status, result] = system(['sips -x "' filename '.icc" "' filename '"']);
    profile = iccread([filename '.icc']);
end

end
