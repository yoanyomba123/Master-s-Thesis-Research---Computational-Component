%% Specify imports and clean and clear workspace
clc;
close all;
clear all;

% adding specific folders to current path
addpath(genpath('.'));
addpath(genpath('D:\Yoan\Git\leverUtilities\src\MATLAB'));
addpath(genpath('D:\Yoan\Git\leverjs'));
addpath('D:\Yoan\Git\leverjs\matlab\');
path_name = 'D:\Yoan\TEMP\';

% loading BScans into workspace
if(exist('imagedb.mat'))
   imagedb = load('imagedb.mat');
   BScans_stack = imagedb.BScans_stack;
end

% load in lines
if (exist('volumetricData\volumetricData.mat'))
    load 'volumetricData\volumetricData.mat';
end

%%
specified_path = 'D:\Yoan\DATA';

for i = 1 : size(BScans_stack, 2)
    for j = 1: size(BScans_stack, 1)
        image_vol = BScans_stack{j, i};
        % pre-process the image
        BScans_stack{j, i} = imagePreprocessing(image_vol, "Complex", "");
        if(i == 1)
            path_ext = "\AMD\";
            vol_name = strcat("AMD", num2str(j));
        end
        if(i == 2)
            path_ext = "\DME\";
            vol_name = strcat("DME", num2str(j));
        end
        if(i == 3)
            path_ext = "\NORMAL\";
            vol_name = strcat("NORMAL", num2str(j));
        end
        curr_path = strcat(specified_path, path_ext);
        
        % write to h5 lever format in specified folder
        volumeToH5(BScans_stack{j, i}, char(vol_name), char(curr_path));
        Import.leverImport(curr_path, char(curr_path), char(vol_name), '');
        
        BW = BScans_stack{j, i} * 0;
        pts1 = round(iclines{j,i});
        pts2 = round(iplines{j,i});
        pts3 = round(inflines{j,i});
        pts4 = round(oplines{j,i});
        pts5 = round(rpelines{j,i});
        pts6 = round(onflines{j,i});

        for iz = 1:size(pts1, 2)
            for ii = 1:size(pts1, 1)
                BW(pts1(ii, iz),iz,ii) = 1;
                BW(pts2(ii, iz),iz,ii) = 2;
                BW(pts3(ii, iz),iz,ii) = 3;
                BW(pts4(ii, iz),iz,ii) = 4;
                BW(pts5(ii, iz),iz,ii) = 5;
                BW(pts6(ii, iz),iz,ii) = 6;
            end
        % 2d view
        end
        
        for z = 1:6
            idxPixels = find(BW == z);
            imSize=size(BW);
            channel = 1;
            time = 1;
            newCell=frameTo3D(idxPixels, imSize, channel, 1, ...
                '', '');
            db_path_name = strcat(strcat(strcat(curr_path, "\"), vol_name), ".LEVER");
            AddSQLiteToPath();
            conn = database(db_path_name, '','', 'org.sqlite.JDBC', 'jdbc:sqlite:');
            Write.CreateCells_3D(conn,newCell);
        end
    end
end


%%volume = BScans_stack{1,1};

%% remove all image outliers
%volume = imagePreprocessing(volume, "Complex", "remove");

% Apply the DOG Filter to the 3D Stack
im=volume;
tic
sigma=5;
% sigma/sqrt(2)
imd1=imgaussfilt3(im,sigma/100);
imd2=imgaussfilt3(im,sigma * 10);
imdog=imd1-imd2;
imp=max(imdog,[],3);figure;imagesc(imp)
toc

% apply the preprocessing algorithm you designed to the volumetric scans
improcessed = imagePreprocessing(im, "Complex", "");

% export image stacks to lever h5 format
volumeToH5(imdog, '3DRAW', path_name);
volumeToH5(improcessed, '3DRAWPROCESSED', path_name);

% 2. Point source and Dest Folder to the path refered above
% 3. Open image in lever
% 4. Perform More Analysis On Image
% imp_processed = max(improcessed, [], 3);
%% DOG filter thresholding
DOG = imquantize(imdog, multithresh(imdog, 3));
figure; imagesc(max(DOG,[],3));

bwdog = DOG * 0;
for i = 2:3
    idxPixels = find(DOG == i);
    imSize=size(bwdog);
    channel = 1;
    time = 1;
    newCell=frameTo3D(idxPixels, imSize, channel, 1, ...
        '', '');
    db_path_name = 'D:\Yoan\TEMP\3DRAW.LEVER';
    AddSQLiteToPath();
    conn = database(db_path_name, '','', 'org.sqlite.JDBC', 'jdbc:sqlite:');
    Write.CreateCells_3D(conn,newCell);
end

%%
improcessed_ph = improcessed;
% filter the preprocessed image stack
improcessed_ph = improcessed - imgaussfilt3(improcessed, 10);
% Convert image stack to its black and white complement
bw = imquantize(improcessed_ph, graythresh(improcessed_ph));
bwtemp = imquantize(improcessed_ph, multithresh(improcessed_ph, 3));

% load 2D extracted lines into matlab workspace
load 'volumetricData\volumetricData.mat';

BW = improcessed_ph *0;
pts1 = round(iclines{1,1});
pts2 = round(iplines{1,1});
pts3 = round(inflines{1,1});
pts4 = round(oplines{1,1});
pts5 = round(rpelines{1,1});
pts6 = round(onflines{1,1});

for i = 1:size(pts1, 2)
    for ii = 1:size(pts1, 1)
        BW(pts1(ii, i),i,ii) = 1;
        BW(pts2(ii, i),i,ii) = 2;
        BW(pts3(ii, i),i,ii) = 3;
        BW(pts4(ii, i),i,ii) = 4;
        BW(pts5(ii, i),i,ii) = 5;
        BW(pts6(ii, i),i,ii) = 6;
    end
% 2d view
end

figure; imagesc(any(BW,3));
for i = 1:6
    idxPixels = find(BW == i);
    imSize=size(bw);
    channel = 1;
    time = 1;
    newCell=frameTo3D(idxPixels, imSize, channel, 1, ...
        '', '');
    db_path_name = 'D:\Yoan\TEMP\3DRAWPROCESSED.LEVER';
    AddSQLiteToPath();
    conn = database(db_path_name, '','', 'org.sqlite.JDBC', 'jdbc:sqlite:');
    Write.CreateCells_3D(conn,newCell);
end

% bwToLever(imdog, 'D:\Yoan\TEMP\3DRAW.LEVER');
% Import.leverImport('','D:\Yoan\TEMP\');