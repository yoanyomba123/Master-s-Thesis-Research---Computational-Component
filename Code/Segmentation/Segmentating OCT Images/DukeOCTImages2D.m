%% Credential
% Author - D Yoan L Mekontchou Yomba
% Date - 1/26/2017
% purpose: Segment multiple OCT retinal images in 2D

%% Clean Workspace
clc;
clear all;
close all;
warning off;
%% Path configurations
folder = dir('\\bioimagefs.coe.drexel.edu\Raw\Images\Duke_Public_OCT_images\');
folder(1:2) = [];
%% Obtain Images 
% will eventually have to loop over all folders on this path
imagedirectory = fullfile(folder(1).folder,folder(1).name, 'TIFFs\8bitTIFFs');
% acquire all tif files in given folder
imageset = dir(fullfile(imagedirectory, '*.tif'));

%% Create 3-d image from oct stacks
figure;
for i = 1:numel(imageset)
    imagepath = fullfile(imageset(i).folder, imageset(i).name);
    % images now of type double and pixels in range of 0 - 1
    image = mat2gray(imread(imagepath));
    % generate a three dimensional view of the image and crop as well
    image = imcrop(image,[0.5100, 179.5100, 511.9800, 185.9800]);
    image_3d(:,:,i) = image;
    imshow(image); drawnow;
end
%% Filter image
% define a linear filter for the removal of grain noise
h = fspecial('log')
figure
for i = 1:2%size(image_3d,3)
    % perform median filter with neighborhoods of 4 pixels
    % subtract from this high frequencyme
    image = medfilt2(image_3d(:,:,i),[2,2]) - imgaussfilt(image_3d(:,:,i),900);
    image = ordfilt2(image, 9, true(3));
    image = (image - stdfilt(image)) - rangefilt(image);
    % remove shot noise once again
    image = medfilt2(image,[2,2]) - imgaussfilt(image,1000);
    % acquire image threshold
    threshold = graythresh(image);
    image = imsharpen(image, 'Threshold',threshold,'Amount',9);
    imshowpair(image, image_3d(:,:,i), 'montage'); drawnow;
end
