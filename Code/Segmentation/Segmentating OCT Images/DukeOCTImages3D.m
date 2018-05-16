%% Research Segmentation Script

% Author : D Yoan L Mekontchou Yomba

% Lab:  Biomage Statistical Pattern Recognition Laboratory

% Date: January 2nd 2017

% Content - Segmenting OCT retinal images 

 

%% Introduction

clear all; close all; clc; % clearing all workspace

warning off; % eliminating warnings

%% Adding Folder Path
close all;
clear all;
clc;
folder = dir('\\bioimagefs.coe.drexel.edu\Raw\Images\Duke_Public_OCT_images\');
folder(1:2) = [];
% get file path
imagedirectory = fullfile(folder(1).folder,folder(1).name, 'TIFFs\8bitTIFFs');
% acquire all tif files in given folder
imageset = dir(fullfile(imagedirectory, '*.tif'));
%% Filter image set

EtpfilteredImgSet = [ ];
GabfilteredImgSet = [ ];

GaussfilteredImgSet = [ ];
stdfilteredImgSet = [ ];
figure; 
for i = 1:numel(imageset)
    imagepath = fullfile(imageset(i).folder, imageset(i).name);
    image = mat2gray(imread(imagepath));
    image = imcrop(image, [0.51,158.51,50998, 173.98]);
    image1 = filterim(image);
    image2 = threshold(image1);
    bounds = bwboundaries(image2);
    imagesc(image); hold on;
    for i=1:length(bounds)
       plot(bounds{i}(:,2), bounds{i}(:,1), 'r','linewidth',3); 
    end
    drawnow;
    %imshowpair(image2, image, 'montage'); drawnow;
end
%%
figure
for i = 1:size(image_3d,3)
    image2 = padarray(image_3d(:,:,i),[0,1,1]);
    % suppress light structures connected to the image border
    image2 = imclearborder(image2);
    image_3d(:,:,i) = image2(:,2:end-1,2:end-1);
    imagesc(image_3d(:,:,i)); drawnow

end
%%
%Apply a gaussian filter on image in 3d with standard deviation of 20 then
%subtract the smooted image version from the original
image_3d = image_3d - imgaussfilt3(image_3d,[20,20,3]);

image_3d = max(image_3d,0);
image_3d = medfilt3(image_3d);
for i = 1:size(image_3d,3)
    imagesc(image_3d(:,:,i));
    drawnow;
end

%%
IMG_thresh = graythresh(image_3d);
binary = image_3d > IMG_thresh;
% TODO -- use hist on area to get the optmal threshold
binary2 = bwareaopen(binary,1000);
for i = 1:size(binary,3)
    imagesc([binary(:,:,i),image_3d(:,:,i)]);
    drawnow;
end


%%
v = VideoWriter('segmentation','Uncompressed AVI');
open(v);
for i = 1: numel(imageset)
    imagepath = fullfile(imageset(i).folder, imageset(i).name);
    image = imread(imagepath);
    image2 = padarray(image, [0,1]);
 
    image = imclearborder(image2);
    image = image(:,2:end-1);
    filtimage = image - imgaussfilt(image,30);
    filtimage = medfilt2(filtimage,[5,5]);
    EtpfilteredImgSet{i} =  filtimage;
    imshowpair(image,filtimage,'montage');
    drawnow;
    fr = getframe();
    writeVideo(v,fr);
end
close(v)


v = VideoWriter('newfile','Uncompressed AVI');
open(v);
    for i = 1:size(image_3d,3)
    imagesc(image_3d(:,:,i));
    drawnow;
    fr = getframe();
    writeVideo(v,fr);
end
close(v)


%v.CompressionRatio = 3;
%% ====== SEGMENTATION WITH KMEANS CLUSTERING ALGORITHM =======================
% kmeans used to cluster intensity values of image to segment image into different regions
v = VideoWriter('segmentation2','Uncompressed AVI');
open(v);
for i=1:numel(EtpfilteredImgSet)
%     imagepath = fullfile(imageset(i).folder, imageset(i).name);
%     IMG = imread(imagepath);
    IMG = mat2gray(EtpfilteredImgSet{i});
    IMG_CM = IMG;
    IMG_thresh = graythresh(IMG);
    IMG_thresh = IMG_thresh;
    IMG_CM(IMG_CM<=IMG_thresh)=0;
    
    % find pixelations all greater than 0
    index = find(IMG_CM > 0);
    % create a logical matrix comprised of zeroes matching the size of the
    % previous matrix
    IMG_bwcmp = logical(0*IMG_CM);
    % set all indexes of the logical matrix that had pixalation greater than 0 to 1
    IMG_bwcmp(index) = 1;
    % Segmentation - Black and White
    title('Manual Segmentation - Probably Not The Best - Review With Professor')
    
%     colorim = repmat(mat2gray(IMG),[1,1,3]);
%     colorim(:,:,1) = colorim(:,:,1)+IMG_bwcmp;
% %     colorim(:,:,2) = colorim(:,:,2).*IMG_bwcmp;
% %     colorim(:,:,2) = colorim(:,:,2).*IMG_bwcmp;
% % 
%      imagesc(colorim);
%     drawnow; %imshow(IMG);
%     figure;
    imshowpair(mat2gray(IMG), IMG_bwcmp, 'montage');
    drawnow;
    fr = getframe();
    writeVideo(v,fr);
end
close(v);
%% 
% Must find a way to optimize the number of local neighborhoods
figure;imshow(image);
knnimage = KnnSegmentation(image, 4); 
%% ====== SEGMENTATION WITH MULTITHRESH ========================
% Must find a way to optimize the number of thresholds parameters
[image, imageseg ]= MultiThrehsSegmentation( IMG,2);
%% ============ APPLY KMEANS CLUSTERING TO MULTITHRESH SEGMENTATION ==========
close all;

knnMultimage = KnnSegmentation(imageseg, 3);
% % Must administer bwareaopen
% 
% connected_comp = bwconncomp(knnMultimage);
% 
% im1_complement = bwareaopen(knnMultimage,connected_comp.Connectivity);
% 
% figure; imshow(im1_complement);
%% convert original image to black and white constituent

bw = logical(0*im);

% find all indexes where Img_seg is greater than some pre-specified value

indx = find(im);

% set index location to value of 1

bw(indx) = 1;

% Investigate connectitvity of black and white

CC = bwconncomp(bw);

% Obtain pixels to be evaluated

numPixels = cellfun(@numel,CC.PixelIdxList);

% Cannot quite figure this out
[~,idx] = find(numPixels<50 & numPixels>1e3);

bw(vertcat(CC.PixelIdxList{idx})) = 0;

close all;

figure; imshow(bw);

%%

[L num]=bwlabeln(bw);

figure;

imshow(L); 

%% Start segmentation
% % get AMD Json Files
% amd_jsonfile_path = strcat(root,'\AMD');
% AMDfolder = dir(amd_jsonfile_path);
% AMDfolder(1:2) = [];
% AMDfilenames = {AMDfolder(:).name};
% for i = 1%:numel(AMDfilenames)
%    filepath = [strcat(AMDfolder(2*i).folder, strcat('\',strcat(AMDfilenames(2*i))))]; 
%    [IM, IMAGEDATA] = MicroscopeData.ReaderH5(char(filepath(:)));
%     
%    % Work the segmentation
%    % get the maximal pixel values in three dimensional space
%     imagesc(max(IM,[],3))
%     % getting rid of unneeded data and taking the sum in 3-dimensional
%     % space
%     imagesc(sum(IM,3))
%     IM2 = IM;
%     
%     % segmented layers
%     IM2(IM2==255)=0;
%     IM3 = IM2 - imgaussfilt3(IM2,[20 20 ,5]);
%     IM3 = max(IM3,0);
%     IM3  = imgaussfilt3(IM3,[5,5,1]);
%     imagesc(IM2(:,:,1))
%     
% 
%    % Threshold Image 
%    thresh = graythresh(mat2gray(IM3));
%    bim = mat2gray(IM3)>thresh;
%    imagesc(bim(:,:,1))
%    bim = IMG;
%    bim2 = bim;
%    bim2 = imclose(bim,ones(1,1,3));
%    
%    bim2 = bwareaopen(bim2,20000);
%    
%    bim2 = imopen(bim2,ones(1,1,5));
%    bim2 = bwareaopen(bim2,1000);
% 	 DrawIM = [];   
%     for i=1:size(RGB,3)         
%         LIM = bwlabel(bim(:,:,i));
%         %         imagesc([IM2(:,:,i),bim(:,:,i)*255])
%         DrawIM = repmat(mat2gray(RGB(:,:,i)),[1 1 3]);
%         DrawIM(:,:,1) = min(DrawIM(:,:,1) + (LIM==1),1);
%         DrawIM(:,:,2) = min(DrawIM(:,:,2) + (LIM==2),1);
%         imagesc(mat2gray(DrawIM))
%         drawnow;
%     end
% 
% %     rp = regionprops(bim2)
% %     histogram([rp.Area])
% % color every connected component in 3-d
%      Ln = bwlabeln(bim2);
%  
% end
% %

%%
   bw=smooth3(bw);
    CC = bwconncomp(bw);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [~,idx] = find(numPixels<5 | numPixels>0);
    bw(vertcat(CC.PixelIdxList{idx})) = 0;
    
%     bwProject=max(bw,[],3);
% %     figure;imagesc(bwProject)
%     drawnow
        
    [L num]=bwlabeln(bw);
    for n=1:num
        idx=find(L==n);
        if length(idx)>max_volume_pixels
            continue;
        end
        
        if length(idx)<min_volume_pixels
            continue
        end
        newCell=Segment.FrameSegment_3D_create(idx,size(bw),c,t);
        Cells=[Cells newCell];
         
    end
    tElapsed=toc;
    %fprintf(1,'segmented frame %d, channel %d found %d cells : elapsed time = %f seconds\n',t,c,length(Cells),tElapsed);
    
