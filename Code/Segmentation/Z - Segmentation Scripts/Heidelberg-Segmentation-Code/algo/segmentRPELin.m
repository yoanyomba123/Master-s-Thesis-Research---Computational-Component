function [rpeAuto, rpeMult] = segmentRPELin(bscan, PARAMS, medline)
% SEGMENTRPELIN Segments the RPE from a BScan. Intended for the use on
% linear OCT-B-Scans (e.g. from a volume).
%
% For detailed comments refer to segmentRPECirc(..).
%
% RPEAUTO = segmentRPELINAuto(BSCAN, PARAMS, MEDLINE)
% RPEAUTO: Automated segmentation of the RPE
% BSCAN: Unnormed BScan image 
% PARAMS:   Parameter struct for the automated segmentation
%   In this function, the following parameters are currently used:
%   RPELIN_SEGMENT_MEDFILT1 First median filter values (in z and x direction).
%   Preprocessing before finding extrema. (suggestion: 5 7)
%   RPELIN_SEGMENT_MEDFILT2 Second median filter values (in z and x direction).
%   Preprocessing before finding extrema. Directly applied after the first
%   median filter. (suggestion: Use the same settings)
%   RPELIN_SEGMENT_LINESWEETER1 Linesweeter smoothing values before blood
%   vessel region removal
%   RPELIN_SEGMENT_LINESWEETER2 Linesweeter smoothing values after blood
%   vessel region removal. This is the final smoothing applied to the RPELIN.
%   RPELIN_SEGMENT_POLYDIST
%   RPELIN_SEGMENT_POLYNUMBER
% MEDLINE: The exisiting IS/OS boundary
%
% This is an experimental adaption of the circular scan algorithm to volume
% scans. Preliminar results were published at the ARVO conference 2011:
% Markus A. Mayer, Joachim Hornegger, Christian Y. Mardin, Ralf P. Tornow;
% Retinal Layer Segmentation on OCT-Volume Scans of Normal and 
% Glaucomatous Eyes. Invest. Ophthalmol. Vis. Sci. 2011;52(14):3669
%
% Due to the lack of data and time the approach was not pushed further.
% Now (2015) we would suggest using other volume segmentation approaches.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final version: November 2010
% Revised comments: November 2015

% 1) Normalize the intensity values
bscan(bscan > 1) = 0; 
snBScan = splitnormalize(bscan, PARAMS, 'ipsimple opsimple soft', medline);
snBScan = removebias(snBScan, PARAMS);

% 2) A simple noise removal
snBScan = medfilt2(snBScan, PARAMS.RPELIN_SEGMENT_MEDFILT);

rpeMult = zeros(3, size(bscan, 2));

% 3) Edge detection along A-Scans (taking the sign of the derivative into
% account)
rpe = findRetinaExtrema(snBScan, PARAMS, 2, 'min', ...
                        [round(medline) + PARAMS.RPELIN_MEDLINE_MINDISTBELOW; ...
                        zeros(1, size(bscan,2), 'double') + size(bscan,1)]);

rpeSimple = rpe(1,:);
rpeMult(1,:) = rpe(1,:);
rpeMult(3,:) = rpe(2,:);
                    
% Fit a polynomial through the first RPE segmentation by ransac.
rpeRansac = ransacEstimate(rpeSimple, 'poly', ...
                            PARAMS.RPELIN_RANSAC_NORM_RPE, ...
                            PARAMS.RPELIN_RANSAC_MAXITER, ...
                            PARAMS.RPELIN_RANSAC_POLYNUMBER);
                        
rpeMult(2,:) = rpeRansac;

% Remove points far away from the polynomial and replace them by the
% polynomial.
rpe = mergeLines(rpeSimple, rpeRansac, 'discardOutliers', [PARAMS.RPELIN_MERGE_THRESHOLD ...
                                                           PARAMS.RPELIN_MERGE_DILATE ...
                                                           PARAMS.RPELIN_MERGE_BORDER]);

% Final smoothing.                                                       
rpeAuto =  linesweeter(rpe, PARAMS.RPELIN_LINESWEETER_FINAL);

end