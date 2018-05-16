%% Author Info.
% Name: D Yoan L Mekontchou Yomba
% Date: 12/11/2017

%% Clear workspace
clc;
clear all;
close all;

%% Adding Necessary paths
addpath('./Utilities/*')
addpath('./Utilities/FilteringScripts/*')
addpath('./Utilities/SegmentationScripts/*')

%% Write AMD to Folders
% specify root directory
folder = dir('\\bioimagefs.coe.drexel.edu\Raw\Images\Duke_Public_OCT_images\');

% specify ouput directory
root = 'D:\Yoan\DukeOCT';
mkdir(root, '\AMD');
mkdir(root, '\DME');
mkdir(root, '\NORMAL');

% specify output class directory
AMDpath = strcat(root, '\AMD');
MDEpath = strcat(root, '\DME');
NORMpath =strcat(root, '\NORMAL');
% remove current and past directory pointers
folder(1:2) = [];
class = '';
%% Write Images To Respective Folders
for i=1:numel(folder)
    % get file path
    imagedirectory = fullfile(folder(i).folder,folder(i).name, 'TIFFs\8bitTIFFs');
    % acquire all tif files in given folder
    imageset = dir(fullfile(imagedirectory, '*.tif'));
    
    % check if path name contains some string and assign type and class
    % based on this
    if(contains(imagedirectory, 'NORMAL'))
       type = 'norm';
       class = 'norm';
    elseif(contains(imagedirectory, 'AMD'))
        type = 'amd';
        class = 'amd';
    else
        type = 'dme';
        class = 'dme';
    end
    
    % create folder based on the class type
    if(strcmp(class,'amd')==1)
         %mkdir(AMDpath,folder(i).name);
         %v = strcat(AMDpath, strcat('\',strcat(folder(i).name,'\')));
         v = AMDpath;
   elseif(strcmp(class,'dme')==1)
        %mkdir(MDEpath,folder(i).name);
        %v = strcat(MDEpath, strcat('\',strcat(folder(i).name,'\')));
        v = MDEpath;
   elseif(strcmp(class,'norm')==1)
        %mkdir(NORMpath,folder(i).name);
        %v = strcat(NORMpath, strcat('\',strcat(folder(i).name,'\')));
        v = NORMpath;
   end
   h5Converter(imagedirectory,v,folder(i).name);
end
%% Start Segmentation Work
% observe files in each class specific directory
AMDFolder = dir(AMDpath);
MDEFolder = dir(MDEpath);
NORMFolder = dir(NORMpath);
% removing past and current directory pointers
AMDFolder(1:2) = [];
MDEFolder(1:2) = [];
NORMFolder(1:2) = [];

% acquiring class specific file names
AMDfilenames = {AMDFolder(:).name};
MDEfilenames = {MDEFolder(:).name};
NORMfilenames = {NORMFolder(:).name};

Imgdata = [];
for i = 1:numel(AMDfilenames)
   filepath = [strcat(AMDFolder(2*i).folder, strcat('\',strcat(AMDfilenames(2*i))))]; 
   [IM, IMAGEDATA] = MicroscopeData.ReaderH5(char(filepath(:)));
   
   % Observe the Iniital Maximal Pixel Intensities 
%    imagesc(max(IM, [],3));
   
   filteredIm = filteringScript(IM);
%    figure
%    imagesc(filteredIm(:,:,1))
   
   imagesc(max(filteredIm,[],3)) 

   % Threshold Image
   % ############# MUST BE DONE IN SMART WAY###########
   % ############# Thoughts ? ######################
   % Choose threshold in a way that minimized within class deviation and
   % maximized between class deviation
  
%    Applying multithresh
%    lm = multithresh(filteredIm,6);
%    quantize the image
%    q = imquantize(filteredIm, lm);
%    Turning image into black and white complement
%    bw = logical(0*filteredIm);
%    idx=find(q>1 & q<6);
%    bw(idx)=1;
%    imagesc(bw(:,:,1))
%    find connected components in my image
%    CC = bwconncomp(bw);
%    performing morphological open on the image
%    bw = imopen(bw,ones(1,1,10));
% 
%    D3d.Open(bw);
   
   
   % Acquire image threshold values
   threshold_value = graythresh(mat2gray(filteredIm));
   
   imagesc(filteredIm(:,:,1));
   % Threshold the image
   Img_thresh = mat2gray(filteredIm) > threshold_value;
   imagesc(Img_thresh(:,:,1));
   props = regionprops(Img_thresh);
   maximumvalues = sort([props.Area]);
   maximumvalues = maximumvalues(end-1:end);
   minimum_d = min(maximumvalues);
   % histogram(log([props.Area]),10);
   Img_thresh = bwareaopen(Img_thresh ,minimum_d-1);
   imagesc(max(Img_thresh,[],3));
    % Lets See this in 3-D
   D3d.Open(Img_thresh);
%    imagesc(max(Img_thresh,[],3))
   drawnow;
%    for i = 1:49
%     imagesc(Img_thresh(:,:,i));
%     drawnow;
%    end
end

imagesc(max(Img_thresh,[],3))