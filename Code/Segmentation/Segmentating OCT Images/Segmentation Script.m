  [IM, IMAGEDATA] = MicroscopeData.ReaderH5();
 
    imagesc(max(IM,[],3))
    
    imagesc(sum(IM,3))
    IM2 = IM;
   
%% Segmentation Script
    % segmented layes
    IM2(IM2==255)=0;
     % got rid of yellow bars
    bim = IM2>100;
        
   
DrawIM = [];
    for i=1:2:size(IM2,3)
        
        bim(:,:,i) = bwareaopen(bim(:,:,i),1000);
        LIM = bwlabel(bim(:,:,i));
%         imagesc([IM2(:,:,i),bim(:,:,i)*255])
DrawIM = repmat(mat2gray(IM2(:,:,i)),[1 1 3]);
DrawIM(:,:,1) = min(DrawIM(:,:,1) + (LIM==1),1);
DrawIM(:,:,2) = min(DrawIM(:,:,2) + (LIM==2),1);

imagesc(mat2gray(DrawIM))
        drawnow;
    end

    rp = regionprops(bim)
    histogram([rp.Area])
    