function res = mirrorCirc(data, mode, width)
% MIRRORCIRC: Mirrors matrices/vectors to left and right.
% 
% RES = mirrorCirc(DATA, MODE, WIDTH)
% DATA: A vector or matrix.
% MODE: 'add' extends the matrix by reflecting it at the left and right
% boundary. Everything else makes the matrix smaller.
% WIDTH: Length of extension/removal.
% RES: Reflected/Cut image.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: June 2010
% Revised comments: November 2015

if strcmp(mode, 'add') 
    res = [data(:, width+1:-1:2) data data(:, end-1:-1:end-width)];
else
    res = data(:, width+1:end-width);
end

