function data = loadMetaDataEnfaceVisu(ActDataDescriptors, dispCorr, tags, noPositions)
% LOADMETADATAVISU Loads volume meta data (a 2D array) especially designed 
% for the use in the octsegVisu GUI.
% 
% DATA = loadMetaDataEnfaceVisu(ACTDATADESCRIPTORS, DISPCORR, TAGS, NOPOSITIONS)
% ACTDATADESCRIPTORS, DISPCORR: Description can be found in octsegVisu
% TAGS: The automated and manual segmentation tags together in a cell array. 
%       If only the automated segmentation should be loaded, leave the
%       other entry filled with an empty array.
% DATA: A 2D array, where the gaps in the man-Data are filled with the auto-Data.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: Some time in 2010
% Revised comments: November 2015

if nargin < 4
    noPositions = 0;
end

autoData = readOctMetaVolume(ActDataDescriptors, tags{1});

if dispCorr
    data = readOctMetaVolume(ActDataDescriptors, tags{2});
    
    if noPositions
        if sum(sum(data)) == 0
            data = autoData;
        end
    else
        if numel(data) ~= 0
            data(data == 0) = autoData(data == 0);
        else
            data = autoData;
        end
    end
else
    data = autoData;
end
