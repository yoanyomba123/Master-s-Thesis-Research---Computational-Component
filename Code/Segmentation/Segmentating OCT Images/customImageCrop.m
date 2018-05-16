function image = customImageCrop( image )
% parameter definition
format longg;
format compact;
fontSize = 20;

% Crops and image automatically
grayImage = image;
% Get the dimensions of the image.  
% numberOfColorBands should be = 1.
[rows columns numberOfColorBands] = size(grayImage);

% Get all rows and columns where the image is nonzero
[nonZeroRows nonZeroColumns] = find(grayImage);
% Get the cropping parameters
topRow = min(nonZeroRows(:));
bottomRow = max(nonZeroRows(:));
leftColumn = min(nonZeroColumns(:));
rightColumn = max(nonZeroColumns(:));
% Extract a cropped image from the original.
croppedImage = grayImage(topRow:bottomRow, leftColumn:rightColumn);
image = im2bw(image);
image = imclearborder(croppedImage);
end

