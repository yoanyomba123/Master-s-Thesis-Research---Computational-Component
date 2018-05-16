function data = readOctMetaVolumeMult(ActDataDescriptors, tag, number)
% READOCTMETAVOLUMEMULT Reads the meta of each A-Scan data of a complete volume
% (if available) and returns a 2D array
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: Some time in 2011
% Revised comments: November 2015

data = zeros(ActDataDescriptors.Header.NumBScans, ActDataDescriptors.Header.SizeX, number, 'double');
for i = 1:numel(ActDataDescriptors.filenameList)
    metaData = readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{i}], ...
        [ActDataDescriptors.evaluatorName tag 'Data']);   
    
    if numel(metaData) == ActDataDescriptors.Header.SizeX * number
        metaDataFormat = zeros(1, ActDataDescriptors.Header.SizeX, number, 'double');
        for n = 1:number
            metaDataFormat(1, :, n) = metaData((((n - 1) * ActDataDescriptors.Header.SizeX) + 1): ...
                (((n - 1) * ActDataDescriptors.Header.SizeX) + ActDataDescriptors.Header.SizeX));
        end
        data(i,:,:) = metaDataFormat;
    end
    
end

