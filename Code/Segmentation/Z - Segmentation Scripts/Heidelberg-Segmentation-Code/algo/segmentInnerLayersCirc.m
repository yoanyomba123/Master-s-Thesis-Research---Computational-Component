function [icl, opl, ipl] = segmentInnerLayersCirc(bscan, Params, rpe, infl, medline, bv)
% SEGMENTINNERLAYERSCIRC Segments some inner retinal layers from a BScan.
% Intended for use on circular OCT B-Scans.
%
% [ICL, OPL, IPL] = segmentInnerLayersCirc(BSCAN, PARAMS, RPE, INFL, MEDLINE, BV) 
% Segments some inner layer boundaries, namely:
% The boundary between the GC/IPL and the INL, called IPL in the code.
% The boundary between the OPL and ONL/IS, called OPL in the code.
% The boundary between the ONL/IS and the OS, called ICL in the ode.
% 
% BSCAN: Unnormed B-Scan image. 
% PARAMS:   Parameter struct for the automated segmentation
%   In this function, the following parameters are currently used:
%   INNERCIRC_SEGMENT_MIRRORWIDTH: Extension of the B-Scan to the left and
%   right for better segmentations at the border.
%   INNERCIRC_EXTENDBLOODVESSELS_ADDWIDTH,
%   INNERCIRC_EXTENDBLOODVESSELS_MULTWIDTHTHRESH,
%   INNERCIRC_EXTENDBLOODVESSELS_MULTWIDTH: This values should make BV 
%   smaller in size for the energy minimization approach.
%   INNERCIRC_SEGMENT_AVERAGEWIDTH: Averaging window as simple denoiser.
%   [3 7] is currently recommended.
%   INNERCIRC_SEGMENT_MINDIST_RPE_ICL: Min. distance between RPE and ICL.
%   (Suggestion: 1)
%   INNERCIRC_SEGMENT_RPESORTPART,
%   INNERCIRC_SEGMENT_RPEDILATE,
%   INNERCIRC_SEGMENT_RPEWINDOW_ICL,
%   INNERCIRC_SEGMENT_RPECONSTRANGE_ICL: Constrain the ICL values by
%   distance to the RPE.
%   INNERCIRC_SEGMENT_MINDIST_ICL_OPL: Minimum distance between ICL and OPL
%   (suggested: 5)
%   INNERCIRC_SEGMENT_RPEWINDOW_OPL,
%   INNERCIRC_SEGMENT_RPECONSTRANGE_OPL: Constrain the OPL values by
%   distance to RPE.
%   INNERCIRC_SEGMENT_LINESWEETER_OPL: Linesweeter values of the OPL.
%   For the IPL, the same parameters (with different values) as for the 
%   OPL are present, named *IPL* instead of *OPL*.
% RPE: Segmentation of the RPE in OCTSEG line format
% INFL: Segmentation of the INFL in OCTSEG line format
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


% 1) Normalize intensity values and align the image to the RPE
bscan = mirrorCirc(bscan, 'add', Params.INNERCIRC_SEGMENT_MIRRORWIDTH);
rpe = mirrorCirc(rpe, 'add', Params.INNERCIRC_SEGMENT_MIRRORWIDTH);
infl = mirrorCirc(infl, 'add', Params.INNERCIRC_SEGMENT_MIRRORWIDTH);
medline = mirrorCirc(medline, 'add', Params.INNERCIRC_SEGMENT_MIRRORWIDTH);
bv =  mirrorCirc(bv, 'add', Params.INNERCIRC_SEGMENT_MIRRORWIDTH);

bscan(bscan > 1) = 0; 
bscan = sqrt(bscan);
rpe = round(rpe);
infl = round(infl);
[alignedBScan, flatRPE, transformLine] = alignAScans(bscan, Params, [rpe; infl]);
flatINFL = infl - transformLine;
medline = round(medline - transformLine);
alignedBScanDSqrt = sqrt(alignedBScan); % double sqrt for denoising

% 3) Find blood vessels to interpolate over them (extension of blood vessels).
idxBV = find(extendBloodVessels(bv, Params.INNERCIRC_EXTENDBLOODVESSELS_ADDWIDTH, ...
                                    Params.INNERCIRC_EXTENDBLOODVESSELS_MULTWIDTHTHRESH, ...
                                    Params.INNERCIRC_EXTENDBLOODVESSELS_MULTWIDTH));

averageMask = fspecial('average', Params.INNERCIRC_SEGMENT_AVERAGEWIDTH);
alignedBScanDen = imfilter(alignedBScanDSqrt, averageMask, 'symmetric');

% Interpolate over the extended blood vessels 
idxBVlogic = zeros(1,size(alignedBScan, 2), 'uint8') + 1;
idxBVlogic(idxBV) = idxBVlogic(idxBV) - 1;
idxBVlogicInv = zeros(1,size(alignedBScan, 2), 'uint8') + 1 - idxBVlogic;
alignedBScanWoBV = alignedBScanDen(:, idxBVlogic > 0);
alignedBScanInter = alignedBScanDen;
runner = 1:size(alignedBScanDSqrt, 2);
runnerBV = runner(idxBVlogic > 0);
for k = 1:size(alignedBScan,1)
    alignedBScanInter(k, :) = interp1(runnerBV, alignedBScanWoBV(k,:), runner, 'linear');
