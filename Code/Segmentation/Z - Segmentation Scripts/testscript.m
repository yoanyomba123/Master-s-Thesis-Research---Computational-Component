% Load in Bscans
if(exist('imagedb.mat'))
   imagedb = load('imagedb.mat');
   BScans_stack = imagedb.BScans_stack;
end
%% Extract Bscans of interest
Bscans_UF = BScans_stack{6,1};

%% extract Image of interest and apply filtration scheme
% Raw Image

I = BScans_UF(:,:,41);
Iz = I;







%%
% remove any image outliers
I_t = I== 1;
I_t = bwareaopen(I_t, 100);
I(I_t) = 0; 

% apply median filter and then wiener for adaptive filtering
I = medfilt2(I, [3,3]);
I = wiener2(I, [2,2]);

figure; imagesc(I); colormap gray; colorbar;

% remove diffused noise components present in the image by setting to
% background color
I(I <= 0.25) = 0;

% threshold the image and convert to black and white to observe connected components
thresh = graythresh(I);
BW = im2bw(I, thresh);
strel=ones(2,4);

% perform some morphological operation on the logical image to introduce a
% greater amount of space between the two OCT sub structures
BW = imopen(BW, strel);
figure; imagesc([BW, I]); colormap gray; colorbar;
% find all points in which the black and white image is 0 and set those
% current positions in the current image as zero
[r, c] = find(BW == 0);

minimal_intensity = min(I(:));
for i = 1: numel(r)
    I(r(i), c(i)) = minimal_intensity;
end
figure; imagesc(I); colormap gray; colorbar;

% extract connected components from the image
CC = bwconncomp(BW);
numPixels = cellfun(@numel,CC.PixelIdxList);
sorted_pix_list = sort(numPixels,'descend');
regions_of_interest = [];
% acquire the main regions of interests in the current image
for i = 1:length(sorted_pix_list(1:7))
   for j = 1: length(numPixels)
      if(sorted_pix_list(i) == numPixels(j))
        regions_of_interest = [regions_of_interest, j]; 
      end
   end
end
regions_of_interest = unique(regions_of_interest);
for j = 1: length(numPixels)
    for i = 1 : numel(regions_of_interest)
        if(j == regions_of_interest(i))
            break;
        end
        
        if(j ~= regions_of_interest(i) && i == numel(regions_of_interest))
            I(CC.PixelIdxList{j}) = 0;
        end
    end
end
    
figure; imagesc([I, Iz]); colormap gray
disp(regions_of_interest)
    
% apply another round of median filtering to the image for more noise
% filtering 
I = medfilt2(I); 
figure; imshow(I);

% threshold the image into 3 layers
layers = 3;
thresh = multithresh(I,layers);
q = imquantize(I, thresh);
figure; imagesc(q);

% Apply the laplacian of Gaussian filters to the image and obtain an LOG filtered image
% Obtain a canny filtered version of the image as well
sigma = 5 * 0.35;
szFilter = round(size(I)/5);
h = fspecial('log', szFilter, sigma);
H = fspecial('sobel')
imlog = imfilter(I, h, 'replicate');
imlog2 = imfilter(I, H, 'replicate');
imlog = mat2gray(imlog);
imlog2 = mat2gray(imlog2);

% Why LOG and Canny?

% Reasons why we leverage the canny and LOG algorithm for OCT's 
% LOG has many shortcomings some of which are poor detection of edge
% orientation and higly inefficient where gray level image intensity
% functional displays highly variant behavior. So We introduce the Canny
% edge detection scheme into this pre-processing step in order to account
% for those various drawbacks obtained from the laplacian of gaussian
% filter


imlog = Iz - (imlog .* (Iz .* imlog2));
figure; imshow([imlog, imlog2]); colorbar
%[r,c] = find(imlog >= 1);
I_t = imlog == 1;
I_t = bwareaopen(I_t, 100);
imlog(I_t) = 0; 
% identify layers and get rid of B-Ground
Im_tmp = imquantize(I, multithresh(I, 2));
imlog(Im_tmp == 1) = multithresh(I, 1);
figure; imshow(imlog); colorbar; colormap gray;
image = imlog;
% apply the wiener filter once again to smooth out the variational noise
image = imsharpen(wiener2(image, [8,8]));
figure; imshow(image);

