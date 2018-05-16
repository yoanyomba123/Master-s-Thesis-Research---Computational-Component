function [rpeline] = rpeEstimation(bscan, parameters,middleline)
% MEDESTIMATION find the most bottom layer region present inside the OCT image 

% Algorithm:
%   1) Observe points lower than the middle line seperating the OSG & ISG
%   regions
%       A. Filter our image
%       B. Observe the most most drastic gradient changes in the lower
%       region by observing th extreme point of the gradient in the x
%       direction
%   2) process the observed line acquire by removing all outliers and
%   fitting a moving polyfit function

% Preliminary Step
% define window size and degree for line smoothing
window_size = 150;
degree = 4;
% 1) Normalize image intensity values
bscan(bscan >1) = 0;

% 2) Remove Some Noise
bscan = medfilt2(bscan, parameters.RPELIN_SEGMENT_MEDFILT);

% define a matrix of zeros containing 3 rows spanning the full length of
% the image 3x512
rpeMult = zeros(3, size(bscan, 2));

% 3) Edge detection along A-Scans (taking the sign of the derivative into
% account)
% Find the contrast change present in the bscan by computing the gradient
% in the x direction and observing the extreme point of the gradient in
% that diretction 
% find the two most minimal gradient changes 
rpe = findRetinaExtrema(bscan, parameters, 2, 'min', ...
                        [round(middleline) + parameters.RPELIN_MEDLINE_MINDISTBELOW; ...
                        zeros(1, size(bscan,2), 'double') + size(bscan,1)]);
rpeSimple = rpe(1,:);
rpeMult(1,:) = rpe(1,:);
rpeMult(3,:) = rpe(2,:);

% Fit a polynomial through the first RPE segmentation by ransac.
rpeRansac = ransacEstimate(rpeSimple, 'poly', ...
                            parameters.RPELIN_RANSAC_NORM_RPE, ...
                            parameters.RPELIN_RANSAC_MAXITER, ...
                            parameters.RPELIN_RANSAC_POLYNUMBER);
rpeMult(2,:) = rpeRansac;
% Remove points far away from the polynomial and replace them by the
% polynomial.
rpeline = mergeLines(rpeSimple, rpeRansac, 'discardOutliers', [parameters.RPELIN_MERGE_THRESHOLD ...
                                                           parameters.RPELIN_MERGE_DILATE ...
                                                           parameters.RPELIN_MERGE_BORDER]);

% Final smoothing.                                                       
rpeline = linesweeter(rpeline, parameters.RPELIN_LINESWEETER_FINAL);
% apply a windowed poly fit to the line for a more straight edge
rpeline = lineProcessing(size(rpeline,2),rpeline,window_size,degree);
end