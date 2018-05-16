function [newBScanStartX, newBScanEndX, newBScanStartY, newBScanEndY] = checkScanPositionConsistency(BScanStartX, BScanEndX, BScanStartY, BScanEndY)
% CHECKSCANPOSITIONCONSISTENCY
% The Spectralis can only handle horizontal scan lines. We assume scan
% lines going from the left side of the SLO image to the right side
% If this is not the case (and thus the position data in the file is
% corrupted), it is corrected.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: Some time in 2011
% Revised comments: November 2015

distX = BScanEndX - BScanStartX;
distY = BScanEndY - BScanStartY;
if sum(distX) < 0
    temp = BScanEndX;
    BScanEndX = BScanStartX;
    BScanStartX = temp;
end
if sum(distY) < 0
    temp = BScanEndY;
    BScanEndY = BScanStartY;
    BScanStartY = temp;
end

if abs(sum(distX)) == 0
    newBScanStartX = BScanStartY;
    newBScanStartY = BScanStartX;
    newBScanEndX = BScanEndY;
    newBScanEndY = BScanEndX;
else
    newBScanStartX = BScanStartX;
    newBScanStartY = BScanStartY;
    newBScanEndX = BScanEndX;
    newBScanEndY = BScanEndY;
end