% APPLY a fuzzy rule based histogram equalization scheme here for contrast
% enhancement

medline = segmentMedlineLin(image, med_params);
rpeline = segmentRPELin(image, rpe_params, medline);
[onh, onhCenter, onhRadius] = segmentONHVolume(image, onh_params, rpeline);
bvline = segmentBVLin(image,bv_params, onh, rpeline);
inflline = segmentINFLLin(image1, infl_params, rpeline, medline);
[ipl,opl, icl] = SegmentInner(image,rpeline, inflline, medline,bvline, inner_params);
figure; imshow(Iz); hold on; 
plot(rpeline, 'r');hold on; 
plot(ipl, 'y');hold on; 
plot(opl, 'y');hold on; 
plot(icl, 'y');hold on; 

%%




%%

%% threshold the filtered image
thresh = multithresh(imlog, 4);
q = imquantize(imlog, thresh);
figure; imagesc(q);

%% remove all empty cell arrary contents
images = images(~cellfun('isempty', images));

% Read BScans as a volume 
% BScans_UF = Convert_to3d(images);
BScans_UF = BScans_stack{7,1};
% anisotropic diffusuion
for i = 1 : size(BScans_UF, 3)
   BScans_UF(:,:, i) =  imsharpen(BScans_UF(:,:, i)); 
end

% Obtained filtered bscans
[Descriptors2.Header,Descriptors2.BScanHeader, slo2, BScans_F] = openOctListHelp(strcat('./',FILENAME), paths{1}, 'metawrite', FILTER_OP);
dimensions = [5.51, 9.51, 501.98, 478.98];
%%
clc;close all;
BScans_UF = BScans_stack{6,3};
I = BScans_UF(:,:,35);
I = medfilt2(I, [10,10]);
I = imgaussfilt(I);
figure; imshow(I);
I_t = I == 1;
I_t = bwareaopen(I_t, 100);
I(I_t) = 0; 
figure; imshow(I);
I = localcontrast(single(I), 0.5, 0.3);

%identify layers and get rid of B-Ground
%Im_tmp = imquantize(I, multithresh(I, 2));
%I(Im_tmp == 1) = multithresh(I, 1);
%figure; imshow(I);
figure; imshow(I);



szFilter10_10 = round(size(I)/10);
figure;
for i = 0.75
    logRadius = 5* i;
    h = fspecial('log',szFilter10_10,logRadius);
    imlog=imfilter(I,h,'replicate');
    imlog=mat2gray(imlog);
    %imlog(imlog >= 0.55) = min(imlog(:));
    imshow(imlog); title(i); colorbar;
    pause(2);
   
end
 
thresh = multithresh(imlog, 2);
q = imquantize(imlog,thresh);
figure;imagesc(q);

image1 = (I .* (I ./ max(imlog))) ./ max(imlog);

clear image;
image = (I ./ max(imlog)) ./ mean(imlog);
image = imgaussfilt(image1, [3,1]);
figure; imshow(image);

image = enhancedImage;
medline = segmentMedlineLin(image, med_params);
rpeline = segmentRPELin(image, rpe_params, medline);
[onh, onhCenter, onhRadius] = segmentONHVolume(image, onh_params, rpeline);
bvline = segmentBVLin(image,bv_params, onh, rpeline);
inflline = segmentINFLLin(image1, infl_params, rpeline, medline);
[ipl,opl, icl] = SegmentInner(image,rpeline, inflline, medline,bvline, inner_params);

