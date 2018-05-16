%% Duke OCT Image Tif to h5 and Json conversion

% Author Yoan Yomba
% date 12/6/2017
% 
% This script converts images to three dimensional representation to be
% viewed in lever
%
%% clean workspace
clc;
clear all;
close all;
warning off;
%% Directory obsevance
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
%% Data Structure formating
% generate class specific structs to hold the data 
AMD_struct = struct('Class', 'AMD')
MDE_struct = struct('Class', 'DME')
NORM_struct = struct('Class', 'NORM')

% combine class specific struct into one object
Data = {'AMD','MDE', 'NORM'; AMD_struct, MDE_struct, NORM_struct}

%% Perform work on images and write images to AMD, MDE,NORMAL folders
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