end

alignedBScanDSqrt(:, idxBVlogicInv > 0) = alignedBScanInter(:, idxBVlogicInv > 0) ;
averageMask = fspecial('average', Params.INNERCIRC_SEGMENT_AVERAGEWIDTH);
alignedBScanDenAvg = imfilter(alignedBScanDSqrt, averageMask, 'symmetric');

% 4) We try to find the ICL boundary.
% This is pretty simple - it lies between the medline and the RPE and has
% rising contrast. It is the uppermost rising border.
extrICLChoice = findRetinaExtrema(alignedBScanDenAvg, Params,2, 'max', ...
                [medline; flatRPE - Params.INNERCIRC_SEGMENT_MINDIST_RPE_ICL]);
extrICL = min(extrICLChoice,[], 1);
extrICL(idxBV) = 0;
extrICL = treshDistRPE(flatRPE, extrICL, ...
    Params.INNERCIRC_SEGMENT_RPEWINDOW_ICL, ...
    Params.INNERCIRC_SEGMENT_RPECONSTRANGE_ICL, Params);
extrICL = linesweeter(extrICL, Params.INNERCIRC_SEGMENT_LINESWEETER_ICL);
flatICL = round(extrICL);


% 5) We try to find the OPL boundary.
% Constraint: It can not lie above the INFL. 
inflAvg = mean(flatINFL);
oplInnerBound = zeros(1, size(bscan,2), 'double') + inflAvg;
oplInnerBound = round(max([oplInnerBound; flatINFL], [], 1));

extrOPLChoice = findRetinaExtrema(alignedBScanDenAvg, Params,3, 'min', ...
                [oplInnerBound; flatICL - Params.INNERCIRC_SEGMENT_MINDIST_ICL_OPL]);
extrOPL = max(extrOPLChoice,[], 1);
extrOPL(idxBV) = 0;
extrOPL = treshDistRPE(flatRPE, extrOPL, ...
    Params.INNERCIRC_SEGMENT_RPEWINDOW_OPL, ...
    Params.INNERCIRC_SEGMENT_RPECONSTRANGE_OPL, Params);
extrOPL = linesweeter(extrOPL, Params.INNERCIRC_SEGMENT_LINESWEETER_OPL);
flatOPL = round(extrOPL);

% 4) We try to find the IPL boundary.
inflMaxMiddle = max(flatINFL((ceil(0.4 * end):floor(0.6 * end))));
inflMaxLeft = mean(flatINFL(1:floor(0.05 * end)));
inflMaxRight = mean(flatINFL((ceil(0.95 * end):end)));

iplInnerBound = round(interp1([1 (size(bscan,2)/2) size(bscan,2)], [inflMaxLeft inflMaxMiddle inflMaxRight], 1:size(bscan,2)));
iplInnerBound(iplInnerBound < flatINFL) = flatINFL(iplInnerBound < flatINFL);

extrIPLChoice = findRetinaExtrema(alignedBScanDenAvg, Params,2, 'min pos', ...
                [iplInnerBound; flatOPL - Params.INNERCIRC_SEGMENT_MINDIST_OPL_IPL]);
extrIPL = extrIPLChoice(2,:);
extrIPL(idxBV) = 0;
extrIPL = treshDistRPE(flatOPL, extrIPL, ...
    Params.INNERCIRC_SEGMENT_RPEWINDOW_IPL, ...
    Params.INNERCIRC_SEGMENT_RPECONSTRANGE_IPL, Params);
extrIPL = linesweeter(extrIPL, Params.INNERCIRC_SEGMENT_LINESWEETER_IPL);

icl = extrICL + transformLine;
opl = extrOPL + transformLine;
ipl = extrIPL + transformLine;

icl = mirrorCirc(icl, 'remove', Params.INNERCIRC_SEGMENT_MIRRORWIDTH);
opl = mirrorCirc(opl, 'remove', Params.INNERCIRC_SEGMENT_MIRRORWIDTH);
ipl = mirrorCirc(ipl, 'remove', Params.INNERCIRC_SEGMENT_MIRRORWIDTH);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TRESHDISTRPE: We knwo that the RPE-ICL and RPE-OPL distance should be roughly 
% constant. Therefore we treshold values that do not fit into a certain
% range of RPE-ICL distances, averaged in the middle range of the distance
% values.
function res = treshDistRPE(rpe, line, tresh, range, Params)
    dist = abs(rpe - line);
    distSorted = sort(dist(line ~= 0), 'ascend');
    avgDist = mean(distSorted(ceil(end * Params.INNERCIRC_SEGMENT_RPESORTPART(1)):...
                                floor(end * Params.INNERCIRC_SEGMENT_RPESORTPART(2))));
    res = line;
    distWoMean = abs(dist-avgDist);
    idx = distWoMean > tresh;
    idx = bwmorph(idx,'dilate',Params.INNERCIRC_SEGMENT_RPEDILATE);
    if range(1) ~= 0
        idx(1:ceil(range(1) * end)) = 0;
        idx(ceil(range(2) * end:end)) = 0;
    end
    
    if sum(idx) < (numel(idx) * 3 / 4)
        res(idx) = 0;
    end
end

