clc; clear all; close all;
image = getAllfolderimages('\bioimagefs.coe.drexel.edu\Raw\Images\Duke_Public_OCT_images\DME6\TIFFs\8bitTIFFs\01.tif');

I = gather(image{1,2});
I_orig = I;

dimensions = [5.51, 9.51, 501.98, 478.98];
I = imcrop(I, dimensions);
figure; imshow(I);

% Get rid of brigh tspot
I_t = I == 1;
I_t =bwareaopen(I_t, 1000);
I(I_t) = 0; 

% step 2 - identify layers and get rid of B-Ground
Im_tmp = imquantize(I, multithresh(I, 2));
I(Im_tmp == 1) = multithresh(I, 1);

% Step 3 - Filtering
I1 = medfilt2(I, [5, 30]);
I1 = max(median(I1(:)), I1);
I1 = mat2gray(max(0,I1));
I_F = I1;
%I1 = I0 - mat2gray(imgradient(I0));
%I1 = I1 - imgaussfilt(I1, [200, 1]);

% acquire pixel intensities
Ints = I_F(I_F > 0 & I_F < 0.9);
% acquire image positions with pixel intensities higher than 0
[r, c] = find(I_F > 0 & I_F < 0.9);
maxc = [];
minc = [];
% Acquire the lowest boundary line
for i = min(c):max(c)
    maxc(end+1) = max(r(c==i));
    minc(end+1) = min(r(c==i));
end

% Display the lowest layer
order = 10;
figure;
imagesc(I_F); hold on;
plot(min(c):max(c),maxc,'r'); hold on;
plot(min(c):max(c),minc,'g'); hold on;
% flatten each layer
alignedr = r*0;
for i = min(c):max(c)
    alignedr((c==i)) = r(c==i) - minc(i);
end

% align the image entirely
AlignedI = I_F*0;
for i = 1:length(r)
    AlignedI(abs(alignedr(i))+1,c(i)) = Ints(i);
end 
AlignedI = flip(AlignedI,1);
figure
imagesc(AlignedI)

% acquire the height of each histogram bin with respect to the intensity at
% the location -> 9 bins specified
[N,XEDGES,YEDGES] = histcounts2(alignedr,Ints,9);

% Plot the partitioning positions on the pixel distribution
figure, 
lim = 1:length(alignedr);
plot(alignedr(lim),Ints(lim),'.'); hold on;
plot(XEDGES, YEDGES, '.r');hold off;
figure;
hist([alignedr,Ints]);

% segment the image based on the points of partition acquire from the
% histogram distribution of the locations of interest
count = 1;
figure;
imshow(I_orig); hold on;

for item = 1:length(YEDGES)
    % & I_F <= YEDGES(item+1)
    if(i == length(YEDGES))
        [r1, c1] = find(I_F > YEDGES(item) & I_F <= YEDGES(item+1));
    else
        [r1, c1] = find(I_F > YEDGES(item) & I_F <= YEDGES(item+1));
    end
    maxcc = [];
    mincc = [];
    for i = min(c1):max(c1)
        maxcc = [maxcc, max(r1(c1==i))];
        mincc = [mincc, min(r1(c1==i))];
    end
    
    % Intermediary Step - Remove Vertical sections of lines
    maxcc1 = zero_gradient(maxcc);
    mincc1 = zero_gradient(mincc);
    x_max = min(c1):max(c1);
    x_min = x_max(1:length(mincc1));
    x_max = x_max(1:length(maxcc1));
    if length(min(c1):max(c1)) == length(maxcc)
        [x_fitmax, y_fitmax] = polynomial_fit(min(c1):max(c1), maxcc);
        [x_fitmin, y_fitmin] = polynomial_fit(min(c1):max(c1), mincc);
        figure;
        hold on;
        plot(x_max,maxcc1,'r', 'lineWidth',1);
        hold on;
        plot(x_min,mincc1, 'b', 'lineWidth',1);
        hold on;
        plot(min(c1):max(c1),maxcc,'r', 'lineWidth',1);
        hold on;
        plot(min(c1):max(c1),mincc, 'b', 'lineWidth',1);
        hold on
