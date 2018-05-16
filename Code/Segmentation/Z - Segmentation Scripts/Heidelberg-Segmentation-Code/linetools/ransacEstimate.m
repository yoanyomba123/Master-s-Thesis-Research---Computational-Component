function lineBest = ransacEstimate(line, modelmode, errormode, maxiter, modeloptions, falsePositions)
% RANSACESTIMATE Gives the best fitting RANSAC model fit for a line.
% 
% LINEBEST = ransacEstimate(LINE, MODELMODE, ERRORMODE, MAXITER, MODELOPTIONS, FALSEPOSITION)
% 
% LINE: The original linepoints (OCTSEG format).
% MODELMODE, MODELOPTIONS: See ransacFitModel(..)
% ERRORMODE: See ransacComputeError(..)
% MAXITER: The number of iterations of the ransac algorithms.
% FALSEPOSITIONS: A vector (same length as line, where a 1 entry markes an
%   invalid position)
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final version: Some time in 2010
% Revised comments: November 2015

if nargin < 6
    falsePositions = zeros(1, size(line, 2), 'uint8');
end

if nargin < 5
    modeloptions = 5;
end

err = 1000000000;
lineBest = zeros(1, size(line,2), 'single');

for i = 1:maxiter
    lineEst = ransacFitModel(line, modelmode, [(modeloptions(1) * 2) modeloptions(1)], falsePositions);
    
    errNew = ransacComputeError(line, lineEst, errormode, 2, falsePositions);
    
    if errNew < err
        lineBest = lineEst;
        err = errNew;
    end
end

end