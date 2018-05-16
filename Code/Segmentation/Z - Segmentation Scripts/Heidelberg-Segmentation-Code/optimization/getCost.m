function cost = getCost(img, mode, dist)
% GETCOST 
% Returns the result of a cost function for a given position image
% 
% Part of a *FAILED* approch to segmentation optimization by genetic
% optimization. 
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
% Initial version some time in 2012.

if nargin < 3
    dist = [1 1];
end

if strcmp(mode, 'L2')
    [fx, fy] = gradient(img, dist(1), dist(2));
    fAbs = sqrt(fx .* fx + fy .* fy);
    cost = sum(sum(fAbs)) / numel(img);
elseif strcmp(mode, 'L3')
    [fx, fy] = gradient(img, dist(1), dist(2));
    fAbs = (abs(fx) .^ 3 + abs(fy) .^ 3) .^(1/3);
    cost = sum(sum(fAbs)) / numel(img);
elseif strcmp(mode, 'L1')
    [fx, fy] = gradient(img, dist(1), dist(2));
    fAbs = sqrt(abs(fx)  + abs(fy));
    cost = sum(sum(fAbs)) / numel(img);
end

end