% Goal: Adequately Segment OCT Images
% Author: Yoan Yomba

% clear workspace
clc; clear all; close all;

% add all path
addpath(genpath('.'));
addpath(genpath('D:\Yoan\Git\leverUtilities'));
addpath(genpath(('D:\Yoan\Git\leverjs')));
% compile c files to be used in anisotropic diffusion
compile_c_files

%% declare variables
FILENAME = 'filenames.list';
FILEPATH = 'paths.txt';
FILTER_OP = 'filter';


if(exist('imagedb.mat'))
   imagedb = load('imagedb.mat');
   BScans_stack = imagedb.BScans_stack;
else
    ImageData = getAllImagesc();
    for i = 3:size(ImageData,1)
       for j = 1: size(ImageData, 2)
          images = ImageData{i, j}; 
          % Read BScans as a volume 
          BScans_stack{i-2, j} = Convert_to3d(images);
       end
    end
    save -v7.3 imagedb.mat BScans_stack;
end
%% Load Parameters and preprocess the images for visualization purposes
for i = 1:1%size(BScans_stack, 2)
        for j = 1:size(BScans_stack,1)
          BScans_UF = BScans_stack{j,i}; 
          BScans_UF = imagePreprocessing(BScans_UF);
        end
end

if(exist('./parameters/parameters.mat'))
    parameters = load('./parameters/parameters.mat');
    bv_params = parameters.bv_params;
    med_params = parameters.med_params;
    onh_params = parameters.onh_params;
    rpe_params = parameters.rpe_params;
    infl_params = parameters.infl_params;
    onfl_params = parameters.onfl_params;
    inner_params = parameters.inner_params;

else
    % Load Parameters
    PARAMETER_FILENAME = 'octseg.param';
    med_params = loadParameters('MEDLINELIN', PARAMETER_FILENAME);
    onh_params = loadParameters('ONH', PARAMETER_FILENAME);
    rpe_params = loadParameters('RPELIN', PARAMETER_FILENAME);
    bv_params = loadParameters('BV', PARAMETER_FILENAME);
    infl_params = loadParameters('INFL', PARAMETER_FILENAME);
    inner_params = loadParameters('INNERLIN', PARAMETER_FILENAME);
    onfl_params = loadParameters('ONFLLIN', PARAMETER_FILENAME);
    save -v7.3 ./parameters/parameters.mat med_params onh_params rpe_params bv_params infl_params ...
        inner_params onfl_params;
end

%% extract the middle and rpe line from the image
BScans_UF = BScans_stack{5,2};
BScans_PRO = imagePreprocessing(BScans_UF, "Complex");

