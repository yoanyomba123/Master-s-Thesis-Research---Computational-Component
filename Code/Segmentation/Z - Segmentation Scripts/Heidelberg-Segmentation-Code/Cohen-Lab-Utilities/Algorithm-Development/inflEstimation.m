function [inflline] = inflEstimation(bscan,parameters, rpeline, middleline)
%INFLESTIMATION Summary of this function goes here
%   Detailed explanation goes here


% Preliminary Step
% define window size and degree for line smoothing
window_size = 100;
degree = 5;
% 1) Normalize intensity values and align the image to the RPE
bscan = sqrt(sqrt(bscan));
% 2) Align the bscan b ase on the rpe line
[alignedBScan, flatRPE, transformLine] = alignAScans(bscan, parameters, rpeline);
% align the middleline
middleline = round(middleline - transformLine);
% suprres all points less than zero
middleline(middleline < 0) = 0;
% 3x512 matrix created to span width of image
inflChoice = zeros(3, size(bscan, 2));

% 3) Some error handling/constraints are performed here. The medline can 
% not lay below the RPE. The medline is smoothed some more - actually, the
% linesweeter parameters should only be set to do hole interpolation.
middleline(middleline > flatRPE) = flatRPE(middleline > flatRPE);
diffRpeMed = flatRPE - middleline;
middleline(diffRpeMed < 5) = 0;
middleline = linesweeter(middleline, parameters.INFL_SEGMENT_LINESWEETER_MEDLINE);
middleline = round(middleline);

% Instead of separatly normalizing the IS and OS, simple A-Scan based 
% intensity thresholding is applied.
snBScan = treshold(alignedBScan, 'ascanmax', [0.97 0.6]);

% 4) Find the INFL in the upper region of the scan 
linereg = [zeros(1, size(bscan,2), 'double') + 2; middleline - parameters.INFL_MEDLINE_MINDISTABOVE];

% 5) find the maximal gradient change in the upper region of the scan
inflAuto = findRetinaExtrema(snBScan, parameters, 1, 'max', ...
                            [zeros(1, size(bscan,2), 'double') + 2; middleline - parameters.INFL_MEDLINE_MINDISTABOVE]);

                        
inflChoice(1,:) = inflAuto;                        
% Fit a polynomial through the first RPE segmentation by ransac.
inflRansac = ransacEstimate(inflAuto, 'poly', ...
                            0, ...
                            100, ...
                            25);
inflChoice(2,:) = inflRansac;

% Remove points far away from the polynomial and replace them by the
% polynomial.
infl = mergeLines(inflAuto, inflRansac, 'discardOutliers', [4 ...
                                                           8 ...
                                                           5]);

infl =  linesweeter(infl, parameters.INFL_SEGMENT_LINESWEETER_FINAL); 
% 4) Transformation of segmentation results from the aligned-RPE image back
% to the original one
infl = infl + transformLine;
inflAuto(inflAuto < 1) = 1;

% 5) Some additional smoothing
inflline =  linesweeter(infl, parameters.INFL_SEGMENT_LINESWEETER_FINAL);
%inflline = lineProcessing(size(inflline,2),inflline,window_size,degree);

end

