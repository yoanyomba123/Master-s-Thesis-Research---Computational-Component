function databaseWrite(volume, path)
%DATABASEWRITE writes to a lever database for 3-D Visualizations
% Takes as input a 3-D volumetric stack and an image path

% acquire DOG filter
volumedog = dog3D(volume);


% export raw to h5
imd=MicroscopeData.MakeMetadataFromImage(volume);
if (size(imd.Dimensions,2)~=3)
    imd.Dimensions=[imd.Dimensions 1];
end

% wrtie to lever
imd.DatasetName='3Dbraw';
MicroscopeData.WriterH5(volume,'imageData',imd,'path',path);

Import.leverImport('',path);
end
