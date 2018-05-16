function number = getInfoTableColumn(guiMode, descriptor)
% GETINFOTABLECOLUMN: Returns the column number in the octsegMain 
% info table of the passed data descriptor. Used in octsegMain.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: April 2010
% Revised comments: November 2015

global TABLE_HEADERS

number = 0;
for i = 1:numel(TABLE_HEADERS{guiMode})
    if strcmp(TABLE_HEADERS{guiMode}{i}, descriptor)
        number = i;
        return;
    end
end
