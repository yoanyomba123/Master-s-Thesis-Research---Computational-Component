function filteredIm =  filteringScript( IMG )
% This function performs image filtration on some input

% Creating copies of the input image for processing
IMG2 = IMG;
IMG3 = IMG;

% removing uneeded yellow portion of the images
IMG2(IMG2==255) = 0;

% Image Filtration Step

% ######################## Thoughts #######################
% employing Gaussian filter because l find that it is much easier to
% seperate the 2 layers making this into more of a 2 class problem

% negate gaussaing filter output from origin images
IMG3 = IMG2 - imgaussfilt3(IMG2,[30,30,5]);

% Apply gaussian filter to this image now
IMG4 = imgaussfilt3(IMG3, [5, 5,1]);
% registering the two images
% imagesc([mat2gray(IMG2(:,:,1)) mat2gray(IMG3(:,:,1)), mat2gray(IMG4(:,:,1))]);
% title(' Image 1. Regular Image Image ------ 2. Gaussian Filter output negated from Regular Image Image ----- 3. Gaussian Filter Reapplied to Image 2')

filteredIm = IMG4;
end