%         plot(x_fitmax, y_fitmax, 'g', 'lineWidth',1);
%         hold on;
%         plot(x_fitmin, y_fitmin, 'y', 'lineWidth',1);
%         hold on;
    else
        disp('OFF');
        y_max = maxcc1;
        y_min = mincc1;
        x_min = x_max(1:length(mincc1));
        x_max = x_max(1:length(maxcc1));
        plot(medfilt1(x_max,20),medfilt1(y_max,20),'.b', 'lineWidth',1);
        hold on;
        plot(medfilt1(x_min,20),medfilt1(y_min,20),'.b', 'lineWidth',1);
        disp('error');
        disp(length(min(c1):max(c1)));
        disp(length(maxcc));
    end
    hold on;
    
    [maxcc, maxcc_y,indexes_max] = zero_derivative(x_max, maxcc);
%     fit = histfit(indexes_max);
%     maximal_y = max(fit(1).YData);
%     maximal_ypos = find(fit(1).YData == maximal_y);
%     bin_center = fit(1).XData(maximal_ypos);
%     bin_centers = fit(1).XData;
    [mincc, mincc_y,indexes_min] = zero_derivative(x_min, mincc);

    line_struct{count,1} = maxcc;
    line_struct{count,2} = maxcc_y;
    line_struct{count,3} = mincc;
    line_struct{count,4} = mincc_y;
    count = count + 1;
end
hold off;
%%
% count = 1;
% line_size = cellfun(@numel, line_struct);
% for item = 1:length(line_size)
%    if(line_size(item) > 400)
%        ds{count,1} = line_struct{item, 1};
%        ds{count,2} = line_struct{item, 2};
%        ds{count,3} = line_struct{item, 3};
%        ds{count,4} = line_struct{item, 4};
%        count = count + 1;
%    end
% end
% 
% figure; imagesc(I_F);
% hold on;
% for item = 1: length(ds)
%    plot(ds{item, 2}, ds{item,1}, 'r');
%    hold on;
%    plot(ds{item,4}, ds{item, 3}, 'g');
% end
% hold off

%%
figure;
[c,h] = histcounts(I_F(I_F>0), 100);
plot(h(1:end-1),c);
thresh = multithresh(I_F(I_F>0), 7);
hold on;
plot(thresh, thresh*1000, '.');
hold off;
% Segmentation
Im_tmp = imquantize(I_F, thresh);
Im_tmp(I_F == 0) = 0;
Im_seg = Im_tmp * 0;
for i = 1: max(Im_tmp)
   %l = imopen(Im_tmp == i, ones(2, 1));
   l = Im_tmp == i;
   %l = bwareaopen(l, 5);
   Im_seg(l)=i;  
end

% Step 6 - Make Lines
im_final = Im_tmp * 0;
for i=1:max(Im_tmp(:))
  im_final = im_final | imdilate(Im_seg==i, ones(3, 1)) & ~(Im_seg == i);
end


% crop im_final
dimensions = [5.51, 9.51, 501.98, 478.98];
im_fin = imcrop(im_final, dimensions);

 % Step 7 - Show Results
 figure; imagesc([I, I1, mat2gray(Im_tmp),mat2gray(Im_seg), im_final]);
 figure; 
 imshow(I);
 hold on;
 imagesc(im_final);
figure;
 [c,h] = histcounts(I_F(I_F>0), 100);
plot(h(1:end-1),c);
thresh = multithresh(I_F(I_F>0), 7);
hold on;
plot(thresh, thresh*1000, '.');
hold off;

