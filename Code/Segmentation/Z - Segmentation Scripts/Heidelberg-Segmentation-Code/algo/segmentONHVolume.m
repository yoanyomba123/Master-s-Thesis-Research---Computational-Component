function [onh, onhCenter, onhRadius] = segmentONHVolume(volume, params, rpe)
% SEGMENTONHVOLUME Finds out the 2D position of the ONH head in a volume.
% Experimental. Only the center of the ONH is searched.
%
% The method is simple: Use the enface-image above the RPE, apply some
% filtering, tresholding an morphological operators and compute the 
% center of gravity from the results (hopefully only ONH and BV positions
% left). 
%
% This is an experimental adaption of the circular scan algorithm to volume
% scans. Preliminar results were published at the ARVO conference 2011:
% Markus A. Mayer, Joachim Hornegger, Christian Y. Mardin, Ralf P. Tornow;
% Retinal Layer Segmentation on OCT-Volume Scans of Normal and 
% Glaucomatous Eyes. Invest. Ophthalmol. Vis. Sci. 2011;52(14):3669
%
% Due to the lack of data and time the approach was not pushed further.
% Now (2015) we would suggest using other volume segmentation approaches.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: November 2010
% Revised comments: November 2015
volume(volume > 1) = 0;

volume = volume ./ max(max(max(volume)));

for k = 1:size(volume, 3)
    bscan = volume(:,:,k);
    bscanSorted = sort(bscan(:), 'ascend');
    bScanMax = bscanSorted(floor(end * params.ONH_SEGMENT_BSCANTHRESHOLD));
    bscan(bscan > bScanMax) = bScanMax;
    bscan = bscan ./ max(max(bscan));
    volume(:,:,k) = bscan;
end

border = rpe - 10;
border(:,:,2) = rpe;
enface = createEnfaceView(volume, border);

% remove all NAN values 
enface(isnan(enface))=0;
enface(enface > params.ONH_SEGMENT_ENFACETHRESHOLD * mean(mean(enface))) = 1;
enface = 1 - enface;

border = 0.1;
enface(:, 1:round((end * border))) = 0;
enface(:, end-round((end * border)):end) = 0;

enface = medfilt2(enface, params.ONH_SEGMENT_MEDFILT);
enface = medfilt2(enface, params.ONH_SEGMENT_MEDFILT);

enfaceMean2 = mean(enface, 2) ./ sum(mean(enface, 2));
% enfaceMean2(isnan(enfaceMean2))=0;
enfaceCP(1) = sum(enfaceMean2 .* (1:size(enface,1))');
enfaceMean1 = mean(enface, 1) ./ sum(mean(enface, 1));
% enfaceMean1(isnan(enfaceMean1))=0;
enfaceCP(2) = sum(enfaceMean1 .* single(1:size(enface,2)));

enfaceTH = enface > 0;

enfaceTH = bwmorph(enfaceTH, 'erode', params.ONH_SEGMENT_ERODENUMBER); 

onh = zeros(size(enface, 1), size(enface,2));
onh =  logical(onh);
onhOld = onh;

if(isnan(enfaceCP(1))| isnan(enfaceCP(2)))
   enfaceCP(1) = 10;
   enfaceCP(2) = 10;
end

onh(round(enfaceCP(1)), round(enfaceCP(2))) = true;

maxiter = 200;
iter = 0;
while sum(sum(abs(onh - onhOld))) > 0 && iter <= maxiter
    onhOld = onh;
    onh = bwmorph(onh, 'dilate' ); 
    if(max(max(enfaceTH & onh)) == 1)
        onh = onh & enfaceTH;
    end
    iter = iter + 1;
end

onh = bwmorph(onh, 'dilate', params.ONH_SEGMENT_DILATENUMBER); 

for k = 1:size(volume, 3)
    idx = find(onh(k,:));
    if numel(idx > 1)
        onh(k,idx(1):idx(end)) = 1;
    end
end

success = 1;

if sum(sum(single(onh))) == 0
    success = 0;
elseif sum(sum(isnan(onh))) ~= 0
    success = 0;
else
    onhCenterMean2 = mean(single(onh), 2) ./ sum(mean(single(onh), 2));
    onhCenter(1) = size(onh, 1) - sum(onhCenterMean2 .* single(1:size(onh,1))');
    onhCenterMean1 = mean(single(onh), 1) ./ sum(mean(single(onh), 1));
    onhCenter(2) = sum(onhCenterMean1 .* single(1:size(onh,2)));
    
    if onhCenter(1) <= 1
        success = 0;
    elseif onhCenter(1) >= size(onh, 1);
        success = 0;
    end
    
    if onhCenter(2) <= 1
        success = 0;
    elseif onhCenter(2) >= size(onh, 2);
        success = 0;
    end
end

onh = flipdim(onh, 1);

if success
    onhCenter = round(onhCenter);
    onhRadius = 1.0;
else
    disp('ONH Segmentation failed.');
    onhCenter = round( [size(onh,1)/2 size(onh, 2)/2] );
    onhRadius = 0;
end