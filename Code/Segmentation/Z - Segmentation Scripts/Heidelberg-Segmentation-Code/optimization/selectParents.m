function parentIdx = selectParents(sizePop, numCouples, mode, factor)
% SELECTPARENTS
% Generates random couple indices for a genetic algorithm
% 
% Part of a *FAILED* approch to segmentation optimization by genetic
% optimization. 
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
% Initial version some time in 2012.

if nargin < 3
    mode = 'uniform';
end

parentIdx = zeros(numCouples,2);

if strcmp(mode, 'uniform')
    for i = 1:numCouples
        idx = randperm(sizePop);
        parentIdx(i, 1) = idx(1);
        parentIdx(i, 2) = idx(2);
    end
else
    for i = 1:numCouples
        [ignore,idx] = sort(rand(1,sizePop) .* ((1:sizePop) .^ factor));
        parentIdx(i, 1) = idx(1);
        parentIdx(i, 2) = idx(2);
    end
end