figure;
im_fin = imerode(im_fin, ones(1, 1));
im_fin = imopen(im_fin, ones(1, 1));
im_fin = bwareaopen(im_fin,110);
figure;
imshow(im_fin); 
% hold on
% [H,T,R] = hough(im_fin);
% P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
% lines = houghlines(im_fin,T,R,P,'FillGap',5,'MinLength',7);
% max_len = 0;
% for k = 1:length(lines)
%    xy = [lines(k).point1; lines(k).point2];
%    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 
%    % Plot beginnings and ends of lines
%    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% 
%    % Determine the endpoints of the longest line segment
%    len = norm(lines(k).point1 - lines(k).point2);
%    if ( len > max_len)
%       max_len = len;
%       xy_long = xy;
%    end
% end

L1 = bwlabel(im_fin);
figure;imagesc(L1);

L1_max = max(L1(:));
figure; imshow(I);
hold on;
color = ['.g'];
for i = 1:L1_max
    lt = L1 == i;
    [x,y] = find(lt == 1);
    x = medfilt1(x,15);
    y = medfilt1(y,15);
    plot(y,x, color(1), 'lineWidth' , 0.5);
end




% Im_tmp_f = imquantize(I1, multithresh(I1(Im_tmp>1), 5));
% figure; imagesc(Im_tmp_f);
% imhist(I1(Im_tmp_f > 1) );
% conver rgb image to gray scale

% Imgo = I > 0.0001;
% 
% 
% Img0 = Imgs .* Imgo;
% % removes redundant noise but also removes edge intensities
% I = (im2double(I) .* Img0) .* Imgs;
% 
% figure;
% imshow(I); colormap gray;


%% apply michelle filter
I2 = im2double(I2) - stdfilt(im2double(I2));
figure; imagesc(I2); colormap gray; colorbar
%%
I3 = I2;
I4 = I2;

I3(I3 > 0.5 & I3 < 0.65) = 1;
I3 = imfill(I3, 'hole');
I4(I4 < 0.6) = 1;
figure; imagesc(I4); colormap gray; colorbar;title(' I4 with threshold set to less than 0.6');
figure; imagesc(I3); colormap gray; colorbar; title('I3 with threshold set to less than 0.65 and greater than 0.5');

thresh = multithresh(I4, 3);
q = imquantize(I4, thresh);
RGB = label2rgb(q);
gray_im = rgb2gray(RGB);
gray_im2 = medfilt2(gray_im, [1,1]);
gray_im3 = medfilt2(gray_im, [1,1]);
figure; imagesc(gray_im2); colormap gray; colorbar;title('gray_im2');


gray_im2 = (gray_im2 < 40);
gray_im2 = imfill(gray_im2, 'holes');
figure; imagesc(gray_im2); colormap gray; colorbar;title('gray_im2');

[Gx, Gy] = imgradientxy(gray_im2,'prewitt');
figure
imshowpair(Gx, Gy, 'montage')
title('Directional Gradients, Gx and Gy, using Sobel method');
[Gmag, Gdir] = imgradient(Gx, Gy);
imshowpair(Gmag, Gdir, 'montage')
title('Gradient Magnitude, Gmag (left), and Gradient Direction, Gdir (right), using Sobel method')
BW = bwmorph(Gmag, 'skel');
figure; imagesc(BW); colormap gray; colorbar;title('gray_im2');

gray_im2 = ~gray_im2;
gray_im2 = imdilate(gray_im2, ones(1,2));


BW1 = edge(gray_im2, 'canny');
BW1 = bwareaopen(BW1, 100);
BW1 = imclose(BW1, ones(7, 3));
figure; imshow(BW1);

gray_im3 = imfill(gray_im3, 'holes');
%figure; imagesc(gray_im3); colormap gray; colorbar; title('gray_im3')
figure; imagesc(gray_im2); colormap gray; colorbar;title('gray_im2');

%figure; imagesc(gray_im); colormap gray; colorbar;



