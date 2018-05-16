function [icl, opl, ipl] = segmentInnerLayersVolume(volume, params, onh, rpe, infl, medline, bv)
% SEGMENTINNERLAYERSVOLUME Segments the inner layers from a volume.
%
% For detailed comments refer to segmentInnerLayersCirc(..).
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

mask = params.INNERLIN_VOLUME_MASK;
mask = mask ./ sum(mask);
avgMask = zeros(1,1,numel(mask), 'double');
for i = 1:numel(mask)
    avgMask(1,1,i) = mask(i);
end
volume = imfilter(volume, avgMask, 'symmetric') ;

icl = zeros(size(volume, 3), size(volume, 2), 'double');
opl = zeros(size(volume, 3), size(volume, 2), 'double');
ipl = zeros(size(volume, 3), size(volume, 2), 'double');


for i = 1:size(volume, 3)
    [iclLin, oplLin, iplLin] = segmentInnerLayersLin(volume(:,:,i), params, onh(i,:), rpe(i, :), infl(i, :), medline(i,:), bv(i,:));    
 
    icl(i,:) = iclLin;

    opl(i,:) = oplLin;

    ipl(i,:) = iplLin;
    disp(['Inner Layers of BScan ' num2str(i) ' segmented automatically in 2D.']);
end

% Use 2D median filtering to smooth the results.
icl = medfilt2(icl, params.INNERLIN_VOLUME_MEDFILT	, 'symmetric');
ipl = medfilt2(ipl, params.INNERLIN_VOLUME_MEDFILT	, 'symmetric');
opl = medfilt2(opl, params.INNERLIN_VOLUME_MEDFILT	, 'symmetric');

end