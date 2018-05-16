function medline = segmentMedlineLin(bscan, PARAMS)
% SEGMENTMEDLINELin Segments the inner segment (IS) outer segment (OS)
% boundary from a linear B-Scan, e.g. from a volume.
%
% For detailed comments refer to segmentMedlineCirc(..).
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
% First final Version: November 2010
% Revised comments: November 2015

bscan(bscan > 1) = 0; 
medline = findmedline(bscan, PARAMS);

% Fit a polynomial through the first medline segmentation with ransac.
medlineRansac = ransacEstimate(medline, 'poly', ...
                            PARAMS.MEDLINE_RANSAC_NORM, ...
                            PARAMS.MEDLINE_RANSAC_MAXITER, ...
                            PARAMS.MEDLINE_RANSAC_POLYNUMBER);

% Remove points far away from the polynomial and replace them by the
% polynomial.                        
medline = mergeLines(medline, medlineRansac, 'discardOutliers', [PARAMS.MEDLINE_MERGE_THRESHOLD ...
                                                           PARAMS.MEDLINE_MERGE_DILATE ...
                                                           PARAMS.MEDLINE_MERGE_BORDER]);

medline = round(medline);                       
medline(medline < 1) = 1;                                                                                                          

end