PARAMETER_FILENAME = 'octseg.param';
med_params = loadParameters('MEDLINELIN', PARAMETER_FILENAME);
onh_params = loadParameters('ONH', PARAMETER_FILENAME);
rpe_params = loadParameters('RPELIN', PARAMETER_FILENAME);
bv_params = loadParameters('BV', PARAMETER_FILENAME);
infl_params = loadParameters('INFL', PARAMETER_FILENAME);
inner_params = loadParameters('INNERLIN', PARAMETER_FILENAME);
onfl_params = loadParameters('ONFLLIN', PARAMETER_FILENAME);

figure; imshow(I); hold on;
plot(rpeline, 'y'); hold on;
plot(inflline, 'g'); hold on;
plot(ipl, 'c'); hold on;
plot(opl, 'b'); hold on;
plot(icl, 'g'); hold on;
hold off
%% Apply Laplacian of Gaussian Filter For Edge Enhancement



logRadius_75 = .75 * 5;
logRadius_60 = .60 * 5;
logRadius_45 = .45 * 5;
logRadius_30 = .30 * 5;
logRadius_15 = .15 * 5;

h10_75=fspecial('log',szFilter10_10,logRadius_75);
h10_60=fspecial('log',szFilter10_10,logRadius_60);
h10_45=fspecial('log',szFilter10_10,logRadius_45);
h10_30=fspecial('log',szFilter10_10,logRadius_30);
h10_15=fspecial('log',szFilter10_10,logRadius_15);


imlog10_0=imfilter(I,h10_75,'replicate');
imlog10_2=imfilter(I,h10_60,'replicate');
imlog10_3=imfilter(I,h10_45,'replicate');
imlog10_4=imfilter(I,h10_30,'replicate');
imlog10_5=imfilter(I,h10_15,'replicate');


imlog10_0=mat2gray(imlog10_0);
imlog10_2=mat2gray(imlog10_2);
imlog10_3=mat2gray(imlog10_3);
imlog10_4=mat2gray(imlog10_4);
imlog10_5=mat2gray(imlog10_5);


figure; imshow([imlog10_0,imlog10_2,imlog10_3,imlog10_4,imlog10_5]); colorbar;


PARAMETER_FILENAME = 'octseg.param';
med_params = loadParameters('MEDLINELIN', PARAMETER_FILENAME);
onh_params = loadParameters('ONH', PARAMETER_FILENAME);
rpe_params = loadParameters('RPELIN', PARAMETER_FILENAME);
bv_params = loadParameters('BV', PARAMETER_FILENAME);
infl_params = loadParameters('INFL', PARAMETER_FILENAME);
inner_params = loadParameters('INNERLIN', PARAMETER_FILENAME);
onfl_params = loadParameters('ONFLLIN', PARAMETER_FILENAME);

figure; imagesc([I, imlog10_0]);  title("Filter size of [10, 10]"); colorbar;
thresh = multithresh(imlog10_0, 4);
q = imquantize(imlog10_0, thresh);
figure;imagesc(q);
%%


medline = segmentMedlineLin(image, med_params);
rpeline = segmentRPELin(image, rpe_params, medline);
[onh, onhCenter, onhRadius] = segmentONHVolume(image, onh_params, rpeline);
bvline = segmentBVLin(image,bv_params, onh, rpeline);
inflline = segmentINFLLin(image, infl_params, rpeline, medline);
[ipl,opl, icl] = SegmentInner(image,rpeline, inflline, medline,bvline, inner_params);

figure; imshow(I); hold on;
plot(medline,'r'); hold on;
plot(rpeline, 'y'); hold on;
plot(inflline, 'g'); hold on;
plot(ipl, 'c'); hold on;
plot(opl, 'b'); hold on;
plot(icl, 'g'); hold on;
hold off


%% segment inner line

% segment onfl line
[onfl] = SegmentONflStack(BScans_UF,inflline,ipl,icl,opl,bvlinevol,onfl_params);

%%




%%
% Obtain preprocess the unfiltered image
BScans_UF = imagePreprocessing(BScans_UF);
BScans_F = imagePreprocessing(BScans_F);

