function image = imagePreprocessing(volume, type, outliers)
% performs some image preprocessing as well as align the image
% input
%   3D volumetric image stack
% output
%   filtered 3D volumetric image stack
    PARAMETER_FILENAME = 'octseg.param';
    med_params = loadParameters('MEDLINELIN', PARAMETER_FILENAME);
    onh_params = loadParameters('ONH', PARAMETER_FILENAME);
    rpe_params = loadParameters('RPELIN', PARAMETER_FILENAME);
    bv_params = loadParameters('BV', PARAMETER_FILENAME);
    infl_params = loadParameters('INFL', PARAMETER_FILENAME);
    inner_params = loadParameters('INNERLIN', PARAMETER_FILENAME);
    onfl_params = loadParameters('ONFLLIN', PARAMETER_FILENAME);
    if(type ~= "Complex")
       image = medfilt3(volume, [5,5,5], 'zeros') - imgaussfilt3(volume,100);
    else
        for l = 1: size(volume, 3)
            % acquire image
            I = volume(:,:,l);

            % save another copy of the image for later use
            I_copy = I;

            if(outliers == "remove")
                % Get rid of brigh tspot
                I = removeOutliers(I, 3, "zero");
                image = I;
            else
                % Get rid of brigh tspot
                I = removeOutliers(I, 3, "zero");
                
                % apply adaptive filtering
                I = filterAdaptively(I);

                % perform minimal intensity suppression
                [I, BW] = minimalIntensityExtraction(I);

                % perform further suppression based on CC analysis
                I = removeSmallestCC(I, BW);

                % apply the LOG and CANNY filter to the image;
                I = filterCannyLog(I, I_copy);

                % apply an intensity transformation to the image once again for
                % contrast enhancement purposes
                %I = imadjust(I, [0.1, 0.9]);
                I = medfilt2(I, [3,3]);
                image(:,:,l) = I;
            end
        end
    end


%----------------------------------------------------------------------------%
    function result = removeOutliers(image, layers, suppress)
        % REMOVEOUTLIERS remove huge image outliers stemming from
        % microscope error
        % Takes as input an image, the number of layers wished to be used for thresholding purposes
        % and a variable specifying wether to supress pixel values to zero or not and returns a processed image
        
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
        I_temp = imquantize(I, multithresh(I, layers));
        if( suppress == "zero")
            I(I_temp == 1) = 0;
        end
        
        if(suppress == "threshold")
            I(I_temp == 1) = multithresh(I,1);   
        else
            I(I_temp == 1) = min(I(:));
        end
        result = I;
    end

    function result = filterAdaptively(image)
        % FILTERADAPTIVELY(IMAGE) applies som adaptive filter to our image
        % of choise
        % Takes as input an image and returns a filtered image
        I = image;
        
        % apply median filter to remove shot noise
        I = medfilt2(I, [3,3]);
        
        % apply adaptive smoothing to the image base on local statistics as
        % to not smooth edges
        I = wiener2(I, [2,2]);
        
        result = I;
    end

    function [result_I, result_BW] = minimalIntensityExtraction(image)
       % MINIMALINTENSITYEXTRACTION(IMAGE) removes all intensities from the image
       % less than some specified threshold
       % Takes as input an image and returns a filtered image and it black
       % and white constituent
       I = image;
       
       % threshold the image
       threshold = graythresh(I);
       
       % convert image to black and white based on some threshold value
       BW = im2bw(I, threshold);
       
       % apply some morphological operation (dilation) to introduce a
       % greater amount of spcae between the two OCT sub structures
       % open mostly in the y direction for maximal vertical spacing
       BW = imopen(BW, ones(2, 3));
       
       % find all points in the curretn black and white image that are of
       % magnitude 0 and set those current point in the image under
       % analysis to 0
       [r, c] = find(BW == 0);
       
       minimal_intensity = min(I(:));

        for i = 1: numel(r)

            I(r(i), c(i)) = minimal_intensity;

        end
        
        result_I = I;
        result_BW = BW;
        
    end

    function result = removeSmallestCC(image, BWimage)
       % REMOVESMALLESTCC(IMAGE) removes the smallest connected component
       % present in the image byt suppressing the value and setting to 0
       % Takes as input an image and it's black and white constituent and returns a processed image
       % extract connected components from the image

        % obtain image connected components from a black and white image
        CC = bwconncomp(BW);
        % count the magnitude of the CC
        numPixels = cellfun(@numel,CC.PixelIdxList);

        % sort the CC
        sorted_pix_list = sort(numPixels,'descend');

        regions_of_interest = [];

        index = 0;
        % acquire the main regions of interests in the current image
        if(numel(sorted_pix_list) < 7)
            index = numel(sorted_pix_list);
        else
            index = 7;
        end;
        
        for i = 1:length(sorted_pix_list(1:index))
           for j = 1: length(numPixels)
              if(sorted_pix_list(i) == numPixels(j))
                regions_of_interest = [regions_of_interest, j]; 
              end
           end
        end
        % remove any duplicate region of interest
        regions_of_interest = unique(regions_of_interest);

        % set all pixel location not currently in the regions of interest
        % to 0 therefore suppressing unneeded information
        for j = 1: length(numPixels)
            for i = 1 : numel(regions_of_interest)
                if(j == regions_of_interest(i))
                    break;
                end
                if(j ~= regions_of_interest(i) && i == numel(regions_of_interest))
                    I(CC.PixelIdxList{j}) = 0;
                end
            end
        end
        
        result = I;
    end

    function result = filterCannyLog(processedimage,unprocessedimage)
       % FILTERCANNYLOG(IMAGE) applies the canny and Laplacian of Gaussians filter to an image
       % takes as input two images, one which should be a somewhat processed image and the other
       % an unprocessed image and returns a filtered image
       
       % Why LOG and Canny?

       % Reasons why we leverage the canny and LOG algorithm for OCT's 
       % LOG has many shortcomings some of which are poor detection of edge
       % orientation and higly inefficient where gray level image intensity
       % functional displays highly variant behavior. So We introduce the Canny
       % edge detection scheme into this pre-processing step in order to account
       % for those various drawbacks obtained from the laplacian of gaussian

        % filter
       % specify filter sizes and standard deviation
       I = processedimage;
       sigma = 5 * 0.35;
       szFilter = round(size(I)/10);
       
       % generate filter mask for canny edge detection filter
       hcanny = fspecial('sobel')
        
       % generate actual filter now
       hlog = fspecial('log', szFilter, sigma);

       % filter the image based off of both filters
       imlog = mat2gray(imfilter(I, hlog, 'replicate'));
       imcanny = mat2gray(imfilter(I, hcanny, 'replicate'));
       
       % perform some intensity transformation of the LOG image to enhance
       % contrast
       imlog = imadjust(imlog);
       
       % perfom image operation to the original image and filtered images
       % for edge enhancement
       result = unprocessedimage - (imlog .* (unprocessedimage .* imcanny));
       
    end


end




