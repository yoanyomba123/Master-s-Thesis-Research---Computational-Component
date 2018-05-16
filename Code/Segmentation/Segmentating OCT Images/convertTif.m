% import tiffs - sample file
%
% tiff import is tricky as the format is not explicitly specified in the 
% image. we want a 5-D image layed out as (x,y,z,channel,time)
% we then use the leverjsUtilities project to convert this image 
% to a hdf5 (h5) file, and generate a .json.
%
% the hdf5 and .json are then used as inputs to Import.leverImport('','/path/to/json');
% to generate a .LEVER file
% 
% alternatively, in the electron app/import tab, leave 'input folder'
% field empty, and set LEVER folder to /path/to/json, and then 'import' to
% generate .LEVER file.
%
clc;
clear all;
close all;
ROOT='\\bioimagefs.coe.drexel.edu\Raw\Images\Duke_Public_OCT_images\AMD1\TIFFs\8bitTIFFs';
flist=dir(fullfile(ROOT,'*.tif'));

im=[];
for ff=1:length(flist)
    fname=flist(ff).name;
    % get 2-d image
    im1=imread(fullfile(flist(ff).folder,flist(ff).name));
    % parse c,z,t
    % file name is e.g. 01.tif, etc.
    zName=fname(1:end-4);
    z=str2double(zName);
    t=1;
    c=1;
    im(:,:,z,c,t)=im1;
end

% make sure leverjsUtilities project is on your path!
% e.g. path(path,'pathTo\git\utilities\src\MATLAB')
imd=MicroscopeData.MakeMetadataFromImage(im);
if (ROOT(end)=='/' || (ROOT(end)=='\'))
    [~,expName,~]=fileparts(ROOT(1:end-1));
else
    [~,expName,~]=fileparts(ROOT(1:end));
end
imd.DatasetName=expName;
if (size(imd.Dimensions,2)~=3)
    imd.Dimensions=[imd.Dimensions 1];
end

MicroscopeData.WriterH5(im,'imageData',imd,'path','C:\Users\undergrad\Desktop\temp');

