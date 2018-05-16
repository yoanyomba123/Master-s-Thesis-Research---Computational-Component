function h5Converter( root, destinationpath,name )
% converts tif to h5

ROOT=root;
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
imd.DatasetName=name;
if (size(imd.Dimensions,2)~=3)
    imd.Dimensions=[imd.Dimensions 1];
end

MicroscopeData.WriterH5(im,'imageData',imd,'path',destinationpath);

end

