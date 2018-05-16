function genomMut = mutateGenomIdx(genom, genomIdx, values)
% 
% Part of a *FAILED* approch to segmentation optimization by genetic
% optimization. 
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
% Initial version some time in 2012.

genomMut = genom;

idx = randperm(numel(genomIdx));
genomIdx = genomIdx(idx);

numMut = round(rand(1) * numel(genomIdx));
genomIdx = genomIdx(1:numMut);

for g = 1:numel(genomIdx)
    pos = randi(size(values, 2)-1);
    valuesFliped = values(values ~= genomMut(genomIdx(g)));
    genomMut(genomIdx(g)) = valuesFliped(pos);
end
end