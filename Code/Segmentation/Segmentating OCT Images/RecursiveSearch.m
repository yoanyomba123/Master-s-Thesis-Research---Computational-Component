function [ImageCategory] = RecursiveSearch( directory, classname )
% Method performs a recursive folder search of tif files

folder = dir(directory);
folders(1:2) = [];
folderindex = [folders.isdir];
filelist = {folders(~folderindex).name}';
if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
end  
subDirs = {folders(dirIndex).name};  %# Get a list of the subdirectories
validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
% generate class data

for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dir,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir)];  %# Recursively call getAllFiles
end
  

for i=1:numel(folders)
   % check if subfolder contains tif file
   if(isempty(dir('*.tif')))
       RecursiveSearch(dir(folders(:,i)));
   else
       data.name = {classname};
       d = uigetdir(folders(:,i));
       files = dir(fullfile(d, '*.tif'));
      
   end
   folder_subdirectory = {dir(folders(:,1))};
   folder_subdirectory = {folder_subdirectory(3,:).folder};
   
   
    
    
    
end

end

