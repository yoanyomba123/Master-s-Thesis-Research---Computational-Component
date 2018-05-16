function [image, imageseg ]= MultiThrehsSegmentation( IMG,n )
% Performs segmentation by use of multithresh
% reading the first image --> returns image segmentation of choice and
% original image obtained from imquantize

% Utilize Multithresh For Image Segmentation
thresh = multithresh(IMG, n);

img_seg = imquantize(IMG, thresh);
RGB = label2rgb(img_seg);
RGB = RGB > 0.8;
imagesc(RGB); colorbar; title('Color Mapped Image')

for i = 1:n+1
    drawnow,figure(i), imshow(img_seg==i, []);
    fprintf('Image %d\n',i);
end

pmpt = prompt();
im2 = (img_seg == pmpt);
figure; imshow(im2); title('Segmented Image Of Choice');
image = im2;
imageseg = img_seg;
end

