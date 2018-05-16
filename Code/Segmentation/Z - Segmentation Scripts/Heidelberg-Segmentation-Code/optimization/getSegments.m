function segments = getSegments(idx)
% GETSEGMENTS
% Returns the continous lines on an idx image
% 
% Part of a *FAILED* approch to segmentation optimization by genetic
% optimization. 
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
% Initial version some time in 2012.

segments = zeros(1, 3);

k = 1;
for i = 1:size(idx, 1)
    runVal = 0;
    startj = 0;
    for j = 1:size(idx, 2)
        if idx(i,j) == 1
            if runVal
                segments(k, 1) = i;
                segments(k, 2) = startj;
                segments(k, 3) = j - 1;
                k = k + 1;
                runVal = 0;
            end
        else
            if ~runVal
                startj = j;
                runVal = 1;
            end
        end
    end
    if runVal
        segments(k, 1) = i;
        segments(k, 2) = startj;
        segments(k, 3) = size(idx, 2);
        k = k + 1;
    end
end
end