%%
% figure;
% for i = 1:size(BScans_UF, 3)
%     I = BScans_UF(:,:, i);
%     Ip = BScans_PRO(:,:,i);
%     %imshow(Ip);
%     middleline = medEstimation(I, med_params);
%     repline =rpeEstimation(Ip, rpe_params, middleline);
%     inflline = inflEstimation(Ip, infl_params, repline, middleline);
%     bvline = segmentBVLin(Ip, bv_params, ones(3,3), repline);
%     [opl, ipl, icl] = innerEstimation(Ip, inner_params, repline, inflline, middleline, bvline);
%     imshow(I); hold on;
%     plot(repline, 'y'); hold on;
%     %plot(middleline, 'c'); hold on;
%     plot(inflline, 'g'); hold on; 
%     plot(double(bvline), 'r'); hold on;
%     plot(opl, 'r'); hold on;
%     plot(ipl, 'b'); hold on;
%     plot(icl, 'w');
%     drawnow();
% 
% %     med(i, :) = middleline;
% %     rpe(i,:) = repline;
% %     infl(i,:) = inflline;
% %     opll(i, :) = opl;
% %     ipll(i,:) = ipl;
% %     icll(i,:) = icl;
% end
% strDB='D:\Yoan\DukeOCT\DME\DME1.LEVER';
% 
% conn = database(strDB, '','', 'org.sqlite.JDBC', 'jdbc:sqlite:');
% 
% CONSTANTS=Read.getConstants(conn);
% 
% im = MicroscopeData.Reader('imageData',CONSTANTS.imageData, 'chanList',1, ...
%     'timeRange',[1 1],'outType','single','prompt',false);
% sigma = 5;
% type = "";
% bw = dog3D(BScans_PRO, sigma, type);
% idxPixels=find(bw);
% imSize=size(bw);
% bwn=zeros(imSize);
% bwn(idxPixels)=1;
% PAD=5;
% % padd with extra zeros around the outside so our mesh covers boundaries
% bpad = zeros(size(bwn)+10);
% bpad(PAD+1:end-PAD,PAD+1:end-PAD,PAD+1:end-PAD)=bwn;
% bwn = bpad;
% % scale=[1,1,1];
% scale=max(imSize)./imSize/8;
% scale=max(min(scale,0.5),.01);
% resize=round(scale.*size(bwn));
% bwResize=imresize3(bwn,resize);
% [faces,verts]=isosurface(bwResize,graythresh(bwResize));
% if size(verts,1)<10
%     resize=round(2*scale.*size(bwn));
%     bwResize=imresize3(bwn,resize);
%     [faces,verts]=isosurface(bwResize,graythresh(bwResize));
% end
% norms = isonormals(bwResize,verts);
% % rescale verts back to 
% unscale=(size(bwn)./size(bwResize));
% % put unscale on x,y instead of r,c
% unscale=[unscale(2),unscale(1),unscale(3)];
% 
% verts=(verts).*unscale-0.5*unscale;
% edges=Segment.MakeEdges(faces);
%  
% % make edges and faces zero indexed
% edges=edges-1;
% faces=faces-1;
% 
% % subtract extract for padding
% verts=verts-PAD;
% maxRad = verts-repmat(mean(verts,1),size(verts,1),1);
% maxRad=sum(abs(maxRad),2);
% maxRad=max(maxRad);
% newCell=[];
% newCell.time=datetime('now');
% newCell.centroid=[mean(verts,1)]-1;
% newCell.edges=edges;
% newCell.faces=faces;
% newCell.verts=verts;
% newCell.normals=norms;
% xyzPts=[];
% % note that xyzPts are on the correct range, as idxPixels is unpadded...
% [xyzPts(:,2),xyzPts(:,1),xyzPts(:,3)]=ind2sub(imSize,idxPixels);
% 
% newCell.pts=uint16(xyzPts);
% newCell.maxRadius=maxRad;
% newCell.channel=1;
% 
% %strDB='d:\andy\3draw.LEVER';
% strDB = 'D:\Yoan\DukeOCT\DME\DME1.LEVER';
% AddSQLiteToPath();
% conn = database(strDB, '','', 'org.sqlite.JDBC', 'jdbc:sqlite:');
% Write.CreateCells_3D(conn,newCell)

%% Lever Connection
 im = MicroscopeData.Reader('imageData',CONSTANTS.imageData, 'chanList',1, ...
     'timeRange',[1 1],'outType','single','prompt',false);
 sigma = 5;
 type = "";
 volume = dog3D(BScans_PRO, sigma, type);
 idxPixels=find(bw);
 imSize=size(bw);
 bwn=zeros(imSize);
 bwn(idxPixels)=1;
 PAD=5;
 % padd with extra zeros around the outside so our mesh covers boundaries
 bpad = zeros(size(bwn)+10);
 bpad(PAD+1:end-PAD,PAD+1:end-PAD,PAD+1:end-PAD)=bwn;
 bwn = bpad;
 % scale=[1,1,1];
 scale=max(imSize)./imSize/8;
 scale=max(min(scale,0.5),.01);
 resize=round(scale.*size(bwn));
 bwResize=imresize3(bwn,resize);
 [faces,verts]=isosurface(bwResize,graythresh(bwResize));
 if size(verts,1)<10
    resize=round(2*scale.*size(bwn));
    bwResize=imresize3(bwn,resize);
    [faces,verts]=isosurface(bwResize,graythresh(bwResize));
end
norms = isonormals(bwResize,verts);
% rescale verts back to 
unscale=(size(bwn)./size(bwResize));
% put unscale on x,y instead of r,c
unscale=[unscale(2),unscale(1),unscale(3)];

verts=(verts).*unscale-0.5*unscale;
edges=Segment.MakeEdges(faces);
 
% make edges and faces zero indexed
edges=edges-1;
faces=faces-1;

% subtract extract for padding
verts=verts-PAD;
maxRad = verts-repmat(mean(verts,1),size(verts,1),1);
maxRad=sum(abs(maxRad),2);
maxRad=max(maxRad);
newCell=[];
newCell.time=datetime('now');
newCell.centroid=[mean(verts,1)]-1;
newCell.edges=edges;
newCell.faces=faces;
newCell.verts=verts;
newCell.normals=norms;
xyzPts=[];
% note that xyzPts are on the correct range, as idxPixels is unpadded...
[xyzPts(:,2),xyzPts(:,1),xyzPts(:,3)]=ind2sub(imSize,idxPixels);

newCell.pts=uint16(xyzPts);
newCell.maxRadius=maxRad;
newCell.channel=1;