% Load Parameters
PARAMETER_FILENAME = 'octseg.param';
med_params = loadParameters('MEDLINELIN', PARAMETER_FILENAME);
onh_params = loadParameters('ONH', PARAMETER_FILENAME);
rpe_params = loadParameters('RPELIN', PARAMETER_FILENAME);
bv_params = loadParameters('BV', PARAMETER_FILENAME);
infl_params = loadParameters('INFL', PARAMETER_FILENAME);
inner_params = loadParameters('INNERLIN', PARAMETER_FILENAME);
onfl_params = loadParameters('ONFLLIN', PARAMETER_FILENAME);


% Obtain the middle line present between the two largest components in OCT image
% extract the median line between the two highest pixel intensity regions
medlinevol = segmentMedlineVolume(BScans_UF, med_params);
 
% extract the rpe layer present in the image
rpelinevol = segmentRPEVolume(BScans_UF, rpe_params, medlinevol);

% Segment onh line
[onh, onhCenter, onhRadius] = segmentONHVolume(BScans_UF, onh_params, rpelinevol);

% extract infl layer present in the image
inflline = segmentINFLVolume(BScans_UF, infl_params, onh, rpelinevol, medlinevol);


% extract blood vessel regions
bvlinevol = segmentBVVolume(BScans_UF, bv_params,onh, rpelinevol);

% segment inner line
[ipl,opl,icl] = SegmentInnnerStack(BScans_UF,rpelinevol, inflline, medlinevol,bvlinevol, inner_params);

% segment onfl line
[onfl] = SegmentONflStack(BScans_UF,inflline,ipl,icl,opl,bvlinevol,onfl_params);

%% fit a polynomial while sliding a window through original line
w_s = 100;
degree = 20;
for i = 1:2%size(medlinevol, 1)
   medlinevol1(i, :) = lineProcessing(size(medlinevol(i,:), 2),medlinevol(i,:),w_s,degree);
   rpelinevol1(i, :) = lineProcessing(size(rpelinevol(i,:), 2),rpelinevol(i,:),w_s,degree);
   infllinevol1(i, :) = lineProcessing(size(inflline(i,:), 2),inflline(i,:),w_s,degree);
   ipl1(i, :) = lineProcessing(size(ipl(i,:), 2),ipl(i,:),w_s,degree);
   opl1(i, :) = lineProcessing(size(opl(i,:), 2),opl(i,:),w_s,degree);
   icl1(i, :) = lineProcessing(size(icl(i,:), 2),icl(i,:),w_s,degree);
   onfl1(i, :) = lineProcessing(size(onfl(i,:), 2),onfl(i,:),w_s, degree);
end

