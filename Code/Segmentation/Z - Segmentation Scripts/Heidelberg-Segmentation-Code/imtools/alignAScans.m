function [alignedBScan, flatline, transformline] = alignAScans(bscan, params, line)
% ALIGNASCANS: Aligns A-Scan according to a given line. The Image is cut to
% given values above or below, or a second line can be given that is for
% sure also included in the image.
% 
% [ALIGNEDIMAGE, FLATLINE ,TRANSFORMLINE] = alignAScans(BSCAN, PARAMS, LINE)
% BSCAN: An OCT BScan
% LINE: The line that should become flat. No zero entries allowed! Also an
%   additional second line (row in the line matrix) can be provided.
%   This second line is for sure completly in the resulting image.
% PARAMS:  Parameter struct for the automated segmentation.
%   In this function, the following parameters are currently used:
%   ALIGNASCANS_ADDER: First value: space below the flat firstline, 
%   second: space above (suggestion: [30 150])
% ALIGNEDBSCAN: The aligned image.
% FLATLINE: line after flattening.
% TRANSFORMLINE: Add this to a line on the aligned image to get the 
%   line values on the original image.
% 
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: June 2010
% Revised comments: November 2015

PRECISION = 'double';
adder = params.ALIGNASCANS_ADDER;

alignline = line(1,:);

maxlold = ceil(max(alignline));

alignlineInv = maxlold - alignline;
zsize = size(bscan,1);

yi = [1:size(bscan,1)]';
yii = zeros(size(bscan,1), size(bscan,2), PRECISION);
for j = 1:size(bscan,2)
    yii(:,j) = yi;
end
zi = [1:size(bscan,2)];
zii = zeros(size(bscan,1), size(bscan,2), PRECISION);
for i = 1:size(bscan,1)
    zii(i,:) = zi;
end
alignlineInvInt = floor(alignlineInv);
li = alignlineInvInt - alignlineInv;

for j = 1:size(bscan,2)
    yii(:,j) = yii(:,j) + li(j);
end

Yi = interp2(bscan,zii, yii, 'linear' , 0);

alignedBScan = zeros(zsize, size(bscan,2), 'single');
for j = 1:size(bscan,2)
    alignedBScan(alignlineInvInt(j) + 1:alignlineInvInt(j) + zsize, j) = Yi(:,j);
end

if size(line, 1) ~= 1
    diff = line(1,:) - line(2,:);
    maxl = maxlold - ceil(max(max(diff)));
else
    maxl = maxlold;
end

maxl = maxl - adder(2);
if(maxl < 1)
    maxl = 1;
end

if mod(maxlold + adder(1) - maxl, 2) == 0
    maxlold(maxlold + adder(1) + 1 > size(alignedBScan, 1)) = size(alignedBScan, 1) - adder(1) - 1 ;
    alignedBScan = alignedBScan(maxl:maxlold + adder(1) + 1, :);
else
    maxlold(maxlold + adder(1) > size(alignedBScan, 1)) = size(alignedBScan, 1) - adder(1);
    alignedBScan = alignedBScan(maxl:maxlold + adder(1), :);
end

zeroval = maxlold - maxl + 1;
flatline = zeros(1,size(alignlineInvInt,2), PRECISION) + zeroval; 
transformline = line(1,:) - zeroval;