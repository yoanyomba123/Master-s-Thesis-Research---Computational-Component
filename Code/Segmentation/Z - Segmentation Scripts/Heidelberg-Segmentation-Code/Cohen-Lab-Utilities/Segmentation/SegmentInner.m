function [ipl,opl, icl] = SegmentInner(I,rpeline, infline, medline,bvlin, Params)
% segments and detects the lines present in the ISG layer of an OCT image
% 1) Normalize intensity values and align the image to the RPE
bv = bvlin;
rpe = round(rpeline);
infl = round(infline);
[alignedBScan, flatRPE, transformLine] = alignAScans(I, Params, [rpe; infl]);
flatINFL = infl - transformLine;
medline = round(medline - transformLine);
rpeln = round(rpeline - transformLine);
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


% 4) We try to find the CL boundary.
% This is pretty simple - it lies between the medline and the RPE and has
% rising contrast. It is the uppermost rising border.
extrICLChoice = findRetinaExtrema(alignedBScanDenAvg, Params,2, 'max', ...
                [medline; flatRPE - Params.INNERLIN_SEGMENT_MINDIST_RPE_ICL]);
extrICL = min(extrICLChoice,[], 1);
extrICL(idxBV) = 0;
extrICL = linesweeter(extrICL, Params.INNERLIN_SEGMENT_LINESWEETER_ICL);
flatICL = round(extrICL);
                         
% 5) OPL Boundary: In between the ICL and the INFL
oplInnerBound = flatINFL;

extrOPLChoice = findRetinaExtrema(alignedBScanDenAvg, Params,3, 'min', ...
                [oplInnerBound; flatICL - Params.INNERLIN_SEGMENT_MINDIST_ICL_OPL]);
extrOPL = max(extrOPLChoice,[], 1);
extrOPL(idxBV) = 0;
extrOPL = linesweeter(extrOPL, Params.INNERLIN_SEGMENT_LINESWEETER_OPL);
flatOPL = round(extrOPL);


% 5) IPL Boundary: In between the OPL and the INFL
iplInnerBound = flatINFL;
extrIPLChoice = findRetinaExtrema(alignedBScanDenAvg, Params,2, 'min pos', ...
                [iplInnerBound; flatOPL - Params.INNERLIN_SEGMENT_MINDIST_OPL_IPL]);
extrIPL = extrIPLChoice(2,:);
extrIPL(idxBV) = 0;
extrIPL = linesweeter(extrIPL, Params.INNERLIN_SEGMENT_LINESWEETER_IPL);

% figure; imshow(alignedBScanDenAvg); hold on; plot(flatINFL,'r'); hold on; plot(flatICL, 'c'); hold on; plot(extrOPL, 'y');
% hold on; plot(extrIPL, 'g');hold on; plot(rpeln, 'b'); title('flattened line');

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
% 
% figure; imshow(I);hold on; plot(ipl,'r'); hold on; plot(icl, 'b'); hold on; plot(opl, 'c');
% hold on; plot(rpe, 'y'); hold on; plot(infl, 'w'); title('curved line');

end

