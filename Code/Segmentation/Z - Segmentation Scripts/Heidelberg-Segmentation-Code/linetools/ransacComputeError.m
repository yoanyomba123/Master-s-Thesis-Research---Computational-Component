function err = ransacComputeError(line, lineEst, norm, options, falsePositions)
% RANSACCOMPUTEERROR: Computes the error (difference) in between two lines.
% 
% ERR = ransacComputeError(LINE, LINEEST, NORM, OPTIONS, FALSEPOSITIONS)
% LINE, LINEEST: the two lines
% NORM: Currently supported:
%   - 2: L1 Norm.
%   - 1: L1 Norm.
%   - 0: Distances greater than options(1) are counted 
% FALSEPOSITIONS: A vector (same length as line, where a 1 entry markes an
%   invalid position). These will not go into the error computation
% ERR: The resulting error/difference in between the two lines.
% 
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final version: Some time in 2010
% Revised comments: November 2015

correctPositions = falsePositions == 0;
lineValid = line(correctPositions);
lineEstValid = lineEst(correctPositions);

switch norm
    case 2
        err = sum((lineValid - lineEstValid) .^ 2);
    case 1
        err = sum(abs(lineValid - lineEstValid));
    case 0
        dist = abs(lineValid - lineEstValid);
        err = numel(dist(dist > options(1)));
end
        