%%
figure; imshow(gather(images{2})); hold on;
plot(rpelinevol1(2, :), 'b'); hold on;
plot(infllinevol1(2, :), 'r'); hold on;
plot(onfl1(2, :), 'g'); hold on;
plot(ipl1(2, :), 'y'); hold on;
plot(opl1(2, :), 'c'); hold on;
plot(icl1(2, :), 'w'); hold on;
title('Window Size of 500 and polynomial degree of 10');
%% Visualize stacks in 3D
order = 20;
figure; mesh(medfilt1(rpelinevol',order));
hold on; mesh(medfilt1(inflline',order));
hold on; mesh(medfilt1(onfl',order));
hold on; mesh(medfilt1(ipl', order));
hold on; mesh(medfilt1(opl',order));
hold on; mesh(medfilt1(icl',order));

%% Line smoothing
order = 20;
figure; imshow(gather(images{1})); hold on;
plot(rpelinevol(1, :), 'b'); hold on;
plot(inflline(1, :), 'r'); hold on;
plot(onfl(1, :), 'g'); hold on;
plot(ipl(1, :), 'y'); hold on;
plot(opl(1, :), 'c'); hold on;
plot(icl(1, :), 'w'); hold on;
%%
line = opl(1, :);
window_size = 350;
polydegree = 5;
figure;
yfinal = [];
for item = 1:length(line)
    upperbound = item + window_size;
    lowerbound = item;
    if( item + window_size <= length(line))
       y_points = line(lowerbound:upperbound);
       x_points = 1:length(y_points);
       % fit polynomial to the line
       [p, S, mu] = polyfit(x_points,y_points, polydegree);
       % evaluate the fitter polynomial
       [ynew, ~] = polyval(p, x_points, S, mu);
       line_ss(lowerbound:upperbound) = ynew;
       plot(x_points, y_points, 'r'); hold on;
       plot(x_points, ynew,'g');
       hold off
       drawnow;
    end
    %if((item + window) == length(line))
    %    yfinal = [yfinal, ynew(lowerbound:upperbound)];
    %end
end
%
figure; imshow(gather(images{1})); hold on;
%plot(ipl(1,:), 'g', 'lineWidth', 0.5); hold on;
plot(line_ss, 'b');
%% Visualization 
order = 10;
for i = 1:size(BScans_UF, 3)
    
    % specify image path
    path = strcat(pwd, '\OCT-Images\DME\');
    path = strcat(path,int2str(i)); 
    filename = strcat(path, '.JPG');
    
    % acquire images
    curr_im = gather(images{i});
    
    % crop image
    curr_im = imcrop(curr_im, dimensions);
    % generate a vertical border between image sets
    border = 255*ones(size(temp_image,1),5);
    
    % remove the white borders present within image
    I_t = curr_im == 1;
    I_t = bwareaopen(I_t, 100);
    curr_im(I_t) = 0; 
    
    % visualize progress
    figure; imshow([curr_im, border, curr_im]); hold on;
    %plot(medlinevol(i, :), 'r', 'lineWidth', 0.5); hold on;
    plot(rpelinevol(i, :), 'b'); hold on;
    plot(medfilt1(inflline(i, :),order), 'c');hold on;
    plot(medfilt1(onfl(i, :),order), 'w'); hold on;
    plot(medfilt1(ipl(i, :),order), 'r'); hold on;
    plot(medfilt1(opl(i, :),order), 'g'); hold on;
    plot(medfilt1(icl(i, :),order), 'y'); hold on;
    drawnow
    
    % take a screen capture of our images
    screencapture(dimensions, 'target', filename);
end
hold off;

%%
I = BScans_UF(:,:,1);
% constrain the image based on upper and lower bounds
infline = inflline(1,:); % upper bound
medline = medlinevol(1,:);
rpeline = rpelinevol(1,:); % lower bound
bv = bvlinevol(1,:);
Params = inner_params;
[ipl,opl, icl] = SegmentInner(I,rpeline, infline, medline,bv, Params);
% 1) Normalize intensity values and align the image to the RPE
rpe = round(rpeline);
infl = round(infline);
[alignedBScan, flatRPE, transformLine] = alignAScans(I, inner_params, [rpe; infl]);
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

figure; imshow(alignedBScanDenAvg); hold on; plot(flatINFL,'r'); hold on; plot(flatICL, 'c'); hold on; plot(extrOPL, 'y');
hold on; plot(extrIPL, 'g');hold on; plot(rpeln, 'b');

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

figure; imshow(I);hold on; plot(ipl,'r'); hold on; plot(icl, 'b'); hold on; plot(opl, 'c');
hold on; plot(rpe, 'y'); hold on; plot(infl, 'w');

[onflAuto] = SegmentOnfl(I,infl,ipl,icl, opl,bv,onfl_params)


% find ONFL now
bscanDSqrt = sqrt(I);
% 2) Find blood vessels for segmentation and energy-smooth 
[alignedBScanDSqrt flatICL transformLine] = alignAScans(bscanDSqrt, onfl_params, [icl; round(infl)]);
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
noiseStd = estimateNoise(alignedBScanDSqrt, onfl_params);

% Complex diffusion relies on even size. Enlarge the image if needed.
if mod(size(alignedBScanDSqrt,1), 2) == 1 
    alignedBScanDSqrt = alignedBScanDSqrt(1:end-1, :);
end
onfl_params.DENOISEPM_SIGMA = [(noiseStd * onfl_params.ONFLLIN_SEGMENT_DENOISEPM_SIGMAMULT) (pi/1000)];

if mod(size(alignedBScanDSqrt,2), 2) == 1
    temp = alignedBScanDSqrt(:,1);
    alignedBScanDSqrt = alignedBScanDSqrt(:, 2:end);
    alignedBScanDen = real(denoisePM(alignedBScanDSqrt, onfl_params, 'complex'));
    alignedBScanDen = [temp alignedBScanDen];
else
    alignedBScanDen = real(denoisePM(alignedBScanDSqrt, onfl_params, 'complex')); 
end

% Find extrema highest Min, 2 highest min sorted by position
extr2 = findRetinaExtrema(alignedBScanDen, onfl_params, 2, 'min pos th', ...
    [flatINFL + 1; flatIPL - onfl_params.ONFLLIN_SEGMENT_MINDIST_IPL_ONFL]); 
extrMax = findRetinaExtrema(alignedBScanDen, onfl_params, 1, 'min', ...
    [flatINFL + 1; flatIPL - onfl_params.ONFLLIN_SEGMENT_MINDIST_IPL_ONFL]);

% 6) First estimate of the ONFL:
dist = abs(flatIPL - flatINFL);
onfl = extrMax(1,:); 
idx1Miss = find(extr2(1,:) == 0); 
idx2Miss = find(extr2(2,:) == 0); 
onfl(idx2Miss) = flatINFL(idx2Miss); 
onfl(bv(1,:) == 1) = flatIPL(bv(1,:) == 1);
%$onfl(onh(onh == 1)) = flatIPL(onh(onh == 1));
onfl= linesweeter(onfl, onfl_params.ONFLLIN_SEGMENT_LINESWEETER_INIT_INTERPOLATE);

% 7) Do energy smoothing
% Forget about the ONFL estimate and fit a poly trough it. Then Energy!
onfl = linesweeter(onfl, onfl_params.ONFLLIN_SEGMENT_LINESWEETER_INIT_SMOOTH);
onfl = round(onfl);

gaussCompl = fspecial('gaussian', 5 , 1);
smoothedBScan = alignedBScanDen;
smoothedBScan = imfilter(smoothedBScan, gaussCompl, 'symmetric');
smoothedBScan = -smoothedBScan;
smoothedBScan = smoothedBScan ./ (max(max(smoothedBScan)) - min(min(smoothedBScan))) .* 2 - 1;

onfl = energySmooth(smoothedBScan, onfl_params, onfl, find(single(bv(1,:))), [flatINFL; flatIPL]);

% Some additional constraints and a final smoothing
onfl(idx2Miss) = flatINFL(idx2Miss);

onfl = linesweeter(onfl, onfl_params.ONFLLIN_SEGMENT_LINESWEETER_FINAL);

diffNFL = onfl - flatINFL;
onfl(find(diffNFL < 0)) = flatINFL(find(diffNFL < 0));

onflAuto = onfl + transformLine;

figure; imshow(alignedBScanDen); hold on; plot(flatINFL,'r'); hold on; plot(flatICL, 'c'); hold on; plot(extrOPL, 'y');
hold on; plot(extrIPL, 'g');hold on; plot(rpeln, 'b'); hold on; plot(onfl, 'r');


figure; imshow(I);hold on; plot(ipl,'r'); hold on; plot(icl, 'b'); hold on; plot(opl, 'c');
hold on; plot(rpe, 'y'); hold on; plot(infl, 'w');hold on; plot(onflAuto,'g');

%% extract inner lines
[icl, opl, ipl] = segmentInnerLayersVolume(BScans_F, inner_params, onh, rpelinevol, inflline, medlinevol, bvlinevol);
 
% visualize progress
VisualizeInnerLines(BScans_UF, icl, opl, ipl);

%% Extract ONFL lines
onfllinevol = segmentONFLVolume(BScans_F(:,:, 1:10), onfl_params, onh, rpelinevol(1:10,:), icl(1:10,:), ipl(1:10,:), inflline(1:10,:), bvlinevol(1:10,:));
