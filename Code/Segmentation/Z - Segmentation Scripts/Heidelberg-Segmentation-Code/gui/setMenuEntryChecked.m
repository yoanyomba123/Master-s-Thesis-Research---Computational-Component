function newValue = setMenuEntryChecked(handle, value)
% SETMENUENTRYCHECKED: Set the "check" of the menu entry given by "handle"
% to either 'on' or 'off' given by the "value".
% Parameters:
%   handle: Handle to the menu entry
%   value: Either 0 (off) or 1 (on)
% Return:
%   newValue: Just a copy of value;
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: Some time in 2011
% Revised comments: November 2015

if value 
    set(handle, 'Checked', 'on');
else
    set(handle, 'Checked', 'off');
end

newValue = value;