function [rpeAuto, rpeMult] = segmentRPEVolume(volume, params, medline)
% SEGMENTRPEVOLUME Segments the RPE from a Volume.
%
% For detailed comments refer to segmentRPECirc(..).
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

% Denoise the volume by averaging.
mask = params.RPELIN_VOLUME_MASK;
mask = mask ./ sum(mask);
avgMask = zeros(1,1,numel(mask), 'double');
for i = 1:numel(mask)
    avgMask(1,1,i) = mask(i);
end
volume = imfilter(volume, avgMask, 'symmetric') ;

rpeAuto = zeros(size(volume, 3), size(volume, 2), 'double');
rpeMult = zeros(size(volume, 3), size(volume, 2), 3, 'double');

% Step through the B-Scans for segmentation.
for i = 1:size(volume, 3)
    [rpeLin, rpeMultLin] = segmentRPELin(volume(:,:,i), params, medline(i,:));
    
    rpeAuto(i,:) = rpeLin;
    
    for n = 1:size(rpeMultLin, 1)
        rpeMult(i,:, n) = rpeMultLin(n, :);
    end
    disp(['RPE of BScan ' num2str(i) ' segmented automatically in 2D.']);
end

end