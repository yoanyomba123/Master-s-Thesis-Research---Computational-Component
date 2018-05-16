function [medline] = medEstimation(image,params)
% MEDESTIMATION find the black region present inside the OCT image and
% seperate both regions linearly

% Algorithm:
%   1) Apply heavy smoothing to the image
%       A. 2 sets of Gaussian kernels applied
%   2) Detect the min intensity present between the two highest intensity
%   image
%       A. find the 2 maximal intensity change within the OCT image by
%       observing positions of high to low or low to high gradient changes
%       B. extract that position and from this position find position of th
%       minimal point and smooth this position set with a windowed polynomial fitting scheme      

% Preliminary Step
% define window size and degree for line smoothing
window_size = 300;
degree = 5;

% 0) Remove Image outliers
image = removeOutliers(image);
% 1) Normalize Bscans
image(image>1) = 0;

% 2) find the actual middle line separating the ISG and OSG layers
%   1) apply heavy smoothing to the image
%   2) detect the minimum between the two highest intensity peaks

% devise the minimum distance between the layers
mindist = params.MEDLINE_MINDIST;
% created a floored estiamte of the smoothing gaussian kernel
gsize = floor(params.MEDLINE_SIGMA1 * 1.2);
% add the remainder of the divison of 2 of gaussian kernel size + 1 to the original 
gsize = gsize + mod(gsize,2) + 1;
% create a gaussian filter and pass in the custom generated gaussian
% kernel size
gauss = fspecial('gaussian', gsize, params.MEDLINE_SIGMA1);

% apply the gaussian filter to the image
g = imfilter(image, gauss, 'symmetric');
% normalize the filtered image
g = g ./ max(max(g));

% finds the positions with highest/lowest value within a scan by looking for gradient changes.
% changes from positive to negative and vice versa are what we want 
lmax = extremafinder(g, 2, 'max pos');
% find the maximal change in gradient intensity between the images
lmax(:, abs(lmax(2,:) - lmax(1,:)) < mindist) = 0;
lmax = linesweeter(lmax, params.MEDLINE_LINESWEETER);

% apply another heavy filter
gsize = floor(params.MEDLINE_SIGMA1 * 1.2);
gsize = gsize + mod(gsize, 2) + 1;
gauss = fspecial('gaussian', gsize, params.MEDLINE_SIGMA1);

% find the maximal change in gradient intensity in the lowest region of
% the image
g = imfilter(image, gauss, 'symmetric');
lmin = extremafinder(g, 1, 'low pos', lmax);
lmin = linesweeter(lmin, params.MEDLINE_LINESWEETER);

% apply windowed polyfit function to the line
lmin = lineProcessing(size(lmin,2),lmin,window_size,degree);

medline = lmin;
%-----------------------------------------------------------------------%
% Prepocess the image to remove any unecessary boundaries
function image = removeOutliers(image)
% REMOVEOUTLIERS removes any larger missing portion of the image by setting the pixel location to 0 therefore suppresing
% the region
% Input: Raw Image
% Output: PostProcessed Image
I = image; 
% find all portions of the image that map to the massive microscope
% outlier
I_temp = I == 1;

% acquire the position all items less than 100 pixels
I_temp = bwareaopen(I_temp, 100);

% remove the items less than 100 pixels by setting their
% locations equal to 0
I(I_temp) = 0;

% threshold image into 3 layers and remove the brightest layer
% corresponing to the massive outlier
I_temp = imquantize(I, multithresh(I, 3));
I(I_temp == 1) = 0; 

image = I;  
end
end

