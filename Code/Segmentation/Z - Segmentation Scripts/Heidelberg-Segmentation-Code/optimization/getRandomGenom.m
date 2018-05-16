function genom = getRandomGenom(length, values)
% GETRANDOMGENOM
% Creates a genom with random entries
% 
% Part of a *FAILED* approch to segmentation optimization by genetic
% optimization. 
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
% Initial version some time in 2012.

genom = zeros(1, length);
for i = 1:length
    pos = randi(size(values, 2));
    genom(i) = values(pos);
end
end