strDB = 'D:\Yoan\DukeOCT\DME\DME1.LEVER';
AddSQLiteToPath();
conn = database(strDB, '','', 'org.sqlite.JDBC', 'jdbc:sqlite:');
Write.CreateCells_3D(conn,newCell)
%%
im = MicroscopeData.Reader('imageData',CONSTANTS.imageData, 'chanList',1, ...
    'timeRange',[1 1],'outType','single','prompt',false);
bw = im * 0;

pts1 = round(icll);
pts2 = round(ipll);
pts3 = round(infl);
pts4 = round(opll);
pts5 = round(rpe);

for i = 1:size(pts1, 2)
    for ii = 1:size(pts1, 1)
        bw(pts1(ii, i),i,ii) = 1;
        bw(pts2(ii, i),i,ii) = 2;
        bw(pts3(ii, i),i,ii) = 3;
        bw(pts4(ii, i),i,ii) = 4;
        bw(pts5(ii, i),i,ii) = 5;
    end
% 2d view
end
figure; imagesc(any(bw,3));
lm=multithresh(im,5);

q=imquantize(im,lm);

bw=logical(bw);



CC = bwconncomp(bw);

[L num]=bwlabeln(bw);


 

Cells=[];

for n=1:num
    idxPixels=find(L==n);
    bwn=zeros(size(bw));
    bwn(idxPixels)=1;
    [faces,verts]=isosurface(bwn,graythresh(bwn));
    norms = isonormals(bwn,verts);
    edges=Segment.MakeEdges(faces);  
    % make edges and faces zero indexed
    edges=edges-1;
    faces=faces-1;
    maxRad = verts-repmat(mean(verts,1),size(verts,1),1);
    maxRad=sum(abs(maxRad),2);
    maxRad=max(maxRad);
    newCell=[];
    newCell.time=1;
    newCell.centroid=[mean(verts,1)]-1;
    newCell.edges=edges;
    newCell.faces=faces;
    newCell.verts=verts;
    newCell.normals=norms;
    xyzPts=[];
    % note that xyzPts are on the correct range, as idxPixels is unpadded...
    [xyzPts(:,2),xyzPts(:,1),xyzPts(:,3)]=ind2sub(size(bw),idxPixels);
    newCell.pts=uint16(xyzPts);
    newCell.maxRadius=maxRad;
    newCell.channel=1;
    Cells=[Cells;newCell];
end
Write.CreateCells_3D(conn,Cells);
%% Process all 3D volumetric images and acquire all layers
if(exist('./volumetricData/volumetricData.mat'))
    volumetricData = load('./volumetricData/volumetricData.mat');
    medlines = volumetricData.medlines;
    rpelines = volumetricData.rpelines;
    onhlines = volumetricData.onhlines;
    inflines = volumetricData.inflines;
    bvlines = volumetricData.bvlines;
    iplines = volumetricData.iplines;
    oplines = volumetricData.oplines;
    iclines = volumetricData.iclines;
    onflines = volumetricData.onflines;    
else
    for i = 1:size(BScans_stack, 2)
        for j = 1:size(BScans_stack,1)
          BScans_UF = BScans_stack{j,i}; 
          BScans_UF = imagePreprocessing(BScans_UF);
          % perform edge enhanced anisotropic diffusion
          medlinevol = segmentMedlineVolume(BScans_UF, med_params);
          rpelinevol = segmentRPEVolume(BScans_UF, rpe_params, medlinevol);
          % Segment onh line
          [onh, onhCenter, onhRadius] = segmentONHVolume(BScans_UF, onh_params, rpelinevol);
          % extract infl layer present in the image
          infllinevol = segmentINFLVolume(BScans_UF, infl_params, onh, rpelinevol, medlinevol);
          bvlinevol = segmentBVVolume(BScans_UF, bv_params,onh, rpelinevol);

          [ipl,opl,icl] = SegmentInnnerStack(BScans_UF,rpelinevol, infllinevol, medlinevol,bvlinevol, inner_params);

          % segment onfl line
          [onfl] = SegmentONflStack(BScans_UF,infllinevol,ipl,icl,opl,bvlinevol,onfl_params);

          medlines{j,i} = medlinevol;
          rpelines{j, i} = rpelinevol;
          onhlines{j,i} = onh;
          inflines{j, i} = infllinevol;
          bvlines{j,i} = bvlinevol;
          iplines{j,i} = ipl;
          oplines{j,i} = opl;
          iclines{j,i} = icl;
          onflines{j,i} = onfl;
       end
    end
    
    save -v7.3 ./volumetricData/volumetricData.mat rpelines medlines onhlines ...
        inflines bvlines iplines oplines iclines onflines
end
    

% Write the segmented and layer detected images to a folder
order = 1;

%% generate a vertical border between image sets
temp_image = gather(BScans_stack{1}(:,:,1));
border = 255*ones(size(temp_image,1),5);

