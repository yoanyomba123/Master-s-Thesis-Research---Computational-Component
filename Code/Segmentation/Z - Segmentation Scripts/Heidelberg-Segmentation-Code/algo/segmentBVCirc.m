function bv = segmentBVCirc(bscan, params, rpe)
% SEGMENTBVAUTO Segments the blood vesses from a BScan.
% 
% BV = segmentRPEAuto(BSCAN, PARAMS, RPE)
% BSCAN: Unnormed BScan image (all parameters in the algorithm are
%   currently adapted to HE VOL data).
% PARAMS: Parameter struct for the automated segmentation. See
%   findbloodvessels(..) for the used parameters. 
% RPE: Segmentation of the RPE
% BV: Blood vessel vector with #A-Scan entries. 0 for no-blood-vessel,
%   1 for blood-vessel-present. 
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: June 2010
% Revised comments: November 2015

bscan(bscan > 1) = 0; 
bscan = sqrt(bscan);

idx = findbloodvessels(bscan, params, rpe);
bv = zeros(1, size(bscan,2), 'uint8');

bv(idx) = 1;

end