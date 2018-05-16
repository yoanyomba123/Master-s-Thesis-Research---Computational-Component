% Segmentation script
% Author: D Yoan L Mekontchou Yomba
% Date: 4/7/2018

% clear work spacer
clc;
clear all;
close all;

% Add all relative paths
addpath(genpath('.'));

FILENAME = 'filenames.list';
FILEPATH = 'paths.txt';

% load in images
[images, file, n, paths] = getAllfolderimages('C:/Users/undergrad/Desktop/Publication_Dataset/DME1/TIFFs/8bitTIFFs/*.tif', FILENAME, FILEPATH);
% remove all empty cell arrary contents
images = images(~cellfun('isempty', images));
% Segmenting Single Image First

% for i = 1: length(images)
%     volumne(:,:, i) = gather(images{i});
% end


% Read BScans as a volume
[ActDataDescriptors.Header, ActDataDescriptors.BScanHeader, slo, BScans] = openOctListHelp(strcat('./',FILENAME), paths{1}, 'metawrite');
dimensions = [5.51, 9.51, 501.98, 478.98];

% %%
% I = gather(images{1,4});
% I = imcrop(I, dimensions);
% % Get rid of brigh tspot
% I_t = I == 1;
% I_t =bwareaopen(I_t, 1000);
% I(I_t) = 0; 
% % identify layers and get rid of B-Ground
% Im_tmp = imquantize(I, multithresh(I, 2));
% I(Im_tmp == 1) = multithresh(I, 1);
% 
% % load parameters
% PARAMETER_FILENAME = 'octseg.param';
% medlin_params = loadParameters('MEDLINELIN', PARAMETER_FILENAME);
% onh_params = loadParameters('ONH', PARAMETER_FILENAME);
% rpelin_params = loadParameters('RPELIN', PARAMETER_FILENAME);
% bv_params = loadParameters('BV', PARAMETER_FILENAME);
% infl_params = loadParameters('INFL', PARAMETER_FILENAME);
% innerlin_params = loadParameters('INNERLIN', PARAMETER_FILENAME);
% onfl_params = loadParameters('ONFL', PARAMETER_FILENAME);
% sklera_params = loadParameters('SKLERA', PARAMETER_FILENAME);
% 
% medline = findmedline(I, medlin_params);
% [rpelin, rpe_mult] = segmentRPELin(I, rpelin_params, medline);
% [infl_line, infl_Choice] = segmentINFLLin(I, infl_params, rpelin, medline);
% 
% 
% [icl, opl, ipl] = segmentInnerLayersLin(I, infl_params, onh, rpelin, infl_lin, medline, bv)
% 
% % visualize the median line
% figure;imshow(I);hold on; plot(medline, 'r'); hold on; plot(rpelin, 'b'); hold on;
% plot(infl_line, 'g');
% ALL BSCANS  
imageset = BScans;
for i = 1:size(BScans,3)
    I = imcrop(BScans(:,:,i), dimensions);
    % Get rid of brigh tspot
    I_t = I == 1;
    I_t = bwareaopen(I_t, 600);
    I(I_t) = 0; 
    % identify layers and get rid of B-Ground
    Im_tmp = imquantize(I, multithresh(I, 2));
    I(Im_tmp == 1) = multithresh(I, 1);
    BScanss(:,:,i) = I;

end
BScans = BScanss;

%% load parameters
PARAMETER_FILENAME = 'octseg.param';
medlin_params = loadParameters('MEDLINELIN', PARAMETER_FILENAME);
onh_params = loadParameters('ONH', PARAMETER_FILENAME);
rpelin_params = loadParameters('RPELIN', PARAMETER_FILENAME);
bv_params = loadParameters('BV', PARAMETER_FILENAME);
infl_params = loadParameters('INFL', PARAMETER_FILENAME);
innerlin_params = loadParameters('INNERLIN', PARAMETER_FILENAME);
onfl_params = loadParameters('ONFL', PARAMETER_FILENAME);


% extract the median line between the two highest pixel intensity regions
medlinevol = segmentMedlineVolume(BScans, medlin_params);
medline = findmedline(I, medlin_params);


% extract rpe layers from volume set
rpevol = segmentRPEVolume(BScans, rpelin_params, medlinevol);
[rpelin, rpe_mult] = segmentRPELin(I, rpelin_params, medline);


% Segment onh line
[onh, onhCenter, onhRadius] = segmentONHVolume(BScans, onh_params, rpevol);

% extract blood vessel regions
bvvol= segmentBVVolume(BScans, bv_params,onh, rpevol);
bv = segmentBVLin(I, bv_params, onh, rpelin);

% extract INFL line
[infl_line, infl_Choice] = segmentINFLLin(I, infl_params, rpelin, medline);
[inflvol, inflvol] = segmentINFLVolume(BScans, infl_params,onh, rpevol, medlinevol);

% extract inner lines
[icl, opl, ipl] = segmentInnerLayersLin(I, innerlin_params, onh, rpelin, infl_line, medline, bv)



% inflvol = zeros(size(bvvol));
% for i = 1:size(BScans, 1)
%     [infl_line, infl_Choice] = segmentINFLLin(BScans(:,:,i), infl_params, rpevol(:, i), medlinevol(i,:));    
%     inflvol(i,:) = infl_line;
% end
% extract inner layers
[icl, opl, ipl] = segmentInnerLayersLin(BScans, innerlin_params, onh, rpevol, infl, medlinevol, bvvol)

for i = 1: size(BScans, 3)
    figure;
    imshow(BScans(:,:,i));
    hold on; plot(rpevol(i, :),'r');
    hold on; plot(medlinevol(i,:), 'b');
    %hold on; plot(bvvol(i, :), 'c');
    hold off;
end


