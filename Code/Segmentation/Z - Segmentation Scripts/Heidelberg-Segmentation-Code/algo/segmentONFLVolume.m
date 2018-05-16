function [onflAuto additional] = segmentONFLVolume(volume, Params, onh, rpe, icl, ipl, infl, bv)
% SEGMENTONFLVOLUME Segments the ONFL from a Volume.
%
% For detailed comments refer to segmentONFLCirc(..).
%
% This is an experimental adaption of the circular scan algorithm to volume
% scans. Preliminar results were published at the ARVO conference 2011:
% Markus A. Mayer, Joachim Hornegger, Christian Y. Mardin, Ralf P. Tornow;
% Retinal Layer Segmentation on OCT-Volume Scans of Normal and 
% Glaucomatous Eyes. Invest. Ophthalmol. Vis. Sci. 2011;52(14):3669
%
% Due to the lack of data and time the approach was not pushed further.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: November 2010
% Revised comments: November 2015

volume(volume > 1) = 0;
volume = sqrt(volume);

bvAll = zeros(size(volume, 3), size(volume, 2), 'uint8');
bvEn = zeros(size(volume, 3), size(volume, 2), 'uint8');

for i = 1:size(volume, 3)
    bvAll(i,:) = extendBloodVessels(bv, Params.ONFLLIN_EXTENDBLOODVESSELS_ADDWIDTH_ALL, ...
                                        Params.ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTHTHRESH_ALL, ...
                                        Params.ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTH_ALL);
    
    bvEn(i,:) = extendBloodVessels(bv, Params.ONFLLIN_EXTENDBLOODVESSELS_ADDWIDTH_EN, ...
                                       Params.ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTHTHRESH_EN, ...
                                       Params.ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTH_EN);                                   
end

mask = Params.ONFLLIN_VOLUME_MASK;
mask = mask ./ sum(mask);
avgMask = zeros(1,1,numel(mask), 'double');
for i = 1:numel(mask)
    avgMask(1,1,i) = mask(i);
end
volume = imfilter(volume, avgMask, 'symmetric') ;

onflAuto = zeros(size(volume, 3), size(volume, 2), 'double');
additional = zeros(size(volume, 3), size(volume, 2), 'double');

for i = 1:size(volume, 3)    
    [onflLin, additionalLin] = segmentONFLLin(volume(:,:,i), Params, onh(i, :), [bvAll(i,:); bvEn(i,:)], rpe(i,:), icl(i,:), ipl(i,:), infl(i,:));

    onflAuto(i,:) = onflLin;
    additional(i,:) = additionalLin;
    
    disp(['ONFL of BScan ' num2str(i) ' segmented automatically in 2D.']);
end

onflAuto = medfilt2(onflAuto, Params.ONFLLIN_VOLUME_MEDFILT, 'symmetric');

end