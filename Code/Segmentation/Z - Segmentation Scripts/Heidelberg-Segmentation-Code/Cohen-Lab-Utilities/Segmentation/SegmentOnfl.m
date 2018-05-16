function [onflAuto, flatONFL, flatINFL,flatIPL,flatICL,alignedBScanDSqrt ] = SegmentOnfl(I,infl,ipl,icl, opl,bv,Params)
% find ONFL now
bscanDSqrt = sqrt(I);
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
onfl(bv(1,:) == 1) = flatIPL(bv(1,:) == 1);
%$onfl(onh(onh == 1)) = flatIPL(onh(onh == 1));
onfl= linesweeter(onfl, Params.ONFLLIN_SEGMENT_LINESWEETER_INIT_INTERPOLATE);

% 7) Do energy smoothing
% Forget about the ONFL estimate and fit a poly trough it. Then Energy!
onfl = linesweeter(onfl, Params.ONFLLIN_SEGMENT_LINESWEETER_INIT_SMOOTH);
onfl = round(onfl);

gaussCompl = fspecial('gaussian', 5 , 1);
smoothedBScan = alignedBScanDen;
smoothedBScan = imfilter(smoothedBScan, gaussCompl, 'symmetric');
smoothedBScan = -smoothedBScan;
smoothedBScan = smoothedBScan ./ (max(max(smoothedBScan)) - min(min(smoothedBScan))) .* 2 - 1;

onfl = energySmooth(smoothedBScan, Params, onfl, find(single(bv(1,:))), [flatINFL; flatIPL]);

% Some additional constraints and a final smoothing
onfl(idx2Miss) = flatINFL(idx2Miss);

onfl = linesweeter(onfl, Params.ONFLLIN_SEGMENT_LINESWEETER_FINAL);

diffNFL = onfl - flatINFL;
onfl(find(diffNFL < 0)) = flatINFL(find(diffNFL < 0));
flatONFL = onfl;
onflAuto = onfl + transformLine;

% figure; imshow(alignedBScanDen); hold on; plot(flatINFL,'r'); hold on; plot(flatICL, 'c'); hold on; plot(onfl, 'r');
% title('flatened image');
% 
% figure; imshow(I);hold on; plot(ipl,'r'); hold on; plot(icl, 'b'); hold on; plot(opl, 'c');hold on; plot(infl, 'w');hold on; plot(onflAuto,'g');
% title('regular OCT Image');

end

