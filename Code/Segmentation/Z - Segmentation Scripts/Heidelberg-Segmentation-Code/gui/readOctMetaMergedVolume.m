function data = readOctMetaMergedVolume(DataDescriptors, tags)
% READOCTMETAMERGEDVOLUME: Helper for reading metaData for the segment
% functions in octsegMain from a volume
% Reads the manual-Data if available, otherwise the auto-Data.
%
% DATADESCRIPTORS: see octsegMain
% TAGS: Cell structure, created by getMetaTag if type 'both...' is used
%
% First final Version: Some time in 2010
% Revised comments: November 2015

data = zeros(DataDescriptors.Header.NumBScans, DataDescriptors.Header.SizeX, 'double');
for i = 1:DataDescriptors.Header.NumBScans
    temp  = readOctMetaMerged(DataDescriptors, tags, i);
    if numel(temp) ~= 0
        data(i,:) = readOctMetaMerged(DataDescriptors, tags, i);
    else
        disp('Meta data load failed!');
        return;
    end
end
