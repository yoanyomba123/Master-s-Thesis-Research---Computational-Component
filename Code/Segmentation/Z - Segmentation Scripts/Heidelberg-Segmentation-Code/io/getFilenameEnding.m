function filenameEnding = getFilenameEnding(filename)
% GETFILENAMEENDING: Returns the filename ending of the filename without 
% the '.'.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: Some time in 2010
% Revised comments: November 2015

[token, remain] = strtok(filename, '.');
while numel(remain) ~= 0
    [token, remain] = strtok(remain, '.');
end

filenameEnding = token;