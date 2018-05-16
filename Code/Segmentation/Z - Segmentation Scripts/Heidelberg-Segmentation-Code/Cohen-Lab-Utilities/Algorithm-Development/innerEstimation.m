function [opl, ipl, icl] = innerEstimation(bscan, parameters, rpeline, inflline, middleline, bvline)
% Preliminary Step
% define window size and degree for line smoothing
window_size = 50;
degree = 25;

% constrain the image based on upper and lower bounds
infline = inflline; % upper bound
medline = middleline;% lower bound
bv = bvline;
Params = parameters;
[ipl,opl, icl] = SegmentInner(bscan,rpeline, infline, medline,bv, Params);
% 1) Normalize intensity values and align the image to the RPE
rpe = round(rpeline);
infl = round(infline);
[alignedBScan, flatRPE, transformLine] = alignAScans(bscan, Params, [rpeline; inflline]);

flatINFL = infl - transformLine;
medline = round(medline - transformLine);
rpeline = round(rpeline - transformLine);
alignedBScanDSqrt = sqrt(alignedBScan); % double sqrt for denoising

% 3) Find blood vessels for segmentation and energy-smooth 
idxBV = find(extendBloodVessels(bv, Params.INNERLIN_EXTENDBLOODVESSELS_ADDWIDTH, ...
                                    Params.INNERLIN_EXTENDBLOODVESSELS_MULTWIDTHTHRESH, ...
                                    Params.INNERLIN_EXTENDBLOODVESSELS_MULTWIDTH));

averageMask = fspecial('average', Params.INNERLIN_SEGMENT_AVERAGEWIDTH);
alignedBScanDen = imfilter(alignedBScanDSqrt, averageMask, 'symmetric');
idxBVlogic = zeros(1,size(alignedBScan, 2), 'uint8') + 1;
idxBVlogic(idxBV) = idxBVlogic(idxBV) - 1;
idxBVlogic(1) = 1;
idxBVlogic(end) = 1;
idxBVlogicInv = zeros(1,size(alignedBScan, 2), 'uint8') + 1 - idxBVlogic;
alignedBScanWoBV = alignedBScanDen(:, find(idxBVlogic));
alignedBScanInter = alignedBScanDen;
runner = 1:size(alignedBScanDSqrt, 2);
runnerBV = runner(find(idxBVlogic));
for k = 1:size(alignedBScan,1)
    alignedBScanInter(k, :) = interp1(runnerBV, alignedBScanWoBV(k,:), runner, 'linear');
end

alignedBScanDSqrt(:, find(idxBVlogicInv)) = alignedBScanInter(:, find(idxBVlogicInv)) ;
averageMask = fspecial('average', Params.INNERLIN_SEGMENT_AVERAGEWIDTH);
alignedBScanDenAvg = imfilter(alignedBScanDSqrt, averageMask, 'symmetric');


% 4) We try to find the ICL boundary.
% This is pretty simple - it lies between the medline and the RPE and has
% rising contrast. It is the uppermost rising border.
extrICLChoice = findRetinaExtrema(alignedBScanDenAvg, Params,2, 'max', ...
                [medline; flatRPE - Params.INNERLIN_SEGMENT_MINDIST_RPE_ICL]);
extrICL = min(extrICLChoice,[], 1);
extrICL(idxBV) = 0;
extrICL = linesweeter(extrICL, Params.INNERLIN_SEGMENT_LINESWEETER_ICL);
flatICL = round(extrICL);
%flatICL = lineProcessing(size(flatICL,2),flatICL,window_size*2,degree);

% 5) OPL Boundary: In between the ICL and the INFL & has a decreasing
% contrast
oplInnerBound = flatINFL;

extrOPLChoice = findRetinaExtrema(alignedBScanDenAvg, Params,3, 'min', ...
                [oplInnerBound; flatICL - Params.INNERLIN_SEGMENT_MINDIST_ICL_OPL]);
extrOPL = max(extrOPLChoice,[], 1);
extrOPL(idxBV) = 0;
extrOPL = linesweeter(extrOPL, Params.INNERLIN_SEGMENT_LINESWEETER_OPL);
flatOPL = round(extrOPL);
%flatOPL = lineProcessing(size(flatOPL,2),flatOPL,window_size,degree);

% 5) IPL Boundary: In between the OPL and the INFL
iplInnerBound = flatINFL;
extrIPLChoice = findRetinaExtrema(alignedBScanDenAvg, Params,2, 'min pos', ...
                [iplInnerBound; flatOPL - Params.INNERLIN_SEGMENT_MINDIST_OPL_IPL]);
extrIPL = extrIPLChoice(2,:);
extrIPL(idxBV) = 0;
flatIPL = round(extrIPL);
%flatIPL = lineProcessing(size(flatIPL,2),flatIPL,window_size,degree);

icl = extrICL + transformLine;
opl = round(extrOPL + transformLine);
ipl = round(extrIPL + transformLine);

icl(icl < 1) = 1;
opl(opl < 1) = 1;
ipl(ipl < 1) = 1;

ipl(ipl < infl) = infl(ipl < infl);
icl(icl > rpe) = rpe(icl > rpe);
opl(opl > icl) = icl(opl > icl);
opl(opl < ipl) = ipl(opl < ipl);
icl(icl < opl) = opl(icl < opl);

%ipl = lineProcessing(size(ipl,2),ipl,window_size,degree*2);
%icl = lineProcessing(size(icl,2),icl,window_size,degree*2);
%opl = lineProcessing(size(opl,2),opl,window_size,degree*2);

% 
% figure; imshow(bscan); hold on; plot(ipl, 'r'); hold on; plot(opl, 'g'); hold on; plot(icl,'b');
% figure; imshow(alignedBScanDenAvg); hold on; plot(rpeline, 'r'); hold on;
% plot(medline, 'c'); hold on; plot(flatINFL,'b'); hold on; plot(flatICL, 'y'); hold on; plot(flatOPL, 'y');
% hold on; plot(flatIPL, 'r');

end

