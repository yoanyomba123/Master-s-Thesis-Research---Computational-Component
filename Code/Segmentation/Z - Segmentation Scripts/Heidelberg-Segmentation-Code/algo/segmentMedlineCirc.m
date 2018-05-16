function medline = segmentMedlineCirc(bscan, params)
% SEGMENTMEDLINECIRC Finds a line in the middle of the ONL to split the
% circular scan into an inner and outer segment.
%
% PARAMS: Parameter struct for the automated segmentation
%   In this function, the following parameters are currently used:
%   - See findmedline(...) for parameters used.
%
% The algorithm (of which this function is a part) is described in 
% Markus A. Mayer, Joachim Hornegger, Christian Y. Mardin, Ralf P. Tornow:
% Retinal Nerve Fiber Layer Segmentation on FD-OCT Scans of Normal Subjects
% and Glaucoma Patients, Biomedical Optics Express, Vol. 1, Iss. 5, 
% 1358-1383 (2010). Note that modifications have been made to the
% algorithm since the paper publication.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: June 2010
% Revised comments: November 2015

bscan(bscan > 1) = 0; 
medline = findmedline(bscan, params);
medline = floor(medline);
medline(medline < 1) = 1;

end