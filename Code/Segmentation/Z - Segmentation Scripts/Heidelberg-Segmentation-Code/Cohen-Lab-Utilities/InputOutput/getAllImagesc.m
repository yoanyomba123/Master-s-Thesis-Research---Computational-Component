function ImageData = getAllImagesc(folder)

% Searches For all OCT images in a given path and returns a data structure
% containing the image set
% Input
%   OCT image root path
% Output
%   cell array containing 3D volumetric images

if nargin == 0
    folder = dir('\\bioimagefs.coe.drexel.edu\Raw\Images\Duke_Public_OCT_images\');
end

% specify ouput directory
root = 'C:\Users\undergrad\Desktop\Research - Master Thesis\Code\Segmentation\Z - Segmentation Scripts\OCT-Images';
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

% generate class specific structs to hold the data 
AMD_struct = struct('Class', 'AMD')
DME_struct = struct('Class', 'DME')
NORM_struct = struct('Class', 'NORM')

% combine class specific struct into one object
Data = {'AMD','DME', 'NORM'; AMD_struct, DME_struct, NORM_struct}

Data_AMD = {'AMD';AMD_struct};
Data_DME = {'DME';DME_struct};
Data_NORM = {'NORM';NORM_struct};

% Perform work on images and write images to AMD, MDE,NORMAL folders
for i=1:numel(folder)
    % get file path
    imagedirectory = fullfile(folder(i).folder,folder(i).name, 'TIFFs\8bitTIFFs\');
    image_path = strcat(imagedirectory, '*.tif');
    
    % get set of images
    imagefiles = getAllfolderimagesNoPath(image_path);
    
    % acquire all tif files in given folder
    imageset = dir(fullfile(imagedirectory, '*.tif'));
    % check if path name contains some string and assign type and class
    % based on this as well as set of images
    if(contains(imagedirectory, 'NORMAL'))
       type = 'norm';
       class = 'norm';
       Data_NORM{size(Data_NORM(:, 1), 1)+1} = imagefiles;
    elseif(contains(imagedirectory, 'AMD'))
        type = 'amd';
        class = 'amd';
       Data_AMD{size(Data_AMD(:, 1), 1)+1} = imagefiles;
    else
        type = 'dme';
        class = 'dme';
        Data_DME{size(Data_DME(:, 1), 1)+1} = imagefiles;
    end
    
    % create folder based on the class type
    if(strcmp(class,'amd')==1)
         v = AMDpath;
   elseif(strcmp(class,'dme')==1)
        v = MDEpath;
   elseif(strcmp(class,'norm')==1)
        v = NORMpath;
   end
   %h5Converter(imagedirectory,v,folder(i).name);
end

Data_NORM = Data_NORM(~cellfun('isempty',Data_NORM));  
Data_AMD = Data_AMD(~cellfun('isempty',Data_AMD));  
Data_DME = Data_DME(~cellfun('isempty',Data_DME));  

ImageData = [Data_NORM, Data_AMD, Data_DME];

end


function [imagesfile] = getAllfolderimagesNoPath(directory)
% Returns all images files specified at directory in image struct
% Input
%   directory path
% Output
%   cell array containing 3D volumetric image
imagefilesPatient1 = dir(directory);      
nfiles = length(imagefilesPatient1);    % Number of files found
images = [];
directory = nfiles;
imageset = {};
for ii=1:nfiles
   currentfilename = imagefilesPatient1(ii).name;
   currentfolder = imagefilesPatient1(ii).folder;
   sample = strcat(currentfolder, '\');
   fullFileName = fullfile(imagefilesPatient1(ii).folder, currentfilename);
   currentimage = (imread(fullFileName));
   I = mat2gray(currentimage);
   imageset{ii} = I;
end
imagesfile = imageset;
end

