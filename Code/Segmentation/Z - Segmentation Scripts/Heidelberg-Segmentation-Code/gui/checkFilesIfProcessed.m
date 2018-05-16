function [status, processedList, notProcessedList] = checkFilesIfProcessed(ActDataDescriptors, metaTag)
% CHECKFILESIFPROCESSED Checks if the task has already been performed 
% (according to the meta files). The evaluator name is sticked together 
% with the requested Tag, except in the case of the OCTSEG tag.
% Intended for the use in octsegMain. 
% 
% [STATUS, PROCESSEDLIST, NOTPROCESSEDLIST] = checkFilesIfProcessed(ACTDATADESCRIPTORS, METATAG)
% ACTDATADESCRIPTORS: See octsegMain
% METATAG: The metaTag you want to check
% STATUS - have all/some/none of the files been processed?
% PROCESSEDLIST, NOTPROCESSEDLIST: The parts of a filenameList, that have
%   been processed/notProcessed
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: Some time in 2010
% Revised comments: November 2015

global PROCESSEDFILES;

processedList = [];
notProcessedList = [];

if ~strcmp(metaTag, 'OCTSEG')
    metaTag = [ActDataDescriptors.evaluatorName metaTag];
end

for i = 1:numel(ActDataDescriptors.filenameList)
    metaInfo = readOctMeta([ActDataDescriptors.pathname ActDataDescriptors.filenameList{i,1}], metaTag);
    if numel(metaInfo) ~= 0
        if metaInfo ~= 0
            processedList = [processedList i];
        else
            notProcessedList = [notProcessedList i];
        end
    else
        notProcessedList = [notProcessedList i];
    end
end

if numel(processedList) == 0
    status = PROCESSEDFILES.NONE;
elseif numel(processedList) == numel(ActDataDescriptors.filenameList)
    status = PROCESSEDFILES.ALL;
else
    status = PROCESSEDFILES.SOME;
end
