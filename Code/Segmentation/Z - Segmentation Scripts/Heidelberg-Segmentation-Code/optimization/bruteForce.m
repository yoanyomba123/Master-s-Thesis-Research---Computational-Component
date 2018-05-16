function bestGenom = bruteForce(fixedLayer, layers, segments, genValues, evalAdder, costFunction, dist, gradient, factor)
% BRUTEFORCE
% Selects the best genom out of ALL possible solutions
% 
% Part of a *FAILED* approch to segmentation optimization by genetic
% optimization. 
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
% Initial version some time in 2012.

if nargin < 8
    gradient = [];
end



population =  createInitPopulation(1, size(segments, 1), genValues, 'all');

if numel(strfind(costFunction, 'Grad')) == 0
    costs = getPopulationCosts(fixedLayer, layers, population, segments, costFunction, evalAdder, dist, gradient);
else
    costs = getPopulationCosts(fixedLayer, layers, population, segments,'L2', evalAdder, dist, gradient);
    costsGrad = getPopulationCosts(fixedLayer, layers, population, segments, 'Grad', evalAdder, dist, gradient);
    costs = costs + costsGrad * factor;
end
[costsSorted idx] = sort(costs, 'ascend');
bestGenom = population(idx(1), :);
