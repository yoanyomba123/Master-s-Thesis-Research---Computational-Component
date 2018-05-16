function volumeToH5(volume,DatasetName, path_name)
%VOLUMETOH5 Converts a Volumetric Image To Lever Format 

    % volumeToh5(VOLUME, DATASETNAME, PATH_NAME) converts a volumetric scan to lever h5
    % format. Volume is a 3D stack of images. DATASETNAME is the preferred name of
    % database. PATH_NAME is the folder path to which .h5 files will be
    % written to
    imd = MicroscopeData.MakeMetadataFromImage(volume);
    imd.DatasetName = DatasetName;
    if (size(imd.Dimensions,2)~=3)
        imd.Dimensions=[imd.Dimensions 1];
    end
    MicroscopeData.WriterH5(volume, 'imageData', imd, 'path', path_name);
end

