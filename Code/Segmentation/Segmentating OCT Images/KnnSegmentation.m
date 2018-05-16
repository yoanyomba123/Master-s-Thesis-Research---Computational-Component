function image = KnnSegmentation( IMG, n )
% Performs segmentation by use of knn algorithm
imdata = reshape(IMG, [], 1); % image converted to 1-D array form;

imdata = double(imdata); % convert from uint8 to double

[IDX, nn] = kmeans(imdata,n); % perform kmeans on image data with four clusters returning centroid locations

imidx = reshape(IDX, size(IMG)); % reshaping IDX into the size of original image

figure; imshow(imidx,[]), title('clustered image by intensities')
figure;
imshow(imidx);

figure;
for i = 1:n
    drawnow,figure(i), imshow(imidx==i, []);
    fprintf('Value of Image: %d\n',i);
end
% Making script interactive
prompt = 'Enter Image Segmentation Choice? ';
x = input(prompt);
image = (imidx == x);

figure;
imshow(image);
title('Segmentation Of Choice');

end

