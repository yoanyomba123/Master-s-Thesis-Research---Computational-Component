function sumSeg = getSegmentSums(segments, img)
% 
% Part of a *FAILED* approch to segmentation optimization by genetic
% optimization. 
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
% Initial version some time in 2012.

sumSeg = zeros(size(segments, 1), 1);
for i = 1:size(segments, 1)
    sumSeg(i) = sum(img(segments(i,1), segments(i,2):segments(i,3)));
end

end
