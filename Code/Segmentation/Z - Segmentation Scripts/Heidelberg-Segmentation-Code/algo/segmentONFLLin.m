function [onflAuto, additional] = segmentONFLLin(bscan, Params, onh, bv, rpe, icl, ipl, infl)
% SEGMENTRPELIN Segments the ONFL from a BScan. Intended for the use on
% linear OCT-B-Scans (e.g. from a volume).
%
% For detailed comments refer to segmentONFLCirc(..).
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

% 1) Normalize intensity values 
bscanDSqrt = sqrt(bscan);

% 2) Find blood vessels for segmentation and energy-smooth 
[alignedBScanDSqrt flatICL transformLine] = alignAScans(bscanDSqrt, Params, [icl; round(infl)]);
flatINFL = round(infl - transformLine);
flatIPL = round(ipl - transformLine);

averageMask = fspecial('average', [3 7]);
alignedBScanDen = imfilter(alignedBScanDSqrt, averageMask, 'symmetric');

idxBVlogic = zeros(1,size(alignedBScanDSqrt, 2), 'uint8') + 1;
idxBVlogic(bv(1,:) == 1) = idxBVlogic(bv(1,:) == 1) - 1;
idxBVlogic(1) = 1;
idxBVlogic(end) = 1;
idxBVlogicInv = zeros(1,size(alignedBScanDSqrt, 2), 'uint8') + 1 - idxBVlogic;
alignedBScanWoBV = alignedBScanDen(:, find(idxBVlogic));
alignedBScanInter = alignedBScanDen;
runner = 1:size(alignedBScanDSqrt, 2);
runnerBV = runner(find(idxBVlogic));
for k = 1:size(alignedBScanDSqrt,1)
    alignedBScanInter(k, :) = interp1(runnerBV, alignedBScanWoBV(k,:), runner, 'linear', 0);
end

alignedBScanDSqrt(:, find(idxBVlogicInv)) = alignedBScanInter(:, find(idxBVlogicInv)) ;

% 2) Denoise the image with complex diffusion
noiseStd = estimateNoise(alignedBScanDSqrt, Params);
% Complex diffusion relies on even size. Enlarge the image if needed.
if mod(size(alignedBScanDSqrt,1), 2) == 1 
    alignedBScanDSqrt = alignedBScanDSqrt(1:end-1, :);
end
Params.DENOISEPM_SIGMA = [(noiseStd * Params.ONFLLIN_SEGMENT_DENOISEPM_SIGMAMULT) (pi/1000)];
if mod(size(alignedBScanDSqrt,2), 2) == 1
    temp = alignedBScanDSqrt(:,1);
    alignedBScanDSqrt = alignedBScanDSqrt(:, 2:end);
    alignedBScanDen = real(denoisePM(alignedBScanDSqrt, Params, 'complex'));
    alignedBScanDen = [temp alignedBScanDen];
else
    alignedBScanDen = real(denoisePM(alignedBScanDSqrt, Params, 'complex')); 
end

% Find extrema highest Min, 2 highest min sorted by position
extr2 = findRetinaExtrema(alignedBScanDen, Params, 2, 'min pos th', ...
    [flatINFL + 1; flatIPL - Params.ONFLLIN_SEGMENT_MINDIST_IPL_ONFL]); 
extrMax = findRetinaExtrema(alignedBScanDen, Params, 1, 'min', ...
    [flatINFL + 1; flatIPL - Params.ONFLLIN_SEGMENT_MINDIST_IPL_ONFL]);


% 6) First estimate of the ONFL:
dist = abs(flatIPL - flatINFL);
onfl = extrMax(1,:); 
idx1Miss = find(extr2(1,:) == 0); 
idx2Miss = find(extr2(2,:) == 0); 
onfl(idx2Miss) = flatINFL(idx2Miss); 
onfl(bv(1,:) == 1)  = flatIPL(bv(1,:) == 1);
onfl(onh == 1) = flatIPL(onh == 1);
onfl= linesweeter(onfl, Params.ONFLLIN_SEGMENT_LINESWEETER_INIT_INTERPOLATE);

onflEstimate = ransacEstimate(onfl, 'poly', ...
                            Params.ONFLLIN_RANSAC_NORM, ...
                            Params.ONFLLIN_RANSAC_MAXITER, ...
                            Params.ONFLLIN_RANSAC_POLYNUMBER, ...
                            onh);
onfl = mergeLines(onfl, onflEstimate, 'discardOutliers', [Params.ONFLLIN_MERGE_THRESHOLD ...
                                                          Params.ONFLLIN_MERGE_DILATE ...
                                                          Params.ONFLLIN_MERGE_BORDER]);


additional(1,:) = onfl + transformLine;

% 7) Do energy smoothing
% Forget about the ONFL estimate and fit a poly trough it. Then Energy!
onfl = linesweeter(onfl, Params.ONFLLIN_SEGMENT_LINESWEETER_INIT_SMOOTH);
onfl = round(onfl);

gaussCompl = fspecial('gaussian', 5 , 1);
smoothedBScan = alignedBScanDen;
smoothedBScan = imfilter(smoothedBScan, gaussCompl, 'symmetric');
smoothedBScan = -smoothedBScan;
smoothedBScan = smoothedBScan ./ (max(max(smoothedBScan)) - min(min(smoothedBScan))) .* 2 - 1;

onfl = energySmooth(smoothedBScan, Params, onfl, find(single(bv(2,:))), [flatINFL; flatIPL]);

% Some additional constraints and a final smoothing
onfl(idx2Miss) = flatINFL(idx2Miss);

onfl = linesweeter(onfl, Params.ONFLLIN_SEGMENT_LINESWEETER_FINAL);

diffNFL = onfl - flatINFL;
onfl(find(diffNFL < 0)) = flatINFL(find(diffNFL < 0));

onflAuto = onfl + transformLine;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A simple noise estimate for adapting a denoising filter. It may seem a
% bit weird at first glance, but it delivers appropriate results.
function res = estimateNoise(octimg, Params)
    octimg = octimg - mean(mean(octimg)); 
    mimg = medfilt2(octimg, Params.ONFLLIN_SEGMENT_NOISEESTIMATE_MEDIAN);
    octimg = mimg - octimg;

    octimg = abs(octimg);

    line = reshape(octimg, numel(octimg), 1);
    res = std(line);
end

end