% specify image dimensions for screen capture
image_dimensions = [1.51, 0.51, 1.008, 0.4790];

w_s = 100;
degree = 5;
for i = 2:2%size(inflines,2)
    for j = 1:9%size(inflines, 1)
        % specify image path
        switch(i)
            case 1
                path = strcat(pwd, '\OCT-Images\NORM\');
                norm_folder_path = strcat('NORM', num2str(j));
                norm_folder_path = strcat(norm_folder_path, '\');
                norm_folder_path = strcat(path,norm_folder_path); 
                mkdir(norm_folder_path);
                path = norm_folder_path;
            case 2
                path = strcat(pwd, '\OCT-Images\AMD\');
                amd_folder_path = strcat('AMD', num2str(j));
                amd_folder_path = strcat(amd_folder_path, '\');
                amd_folder_path = strcat(path,amd_folder_path); 
                mkdir(amd_folder_path);
                path = amd_folder_path;
            case 3
                path = strcat(pwd, '\OCT-Images\DME\');
                dme_folder_path = strcat('DME', num2str(j));
                dme_folder_path = strcat(dme_folder_path, '\');
                dme_folder_path = strcat(path,dme_folder_path); 
                mkdir(dme_folder_path);
                path = dme_folder_path;
        end
        % acquire images
        imagestack = BScans_stack{j, i};
        inflvolume = inflines{j, i};
        rpevolume = rpelines{j, i};
        onhvolume = onhlines{j,i};
        bvvolume = bvlines{j,i};
        iplvolume = iplines{j,i};
        oplvolume = oplines{j,i};
        iclvolume = iclines{j,i};
        onflvolume = onflines{j,i};
        
        for k = 1:size(inflvolume, 1)
            image_name = strcat(int2str(k), '.tif'); 
            filename = strcat(path, image_name);
            curr_im = imagestack(:,:,k);
            % crop image
            %curr_im = imcrop(curr_im, dimensions);
            % remove the white borders present within image
            I_t = curr_im == 1;
            I_t = bwareaopen(I_t, 100);
            curr_im(I_t) = 0; 
            
            % visualize progress
            figure; imshow([curr_im, border, curr_im]); hold on;
            %plot(medlinevol(i, :), 'r', 'lineWidth', 0.5); hold on;
            %plot(lineProcessing(size(rpevolume(k, :),2),rpevolume(k,:),w_s,degree), 'c');hold on;
            %plot(lineProcessing(size(inflvolume(k, :),2), inflvolume(k,:),w_s,degree), 'w');hold on;
            %plot(lineProcessing(size(onflvolume(k, :),2), onflvolume(k,:),w_s,degree), 'b');hold on;
            %plot(lineProcessing(size(iplvolume(k, :),2), iplvolume(k,:),w_s,degree), 'r');hold on;
            %plot(lineProcessing(size(iclvolume(k, :),2), iclvolume(k,:),w_s,degree), 'g');hold on;
            %plot(lineProcessing(size(oplvolume(k, :),2), oplvolume(k,:),w_s,degree), 'y');hold on;
            
            plot(rpevolume(k, :), 'c');hold on;
            plot(inflvolume(k, :), 'w'); hold on;
            plot(onflvolume(k, :), 'b');hold on;
            plot(iplvolume(k, :), 'r');hold on;
            plot(iclvolume(k, :), 'g');hold on;
            plot(oplvolume(k, :), 'y');hold on;
            set(gca,'pos',[0,0,1,1]); print(filename, '-dtiff');
            drawnow
            
            % take a screen capture of our images
            % screencapture(gcf,[], 'target', filename);
        end 
    end
end
hold off;

%% Store segmented layers
rpevolume_t = smoothLine(rpevolume);
inflvolume_t = smoothLine(inflvolume);
onflvolume_t = smoothLine(onflvolume);
iplvolume_t = smoothLine(iplvolume);
iclvolume_t = smoothLine(iclvolume);
oplolume_t = smoothLine(oplvolume);

figure; mesh(rpevolume_t);
hold on; mesh(inflvolume_t);
hold on; mesh(onflvolume_t);
hold on; mesh(iplvolume_t);
hold on; mesh(iclvolume_t);
hold on; mesh(oplolume_t);
%%
addpath('D:\Yoan\Git\leverjs\matlab');
AddSQLiteToPath();
strDB='D:\Yoan\DukeOCT\AMD\AMD1.LEVER';
conn = database(strDB, '','', 'org.sqlite.JDBC', 'jdbc:sqlite:');
CONSTANTS=Read.getConstants(conn);

im = MicroscopeData.Reader('imageData',CONSTANTS.imageData, 'chanList',1, ...
    'timeRange',[1 1],'outType','single','prompt',false);
