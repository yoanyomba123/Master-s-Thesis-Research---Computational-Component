function [goOn, notProcessedList] = getFileNumbersForAutomatedProcessing(DataDescriptors, guiMode, descriptor)
% GETFILENUMBERSFORAUTOMATEDPROCESSING: Gui helper used in octsegMain for
% finding out if the user wants to segment the remaining or all files.
% 
% First checks, if the segmentation (set by the descriptor) has already be
% performed. If yes, the user is asked how to proceed.
% Parameters can be looked up in the octsegMain
% Return values:
% 
% NOTPROCESSEDLIST: The filenumbers of the files to process
% GOON: set to 1 if the segmentation should be started.
%
% First final Version: April 2010
% Revised comments: November 2015

global PROCESSEDFILES;
global PROCESSEDFILESANSWER;

goOn = 1;

[status, ~, notProcessedList] = checkFilesIfProcessed(DataDescriptors, getMetaTag(descriptor, 'auto'));

if status ~= PROCESSEDFILES.NONE
    if guiMode == 2 || guiMode == 3
        answer = processAllQuestion(['Should the ' descriptor ' be automatically segmented on all files or only the remaining ones?']);
        if answer == PROCESSEDFILESANSWER.CANCEL
            goOn = 0;
        elseif answer == PROCESSEDFILESANSWER.ALL
            notProcessedList = 1:numel(DataDescriptors.filenameList);
        elseif answer == PROCESSEDFILESANSWER.REMAINING
        else
            goOn = 0;
        end
    elseif guiMode == 1
        answer = questionText(['The ' descriptor ' will be segmented for ALL BScans again. Previously generated results will be lost!']);
        if answer == PROCESSEDFILESANSWER.CANCEL
            goOn = 0;
            return;
        end
        notProcessedList = 1:DataDescriptors.Header.NumBScans;
    end
end