function medline = segmentMedlineVolume(volume, params)
% SEGMENTMEDLINEVOLUME Segments the inner segment (IS) outer segment (OS)
% boundary from a Volume.
%
% For detailed comments refer to segmentMedlineCirc(..).
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

medline = zeros(size(volume, 3), size(volume, 2), 'double');

for i = 1:size(volume, 3)
    medlineLin = segmentMedlineLin(volume(:,:,i), params);
    medline(i,:) = medlineLin;
    disp(['Medline of BScan ' num2str(i) ' segmented automatically in 2D.']);
end

% Perform 2D median filtering for smoothing.
medline = medfilt2(medline, params.MEDLINEVOL_MEDFILT, 'symmetric');

end