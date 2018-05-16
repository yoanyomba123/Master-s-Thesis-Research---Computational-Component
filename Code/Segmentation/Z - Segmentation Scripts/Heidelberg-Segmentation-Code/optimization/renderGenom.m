function img = renderGenom(fixedLayer, layers, genom, segments)
% RENDERGENOM
% Creates position image out of genom and the related segments
% 
% Part of a *FAILED* approch to segmentation optimization by genetic
% optimization. 
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
% Initial version some time in 2012.

img = fixedLayer;
for i = 1:size(genom, 2)
    img(segments(i,1), segments(i,2):segments(i,3)) = layers(segments(i,1), segments(i,2):segments(i,3), genom(i));
end
end