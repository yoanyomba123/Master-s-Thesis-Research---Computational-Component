function data = readOctMetaVolume(ActDataDescriptors, tag)
% READOCTMETAVOLUME Reads the meta of each A-Scan data of a complete volume
% (if available) and returns a 2D array
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: Some time in 2011
% Revised comments: November 2015

data = zeros(ActDataDescriptors.Header.NumBScans, ActDataDescriptors.Header.SizeX, 'double');
for i = 1:numel(ActDataDescriptors.filenameList)
    metaData = readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{i}], ...
                           [ActDataDescriptors.evaluatorName tag 'Data']);
    if numel(metaData) == ActDataDescriptors.Header.SizeX
        data(i,:) = metaData;
    end
end

