function [imagesfile, fileID, n, paths] = getAllfolderimages(directory, file, file_path)
% Returns all images files specified at directory in image struct
% Inputs
%   Directory path
%   file name
%   file path
% Outputs
%    cell array of images 
%    fileId
%    Number of files
%    set of paths to all images

imagefilesPatient1 = dir(directory);      
nfiles = length(imagefilesPatient1);    % Number of files found
images = [];
directory = nfiles;

% open file;
fileID = fopen(file, 'w');
filePaths = fopen(file_path, 'w');
for ii=1:nfiles
   currentfilename = imagefilesPatient1(ii).name;
   currentfolder = imagefilesPatient1(ii).folder;
   sample = strcat(currentfolder, '\');
   paths{ii} = sample;
   fprintf(fileID, '%s\n',currentfilename); 
   fprintf(filePaths, '%s\n',currentfolder); 
   fullFileName = fullfile(imagefilesPatient1(ii).folder, currentfilename);
   currentimage = gpuArray(imread(fullFileName));

   I = mat2gray(currentimage);
   imageset{ii} = I;

end
imagesfile = imageset;
fclose(fileID);
fclose(filePaths);
n = directory;
end