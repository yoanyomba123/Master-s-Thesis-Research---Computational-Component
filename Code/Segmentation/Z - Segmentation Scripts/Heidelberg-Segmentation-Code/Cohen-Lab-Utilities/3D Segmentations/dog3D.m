function volume = dog3D(vol, sigma, type)
% 3DDOG takes performs a difference of gaussians operation on a volumetric
% image stack
% 
% Algorithm: Compute the difference of 2 gaussians with substantially
% different sigma
% Input: 3D Volumetric Stack & Sigma
% Output: 3D Volumetric Stack
if nargin < 2
    sigma = 5;
    type = "";
end

volume = vol;

% First Gaussian Operation
imd1 = imgaussfilt3(volume,sigma/sqrt(10));
imd2 = imgaussfilt3(volume,sigma*sqrt(10));

% compute the difference of gaussians
imdog = imd1 - imd2;

% acquire a black and white representation of the difference of gaussians
if(type == "BW")
    % find the maximal intensities in the zth dimensions
    imp = max(imdog, [], 3); 

    imp = getMeshFromBW(imp);
    figure; imagesc(imp);
    volume = imp;
else
    volume = imdog;
end



%-------------------------------------------------------------------------%
    function volume = getMeshFromBW(volume)
    % GETMESHFROMBW performs mesh analysis of a bw image
    % algorithm: acquires a surface representation of the image stack by
    % means of thresholding
    % Takes as input some volume and returns a processed volume
    
    % set image to its grayscale complement
    im=mat2gray(volume);
    % threshold the image stack
    level=graythresh(im(:));
    % find all values within the stack greather than some level
    bw=logical(im>level);
    
    % find the maximum values in the zth dimentions
    imp=max(bw,[],3);
    
    %figure;imagesc(imp); 
    volume = imp;
        
    end
end