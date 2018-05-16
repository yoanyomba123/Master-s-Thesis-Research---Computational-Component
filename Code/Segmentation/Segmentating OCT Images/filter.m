function image = filterim( im )
% Performs some image filtration
im = medfilt2(im,[2,2]) - imgaussfilt(im, 900);
im = mat2gray(im);
im = ordfilt(im, 4, true(2));
im = im - stdfilt(im);
im = im -rangefilt(im);

level = graythresh(im);
h = special('gaussian');

se = strel('sphere',6);
im= imdilate(im, se);
im = imerode(im, se);

im = im - imagaussfilt(im, 500);
im = imsharpen(im, 'Threshold', level, 'Amount',9);

image = im;


end

