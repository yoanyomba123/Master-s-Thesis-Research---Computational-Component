function [numDescriptor, openFuncHandle, filenameEnding] = examineOctFile(pathname, filename)
% EXAMINEOCTFILE Return information about an OCT file
% 
% [NUMDESCRIPTOR OPENFUNCHANDLE FILENAMEENDING] = examineOctFile(PATHNAME, FILENAME);
% Gives a rough examination of the OCT file only according to the filename.
% Requires calling of the octsegConstantVariables function somewhere
%   beforehand.
% PATHNAME: Path to the OCT file, without filename.
% FILENAME: filename of the OCT file, without path.
% NUMDESCRIPTOR: A integer represents what filetype the OCT file is
%   - see octsegConstantVariables for a description and documentation. 
% OPENFUNCHANDLE: Handle to a function that might open the file
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: Some time in 2010
% Revised comments: November 2015

global FILETYPE;

% Is the file existent?
if ~exist([pathname filename], 'file')
    numDescriptor = 0;
    openFuncHandle = 0;  
    return;
end

% Find out the file ending
[token, remain] = strtok(filename, '.');
while numel(remain) ~= 0
    [token, remain] = strtok(remain, '.');
end
filenameEnding = token;

% Compare with the available endings;
if strcmpi(filenameEnding, 'vol')
    numDescriptor = FILETYPE.HE;
    openFuncHandle = @openVol;
    filenameEnding = '.vol';
elseif strcmpi(filenameEnding, 'oct')
    numDescriptor = FILETYPE.RAW;
    openFuncHandle = @openPlain;
    filenameEnding = '.oct';
elseif strcmpi(filenameEnding, 'pgm') || strcmpi(filenameEnding, 'tif') || strcmpi(filenameEnding, 'jpg') || strcmpi(filenameEnding, 'bmp')
    numDescriptor = FILETYPE.IMAGE;
    openFuncHandle =  @openOctImg;  
    filenameEnding = ['.' filenameEnding];
elseif strcmpi(filenameEnding, 'list')
    numDescriptor = FILETYPE.LIST;
    openFuncHandle =  @openOctList;      
    filenameEnding = '.list';    
else
    numDescriptor = FILETYPE.OTHER;
    openFuncHandle = @openOctImg;  
end
    
end