function tag = getMetaTag(descriptor, type)
% GETMETATAG: Returns meta tag for a certain descriptor
% Needs the global variable TABLE_META_TAGS.

% Parameters:
%   DESCRIPTOR: The descriptor you search the associated tag with 
%       For a list of the descriptors, have a look at:
%       octsegConstantVariables 
%   TYPE: Do you want to have the automated segmentation ('auto) or manual
%       segmentation ('man') tag? Do you want to have just the information
%       if the segmentation was performed or the associated data 
%       ('autoData'/'manData') 
%       Or both tags (auto/man) together in a cell array?
% Return value:
%   TAG: The meta tag associated with the descriptor 
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: April 2010
% Revised comments: November 2015

global TABLE_META_TAGS;

for i = 1:size(TABLE_META_TAGS,1)
    if strcmp(TABLE_META_TAGS{i, 1}, descriptor)
        switch type
            case 'auto'
                tag = TABLE_META_TAGS{i, 2};
            case 'man'
                tag = TABLE_META_TAGS{i, 3};
            case 'autoData'
                tag = [TABLE_META_TAGS{i, 2} 'Data'];
            case 'manData'
                tag = [TABLE_META_TAGS{i, 3} 'Data'];
            case 'both'
                tag = {TABLE_META_TAGS{i, 2} TABLE_META_TAGS{i, 3}};
            case 'bothData'
                tag = {[TABLE_META_TAGS{i, 2} 'Data'] ...
                       [TABLE_META_TAGS{i, 3} 'Data']};
            otherwise
                disp('getMetaTag: type not known (other than auto/man)!');
                return;
        end
        
        break;
    end
end

end